#!/bin/bash
# =============================================================================
# Development Server Startup Script
# =============================================================================
# Starts the development server with proper configuration.
# Detects project type and starts the appropriate server.
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/dev-server.log"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create logs directory
mkdir -p "$PROJECT_ROOT/logs"

# Detect project type and start server
start_server() {
    cd "$PROJECT_ROOT"

    log_info "Detecting project type..."

    # Node.js / Next.js
    if [ -f "package.json" ]; then
        if grep -q "next" package.json 2>/dev/null; then
            log_info "Detected Next.js project"
            log_info "Starting Next.js development server..."
            npm run dev 2>&1 | tee "$LOG_FILE"
        elif grep -q "react-scripts" package.json 2>/dev/null; then
            log_info "Detected Create React App project"
            npm start 2>&1 | tee "$LOG_FILE"
        elif grep -q "vite" package.json 2>/dev/null; then
            log_info "Detected Vite project"
            npm run dev 2>&1 | tee "$LOG_FILE"
        elif grep -q '"dev"' package.json 2>/dev/null; then
            log_info "Detected Node.js project with dev script"
            npm run dev 2>&1 | tee "$LOG_FILE"
        else
            log_info "Detected Node.js project"
            node . 2>&1 | tee "$LOG_FILE"
        fi

    # Python / Django
    elif [ -f "manage.py" ]; then
        log_info "Detected Django project"
        python manage.py runserver 2>&1 | tee "$LOG_FILE"

    # Python / Flask
    elif [ -f "app.py" ] || [ -f "main.py" ]; then
        log_info "Detected Flask/FastAPI project"
        python app.py 2>&1 | tee "$LOG_FILE" || python main.py 2>&1 | tee "$LOG_FILE"

    # Go
    elif [ -f "main.go" ]; then
        log_info "Detected Go project"
        go run main.go 2>&1 | tee "$LOG_FILE"

    # Rust
    elif [ -f "Cargo.toml" ]; then
        log_info "Detected Rust project"
        cargo run 2>&1 | tee "$LOG_FILE"

    # Ruby on Rails
    elif [ -f "Gemfile" ] && [ -f "config/application.rb" ]; then
        log_info "Detected Rails project"
        bundle exec rails server 2>&1 | tee "$LOG_FILE"

    else
        log_error "Could not detect project type"
        log_info "Please create a custom start script or modify this script"
        exit 1
    fi
}

# Health check
health_check() {
    local port=${1:-3000}
    local max_retries=30
    local retry=0

    log_info "Waiting for server to be ready on port $port..."

    while [ $retry -lt $max_retries ]; do
        if curl -s "http://localhost:$port/health" > /dev/null 2>&1 || \
           curl -s "http://localhost:$port" > /dev/null 2>&1; then
            log_success "Server is ready!"
            echo ""
            echo "  Local:   http://localhost:$port"
            echo "  Logs:    $LOG_FILE"
            echo ""
            return 0
        fi
        sleep 1
        ((retry++))
    done

    log_error "Server failed to start within 30 seconds"
    return 1
}

# Main
main() {
    echo ""
    echo "=========================================="
    echo "  Starting Development Server"
    echo "=========================================="
    echo ""

    # Source .env if it exists
    if [ -f "$PROJECT_ROOT/.env" ]; then
        log_info "Loading environment from .env"
        export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
    fi

    start_server
}

main "$@"