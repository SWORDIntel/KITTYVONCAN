# Phase 1/2F Implementation - Data Fabric & SOC Router

> **Date:** 2025-12-01
> **Version:** 1.0.0
> **Status:** IMPLEMENTED

## Overview

This implementation completes key components from **Phase 1 (Foundation)** and **Phase 2F (Fast Fabric + SHRINK-SOC)**:

1. **Redis Streams** - Event bus for cross-layer intelligence flows
2. **tmpfs SQLite** - Hot-path database for real-time state
3. **SOC Router (Device 52)** - Security Analytics fusion service

---

## Components Implemented

### 1. Redis Streams Client (`src/infrastructure/redis_streams.py`)

High-speed event bus for DSMIL cross-layer communication.

**Streams:**
| Stream | Purpose | Producers | Consumers |
|--------|---------|-----------|-----------|
| `L3_IN` | Layer 3 inputs | Devices 0-11 | Devices 15-22 |
| `L3_OUT` | Layer 3 decisions | Devices 15-22 | Layer 4, SOC Router |
| `L4_IN` | Layer 4 inputs | Layer 3, external | Devices 23-30 |
| `L4_OUT` | Layer 4 decisions | Devices 23-30 | Layer 5, SOC Router |
| `SOC_EVENTS` | Fused security alerts | SOC Router | Layer 8, Layer 9 |

**Features:**
- Automatic stream initialization
- Consumer groups for reliable delivery
- Event serialization (JSON)
- Statistics and monitoring

**Usage:**
```python
from src.infrastructure.redis_streams import (
    RedisStreamsClient, StreamName, create_event, Severity, EventCategory
)

client = RedisStreamsClient()
client.connect()
client.initialize_streams()

# Publish event
event = create_event(
    source_device=15,
    source_layer=3,
    category=EventCategory.SECURITY,
    severity=Severity.HIGH,
    payload={"alert": "Anomaly detected"}
)
client.publish(StreamName.L3_OUT, event)
```

### 2. Hot-Path Database (`src/infrastructure/hotpath_db.py`)

RAM-backed SQLite for real-time state queries.

**Location:** `/mnt/dsmil-ram/hotpath.db` (4 GB tmpfs)

**Tables:**
| Table | Purpose | Retention |
|-------|---------|-----------|
| `raw_events_fast` | Raw events | 24h |
| `model_outputs_fast` | AI inference results | 24h |
| `layer_state` | Layer resource tracking | Real-time |
| `device_status` | Device status | Real-time |
| `soc_events_cache` | SOC events cache | 7 days |
| `shrink_metrics` | SHRINK metrics history | 24h |

**Features:**
- WAL mode for concurrent access
- Indexed queries for fast lookups
- Automatic cleanup of old data
- Statistics reporting

**Usage:**
```python
from src.infrastructure.hotpath_db import HotPathDB

db = HotPathDB()
db.connect()
db.initialize_schema()

# Insert event
db.insert_event(
    event_id="uuid",
    device_id=52,
    layer=8,
    source="soc-router",
    compartment="GENERAL",
    category="SECURITY",
    severity="HIGH",
    payload={"alert": "data"}
)

# Query recent events
events = db.get_recent_events(layer=8, severity="HIGH", limit=10)
```

### 3. SOC Router Service (`src/services/soc_router.py`)

Device 52 - Security Analytics fusion service.

**Device Assignment:**
- **Device ID:** 52
- **Layer:** 8 (ENHANCED_SEC)
- **Token Base:** 0x809C
- **Memory Budget:** 1.5 GB
- **TOPS:** 10

**Architecture:**
```
Redis L3_OUT ──┐
               ├──> SOC Router ──> Redis SOC_EVENTS ──> Layer 8 Workers
Redis L4_OUT ──┤                                      └──> Layer 9
               │
SHRINK :8500 ──┘
```

**Features:**
- Fuses L3/L4 outputs with SHRINK metrics
- Auto-escalates severity based on SHRINK risk
- Publishes to SOC_EVENTS stream
- Writes to hot-path database
- Device status heartbeat

**Usage:**
```bash
# Run directly
python3 src/services/soc_router.py

# Or via systemd
sudo systemctl start dsmil-soc-router
```

---

## File Structure

```
KITTYVONCAN/
├── src/
│   ├── infrastructure/
│   │   ├── __init__.py
│   │   ├── redis_streams.py      # Redis Streams client
│   │   └── hotpath_db.py         # Hot-path SQLite database
│   └── services/
│       ├── __init__.py
│       └── soc_router.py         # SOC Router (Device 52)
├── scripts/
│   ├── init_hotpath_db.sql       # Database schema
│   ├── setup_data_fabric.sh      # Setup script
│   └── test_soc_router.py        # Test script
└── systemd/
    └── dsmil-soc-router.service  # systemd unit
```

---

## Setup Instructions

### Prerequisites

```bash
# Install Redis
sudo apt-get install redis-server

# Install Python dependencies
pip install redis requests

# Create DSMIL user (if not exists)
sudo useradd -r -s /bin/false -m -d /opt/dsmil dsmil
```

### Quick Setup

```bash
# Run setup script
cd KITTYVONCAN
sudo ./scripts/setup_data_fabric.sh

# Or dry-run first
./scripts/setup_data_fabric.sh --dry-run
```

### Manual Setup

```bash
# 1. Start Redis
sudo systemctl enable --now redis-server

# 2. Create tmpfs mount
sudo mkdir -p /mnt/dsmil-ram
sudo mount -t tmpfs -o size=4G,mode=0770 tmpfs /mnt/dsmil-ram

# 3. Add to fstab (persistence)
echo "tmpfs /mnt/dsmil-ram tmpfs size=4G,mode=0770 0 0" | sudo tee -a /etc/fstab

# 4. Initialize database
sqlite3 /mnt/dsmil-ram/hotpath.db < scripts/init_hotpath_db.sql

# 5. Initialize Redis streams
redis-cli XGROUP CREATE L3_IN dsmil 0 MKSTREAM
redis-cli XGROUP CREATE L3_OUT dsmil 0 MKSTREAM
redis-cli XGROUP CREATE L4_IN dsmil 0 MKSTREAM
redis-cli XGROUP CREATE L4_OUT dsmil 0 MKSTREAM
redis-cli XGROUP CREATE SOC_EVENTS dsmil 0 MKSTREAM
```

### Install systemd Service

```bash
# Copy service file
sudo cp systemd/dsmil-soc-router.service /etc/systemd/system/

# Reload and enable
sudo systemctl daemon-reload
sudo systemctl enable dsmil-soc-router

# Start service
sudo systemctl start dsmil-soc-router

# Check status
sudo systemctl status dsmil-soc-router
journalctl -u dsmil-soc-router -f
```

---

## Testing

```bash
# Run test suite
python3 scripts/test_soc_router.py

# Verbose output
python3 scripts/test_soc_router.py --verbose
```

**Expected Output:**
```
==================================================
DSMIL SOC Router Infrastructure Tests
==================================================

🔴 Testing Redis Streams...
  ✅ Connected to Redis
  ✅ Initialized 13/13 streams
  ✅ Published test event
  ✅ Redis tests passed

💾 Testing Hot-Path Database...
  ✅ Connected to hot-path DB
  ✅ Schema initialized
  ✅ Hot-path DB tests passed

🧠 Testing SHRINK Integration...
  ⚠️  SHRINK not available (optional)

🔧 Testing SOC Router...
  📊 Device ID: 52
  📊 Token Base: 0x809C
  ✅ SOC Router instantiation passed

==================================================
Test Summary
==================================================
  redis: ✅ PASSED
  hotpath_db: ✅ PASSED
  shrink: ✅ PASSED
  soc_router: ✅ PASSED

Total: 4/4 tests passed
🎉 All tests passed!
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_HOST` | localhost | Redis server host |
| `REDIS_PORT` | 6379 | Redis server port |
| `REDIS_DB` | 0 | Redis database number |
| `SHRINK_URL` | http://localhost:8500 | SHRINK API endpoint |
| `SHRINK_POLL_INTERVAL` | 1.0 | SHRINK polling interval (seconds) |
| `BATCH_SIZE` | 10 | Events per batch |
| `POLL_TIMEOUT` | 5000 | Redis read timeout (ms) |
| `LOG_LEVEL` | INFO | Logging level |

### Severity Escalation

SOC Router automatically escalates event severity based on SHRINK metrics:

| SHRINK Metric | Threshold | Action |
|---------------|-----------|--------|
| `crisis_level` | ≥ 0.8 | Escalate to CRITICAL |
| `risk_acute_stress` | ≥ 0.7 | Escalate +1 level |

---

## Monitoring

### Redis Streams

```bash
# Stream lengths
redis-cli XLEN L3_OUT
redis-cli XLEN SOC_EVENTS

# Stream info
redis-cli XINFO STREAM SOC_EVENTS
```

### Hot-Path Database

```sql
-- Event counts
SELECT layer, severity, COUNT(*) FROM raw_events_fast GROUP BY layer, severity;

-- SOC events
SELECT * FROM soc_events_cache ORDER BY ts DESC LIMIT 10;

-- Device status
SELECT * FROM device_status WHERE status = 'ONLINE';

-- SHRINK metrics
SELECT * FROM shrink_metrics ORDER BY ts DESC LIMIT 5;
```

### SOC Router Logs

```bash
# Systemd logs
journalctl -u dsmil-soc-router -f

# Stats in logs (every 30s)
# 📊 Stats: uptime=123s, processed=45, published=42, shrink=✅
```

---

## Integration Points

### With SHRINK (Phase 2F)

SOC Router pulls metrics from SHRINK at `http://localhost:8500/api/v1/metrics`:

```json
{
  "risk_acute_stress": 0.35,
  "crisis_level": 0.12,
  "lbi_hyperfocus_density": 0.58,
  "sentiment_score": 0.72,
  "entropy": 0.45
}
```

### With Layer 8 Devices (Phase 4)

SOC_EVENTS stream consumed by:
- Device 51: Adversarial ML Defense
- Device 53: Cryptographic AI
- Device 54: Threat Intel Fusion
- Device 55-58: Other L8 workers

### With Layer 9 (Phase 4)

High-severity SOC_EVENTS escalated to Layer 9 Command.

---

## Next Steps

1. **Phase 4:** Implement Layer 8 workers (Devices 51, 53-58)
2. **Phase 4:** Implement Layer 9 Command integration
3. **Phase 6:** Add OpenAI-compatible shim for L7
4. **Phase 7:** Implement DBE protocol for secure mesh

---

## References

- [Phase 1 Documentation](comprehensive-plan/Phases/Phase1.md)
- [Phase 2F Documentation](comprehensive-plan/Phases/Phase2F.md)
- [Implementation Roadmap](comprehensive-plan/07_IMPLEMENTATION_ROADMAP.md)
- [Device ID Mapping](DEVICE_ID_MAPPING.md)

---

**Status:** ✅ **IMPLEMENTATION COMPLETE**

Phase 1/2F data fabric and SOC Router are now implemented and ready for use.

