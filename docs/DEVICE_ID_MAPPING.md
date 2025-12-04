# DSMIL Device ID Mapping

> **Document Version:** 1.0
> **Date:** 2025-12-01
> **Purpose:** Map OGPhases logical device IDs (0-103) to implementation hex IDs (0x8000-0x80FF)

## Overview

The DSMIL system uses **two device ID schemes**:

1. **OGPhases (Logical):** Device IDs 0-103, organized by security layer
2. **Implementation (Hex):** Device IDs 0x8000-0x80FF, organized by functional group

This document provides the authoritative mapping between them.

---

## Conversion Formula

```python
# Logical ID (0-103) to Hex ID
hex_id = 0x8000 + (logical_id * 3)

# Example: Logical 47 → 0x8000 + (47 * 3) = 0x808D
```

**Note:** The `* 3` factor accounts for token space (each device has 3 tokens).

---

## Layer-to-Group Mapping

| OGPhases Layer | Security Level | Hex Group | Group Name |
|----------------|----------------|-----------|------------|
| Layer 0-1 | LOCKED/PUBLIC | N/A | Not mapped |
| Layer 2 | TRAINING | Group 6 | Training Functions (0x8060-0x806B) |
| Layer 3 | SECRET | Group 3 | Data Processing (0x8030-0x803B) |
| Layer 4 | TOP_SECRET | Group 3-4 | Data Processing / Storage Control |
| Layer 5 | COSMIC | Group 4 | Storage Control (0x8040-0x804B) |
| Layer 6 | ATOMAL | Group 5 | Peripheral Management (0x8050-0x805B) |
| Layer 7 | EXTENDED | Group 7-8 | Diagnostic / Advanced (0x8070-0x808F) |
| Layer 8 | ENHANCED_SEC | Group 1 | Extended Security (0x8010-0x801B) |
| Layer 9 | EXECUTIVE | Group 0 | Core Security (0x8000-0x800B) |

---

## Device Mapping Tables

### Layer 3 (SECRET) - Devices 15-22

| Logical ID | Name (OGPhases) | Hex ID | Name (Implementation) |
|------------|-----------------|--------|----------------------|
| 15 | CRYPTO | 0x802D | Encryption Controller |
| 16 | SIGNALS | 0x8030 | Signal Processing |
| 17 | NUCLEAR | 0x8033 | Restricted - Nuclear Data |
| 18 | WEAPONS | 0x8036 | Restricted - Weapons Data |
| 19 | COMMS | 0x8039 | Secure Communications |
| 20 | SENSORS | 0x803C | Sensor Array Control |
| 21 | MAINT | 0x803F | Maintenance Systems |
| 22 | EMERGENCY | 0x8042 | Emergency Protocols |

### Layer 4 (TOP_SECRET) - Devices 23-30

| Logical ID | Name (OGPhases) | Hex ID | Name (Implementation) |
|------------|-----------------|--------|----------------------|
| 23 | Mission Planning | 0x8045 | Mission Planner |
| 24 | Strategic Analysis | 0x8048 | Strategic Analyzer |
| 25 | Intel Fusion | 0x804B | Intelligence Fusion |
| 26 | Command Decision | 0x804E | Command Decision Support |
| 27 | Tactical Analysis | 0x8051 | Tactical Analyzer |
| 28 | Resource Allocation | 0x8054 | Resource Manager |
| 29 | Threat Assessment | 0x8057 | Threat Assessor |
| 30 | Coalition Intel | 0x805A | Coalition Integration |

### Layer 5 (COSMIC) - Devices 31-36

| Logical ID | Name (OGPhases) | Hex ID | Name (Implementation) |
|------------|-----------------|--------|----------------------|
| 31 | Predictive Analytics 1 | 0x805D | Predictor Core |
| 32 | Predictive Analytics 2 | 0x8060 | Predictor Extended |
| 33 | Pattern Recognition | 0x8063 | Pattern Analyzer |
| 34 | Coalition Analytics | 0x8066 | Coalition Analyzer |
| 35 | Threat Forecasting | 0x8069 | Threat Forecaster |
| 36 | Global Correlation | 0x806C | Global Correlator |

### Layer 6 (ATOMAL) - Devices 37-42

| Logical ID | Name (OGPhases) | Hex ID | Name (Implementation) |
|------------|-----------------|--------|----------------------|
| 37 | ATOMAL Fusion 1 | 0x806F | ATOMAL Primary |
| 38 | ATOMAL Fusion 2 | 0x8072 | ATOMAL Secondary |
| 39 | NC3 Link | 0x8075 | NC3 Interface |
| 40 | Strategic ATOMAL | 0x8078 | Strategic Nuclear |
| 41 | Tactical ATOMAL | 0x807B | Tactical Nuclear |
| 42 | ATOMAL Archive | 0x807E | Nuclear Archive |

### Layer 7 (EXTENDED) - Devices 43-50

| Logical ID | Name (OGPhases) | Hex ID | Name (Implementation) |
|------------|-----------------|--------|----------------------|
| 43 | Extended Analytics | 0x8081 | Extended Analyzer |
| 44 | Cross-Domain Fusion | 0x8084 | Cross-Domain Fuser |
| 45 | Enhanced Prediction | 0x8087 | Enhanced Predictor |
| **46** | **Quantum Integration** | 0x808A | **Quantum Coprocessor** |
| **47** | **Advanced AI/ML** | 0x808D | **Primary LLM Device** |
| 48 | Strategic Planning | 0x8090 | Strategic Planner |
| 49 | Global Intelligence | 0x8093 | Global Intel |
| 50 | Autonomous Systems | 0x8096 | Autonomous Controller |

### Layer 8 (ENHANCED_SEC) - Devices 51-58

| Logical ID | Name (OGPhases) | Hex ID | Name (Implementation) |
|------------|-----------------|--------|----------------------|
| 51 | Adversarial ML Defense | 0x8099 | AdvML Defender |
| 52 | Security Analytics | 0x809C | Security Analyzer |
| 53 | Crypto AI | 0x809F | Crypto AI Engine |
| 54 | Threat Intel | 0x80A2 | Threat Intelligence |
| 55 | Behavioral Biometrics | 0x80A5 | Biometric Analyzer |
| 56 | Secure Enclave | 0x80A8 | Secure Enclave Mgr |
| 57 | Network Security AI | 0x80AB | Network Security AI |
| 58 | SOAR | 0x80AE | SOAR Orchestrator |

### Layer 9 (EXECUTIVE) - Devices 59-62

| Logical ID | Name (OGPhases) | Hex ID | Name (Implementation) |
|------------|-----------------|--------|----------------------|
| 59 | Strategic Planning | 0x80B1 | Executive Planner |
| 60 | Decision Support | 0x80B4 | Decision Support |
| **61** | **Nuclear C&C Integration** | 0x80B7 | **NC3 Integration** |
| 62 | Global Situational Awareness | 0x80BA | Global Awareness |

### Special Devices

| Logical ID | Name (OGPhases) | Hex ID | Name (Implementation) | Notes |
|------------|-----------------|--------|----------------------|-------|
| 83 | Emergency Stop | 0x80F5 | Emergency Stop | Hardware read-only |

---

## Implementation Groups (Hex)

### Group 0: Core Security (0x8000-0x800B)

```
0x8000 - TPM Control
0x8001 - Boot Security
0x8002 - Credential Vault
0x8003 - Audit Log Controller
0x8004 - Event Logger
0x8005 - Performance Monitor
0x8006 - Thermal Sensor Hub
0x8007 - Power State Controller
0x8008 - Emergency Response Prep
0x8009 - DATA DESTRUCTION [QUARANTINED]
0x800A - SECURE WIPE [QUARANTINED]
0x800B - EMERGENCY LOCKDOWN [QUARANTINED]
```

### Group 1: Extended Security (0x8010-0x801B)

```
0x8010 - Access Control
0x8011 - Authentication Hub
0x8012 - Authorization Manager
0x8013 - Session Controller
0x8014 - Token Manager
0x8015 - Certificate Authority
0x8016 - Key Management
0x8017 - Security Policy Engine
0x8018 - Intrusion Detection
0x8019 - BIOS FLASH [QUARANTINED]
0x801A - FIRMWARE UPDATE [QUARANTINED]
0x801B - NVRAM CLEAR [QUARANTINED]
```

### Group 7: Diagnostic Tools (0x8070-0x807B)

```
0x8070 - System Diagnostics
0x8071 - Memory Tester
0x8072 - CPU Diagnostics
0x8073 - Storage Diagnostics
0x8074 - Network Diagnostics
0x8075 - Thermal Diagnostics
0x8076 - Power Diagnostics
0x8077 - I/O Diagnostics
0x8078 - Sensor Diagnostics
0x8079 - Firmware Diagnostics
0x807A - Security Diagnostics
0x807B - Performance Diagnostics
```

### Group 8: Advanced Capabilities (0x8080-0x808F)

```
0x8080 - Advanced AI Controller
0x8081 - ML Inference Engine
0x8082 - Neural Network Accelerator
0x8083 - Vector Processing Unit
0x8084 - Quantum Interface (simulated)
0x8085 - Strategic AI
0x8086 - Tactical AI
0x8087 - Predictive Analytics
```

---

## Code Examples

### Converting IDs in Python

```python
def logical_to_hex(logical_id: int) -> int:
    """Convert OGPhases logical ID to implementation hex ID"""
    if not 0 <= logical_id <= 103:
        raise ValueError(f"Logical ID must be 0-103, got {logical_id}")
    return 0x8000 + (logical_id * 3)

def hex_to_logical(hex_id: int) -> int:
    """Convert implementation hex ID to OGPhases logical ID"""
    if not 0x8000 <= hex_id <= 0x80FF:
        raise ValueError(f"Hex ID must be 0x8000-0x80FF, got {hex_id:#x}")
    return (hex_id - 0x8000) // 3

# Examples
print(f"Device 47 (LLM) → {logical_to_hex(47):#x}")  # 0x808d
print(f"Device 61 (NC3) → {logical_to_hex(61):#x}")  # 0x80b7
```

### Using Device Database

```python
from ai.integrations.databases.device_extended import (
    get_device_extended,
    ALL_DEVICES_EXTENDED
)

# Get device by hex ID
device = get_device_extended(0x808D)
print(f"Device: {device.name}, Status: {device.status}")

# Get device by logical ID (convert first)
logical_id = 47
hex_id = 0x8000 + (logical_id * 3)
device = get_device_extended(hex_id)
```

---

## Quarantined Devices

The following devices are **QUARANTINED** and must never be activated:

| Hex ID | Name | Risk |
|--------|------|------|
| 0x8009 | DATA DESTRUCTION | Irreversible data loss |
| 0x800A | SECURE WIPE | Irreversible data loss |
| 0x800B | EMERGENCY LOCKDOWN | System lockout |
| 0x8019 | BIOS FLASH | BIOS corruption risk |
| 0x801A | FIRMWARE UPDATE | Firmware corruption risk |
| 0x801B | NVRAM CLEAR | Configuration loss |

---

## Version History

- **v1.0 (2025-12-01):** Initial device ID mapping document

