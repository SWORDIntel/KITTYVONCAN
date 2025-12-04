# Next Phase Implementation Prompt

**Date:** 2025-12-01
**Status:** Ready for Implementation
**Priority:** High

---

## Overview

This document provides a comprehensive prompt for implementing the remaining Layer 8 and Layer 9 worker devices, Grafana monitoring dashboards, and production hardening (logging/metrics). This builds on the existing foundation of Devices 51, 52, 58, and 59.

---

## Part 1: Remaining L8/L9 Worker Devices

### Context

**Already Implemented:**
- Device 51: Adversarial ML Defense (`src/services/l8_advml_defense.py`)
- Device 52: SOC Router (`src/services/soc_router.py`)
- Device 58: SOAR Orchestrator (`src/services/l8_soar.py`)
- Device 59: Strategic Planning / COA Engine (`src/services/l9_strategic.py`)

**To Implement:**
- **Layer 8 (ENHANCED_SEC):** Devices 53-57
- **Layer 9 (EXECUTIVE):** Devices 60-62

### Device Specifications

#### Device 53: Crypto AI Engine (Layer 8)
**Hex ID:** 0x809F
**Clearance:** 0xFF080808
**Purpose:** Post-quantum cryptography operations, cryptographic AI analysis

**Requirements:**
- Integrate with existing quantum crypto layer (`ai/integrations/security/quantum.py`)
- Support ML-KEM-1024 (Kyber) key exchange
- Support ML-DSA-87 (Dilithium) signatures
- Cryptographic AI analysis (detect weak keys, analyze cipher strength)
- Integration with DBE Protocol (`src/security/dbe_protocol.py`)
- Publish to `DBE_OUT_53` stream, consume from `DBE_IN_53`

**Reference:**
- `docs/DEVICE_ID_MAPPING.md` - Device mapping
- `src/security/dbe_protocol.py` - DBE integration pattern
- `ai/integrations/security/quantum.py` - Quantum crypto layer

**File:** `src/services/l8_crypto_ai.py`

---

#### Device 54: Threat Intelligence Fusion (Layer 8)
**Hex ID:** 0x80A2
**Clearance:** 0xFF080808
**Purpose:** Threat intelligence aggregation, APT tracking, IOC correlation

**Requirements:**
- Consume from SOC Router (`SOC_EVENTS` stream)
- Threat intelligence fusion (multiple sources)
- APT (Advanced Persistent Threat) tracking
- IOC (Indicators of Compromise) correlation
- Threat actor profiling
- Integration with SHRINK metrics for risk assessment
- Publish threat intelligence reports to `L8_ALERTS`

**Reference:**
- `src/services/soc_router.py` - SOC event structure
- `src/infrastructure/redis_streams.py` - Stream definitions

**File:** `src/services/l8_threat_intel.py`

---

#### Device 55: Behavioral Biometrics Analyzer (Layer 8)
**Hex ID:** 0x80A5
**Clearance:** 0xFF080808
**Purpose:** Behavioral biometric analysis, continuous authentication

**Requirements:**
- Behavioral pattern analysis (keystroke dynamics, mouse movements, typing patterns)
- Continuous authentication scoring
- Anomaly detection in user behavior
- Integration with Policy Engine (`src/security/policy_engine.py`) for access decisions
- Real-time risk scoring
- Publish authentication events to `L8_ALERTS`

**Reference:**
- `src/security/policy_engine.py` - Policy evaluation
- `src/services/l8_advml_defense.py` - Similar pattern for anomaly detection

**File:** `src/services/l8_biometrics.py`

---

#### Device 56: Secure Enclave Manager (Layer 8)
**Hex ID:** 0x80A8
**Clearance:** 0xFF080808
**Purpose:** Secure enclave management, isolated execution environments

**Requirements:**
- Enclave lifecycle management (create, destroy, attest)
- Secure memory isolation
- Attestation verification
- Integration with TPM/HSM for key management
- Enclave-to-enclave secure communication
- Audit logging for enclave operations

**Reference:**
- Device 0 (TPM Control) in device database
- `src/security/dbe_protocol.py` - Secure communication

**File:** `src/services/l8_enclave_mgr.py`

---

#### Device 57: Network Security AI (Layer 8)
**Hex ID:** 0x80AB
**Clearance:** 0xFF080808
**Purpose:** Network traffic analysis, intrusion detection, network anomaly detection

**Requirements:**
- Network traffic analysis (packet inspection, flow analysis)
- Intrusion detection (signature-based and ML-based)
- Network anomaly detection
- DDoS detection and mitigation
- Integration with SOC Router for alerting
- Network topology awareness
- Publish network security events to `SOC_EVENTS`

**Reference:**
- `src/services/soc_router.py` - Event publishing pattern
- `src/services/l8_advml_defense.py` - ML-based detection pattern

**File:** `src/services/l8_network_ai.py`

---

#### Device 60: Decision Support System (Layer 9)
**Hex ID:** 0x80B4
**Clearance:** 0xFF090909
**Purpose:** Executive decision support, strategic analysis

**Requirements:**
- Consume from Strategic Planning (Device 59) COA outputs
- Decision support analysis (risk assessment, resource allocation)
- Multi-criteria decision analysis (MCDA)
- Integration with Layer 9 command streams (`L9_COMMANDS`)
- Executive-level reporting
- Integration with Policy Engine for ROE compliance

**Reference:**
- `src/services/l9_strategic.py` - COA structure
- `docs/comprehensive-plan/Phases/Phase5.md` - Layer 9 requirements

**File:** `src/services/l9_decision_support.py`

---

#### Device 61: NC3 Integration (Layer 9)
**Hex ID:** 0x80B7
**Clearance:** 0xFF090909
**Purpose:** Nuclear Command, Control, and Communications integration

**Requirements:**
- **CRITICAL:** ROE (Rules of Engagement) enforcement via Policy Engine
- Two-person authorization required for all operations
- NC3 system interface (read-only, no kinetic control)
- Audit logging for all NC3 operations (Device 14 integration)
- Integration with quantum crypto (Device 46) for secure communications
- Strict compartmentation (NUCLEAR compartment required)
- Publish NC3 events to `L9_COMMANDS` (read-only status)

**Reference:**
- `src/security/policy_engine.py` - ROE enforcement (see Device 61 special handling)
- `docs/DEVICE_ID_MAPPING.md` - Device 61 special requirements
- `technical/System-Activation/COMPLETE_SYSTEM_ACTIVATION_SUMMARY.md` - NC3 authorization details

**File:** `src/services/l9_nc3_integration.py`

**Security Notes:**
- Device 61 requires `category="NC3"` and valid ROE token
- All operations must be logged to Device 14 (Audit Log Controller)
- No kinetic control - read-only status reporting only
- Two-person token required (Policy Engine handles this)

---

#### Device 62: Global Situational Awareness (Layer 9)
**Hex ID:** 0x80BA
**Clearance:** 0xFF090909
**Purpose:** Global intelligence fusion, coalition coordination

**Requirements:**
- Multi-INT (intelligence) fusion (SIGINT, GEOINT, HUMINT, OSINT)
- Coalition intelligence coordination (Five Eyes + allies)
- Global situational awareness dashboard data
- Multi-lingual NLP support
- Geopolitical forecasting
- Integration with Device 49 (Global Intelligence) outputs
- Publish to `L9_COMMANDS` for executive visibility

**Reference:**
- `docs/comprehensive-plan/Phases/Phase5.md` - Layer 9 requirements
- `technical/comprehensive-plan/05_LAYER_SPECIFIC_DEPLOYMENTS.md` - Device 62 specifications

**File:** `src/services/l9_global_awareness.py`

---

### Implementation Pattern

All devices should follow this pattern:

```python
#!/usr/bin/env python3
"""
Device XX: [Name] - [Layer] [Purpose]
"""

import logging
import time
from dataclasses import dataclass
from typing import Dict, List, Optional, Any
from uuid import uuid4

from infrastructure.redis_streams import RedisStreamsClient, StreamName, DSMILEvent
from infrastructure.hotpath_db import HotPathDB, HotPathConfig
from security.policy_engine import PolicyEngine, SecurityLevel
from security.dbe_protocol import DBEProtocol
from security.dbe_mesh import DBEMeshClient

logger = logging.getLogger(__name__)

# Device constants
DEVICE_ID = XX
LAYER = X
DEVICE_NAME = "[Name]"
TOKEN_BASE = 0x8000 + (DEVICE_ID * 3)

@dataclass
class DeviceXXConfig:
    """Configuration for Device XX"""
    redis_host: str = "localhost"
    redis_port: int = 6379
    # ... device-specific config

class DeviceXXService:
    """
    Device XX: [Name]
    """

    def __init__(self, config: Optional[DeviceXXConfig] = None):
        self.config = config or DeviceXXConfig()
        self.device_id = DEVICE_ID
        self.layer = LAYER

        # Infrastructure
        self.redis: Optional[RedisStreamsClient] = None
        self.hotpath_db: Optional[HotPathDB] = None
        self.policy_engine: Optional[PolicyEngine] = None
        self.dbe: Optional[DBEProtocol] = None
        self.mesh: Optional[DBEMeshClient] = None

    def initialize(self) -> bool:
        """Initialize device service"""
        try:
            # Initialize Redis
            self.redis = RedisStreamsClient()
            if not self.redis.connect():
                logger.error("Failed to connect to Redis")
                return False

            # Initialize hot-path DB
            self.hotpath_db = HotPathDB(config=HotPathConfig())
            if not self.hotpath_db.connect():
                logger.error("Failed to connect to hot-path DB")
                return False

            # Initialize policy engine
            self.policy_engine = PolicyEngine()

            # Initialize DBE protocol
            self.dbe = DBEProtocol(device_id=DEVICE_ID, layer=LAYER)

            # Initialize DBE mesh
            self.mesh = DBEMeshClient(device_id=DEVICE_ID, layer=LAYER)
            if not self.mesh.connect():
                logger.warning("DBE mesh connection failed, continuing without mesh")

            logger.info(f"Device {DEVICE_ID} ({DEVICE_NAME}) initialized")
            return True

        except Exception as e:
            logger.error(f"Failed to initialize Device {DEVICE_ID}: {e}")
            return False

    def process_event(self, event: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Process incoming event"""
        # Device-specific processing logic
        pass

    def run(self):
        """Main service loop"""
        # Service loop implementation
        pass

if __name__ == "__main__":
    service = DeviceXXService()
    if service.initialize():
        service.run()
```

---

## Part 2: Grafana Dashboards

### Requirements

Create pre-built Grafana dashboards for monitoring the DSMIL system. Dashboards should be JSON files compatible with Grafana's provisioning system.

**Location:** `deploy/grafana/dashboards/`

### Dashboard Specifications

#### 1. System Overview Dashboard (`dsmil-overview.json`)
**Purpose:** High-level system health and performance

**Panels:**
- System uptime
- Total TOPS utilization (theoretical vs physical)
- Memory usage by layer (62 GB total)
- Active devices count by layer
- Event throughput (events/sec)
- Error rate
- SHRINK crisis level indicator

**Data Sources:**
- Prometheus (metrics)
- Loki (logs)

---

#### 2. Layer Performance Dashboard (`dsmil-layers.json`)
**Purpose:** Per-layer performance metrics

**Panels (per layer):**
- Layer TOPS utilization
- Active devices
- Memory usage
- Event processing latency (p50, p95, p99)
- Error rate
- Model inference latency

**Layers:** 2-9 (TRAINING through EXECUTIVE)

---

#### 3. Device Status Dashboard (`dsmil-devices.json`)
**Purpose:** Individual device health and status

**Panels:**
- Device status table (104 devices)
- Device health heatmap
- Device TOPS allocation
- Device memory usage
- Device error rates
- Device response times

**Filters:**
- By layer
- By device group
- By status (operational, degraded, failed)

---

#### 4. Security Dashboard (`dsmil-security.json`)
**Purpose:** Security monitoring and threat detection

**Panels:**
- SOC events timeline
- Threat detection rate
- Adversarial ML flags
- Policy violations
- Authentication failures
- Network intrusion attempts
- SHRINK risk metrics
- ROE compliance status

**Alerts:**
- High threat level
- Policy violations
- Authentication anomalies

---

#### 5. Data Fabric Dashboard (`dsmil-data-fabric.json`)
**Purpose:** Redis Streams and hot-path DB monitoring

**Panels:**
- Redis stream lengths
- Stream consumption lag
- Hot-path DB size
- Database query latency
- Stream publish rate
- Stream consumption rate
- Database write latency

**Streams:**
- L3_IN, L3_OUT, L4_IN, L4_OUT
- SOC_EVENTS
- DBE_IN_*, DBE_OUT_*
- L8_ALERTS, L9_COMMANDS

---

#### 6. Layer 8 Security Dashboard (`dsmil-layer8.json`)
**Purpose:** Layer 8 security devices detailed view

**Panels:**
- Device 51: AdvML detection rate
- Device 52: SOC Router event fusion rate
- Device 53: Crypto operations/sec
- Device 54: Threat intel updates
- Device 55: Biometric auth attempts
- Device 56: Enclave operations
- Device 57: Network security events
- Device 58: SOAR playbook executions

---

#### 7. Layer 9 Executive Dashboard (`dsmil-layer9.json`)
**Purpose:** Layer 9 executive command monitoring

**Panels:**
- Device 59: COA generation rate
- Device 60: Decision support queries
- Device 61: NC3 operations (read-only, audit log)
- Device 62: Global awareness updates
- Executive command latency
- ROE compliance rate
- Strategic planning metrics

**Note:** Device 61 panel should show read-only operations only, with audit log references.

---

### Grafana Configuration

**Location:** `deploy/grafana/grafana.ini` (if needed)
**Provisioning:** `deploy/grafana/provisioning/dashboards/dashboards.yml`

**Example `dashboards.yml`:**
```yaml
apiVersion: 1

providers:
  - name: 'DSMIL Dashboards'
    orgId: 1
    folder: 'DSMIL'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/dashboards
```

---

## Part 3: Production Hardening - Logging & Metrics

### Logging Requirements

#### 1. Structured Logging
**Standard:** JSON-formatted logs compatible with Loki

**Fields:**
- `timestamp`: ISO 8601 format
- `level`: DEBUG, INFO, WARNING, ERROR, CRITICAL
- `device_id`: Device identifier
- `layer`: Layer number
- `service`: Service name
- `event_type`: Event category
- `message`: Human-readable message
- `context`: Additional structured data (dict)

**Implementation:**
- Use Python `logging` module with JSON formatter
- All services should use consistent logging format
- Integration with journald for systemd services

**File:** `src/utils/logging_config.py`

---

#### 2. Log Aggregation
**Requirements:**
- All logs forwarded to Loki
- Log retention: 30 days (hot), 90 days (cold)
- Log rotation: Daily, compressed after 7 days
- Integration with Promtail for log collection

**Configuration:**
- `deploy/promtail/promtail.yml` - Log collection config
- `deploy/loki/loki.yml` - Log storage config

---

#### 3. Audit Logging
**Requirements:**
- Device 14 (Audit Log Controller) integration
- All security events logged
- Device 61 (NC3) operations logged with two-person token info
- Policy violations logged
- ROE compliance events logged

**File:** `src/utils/audit_logger.py`

---

### Metrics Requirements

#### 1. Prometheus Metrics
**Standard:** Prometheus exposition format

**Metric Categories:**

**System Metrics:**
- `dsmil_system_uptime_seconds`
- `dsmil_system_memory_bytes`
- `dsmil_system_tops_total`
- `dsmil_system_tops_used`

**Layer Metrics:**
- `dsmil_layer_devices_active{layer}`
- `dsmil_layer_memory_bytes{layer}`
- `dsmil_layer_tops_used{layer}`
- `dsmil_layer_events_total{layer,type}`

**Device Metrics:**
- `dsmil_device_status{device_id,device_name}`
- `dsmil_device_requests_total{device_id,status}`
- `dsmil_device_latency_seconds{device_id,operation}`
- `dsmil_device_errors_total{device_id,error_type}`

**Security Metrics:**
- `dsmil_security_threats_total{severity,category}`
- `dsmil_security_policy_violations_total{device_id}`
- `dsmil_security_auth_failures_total{device_id}`
- `dsmil_security_roe_compliance{device_id}`

**Data Fabric Metrics:**
- `dsmil_redis_stream_length{stream_name}`
- `dsmil_redis_stream_lag{stream_name,consumer_group}`
- `dsmil_db_query_duration_seconds{operation,table}`
- `dsmil_db_size_bytes{database}`

**Implementation:**
- Use `prometheus_client` library
- All services expose `/metrics` endpoint
- Metrics registry per service

**File:** `src/utils/metrics.py`

---

#### 2. Metrics Collection
**Requirements:**
- Prometheus scrapes all service endpoints
- Scrape interval: 15 seconds
- Retention: 30 days
- Alert rules for critical metrics

**Configuration:**
- `deploy/prometheus/prometheus.yml` - Scrape config
- `deploy/prometheus/alerts.yml` - Alert rules

---

#### 3. SHRINK Metrics Integration
**Requirements:**
- SHRINK metrics exposed as Prometheus metrics
- Integration with Grafana dashboards
- Alert on high crisis level

**Metrics:**
- `shrink_crisis_level`
- `shrink_risk_acute_stress`
- `shrink_lbi_hyperfocus_density`
- `shrink_sentiment_score`

---

### Implementation Files

**Logging:**
- `src/utils/logging_config.py` - Centralized logging configuration
- `src/utils/audit_logger.py` - Audit logging utilities
- `deploy/promtail/promtail.yml` - Log collection config
- `deploy/loki/loki.yml` - Log storage config

**Metrics:**
- `src/utils/metrics.py` - Prometheus metrics utilities
- `deploy/prometheus/prometheus.yml` - Metrics collection config
- `deploy/prometheus/alerts.yml` - Alert rules

**Grafana:**
- `deploy/grafana/dashboards/*.json` - Dashboard definitions
- `deploy/grafana/provisioning/dashboards/dashboards.yml` - Dashboard provisioning

---

## Testing Requirements

### Unit Tests
- Each device service should have unit tests
- Test device initialization
- Test event processing logic
- Test error handling

**Location:** `tests/unit/test_l8_*.py`, `tests/unit/test_l9_*.py`

### Integration Tests
- Test device integration with Redis Streams
- Test device integration with hot-path DB
- Test DBE mesh communication
- Test Policy Engine integration

**Location:** `tests/integration/test_l8_*.py`, `tests/integration/test_l9_*.py`

### E2E Tests
- Test complete Layer 8 security flow
- Test Layer 9 executive command flow
- Test Device 61 NC3 integration with ROE enforcement

**Location:** `tests/e2e/test_layer8_complete.py`, `tests/e2e/test_layer9_complete.py`

---

## Documentation Requirements

### Service Documentation
Each device service should include:
- Purpose and capabilities
- Configuration options
- Input/output streams
- Integration points
- Security considerations

**Location:** `docs/services/device_*.md`

### API Documentation
- Device service APIs
- DBE mesh API
- Policy Engine API

**Location:** `docs/api/`

---

## Implementation Order

### Phase 1: Layer 8 Devices (Devices 53-57)
1. Device 53: Crypto AI Engine
2. Device 54: Threat Intelligence Fusion
3. Device 55: Behavioral Biometrics Analyzer
4. Device 56: Secure Enclave Manager
5. Device 57: Network Security AI

**Estimated Time:** 2-3 days per device

### Phase 2: Layer 9 Devices (Devices 60-62)
1. Device 60: Decision Support System
2. Device 61: NC3 Integration (with ROE enforcement)
3. Device 62: Global Situational Awareness

**Estimated Time:** 3-4 days per device (Device 61 requires extra security review)

### Phase 3: Grafana Dashboards
1. System Overview Dashboard
2. Layer Performance Dashboard
3. Device Status Dashboard
4. Security Dashboard
5. Data Fabric Dashboard
6. Layer 8 Security Dashboard
7. Layer 9 Executive Dashboard

**Estimated Time:** 1 day per dashboard

### Phase 4: Production Hardening
1. Structured logging implementation
2. Prometheus metrics implementation
3. Log aggregation setup (Promtail/Loki)
4. Metrics collection setup (Prometheus)
5. Alert rules configuration

**Estimated Time:** 2-3 days

---

## Success Criteria

### Devices
- ✅ All 8 devices (53-57, 60-62) implemented and tested
- ✅ All devices integrate with DBE mesh
- ✅ All devices integrate with Policy Engine
- ✅ Device 61 enforces ROE with two-person authorization
- ✅ All devices have unit and integration tests

### Grafana Dashboards
- ✅ All 7 dashboards created and provisioned
- ✅ Dashboards display real-time data from Prometheus/Loki
- ✅ Dashboards include appropriate alerts
- ✅ Dashboards are documented

### Production Hardening
- ✅ Structured JSON logging implemented
- ✅ All services expose Prometheus metrics
- ✅ Log aggregation working (Loki)
- ✅ Metrics collection working (Prometheus)
- ✅ Alert rules configured and tested

---

## References

### Existing Code
- `src/services/l8_advml_defense.py` - Device 51 implementation pattern
- `src/services/soc_router.py` - Device 52 implementation pattern
- `src/services/l8_soar.py` - Device 58 implementation pattern
- `src/services/l9_strategic.py` - Device 59 implementation pattern

### Documentation
- `docs/DEVICE_ID_MAPPING.md` - Device specifications
- `docs/comprehensive-plan/Phases/Phase4.md` - Layer 8 requirements
- `docs/comprehensive-plan/Phases/Phase5.md` - Layer 9 requirements
- `docs/PHASE1_IMPLEMENTATION.md` - Infrastructure patterns

### Security
- `src/security/policy_engine.py` - Policy Engine API
- `src/security/dbe_protocol.py` - DBE Protocol API
- `src/security/dbe_mesh.py` - DBE Mesh API

---

## Notes

1. **Device 61 (NC3) Security:** This device requires special attention. All operations must be read-only, logged to Device 14, and require two-person authorization via Policy Engine. No kinetic control is permitted.

2. **Testing:** Use the existing test harness (`tests/`) and follow the patterns established in `tests/integration/test_soc_router.py` and `tests/e2e/test_layer8_flow.py`.

3. **Metrics:** Follow Prometheus best practices. Use appropriate metric types (counter, gauge, histogram) and include helpful labels.

4. **Logging:** Ensure all logs are structured (JSON) and include device_id, layer, and service context.

5. **Grafana:** Export dashboards as JSON files compatible with Grafana provisioning. Test dashboards with real data before committing.

---

**Ready to begin implementation.**

