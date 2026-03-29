# QA Process

This document defines the Quality Assurance workflow for the Product repository.

## Code Review Flow

All code changes follow a structured review process before merging:

```
Developer PR -> CI Pass -> Staff Engineer Review
                           |
                           v
                  [CI blocks merge]
                           |
                           v
                  [Approve -> QA Engineer]
                           |
                           v
                  [Manual smoke + functional review]
                           |
                           v
                  [Approve -> Release Engineer]
                           |
                           v
                  [Deploy to staging + verify]
```

### Branch Protection Rules

- Require CI pass before merge (lint, typecheck, test, build)
- Require Staff Engineer approval
- Require QA Engineer approval for feature changes
- No direct commits to main branch

## Review Checklist Template

Use this checklist for every PR review:

### QA Review Checklist

#### Automated Checks
- [ ] CI lint passed
- [ ] CI typecheck passed
- [ ] CI tests passed
- [ ] CI build passed

#### Functional Verification
- [ ] App starts locally (`pnpm dev`)
- [ ] Health endpoint responds (API at port 3001)
- [ ] No console errors in browser
- [ ] Basic user flow works

#### Code Quality
- [ ] No obvious bugs
- [ ] Error handling present where needed
- [ ] Logging adequate for debugging
- [ ] No security issues (no hardcoded secrets, proper input validation)

#### Sign-off
- QA Engineer: _______________
- Date: _______________
- Notes: _______________

## Sign-off Requirements

### Minimum Approvers

| Change Type | Required Approvers |
|-------------|-------------------|
| Bug fix | Staff Engineer + QA Engineer |
| Feature | Staff Engineer + QA Engineer + Release Engineer |
| Infrastructure | Staff Engineer + Release Engineer |
| Documentation | Staff Engineer |

### Sign-off Criteria

Before approving, verify:

1. **Automated Tests Pass**: All CI checks must pass
2. **Manual Verification**: App runs locally and basic flows work
3. **Code Quality**: No obvious bugs or security issues
4. **Documentation**: Updated if behavior changes

## Testing Requirements

### Test Coverage Minimums

| Component | Minimum Coverage | Critical Paths |
|-----------|------------------|----------------|
| API routes | 80% | Health, auth, CRUD operations |
| Web components | 60% | Shared UI, forms |
| Integration | 100% smoke | Full flow: DB-API-Web |

### Test Types

1. **Unit Tests** (vitest for API, vitest for Web)
   - Test individual functions and components
   - Run on every PR via CI

2. **E2E Smoke Tests** (Playwright)
   - Verify web page loads
   - Verify API connectivity
   - Verify basic user flow
   - Run before deployment

3. **Integration Tests**
   - Test database connectivity
   - Test API endpoints with real DB
   - Health check verification

### Running Tests

```bash
# Run all tests
pnpm test

# Run E2E smoke tests (requires Playwright browsers)
pnpm test:e2e

# Run smoke verification script
pnpm smoke
```

### Pre-Deployment Verification

Before any deployment:

1. Run full test suite: `pnpm test`
2. Run E2E smoke tests: `pnpm test:e2e`
3. Run smoke script: `pnpm smoke`
4. Manual verification on staging environment

## QA Engineer Responsibilities

The QA Engineer agent is responsible for:

1. **Code Review**: Review PRs for quality and functionality
2. **Manual Testing**: Verify features work as expected
3. **Regression Testing**: Ensure existing functionality not broken
4. **Bug Investigation**: Investigate and document reported issues
5. **Test Maintenance**: Keep test suite up-to-date

## Related Documents

- [YCG-17](/YCG/issues/YCG-17) - QA Process (parent issue)
- [Engineering Practices](/YCG/issues/YCG-4) - Engineering standards
- [Onboarding Project](/YCG/projects/onboarding) - Project context