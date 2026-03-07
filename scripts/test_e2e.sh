#!/bin/bash
# =============================================================================
# End-to-End Testing Script
# =============================================================================
# Runs end-to-end tests with browser automation (Playwright).
# Supports smoke tests, full tests, and specific feature tests.
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCREENSHOT_DIR="$PROJECT_ROOT/logs/screenshots"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create directories
mkdir -p "$SCREENSHOT_DIR"

# Default values
SMOKE_ONLY=false
FEATURE_ID=""
HEADLESS=false
BASE_URL="http://localhost:3000"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --smoke)
            SMOKE_ONLY=true
            shift
            ;;
        --feature)
            FEATURE_ID="$2"
            shift 2
            ;;
        --headless)
            HEADLESS=true
            shift
            ;;
        --url)
            BASE_URL="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--smoke] [--feature F00X] [--headless] [--url URL]"
            exit 1
            ;;
    esac
done

# =============================================================================
# Smoke Tests
# =============================================================================

run_smoke_tests() {
    log_info "Running smoke tests..."

    cd "$PROJECT_ROOT"

    # Check if server is running
    if ! curl -s "$BASE_URL" > /dev/null 2>&1; then
        log_error "Server is not running at $BASE_URL"
        log_info "Please run ./scripts/start_dev.sh first"
        exit 1
    fi

    log_success "Server is responding"

    # Run Playwright smoke tests if available
    if [ -f "playwright.config.js" ] || [ -f "playwright.config.ts" ]; then
        log_info "Running Playwright smoke tests..."
        npx playwright test --grep "@smoke" --reporter=list
    elif [ -f "tests/e2e/smoke.spec.js" ]; then
        log_info "Running custom smoke tests..."
        node tests/e2e/smoke.spec.js
    else
        log_warning "No smoke tests found. Running basic health check..."

        # Basic health check using curl
        local status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL")

        if [ "$status" = "200" ]; then
            log_success "Health check passed (HTTP $status)"
        else
            log_error "Health check failed (HTTP $status)"
            exit 1
        fi
    fi

    log_success "Smoke tests passed!"
}

# =============================================================================
# Feature-Specific Tests
# =============================================================================

run_feature_test() {
    local feature_id="$1"

    log_info "Running tests for feature $feature_id..."

    cd "$PROJECT_ROOT"

    # Find test file for feature
    local test_file=""

    if [ -f "tests/e2e/${feature_id,,}.spec.js" ]; then
        test_file="tests/e2e/${feature_id,,}.spec.js"
    elif [ -f "tests/e2e/${feature_id}.spec.js" ]; then
        test_file="tests/e2e/${feature_id}.spec.js"
    else
        log_error "No test file found for feature $feature_id"
        log_info "Expected: tests/e2e/${feature_id}.spec.js"
        exit 1
    fi

    log_info "Running test file: $test_file"

    if [ -f "playwright.config.js" ]; then
        npx playwright test "$test_file" --reporter=list
    else
        node "$test_file"
    fi
}

# =============================================================================
# Full Test Suite
# =============================================================================

run_full_tests() {
    log_info "Running full E2E test suite..."

    cd "$PROJECT_ROOT"

    if [ -f "playwright.config.js" ] || [ -f "playwright.config.ts" ]; then
        log_info "Running Playwright tests..."

        if [ "$HEADLESS" = true ]; then
            npx playwright test --reporter=list
        else
            npx playwright test --reporter=list --headed
        fi
    else
        log_warning "No Playwright configuration found"

        if [ -d "tests/e2e" ]; then
            log_info "Running all tests in tests/e2e..."

            for test_file in tests/e2e/*.spec.js; do
                if [ -f "$test_file" ]; then
                    log_info "Running: $test_file"
                    node "$test_file" || true
                fi
            done
        else
            log_error "No E2E tests found. Please create tests in tests/e2e/"
            exit 1
        fi
    fi

    log_success "E2E tests completed!"
}

# =============================================================================
# Generate Test Report
# =============================================================================

generate_report() {
    log_info "Generating test report..."

    cd "$PROJECT_ROOT"

    if [ -f "playwright-report/index.html" ]; then
        log_success "Report generated at: playwright-report/index.html"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo "=========================================="
    echo "  E2E Testing"
    echo "=========================================="
    echo ""

    # Source .env if it exists
    if [ -f "$PROJECT_ROOT/.env" ]; then
        export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
    fi

    if [ "$SMOKE_ONLY" = true ]; then
        run_smoke_tests
    elif [ -n "$FEATURE_ID" ]; then
        run_feature_test "$FEATURE_ID"
    else
        run_full_tests
    fi

    generate_report

    echo ""
    log_success "Testing complete!"
    echo ""
}

main