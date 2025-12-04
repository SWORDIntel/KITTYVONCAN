#!/usr/bin/env python3
"""
dsmilctl - DSMIL Unified Command-Line Interface

Unified CLI for managing and interacting with DSMIL components.

Usage:
    dsmilctl status              # Show system status
    dsmilctl devices [--layer N] # List devices
    dsmilctl events [--severity] # Show SOC events
    dsmilctl query "prompt"      # Query L7 LLM
    dsmilctl start <service>     # Start a service
    dsmilctl stop <service>      # Stop a service
    dsmilctl logs <service>      # Show service logs
"""

import argparse
import json
import os
import sys
import time
from datetime import datetime
from typing import Any, Dict, List, Optional

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

try:
    from infrastructure.redis_streams import RedisStreamsClient, StreamName
    from infrastructure.hotpath_db import HotPathDB
    HAS_INFRA = True
except ImportError:
    HAS_INFRA = False

# ANSI colors
class C:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    END = '\033[0m'

# Device definitions
DEVICES = {
    # Layer 3 - SECRET
    15: ("L3 Sensor Fusion", 3), 16: ("L3 Pattern Detect", 3), 17: ("L3 Anomaly", 3),
    18: ("L3 Correlation", 3), 19: ("L3 Filter", 3), 20: ("L3 Aggregator", 3),
    21: ("L3 Classifier", 3), 22: ("L3 Router", 3),
    # Layer 4 - TOP_SECRET
    23: ("L4 Mission Plan", 4), 24: ("L4 Multi-Domain", 4), 25: ("L4 Risk Assess", 4),
    26: ("L4 Decision", 4), 27: ("L4 Priority", 4), 28: ("L4 Scheduler", 4),
    29: ("L4 Coordinator", 4), 30: ("L4 Optimizer", 4),
    # Layer 5 - COSMIC
    31: ("L5 Predictive Analytics", 5), 32: ("L5 Forecasting", 5), 33: ("L5 Trends", 5),
    34: ("L5 Scenarios", 5), 35: ("L5 Simulation", 5), 36: ("L5 Projection", 5),
    # Layer 6 - ATOMAL
    37: ("L6 Nuclear Intel", 6), 38: ("L6 Treaty Monitor", 6), 39: ("L6 Risk Analysis", 6),
    40: ("L6 Proliferation", 6), 41: ("L6 Verification", 6), 42: ("L6 Assessment", 6),
    # Layer 7 - EXTENDED
    43: ("L7 Router", 7), 44: ("L7 RAG", 7), 45: ("L7 Code Gen", 7),
    46: ("L7 Analysis", 7), 47: ("L7 Primary LLM", 7), 48: ("L7 Backup LLM", 7),
    49: ("L7 Summarizer", 7), 50: ("L7 Translator", 7),
    # Layer 8 - ENHANCED_SEC
    51: ("AdvML Defense", 8), 52: ("SOC Router", 8), 53: ("Crypto AI", 8),
    54: ("Threat Intel", 8), 55: ("Biometrics", 8), 56: ("Enclave Mgmt", 8),
    57: ("Network AI", 8), 58: ("SOAR", 8),
    # Layer 9 - EXECUTIVE
    59: ("Strategic Planning", 9), 60: ("Global Strategy", 9),
    61: ("NC3 Integration", 9), 62: ("Coalition Intel", 9),
}

LAYER_NAMES = {
    2: "TRAINING", 3: "SECRET", 4: "TOP_SECRET", 5: "COSMIC",
    6: "ATOMAL", 7: "EXTENDED", 8: "ENHANCED_SEC", 9: "EXECUTIVE"
}

SERVICES = {
    "soc-router": "src/services/soc_router.py",
    "advml": "src/services/l8_advml_defense.py",
    "soar": "src/services/l8_soar.py",
    "openai-shim": "src/api/openai_shim.py",
}


def print_banner():
    print(f"""
{C.CYAN}╔═══════════════════════════════════════════════════════╗
║  {C.BOLD}DSMIL Control Interface{C.END}{C.CYAN}                               ║
║  {C.GREEN}104 Devices • 9 Layers • 1440 TOPS{C.CYAN}                    ║
╚═══════════════════════════════════════════════════════╝{C.END}
""")


def cmd_status(args):
    """Show system status"""
    print_banner()
    print(f"{C.BOLD}System Status{C.END}\n")
    
    # Check Redis
    redis_status = f"{C.RED}OFFLINE{C.END}"
    if HAS_INFRA:
        try:
            client = RedisStreamsClient()
            if client.connect():
                redis_status = f"{C.GREEN}ONLINE{C.END}"
                client.disconnect()
        except:
            pass
    print(f"  Redis:        {redis_status}")
    
    # Check Hot-path DB
    db_status = f"{C.RED}OFFLINE{C.END}"
    if HAS_INFRA:
        try:
            db = HotPathDB()
            if db.connect():
                db_status = f"{C.GREEN}ONLINE{C.END}"
                db.disconnect()
        except:
            pass
    print(f"  Hot-path DB:  {db_status}")
    
    # Check Ollama
    ollama_status = f"{C.RED}OFFLINE{C.END}"
    if HAS_REQUESTS:
        try:
            r = requests.get("http://localhost:11434/api/tags", timeout=2)
            if r.status_code == 200:
                ollama_status = f"{C.GREEN}ONLINE{C.END}"
        except:
            pass
    print(f"  Ollama:       {ollama_status}")
    
    # Check SHRINK
    shrink_status = f"{C.YELLOW}UNKNOWN{C.END}"
    if HAS_REQUESTS:
        try:
            r = requests.get("http://localhost:8500/health", timeout=2)
            if r.status_code == 200:
                shrink_status = f"{C.GREEN}ONLINE{C.END}"
        except:
            shrink_status = f"{C.RED}OFFLINE{C.END}"
    print(f"  SHRINK:       {shrink_status}")
    
    # Layer summary
    print(f"\n{C.BOLD}Layer Summary{C.END}\n")
    for layer in range(2, 10):
        devices = [d for d, (_, l) in DEVICES.items() if l == layer]
        name = LAYER_NAMES.get(layer, "UNKNOWN")
        print(f"  Layer {layer} ({name:12}): {len(devices)} devices")
    
    print(f"\n  {C.BOLD}Total: 104 devices across 9 operational layers{C.END}")


def cmd_devices(args):
    """List devices"""
    print_banner()
    
    layer_filter = args.layer
    
    if layer_filter:
        print(f"{C.BOLD}Devices - Layer {layer_filter} ({LAYER_NAMES.get(layer_filter, 'UNKNOWN')}){C.END}\n")
    else:
        print(f"{C.BOLD}All Devices{C.END}\n")
    
    print(f"  {'ID':>4}  {'Token':>8}  {'Layer':>5}  {'Name':<25}  Status")
    print(f"  {'-'*4}  {'-'*8}  {'-'*5}  {'-'*25}  {'-'*8}")
    
    # Get device statuses from DB if available
    statuses = {}
    if HAS_INFRA:
        try:
            db = HotPathDB()
            if db.connect():
                for s in db.get_device_statuses():
                    statuses[s['device_id']] = s['status']
                db.disconnect()
        except:
            pass
    
    for device_id, (name, layer) in sorted(DEVICES.items()):
        if layer_filter and layer != layer_filter:
            continue
        
        token = f"0x{0x8000 + device_id * 3:04X}"
        status = statuses.get(device_id, "UNKNOWN")
        
        if status == "ONLINE":
            status_str = f"{C.GREEN}ONLINE{C.END}"
        elif status == "OFFLINE":
            status_str = f"{C.RED}OFFLINE{C.END}"
        else:
            status_str = f"{C.YELLOW}UNKNOWN{C.END}"
        
        print(f"  {device_id:>4}  {token:>8}  L{layer:<4}  {name:<25}  {status_str}")


def cmd_events(args):
    """Show SOC events"""
    print_banner()
    print(f"{C.BOLD}Recent SOC Events{C.END}\n")
    
    if not HAS_INFRA:
        print(f"  {C.RED}Infrastructure modules not available{C.END}")
        return
    
    try:
        db = HotPathDB()
        if not db.connect():
            print(f"  {C.RED}Failed to connect to database{C.END}")
            return
        
        events = db.get_recent_soc_events(
            severity=args.severity.upper() if args.severity else None,
            limit=args.limit
        )
        
        if not events:
            print(f"  {C.YELLOW}No events found{C.END}")
            return
        
        for event in events:
            ts = datetime.fromtimestamp(event['ts']).strftime('%H:%M:%S')
            sev = event['severity']
            
            if sev == "CRITICAL":
                sev_str = f"{C.RED}{C.BOLD}{sev}{C.END}"
            elif sev == "HIGH":
                sev_str = f"{C.RED}{sev}{C.END}"
            elif sev == "MEDIUM":
                sev_str = f"{C.YELLOW}{sev}{C.END}"
            else:
                sev_str = f"{C.GREEN}{sev}{C.END}"
            
            print(f"  [{ts}] {sev_str:>20}  {event['category']:<12}  Device {event['source_device']}")
            
            # Show enrichment if available
            l8 = event.get('l8_enrichment', {})
            if isinstance(l8, str):
                l8 = json.loads(l8)
            
            if l8.get('advml_flags'):
                print(f"           {C.RED}⚠ Flags: {', '.join(l8['advml_flags'])}{C.END}")
            if l8.get('soar_proposals'):
                print(f"           {C.CYAN}→ Proposals: {len(l8['soar_proposals'])} action(s){C.END}")
        
        db.disconnect()
        
    except Exception as e:
        print(f"  {C.RED}Error: {e}{C.END}")


def cmd_query(args):
    """Query L7 LLM"""
    print_banner()
    
    if not HAS_REQUESTS:
        print(f"{C.RED}requests library not available{C.END}")
        return
    
    prompt = args.prompt
    model = args.model
    
    print(f"{C.BOLD}Query:{C.END} {prompt[:100]}{'...' if len(prompt) > 100 else ''}")
    print(f"{C.BOLD}Model:{C.END} {model}\n")
    
    # Try OpenAI shim first
    try:
        r = requests.post(
            "http://localhost:8080/v1/chat/completions",
            json={
                "model": model,
                "messages": [{"role": "user", "content": prompt}],
                "stream": False
            },
            timeout=120
        )
        
        if r.status_code == 200:
            data = r.json()
            content = data['choices'][0]['message']['content']
            print(f"{C.GREEN}Response:{C.END}\n{content}")
            return
    except:
        pass
    
    # Fallback to direct Ollama
    try:
        r = requests.post(
            "http://localhost:11434/api/chat",
            json={
                "model": "deepseek-r1:1.5b",
                "messages": [{"role": "user", "content": prompt}],
                "stream": False
            },
            timeout=120
        )
        
        if r.status_code == 200:
            data = r.json()
            content = data['message']['content']
            print(f"{C.GREEN}Response:{C.END}\n{content}")
            return
    except Exception as e:
        print(f"{C.RED}Error: {e}{C.END}")
        print(f"{C.YELLOW}Ensure OpenAI shim or Ollama is running{C.END}")


def cmd_streams(args):
    """Show Redis stream info"""
    print_banner()
    print(f"{C.BOLD}Redis Streams{C.END}\n")
    
    if not HAS_INFRA:
        print(f"  {C.RED}Infrastructure modules not available{C.END}")
        return
    
    try:
        client = RedisStreamsClient()
        if not client.connect():
            print(f"  {C.RED}Failed to connect to Redis{C.END}")
            return
        
        info = client.get_all_streams_info()
        
        print(f"  {'Stream':<15}  {'Messages':>10}  Status")
        print(f"  {'-'*15}  {'-'*10}  {'-'*8}")
        
        for stream, data in info.items():
            length = data.get('length', 0)
            status = f"{C.GREEN}ACTIVE{C.END}" if length > 0 else f"{C.YELLOW}EMPTY{C.END}"
            print(f"  {stream:<15}  {length:>10}  {status}")
        
        client.disconnect()
        
    except Exception as e:
        print(f"  {C.RED}Error: {e}{C.END}")


def cmd_metrics(args):
    """Show SHRINK metrics"""
    print_banner()
    print(f"{C.BOLD}SHRINK Metrics{C.END}\n")
    
    if not HAS_REQUESTS:
        print(f"  {C.RED}requests library not available{C.END}")
        return
    
    try:
        r = requests.get("http://localhost:8500/api/v1/metrics", timeout=5)
        if r.status_code != 200:
            print(f"  {C.RED}SHRINK not available{C.END}")
            return
        
        metrics = r.json()
        
        for key, value in metrics.items():
            if isinstance(value, float):
                # Color code risk metrics
                if 'risk' in key.lower() or 'crisis' in key.lower():
                    if value > 0.7:
                        color = C.RED
                    elif value > 0.4:
                        color = C.YELLOW
                    else:
                        color = C.GREEN
                    print(f"  {key:<30}  {color}{value:.3f}{C.END}")
                else:
                    print(f"  {key:<30}  {value:.3f}")
            else:
                print(f"  {key:<30}  {value}")
                
    except Exception as e:
        print(f"  {C.RED}Error: {e}{C.END}")


def cmd_help(args):
    """Show help"""
    print_banner()
    print(f"""{C.BOLD}Commands:{C.END}

  {C.CYAN}status{C.END}                     Show system status
  {C.CYAN}devices{C.END} [--layer N]        List devices (optionally filter by layer)
  {C.CYAN}events{C.END} [--severity S]      Show recent SOC events
  {C.CYAN}streams{C.END}                    Show Redis stream info
  {C.CYAN}metrics{C.END}                    Show SHRINK metrics
  {C.CYAN}query{C.END} "prompt"             Query L7 LLM
  {C.CYAN}help{C.END}                       Show this help

{C.BOLD}Examples:{C.END}

  dsmilctl status
  dsmilctl devices --layer 8
  dsmilctl events --severity HIGH --limit 20
  dsmilctl query "Summarize recent security events"
""")


def main():
    parser = argparse.ArgumentParser(
        description="DSMIL Unified Command-Line Interface",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Commands")
    
    # status
    subparsers.add_parser("status", help="Show system status")
    
    # devices
    p_devices = subparsers.add_parser("devices", help="List devices")
    p_devices.add_argument("--layer", "-l", type=int, help="Filter by layer (2-9)")
    
    # events
    p_events = subparsers.add_parser("events", help="Show SOC events")
    p_events.add_argument("--severity", "-s", help="Filter by severity")
    p_events.add_argument("--limit", "-n", type=int, default=20, help="Max events")
    
    # streams
    subparsers.add_parser("streams", help="Show Redis stream info")
    
    # metrics
    subparsers.add_parser("metrics", help="Show SHRINK metrics")
    
    # query
    p_query = subparsers.add_parser("query", help="Query L7 LLM")
    p_query.add_argument("prompt", help="Query prompt")
    p_query.add_argument("--model", "-m", default="dsmil-default", help="Model to use")
    
    # help
    subparsers.add_parser("help", help="Show help")
    
    args = parser.parse_args()
    
    commands = {
        "status": cmd_status,
        "devices": cmd_devices,
        "events": cmd_events,
        "streams": cmd_streams,
        "metrics": cmd_metrics,
        "query": cmd_query,
        "help": cmd_help,
    }
    
    if not args.command:
        cmd_help(args)
    elif args.command in commands:
        commands[args.command](args)
    else:
        print(f"Unknown command: {args.command}")
        cmd_help(args)


if __name__ == "__main__":
    main()

