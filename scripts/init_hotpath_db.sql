-- DSMIL Hot-Path Database Schema
-- Version: 1.0.0
-- Location: /mnt/dsmil-ram/hotpath.db
--
-- Initialize with:
--   sqlite3 /mnt/dsmil-ram/hotpath.db < init_hotpath_db.sql
--
-- Tables:
--   raw_events_fast     - Raw event storage (24h retention)
--   model_outputs_fast  - AI inference results (24h retention)
--   layer_state         - Layer resource tracking
--   device_status       - Real-time device status
--   soc_events_cache    - SOC events cache (7d retention)
--   shrink_metrics      - SHRINK metrics history (24h retention)

-- Enable WAL mode for better performance
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000;  -- 64MB cache
PRAGMA temp_store = MEMORY;

-- Raw events from all layers
CREATE TABLE IF NOT EXISTS raw_events_fast (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ts REAL NOT NULL,                    -- Unix timestamp with microseconds
    event_id TEXT NOT NULL UNIQUE,       -- UUID event identifier
    device_id INTEGER NOT NULL,          -- Device 0-103
    layer INTEGER NOT NULL,              -- Layer 2-9
    source TEXT NOT NULL,                -- Data source/sensor
    compartment TEXT NOT NULL,           -- CRYPTO, SIGNALS, NUCLEAR, etc.
    category TEXT NOT NULL,              -- AUTH, NETWORK, SYSTEM, APP, INTEL
    severity TEXT NOT NULL,              -- LOW, MEDIUM, HIGH, CRITICAL
    payload BLOB NOT NULL,               -- JSON event data
    token_id INTEGER,                    -- 0x8000 + (device_id * 3) + offset
    clearance INTEGER,                   -- 0x02020202 - 0x09090909
    processed INTEGER DEFAULT 0          -- 0=pending, 1=processed
);

-- Model inference outputs
CREATE TABLE IF NOT EXISTS model_outputs_fast (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ts REAL NOT NULL,
    output_id TEXT NOT NULL UNIQUE,      -- UUID output identifier
    device_id INTEGER NOT NULL,          -- Source device (0-103)
    layer INTEGER NOT NULL,              -- Layer 2-9
    model TEXT NOT NULL,                 -- Model name/version
    input_ref TEXT,                      -- Reference to input event_id
    output_json TEXT NOT NULL,           -- JSON result
    score REAL,                          -- Confidence/risk score
    tops_used REAL,                      -- TOPS consumed
    latency_ms REAL,                     -- Processing time
    hardware TEXT                        -- NPU, GPU, CPU
);

-- Current layer state (resource tracking)
CREATE TABLE IF NOT EXISTS layer_state (
    layer INTEGER PRIMARY KEY,           -- Layer 2-9
    active_devices TEXT NOT NULL,        -- JSON array of active device IDs
    memory_used_gb REAL NOT NULL,        -- Current memory consumption
    tops_used REAL NOT NULL,             -- Current TOPS utilization
    tops_available REAL NOT NULL,        -- Available TOPS capacity
    event_count INTEGER DEFAULT 0,       -- Events processed this session
    last_update REAL NOT NULL            -- Last state update timestamp
);

-- Real-time device status
CREATE TABLE IF NOT EXISTS device_status (
    device_id INTEGER PRIMARY KEY,       -- Device 0-103
    layer INTEGER NOT NULL,              -- Layer 2-9
    name TEXT NOT NULL,                  -- Device name
    status TEXT NOT NULL,                -- ONLINE, OFFLINE, BUSY, ERROR
    memory_mb REAL DEFAULT 0,            -- Memory usage in MB
    tops_allocated REAL DEFAULT 0,       -- TOPS allocated
    last_heartbeat REAL,                 -- Last heartbeat timestamp
    metadata TEXT                        -- JSON additional metadata
);

-- SOC events cache (for fast queries)
CREATE TABLE IF NOT EXISTS soc_events_cache (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ts REAL NOT NULL,
    event_id TEXT NOT NULL UNIQUE,
    severity TEXT NOT NULL,
    category TEXT NOT NULL,
    source_device INTEGER NOT NULL,
    source_layer INTEGER NOT NULL,
    signals TEXT,                        -- JSON L3-L7 signals
    shrink_metrics TEXT,                 -- JSON SHRINK metrics
    l8_enrichment TEXT,                  -- JSON L8 enrichment
    payload TEXT NOT NULL                -- JSON full payload
);

-- SHRINK metrics history
CREATE TABLE IF NOT EXISTS shrink_metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ts REAL NOT NULL,
    risk_acute_stress REAL,
    crisis_level REAL,
    lbi_hyperfocus_density REAL,
    sentiment_score REAL,
    entropy REAL,
    metrics_json TEXT                    -- Full metrics JSON
);

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_raw_events_fast_ts ON raw_events_fast(ts);
CREATE INDEX IF NOT EXISTS idx_raw_events_fast_device ON raw_events_fast(device_id, ts);
CREATE INDEX IF NOT EXISTS idx_raw_events_fast_layer ON raw_events_fast(layer, ts);
CREATE INDEX IF NOT EXISTS idx_raw_events_fast_severity ON raw_events_fast(severity, ts);
CREATE INDEX IF NOT EXISTS idx_raw_events_fast_processed ON raw_events_fast(processed, ts);

CREATE INDEX IF NOT EXISTS idx_model_outputs_fast_layer_ts ON model_outputs_fast(layer, ts);
CREATE INDEX IF NOT EXISTS idx_model_outputs_fast_device_ts ON model_outputs_fast(device_id, ts);
CREATE INDEX IF NOT EXISTS idx_model_outputs_fast_model ON model_outputs_fast(model, ts);

CREATE INDEX IF NOT EXISTS idx_soc_events_cache_ts ON soc_events_cache(ts);
CREATE INDEX IF NOT EXISTS idx_soc_events_cache_severity ON soc_events_cache(severity, ts);

CREATE INDEX IF NOT EXISTS idx_shrink_metrics_ts ON shrink_metrics(ts);

-- Initialize layer states for Layers 2-9
INSERT OR IGNORE INTO layer_state (layer, active_devices, memory_used_gb, tops_used, tops_available, last_update)
VALUES
    (2, '[]', 0, 0, 102, strftime('%s', 'now')),   -- TRAINING: 102 TOPS
    (3, '[]', 0, 0, 50, strftime('%s', 'now')),    -- SECRET: 50 TOPS
    (4, '[]', 0, 0, 65, strftime('%s', 'now')),    -- TOP_SECRET: 65 TOPS
    (5, '[]', 0, 0, 105, strftime('%s', 'now')),   -- COSMIC: 105 TOPS
    (6, '[]', 0, 0, 160, strftime('%s', 'now')),   -- ATOMAL: 160 TOPS
    (7, '[]', 0, 0, 440, strftime('%s', 'now')),   -- EXTENDED: 440 TOPS (primary)
    (8, '[]', 0, 0, 80, strftime('%s', 'now')),    -- ENHANCED_SEC: 80 TOPS
    (9, '[]', 0, 0, 200, strftime('%s', 'now'));   -- EXECUTIVE: 200 TOPS

-- Print schema info
.schema

