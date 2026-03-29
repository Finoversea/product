# E2E Smoke Tests

This directory contains Playwright E2E smoke tests for the Product web application.

## Test Coverage

The smoke tests verify:

1. **Web Page Loads**
   - Homepage loads successfully
   - Page renders without console errors
   - Homepage has correct structure

2. **API Connectivity**
   - API health endpoint responds (`/health`)
   - API info endpoint responds (`/api`)
   - Web can reach API docs link

3. **Basic User Flow**
   - User can view homepage and click links
   - Page responsive layout works
   - Page styling loads correctly

## Prerequisites

- Node.js 20+
- pnpm 8+
- API server running on port 3001 (or set `API_URL` env var)
- Web server running on port 3000 (auto-started by Playwright config)

## Installation

```bash
pnpm install
npx playwright install chromium
```

## Running Tests

```bash
# Run all E2E tests
pnpm test:e2e

# Run with UI mode (interactive)
pnpm test:e2e:ui

# View test report
pnpm test:e2e:report
```

## Environment Variables

- `WEB_URL`: Base URL for web app (default: `http://localhost:3000`)
- `API_URL`: Base URL for API (default: `http://localhost:3001`)
- `CI`: Set to enable CI-specific behavior (retries, single worker)

## CI Integration

Tests are configured for CI:
- 2 retries on failure
- Single worker
- Web server auto-starts with `pnpm dev`

Note: API server must be started separately in CI before running tests.