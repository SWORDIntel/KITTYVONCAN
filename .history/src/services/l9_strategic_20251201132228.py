#!/usr/bin/env python3
"""
DSMIL Device 59 - Strategic Planning (COA Engine)

Layer 9 service that generates Courses of Action (COA) for strategic decision support.
All outputs are ADVISORY ONLY - never auto-executed.

Device: 59 | Layer: 9 | Token: 0x80B1 | Memory: 3.0 GB | TOPS: 80

Features:
- COA generation based on SOC events and L8 analysis
- Scenario evaluation with risk assessment
- Multi-option decision support
- ROE-gated operations
- 2-person integrity for high-consequence recommendations
"""

import json
import logging
import os
import signal
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from threading import Event
from typing import Any, Dict, List, Optional
from uuid import uuid4

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from infrastructure.redis_streams import RedisStreamsClient, StreamName, SOCEvent
    from infrastructure.hotpath_db import get_db
    from security.policy_engine import (
        PolicyEngine, create_policy_request, ActionCategory,
        PolicyDecision, TwoPersonSignature
    )
    AVAILABLE = True
except ImportError:
    AVAILABLE = False

logger = logging.getLogger(__name__)

DEVICE_ID = 59
DEVICE_NAME = "Strategic Planning"
LAYER = 9
TOKEN_BASE = 0x8000 + (DEVICE_ID * 3)


class COAType(str, Enum):
    """Types of Courses of Action"""
    DEFENSIVE = "DEFENSIVE"
    OFFENSIVE = "OFFENSIVE"
    DIPLOMATIC = "DIPLOMATIC"
    INTELLIGENCE = "INTELLIGENCE"
    SUPPORT = "SUPPORT"
    HYBRID = "HYBRID"


class RiskLevel(str, Enum):
    """Risk levels for COA options"""
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    EXTREME = "EXTREME"


@dataclass
class COAOption:
    """Single Course of Action option"""
    option_id: str
    name: str
    coa_type: str
    description: str
    risk_level: str
    success_probability: float
    resource_requirements: List[str]
    time_to_execute: str
    dependencies: List[str]
    second_order_effects: List[str]
    advisory_only: bool = True
    requires_2person: bool = False

    def to_dict(self) -> Dict:
        return {
            "option_id": self.option_id,
            "name": self.name,
            "type": self.coa_type,
            "description": self.description,
            "risk_level": self.risk_level,
            "success_probability": self.success_probability,
            "resource_requirements": self.resource_requirements,
            "time_to_execute": self.time_to_execute,
            "dependencies": self.dependencies,
            "second_order_effects": self.second_order_effects,
            "advisory_only": self.advisory_only,
            "requires_2person": self.requires_2person,
            "classification": "EXECUTIVE",
            "generated_by": f"Device-{DEVICE_ID}"
        }


@dataclass
class COAResult:
    """Complete COA analysis result"""
    coa_id: str
    scenario_id: str
    generated_at: float
    situation_summary: str
    options: List[COAOption]
    recommended_option: Optional[str]
    recommendation_rationale: str
    constraints: List[str]
    assumptions: List[str]
    advisory_flag: bool = True

    def to_dict(self) -> Dict:
        return {
            "coa_id": self.coa_id,
            "scenario_id": self.scenario_id,
            "generated_at": self.generated_at,
            "generated_at_iso": datetime.fromtimestamp(self.generated_at).isoformat(),
            "situation_summary": self.situation_summary,
            "options": [o.to_dict() for o in self.options],
            "option_count": len(self.options),
            "recommended_option": self.recommended_option,
            "recommendation_rationale": self.recommendation_rationale,
            "constraints": self.constraints,
            "assumptions": self.assumptions,
            "advisory_flag": self.advisory_flag,
            "disclaimer": "ADVISORY ONLY - Requires human decision and approval"
        }


class StrategicPlanningService:
    """Device 59 - Strategic Planning / COA Engine"""

    # COA templates based on event patterns
    COA_TEMPLATES = {
        "CRITICAL_SECURITY": [
            COAOption(
                option_id="", name="Immediate Containment",
                coa_type=COAType.DEFENSIVE.value,
                description="Isolate affected systems, revoke compromised credentials, activate incident response",
                risk_level=RiskLevel.MODERATE.value,
                success_probability=0.85,
                resource_requirements=["SOC Team", "IR Team", "Network Ops"],
                time_to_execute="< 1 hour",
                dependencies=["Network segmentation capability", "Credential management"],
                second_order_effects=["Service disruption", "User impact"],
            ),
            COAOption(
                option_id="", name="Active Defense",
                coa_type=COAType.OFFENSIVE.value,
                description="Engage threat actor, deploy deception, gather intelligence",
                risk_level=RiskLevel.HIGH.value,
                success_probability=0.65,
                resource_requirements=["Threat Hunt Team", "Deception Infrastructure", "Legal Approval"],
                time_to_execute="2-4 hours",
                dependencies=["Legal authorization", "Deception capability"],
                second_order_effects=["Adversary awareness", "Escalation risk"],
                requires_2person=True
            ),
            COAOption(
                option_id="", name="Monitor and Assess",
                coa_type=COAType.INTELLIGENCE.value,
                description="Continue monitoring, gather more intelligence before action",
                risk_level=RiskLevel.LOW.value,
                success_probability=0.75,
                resource_requirements=["Monitoring Team", "Analysis Capacity"],
                time_to_execute="Ongoing",
                dependencies=["Detection capability maintained"],
                second_order_effects=["Potential damage if threat advances"],
            ),
        ],
        "HIGH_SECURITY": [
            COAOption(
                option_id="", name="Enhanced Monitoring",
                coa_type=COAType.DEFENSIVE.value,
                description="Increase monitoring, alert SOC, prepare response teams",
                risk_level=RiskLevel.LOW.value,
                success_probability=0.9,
                resource_requirements=["SOC Staff"],
                time_to_execute="< 30 min",
                dependencies=[],
                second_order_effects=["Minor resource consumption"],
            ),
            COAOption(
                option_id="", name="Targeted Investigation",
                coa_type=COAType.INTELLIGENCE.value,
                description="Deep-dive analysis of affected systems and indicators",
                risk_level=RiskLevel.LOW.value,
                success_probability=0.8,
                resource_requirements=["Forensics Team"],
                time_to_execute="1-2 hours",
                dependencies=["Forensic tools"],
                second_order_effects=["Resource allocation from other tasks"],
            ),
        ],
    }

    def __init__(self):
        self.redis: Optional[RedisStreamsClient] = None
        self.hotpath_db = None
        self.policy_engine: Optional[PolicyEngine] = None
        self._running = False
        self._shutdown = Event()
        self._events_processed = 0
        self._coa_generated = 0
        self._start_time = 0

    def initialize(self) -> bool:
        logger.info(f"Initializing {DEVICE_NAME} (Device {DEVICE_ID})")

        if AVAILABLE:
            self.redis = RedisStreamsClient()
            if not self.redis.connect():
                return False

            self.hotpath_db = get_db()
            self.hotpath_db.connect()

            self.policy_engine = PolicyEngine()
            # Add authorized signers for 2-person integrity
            self.policy_engine.add_authorized_signer("commander")
            self.policy_engine.add_authorized_signer("deputy-commander")

        logger.info(f"✅ Device {DEVICE_ID} initialized (Token: 0x{TOKEN_BASE:04X})")
        return True

    def _assess_situation(self, events: List[Dict]) -> str:
        """Generate situation summary from events"""
        if not events:
            return "No significant events detected."

        severities = [e.get('severity', 'LOW') for e in events]
        categories = [e.get('category', 'UNKNOWN') for e in events]

        critical = severities.count('CRITICAL')
        high = severities.count('HIGH')

        summary = f"Analysis of {len(events)} events: "
        if critical > 0:
            summary += f"{critical} CRITICAL, "
        if high > 0:
            summary += f"{high} HIGH severity. "

        # Category breakdown
        cat_counts = {}
        for c in categories:
            cat_counts[c] = cat_counts.get(c, 0) + 1

        top_cats = sorted(cat_counts.items(), key=lambda x: x[1], reverse=True)[:3]
        summary += f"Primary categories: {', '.join([c[0] for c in top_cats])}."

        return summary

    def _select_template(self, events: List[Dict]) -> str:
        """Select COA template based on event severity"""
        severities = [e.get('severity', 'LOW') for e in events]

        if 'CRITICAL' in severities:
            return "CRITICAL_SECURITY"
        elif 'HIGH' in severities:
            return "HIGH_SECURITY"
        else:
            return "HIGH_SECURITY"  # Default

    def _check_policy(self, coa_type: str) -> bool:
        """Check if COA generation is allowed"""
        if not self.policy_engine:
            return True

        request = create_policy_request(
            action=f"generate_coa_{coa_type.lower()}",
            category=ActionCategory.ADVISORY,
            source_device=DEVICE_ID,
            source_layer=LAYER,
            requestor_id=DEVICE_NAME
        )

        response = self.policy_engine.evaluate(request)
        return response.decision == PolicyDecision.ALLOW

    def generate_coa(self, scenario_id: str, events: List[Dict]) -> COAResult:
        """Generate Course of Action analysis"""
        # Assess situation
        situation = self._assess_situation(events)

        # Select template
        template_key = self._select_template(events)
        templates = self.COA_TEMPLATES.get(template_key, [])

        # Generate options with unique IDs
        options = []
        for i, template in enumerate(templates):
            option = COAOption(
                option_id=f"COA-{scenario_id[:8]}-{i+1}",
                name=template.name,
                coa_type=template.coa_type,
                description=template.description,
                risk_level=template.risk_level,
                success_probability=template.success_probability,
                resource_requirements=template.resource_requirements.copy(),
                time_to_execute=template.time_to_execute,
                dependencies=template.dependencies.copy(),
                second_order_effects=template.second_order_effects.copy(),
                requires_2person=template.requires_2person
            )

            # Check policy
            if self._check_policy(option.coa_type):
                options.append(option)

        # Select recommended option (lowest risk with highest success)
        recommended = None
        if options:
            # Score: success_prob * (1 - risk_factor)
            risk_factors = {"LOW": 0.1, "MODERATE": 0.3, "HIGH": 0.6, "EXTREME": 0.9}

            def score(opt):
                rf = risk_factors.get(opt.risk_level, 0.5)
                return opt.success_probability * (1 - rf)

            best = max(options, key=score)
            recommended = best.option_id

        # Generate result
        result = COAResult(
            coa_id=str(uuid4())[:12],
            scenario_id=scenario_id,
            generated_at=time.time(),
            situation_summary=situation,
            options=options,
            recommended_option=recommended,
            recommendation_rationale="Selected based on risk-adjusted success probability",
            constraints=["ROE compliance required", "Human approval mandatory"],
            assumptions=["Threat assessment accurate", "Resources available"]
        )

        self._coa_generated += 1
        logger.info(f"Generated COA {result.coa_id} with {len(options)} options")

        return result

    def _process_cycle(self):
        """Process incoming events and generate COAs"""
        if not self.redis:
            return

        try:
            # Read high-severity events from SOC_EVENTS
            messages = self.redis.read_group(
                StreamName.SOC_EVENTS, "l9-strategic", f"device-{DEVICE_ID}",
                count=10, block=5000
            )

            # Filter for events needing strategic analysis
            critical_events = []
            for msg_id, event in messages:
                event_dict = event.to_dict()
                severity = event_dict.get('severity', 'LOW')

                if severity in ['CRITICAL', 'HIGH']:
                    critical_events.append(event_dict)

                self.redis.acknowledge(StreamName.SOC_EVENTS, "l9-strategic", msg_id)
                self._events_processed += 1

            # Generate COA if we have significant events
            if critical_events:
                scenario_id = str(uuid4())
                coa = self.generate_coa(scenario_id, critical_events)

                # Store in database
                if self.hotpath_db:
                    self.hotpath_db.insert_event(
                        event_id=coa.coa_id,
                        device_id=DEVICE_ID,
                        layer=LAYER,
                        source="strategic-planning",
                        compartment="EXECUTIVE",
                        category="COA",
                        severity="HIGH",
                        payload=coa.to_dict()
                    )

                # Log COA summary
                logger.info(
                    f"📋 COA Generated: {coa.coa_id} | "
                    f"Options: {len(coa.options)} | "
                    f"Recommended: {coa.recommended_option}"
                )

        except Exception as e:
            logger.error(f"Error in processing: {e}")

    def run(self):
        if not self.initialize():
            return 1

        self._running = True
        self._start_time = time.time()
        last_heartbeat = 0

        logger.info(f"🚀 {DEVICE_NAME} (Device {DEVICE_ID}) started - ADVISORY ONLY")

        try:
            while self._running and not self._shutdown.is_set():
                self._process_cycle()

                now = time.time()
                if now - last_heartbeat >= 30:
                    if self.hotpath_db:
                        self.hotpath_db.update_device_status(
                            device_id=DEVICE_ID, layer=LAYER, name=DEVICE_NAME,
                            status="ONLINE", memory_mb=500, tops_allocated=80,
                            metadata={
                                "events_processed": self._events_processed,
                                "coa_generated": self._coa_generated,
                                "mode": "ADVISORY_ONLY"
                            }
                        )
                    logger.info(f"📊 processed={self._events_processed}, COAs={self._coa_generated}")
                    last_heartbeat = now

                time.sleep(1)

        except KeyboardInterrupt:
            pass
        finally:
            self.shutdown()

        return 0

    def shutdown(self):
        logger.info("Shutting down...")
        self._running = False
        self._shutdown.set()
        if self.hotpath_db:
            self.hotpath_db.update_device_status(DEVICE_ID, LAYER, DEVICE_NAME, "OFFLINE")
        if self.redis:
            self.redis.disconnect()


def main():
    logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(name)s: %(message)s')
    signal.signal(signal.SIGINT, lambda s, f: None)
    signal.signal(signal.SIGTERM, lambda s, f: None)

    service = StrategicPlanningService()
    sys.exit(service.run())


if __name__ == "__main__":
    main()

