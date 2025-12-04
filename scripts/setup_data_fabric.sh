#!/bin/bash
# DSMIL Data Fabric Setup Script
#
# Sets up the fast data fabric infrastructure:
# - Redis Streams for event bus
# - tmpfs SQLite for hot-path state
# - Required directories and permissions
#
# Usage:
#   sudo ./setup_data_fabric.sh
#   sudo ./setup_data_fabric.sh --dry-run

set -euo pipefail

# Configuration
DSMIL_USER="${DSMIL_USER:-dsmil}"
DSMIL_GROUP="${DSMIL_GROUP:-dsmil}"
TMPFS_SIZE="${TMPFS_SIZE:-4G}"
TMPFS_PATH="/mnt/dsmil-ram"
LOG_DIR="/var/log/dsmil"
OPT_DIR="/opt/dsmil"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DRY_RUN=false

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] $*"
    else
        "$@"
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            print_warn "Running in dry-run mode"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check root
if [ "$EUID" -ne 0 ] && [ "$DRY_RUN" = false ]; then
    print_error "Please run as root (or use --dry-run)"
    exit 1
fi

echo "=============================================="
echo "DSMIL Data Fabric Setup"
echo "=============================================="
echo ""

# 1. Check/Create DSMIL user
print_step "Checking DSMIL user/group..."
if ! id "$DSMIL_USER" &>/dev/null; then
    print_warn "User $DSMIL_USER not found, creating..."
    run_cmd useradd -r -s /bin/false -m -d "$OPT_DIR" "$DSMIL_USER"
    print_success "Created user: $DSMIL_USER"
else
    print_success "User $DSMIL_USER exists"
fi

# 2. Install Redis
print_step "Checking Redis installation..."
if ! command -v redis-server &>/dev/null; then
    print_warn "Redis not found, installing..."
    run_cmd apt-get update
    run_cmd apt-get install -y redis-server
    print_success "Redis installed"
else
    print_success "Redis is installed"
fi

# 3. Configure Redis
print_step "Configuring Redis..."
REDIS_CONF="/etc/redis/redis.conf"
if [ -f "$REDIS_CONF" ]; then
    # Backup original
    if [ ! -f "${REDIS_CONF}.bak" ]; then
        run_cmd cp "$REDIS_CONF" "${REDIS_CONF}.bak"
    fi

    # Apply DSMIL optimizations
    if [ "$DRY_RUN" = false ]; then
        cat >> "$REDIS_CONF" << 'EOF'

# DSMIL Fast Data Fabric Configuration
maxmemory 4gb
maxmemory-policy allkeys-lru
save ""
appendonly yes
appendfsync everysec
# Stream-specific settings
stream-node-max-bytes 4096
stream-node-max-entries 100
EOF
        print_success "Redis configured for DSMIL"
    else
        echo "[DRY-RUN] Would configure Redis"
    fi
else
    print_warn "Redis config not found at $REDIS_CONF"
fi

# 4. Enable and start Redis
print_step "Starting Redis..."
run_cmd systemctl enable redis-server
run_cmd systemctl start redis-server || true
print_success "Redis enabled and started"

# 5. Create tmpfs mount
print_step "Setting up tmpfs mount at $TMPFS_PATH..."
run_cmd mkdir -p "$TMPFS_PATH"

# Check if already mounted
if mountpoint -q "$TMPFS_PATH" 2>/dev/null; then
    print_success "tmpfs already mounted at $TMPFS_PATH"
else
    # Mount tmpfs
    run_cmd mount -t tmpfs -o "size=$TMPFS_SIZE,mode=0770,uid=$DSMIL_USER,gid=$DSMIL_GROUP" tmpfs "$TMPFS_PATH"
    print_success "Mounted tmpfs at $TMPFS_PATH (size: $TMPFS_SIZE)"
fi

# 6. Add to fstab for persistence
print_step "Adding tmpfs to fstab..."
FSTAB_ENTRY="tmpfs $TMPFS_PATH tmpfs size=$TMPFS_SIZE,mode=0770,uid=$DSMIL_USER,gid=$DSMIL_GROUP 0 0"
if grep -q "$TMPFS_PATH" /etc/fstab 2>/dev/null; then
    print_success "fstab entry already exists"
else
    if [ "$DRY_RUN" = false ]; then
        echo "$FSTAB_ENTRY" >> /etc/fstab
        print_success "Added fstab entry for persistence"
    else
        echo "[DRY-RUN] Would add to fstab: $FSTAB_ENTRY"
    fi
fi

# 7. Create directories
print_step "Creating directories..."
run_cmd mkdir -p "$OPT_DIR"
run_cmd mkdir -p "$OPT_DIR/src"
run_cmd mkdir -p "$OPT_DIR/scripts"
run_cmd mkdir -p "$OPT_DIR/logs"
run_cmd mkdir -p "$LOG_DIR"

# Set permissions
run_cmd chown -R "$DSMIL_USER:$DSMIL_GROUP" "$OPT_DIR"
run_cmd chown -R "$DSMIL_USER:$DSMIL_GROUP" "$LOG_DIR"
run_cmd chown -R "$DSMIL_USER:$DSMIL_GROUP" "$TMPFS_PATH"
print_success "Directories created and permissions set"

# 8. Initialize hot-path database
print_step "Initializing hot-path database..."
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SQL_FILE="$SCRIPT_DIR/init_hotpath_db.sql"
DB_FILE="$TMPFS_PATH/hotpath.db"

if [ -f "$SQL_FILE" ]; then
    if [ "$DRY_RUN" = false ]; then
        sqlite3 "$DB_FILE" < "$SQL_FILE" 2>/dev/null || true
        chown "$DSMIL_USER:$DSMIL_GROUP" "$DB_FILE"
        print_success "Hot-path database initialized at $DB_FILE"
    else
        echo "[DRY-RUN] Would initialize database from $SQL_FILE"
    fi
else
    print_warn "SQL file not found: $SQL_FILE"
fi

# 9. Setup journald logging
print_step "Configuring journald for DSMIL..."
JOURNALD_CONF="/etc/systemd/journald.conf.d/dsmil.conf"
run_cmd mkdir -p "$(dirname "$JOURNALD_CONF")"
if [ "$DRY_RUN" = false ]; then
    cat > "$JOURNALD_CONF" << 'EOF'
# DSMIL journald configuration
[Journal]
Storage=persistent
Compress=yes
SystemMaxUse=2G
MaxRetentionSec=7day
EOF
    systemctl restart systemd-journald
    print_success "journald configured"
else
    echo "[DRY-RUN] Would configure journald at $JOURNALD_CONF"
fi

# 10. Create log aggregation (optional)
print_step "Setting up log aggregation..."
DSMIL_LOG="$LOG_DIR/dsmil.log"
if [ "$DRY_RUN" = false ]; then
    touch "$DSMIL_LOG"
    chown "$DSMIL_USER:$DSMIL_GROUP" "$DSMIL_LOG"

    # Create rsyslog rule for DSMIL
    cat > /etc/rsyslog.d/50-dsmil.conf << 'EOF'
# DSMIL log aggregation
:programname, startswith, "dsmil-" /var/log/dsmil/dsmil.log
& stop
EOF
    systemctl restart rsyslog 2>/dev/null || true
    print_success "Log aggregation configured"
else
    echo "[DRY-RUN] Would configure log aggregation"
fi

# 11. Verify Redis streams
print_step "Verifying Redis streams..."
if [ "$DRY_RUN" = false ]; then
    # Create initial streams with consumer groups
    redis-cli XGROUP CREATE L3_IN dsmil 0 MKSTREAM 2>/dev/null || true
    redis-cli XGROUP CREATE L3_OUT dsmil 0 MKSTREAM 2>/dev/null || true
    redis-cli XGROUP CREATE L4_IN dsmil 0 MKSTREAM 2>/dev/null || true
    redis-cli XGROUP CREATE L4_OUT dsmil 0 MKSTREAM 2>/dev/null || true
    redis-cli XGROUP CREATE SOC_EVENTS dsmil 0 MKSTREAM 2>/dev/null || true
    print_success "Redis streams initialized"
else
    echo "[DRY-RUN] Would create Redis streams"
fi

echo ""
echo "=============================================="
echo "DSMIL Data Fabric Setup Complete!"
echo "=============================================="
echo ""
echo "Summary:"
echo "  ✅ Redis server: running"
echo "  ✅ tmpfs mount: $TMPFS_PATH ($TMPFS_SIZE)"
echo "  ✅ Hot-path DB: $TMPFS_PATH/hotpath.db"
echo "  ✅ Log directory: $LOG_DIR"
echo ""
echo "Streams created:"
echo "  • L3_IN, L3_OUT (Layer 3 events)"
echo "  • L4_IN, L4_OUT (Layer 4 events)"
echo "  • SOC_EVENTS (SOC Router output)"
echo ""
echo "Next steps:"
echo "  1. Copy services: sudo cp systemd/*.service /etc/systemd/system/"
echo "  2. Reload systemd: sudo systemctl daemon-reload"
echo "  3. Start SOC Router: sudo systemctl start dsmil-soc-router"
echo ""

