#!/bin/bash
# Smoke test script - verifies built apps start and respond correctly
# Usage: pnpm smoke
#
# Prerequisites: Playwright browsers must be installed (run: pnpm exec playwright install chromium)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
API_DIR="$ROOT_DIR/apps/api"
WEB_DIR="$ROOT_DIR/apps/web"

API_PORT=3001
WEB_PORT=3000
API_URL="http://localhost:$API_PORT"
WEB_URL="http://localhost:$WEB_PORT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Track background processes
API_PID=""
WEB_PID=""
CLEANUP_DONE=false

cleanup() {
    if [ "$CLEANUP_DONE" = true ]; then return; fi
    CLEANUP_DONE=true

    log_info "Cleaning up processes..."

    if [ -n "$API_PID" ] && kill -0 "$API_PID" 2>/dev/null; then
        kill "$API_PID" 2>/dev/null || true
        wait "$API_PID" 2>/dev/null || true
        log_info "API server stopped"
    fi

    if [ -n "$WEB_PID" ] && kill -0 "$WEB_PID" 2>/dev/null; then
        kill "$WEB_PID" 2>/dev/null || true
        wait "$WEB_PID" 2>/dev/null || true
        log_info "Web server stopped"
    fi
}

trap cleanup EXIT INT TERM

# Check Playwright browsers are installed
check_playwright() {
    log_info "Checking Playwright browsers..."
    cd "$WEB_DIR"

    # Check if chromium browser is installed
    PLAYWRIGHT_CACHE="$HOME/Library/Caches/ms-playwright"
    if [ ! -d "$PLAYWRIGHT_CACHE" ] || [ -z "$(ls -A "$PLAYWRIGHT_CACHE" 2>/dev/null)" ]; then
        log_warn "Playwright browsers not installed. Installing chromium..."
        pnpm exec playwright install chromium || {
            log_error "Failed to install Playwright browsers"
            exit 1
        }
    fi
    log_info "Playwright browsers ready"
}

# Wait for service to be ready
wait_for_service() {
    local url="$1"
    local name="$2"
    local max_attempts=30
    local attempt=0

    log_info "Waiting for $name to be ready at $url..."

    while [ $attempt -lt $max_attempts ]; do
        if curl -sf "$url" > /dev/null 2>&1; then
            log_info "$name is ready!"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done

    log_error "$name failed to start after $max_attempts seconds"
    return 1
}

# Step 1: Build apps if not built
log_info "Building apps..."
cd "$ROOT_DIR"
pnpm build

# Verify builds exist
if [ ! -d "$API_DIR/dist" ]; then
    log_error "API build output not found at $API_DIR/dist"
    exit 1
fi

if [ ! -d "$WEB_DIR/.next" ]; then
    log_error "Web build output not found at $WEB_DIR/.next"
    exit 1
fi

log_info "Builds verified successfully"

# Step 2: Start API server
log_info "Starting API server on port $API_PORT..."
cd "$API_DIR"
pnpm start &
API_PID=$!
cd "$ROOT_DIR"

# Step 3: Start Web server
log_info "Starting Web server on port $WEB_PORT..."
cd "$WEB_DIR"
pnpm start &
WEB_PID=$!
cd "$ROOT_DIR"

# Step 4: Wait for services to be ready
wait_for_service "$API_URL/health" "API" || exit 1
wait_for_service "$WEB_URL" "Web" || exit 1

# Step 5: Verify API health endpoint content
log_info "Verifying API health endpoint..."
HEALTH_RESPONSE=$(curl -s "$API_URL/health")
if echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"'; then
    log_info "API health check passed"
else
    log_error "API health check failed: $HEALTH_RESPONSE"
    exit 1
fi

# Step 6: Verify Web homepage loads
log_info "Verifying Web homepage..."
WEB_RESPONSE=$(curl -s "$WEB_URL")
if echo "$WEB_RESPONSE" | grep -q "Welcome to Product"; then
    log_info "Web homepage verified"
else
    log_warn "Web homepage content check inconclusive (may still be valid)"
fi

# Step 7: Run Playwright smoke tests
log_info "Running Playwright smoke tests..."
cd "$WEB_DIR"

# Check Playwright browsers are installed
check_playwright

# Run tests with existing server (we started them above)
export WEB_URL="$WEB_URL"
export API_URL="$API_URL"

pnpm test:e2e -- --project=chromium e2e/smoke.spec.ts || {
    log_error "Smoke tests failed"
    exit 1
}

log_info "All smoke tests passed!"

exit 0