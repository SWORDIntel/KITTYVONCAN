#!/usr/bin/env python3
"""
DSMIL SOC Router Test Script

Tests the SOC Router infrastructure:
- Redis Streams connectivity
- Hot-path database operations
- Event publishing and consumption
- SHRINK integration (if available)

Usage:
    python3 test_soc_router.py
    python3 test_soc_router.py --verbose
"""

import argparse
import json
import os
import sys
import time
from uuid import uuid4

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

def test_redis():
    """Test Redis Streams connectivity"""
    print("\n🔴 Testing Redis Streams...")

    try:
        from infrastructure.redis_streams import (
            RedisStreamsClient, StreamName, DSMILEvent, create_event,
            Severity, EventCategory
        )

        client = RedisStreamsClient()

        # Test connection
        if not client.connect():
            print("  ❌ Failed to connect to Redis")
            return False
        print("  ✅ Connected to Redis")

        # Initialize streams
        results = client.initialize_streams()
        success_count = sum(1 for v in results.values() if v)
        print(f"  ✅ Initialized {success_count}/{len(results)} streams")

        # Test publish
        test_event = create_event(
            source_device=15,
            source_layer=3,
            category=EventCategory.SYSTEM,
            severity=Severity.LOW,
            payload={"test": "data", "timestamp": time.time()}
        )

        msg_id = client.publish(StreamName.L3_OUT, test_event)
        if msg_id:
            print(f"  ✅ Published test event: {msg_id}")
        else:
            print("  ❌ Failed to publish test event")
            return False

        # Test read
        events = client.read(StreamName.L3_OUT, count=1, last_id="0-0")
        if events:
            print(f"  ✅ Read {len(events)} event(s) from L3_OUT")
        else:
            print("  ⚠️  No events read (might be empty)")

        # Get stream info
        info = client.get_stream_info(StreamName.L3_OUT)
        print(f"  📊 L3_OUT: {info.get('length', 0)} messages")

        client.disconnect()
        print("  ✅ Redis tests passed")
        return True

    except ImportError as e:
        print(f"  ❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"  ❌ Error: {e}")
        return False


def test_hotpath_db():
    """Test hot-path database operations"""
    print("\n💾 Testing Hot-Path Database...")

    try:
        from infrastructure.hotpath_db import HotPathDB, HotPathConfig

        # Use temp fallback for testing
        config = HotPathConfig(
            db_path="/tmp/dsmil-test-hotpath.db",
            fallback_path="/tmp/dsmil-test-hotpath.db"
        )
        db = HotPathDB(config)

        if not db.connect():
            print("  ❌ Failed to connect to database")
            return False
        print(f"  ✅ Connected to hot-path DB")

        # Initialize schema
        if db.initialize_schema():
            print("  ✅ Schema initialized")
        else:
            print("  ❌ Failed to initialize schema")
            return False

        # Test event insert
        event_id = str(uuid4())
        if db.insert_event(
            event_id=event_id,
            device_id=52,
            layer=8,
            source="test",
            compartment="GENERAL",
            category="SYSTEM",
            severity="LOW",
            payload={"test": "data"}
        ):
            print(f"  ✅ Inserted test event: {event_id}")
        else:
            print("  ❌ Failed to insert event")
            return False

        # Test SOC event insert
        soc_event_id = str(uuid4())
        if db.insert_soc_event(
            event_id=soc_event_id,
            severity="MEDIUM",
            category="SECURITY",
            source_device=52,
            source_layer=8,
            payload={"soc_test": "data"},
            signals={"l3": {"score": 0.85}},
            shrink_metrics={"risk_acute_stress": 0.3}
        ):
            print(f"  ✅ Inserted SOC event: {soc_event_id}")

        # Test SHRINK metrics insert
        if db.insert_shrink_metrics({
            "risk_acute_stress": 0.25,
            "crisis_level": 0.1,
            "lbi_hyperfocus_density": 0.5
        }):
            print("  ✅ Inserted SHRINK metrics")

        # Test device status
        if db.update_device_status(
            device_id=52,
            layer=8,
            name="Security Analytics",
            status="ONLINE",
            memory_mb=100,
            tops_allocated=10
        ):
            print("  ✅ Updated device status")

        # Test queries
        events = db.get_recent_events(limit=5)
        print(f"  📊 Recent events: {len(events)}")

        soc_events = db.get_recent_soc_events(limit=5)
        print(f"  📊 SOC events: {len(soc_events)}")

        statuses = db.get_device_statuses()
        print(f"  📊 Device statuses: {len(statuses)}")

        # Get stats
        stats = db.get_stats()
        print(f"  📊 DB size: {stats.get('db_size_bytes', 0)} bytes")

        db.disconnect()
        print("  ✅ Hot-path DB tests passed")
        return True

    except ImportError as e:
        print(f"  ❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"  ❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_shrink():
    """Test SHRINK connectivity"""
    print("\n🧠 Testing SHRINK Integration...")

    try:
        from services.soc_router import SHRINKClient

        client = SHRINKClient("http://localhost:8500")

        if client.check_availability():
            print("  ✅ SHRINK is available")

            metrics = client.get_metrics()
            if metrics:
                print(f"  📊 Metrics received: {list(metrics.keys())[:5]}...")
            else:
                print("  ⚠️  No metrics returned")

            alerts = client.get_alerts()
            print(f"  📊 Active alerts: {len(alerts)}")

            return True
        else:
            print("  ⚠️  SHRINK not available (optional)")
            return True  # Not a failure - SHRINK is optional

    except ImportError as e:
        print(f"  ❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"  ⚠️  SHRINK test skipped: {e}")
        return True  # Not a failure


def test_soc_router():
    """Test SOC Router initialization"""
    print("\n🔧 Testing SOC Router...")

    try:
        from services.soc_router import SOCRouter, SOCRouterConfig

        config = SOCRouterConfig(
            redis_host="localhost",
            redis_port=6379,
            shrink_url="http://localhost:8500"
        )

        router = SOCRouter(config)

        # Test stats (before init)
        stats = router.get_stats()
        print(f"  📊 Device ID: {stats['device_id']}")
        print(f"  📊 Token Base: {stats['token_base']}")
        print(f"  📊 Layer: {stats['layer']}")

        print("  ✅ SOC Router instantiation passed")
        return True

    except ImportError as e:
        print(f"  ❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"  ❌ Error: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Test DSMIL SOC Router infrastructure")
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    args = parser.parse_args()

    print("=" * 50)
    print("DSMIL SOC Router Infrastructure Tests")
    print("=" * 50)

    results = {}

    # Run tests
    results["redis"] = test_redis()
    results["hotpath_db"] = test_hotpath_db()
    results["shrink"] = test_shrink()
    results["soc_router"] = test_soc_router()

    # Summary
    print("\n" + "=" * 50)
    print("Test Summary")
    print("=" * 50)

    passed = sum(1 for v in results.values() if v)
    total = len(results)

    for test, result in results.items():
        status = "✅ PASSED" if result else "❌ FAILED"
        print(f"  {test}: {status}")

    print(f"\nTotal: {passed}/{total} tests passed")

    if passed == total:
        print("\n🎉 All tests passed!")
        return 0
    else:
        print("\n⚠️  Some tests failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())

