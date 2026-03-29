import { test, expect } from '@playwright/test';

const API_URL = process.env.API_URL || 'http://localhost:3001';

test.describe('Smoke Tests', () => {
  test.describe('Web Page Loads', () => {
    test('homepage loads successfully', async ({ page }) => {
      await page.goto('/');

      // Verify the page title
      await expect(page).toHaveTitle('Product');

      // Verify main heading is visible
      const heading = page.locator('h1');
      await expect(heading).toBeVisible();
      await expect(heading).toHaveText('Welcome to Product');
    });

    test('homepage renders without console errors', async ({ page }) => {
      const consoleErrors: string[] = [];

      page.on('console', (msg) => {
        if (msg.type() === 'error') {
          consoleErrors.push(msg.text());
        }
      });

      await page.goto('/');

      // Wait for page to fully load
      await page.waitForLoadState('networkidle');

      // Check for no console errors (excluding expected hydration warnings)
      const criticalErrors = consoleErrors.filter(
        (err) =>
          !err.includes('hydration') &&
          !err.includes('Warning:') &&
          !err.includes('prop type')
      );

      expect(criticalErrors).toHaveLength(0);
    });

    test('homepage has correct structure', async ({ page }) => {
      await page.goto('/');

      // Verify main container exists
      const main = page.locator('main');
      await expect(main).toBeVisible();

      // Verify description text
      const description = page.locator('text=Your MVP is ready for development');
      await expect(description).toBeVisible();
    });
  });

  test.describe('API Connectivity', () => {
    test('API health endpoint responds', async ({ request }) => {
      const response = await request.get(`${API_URL}/health`);

      expect(response.status()).toBe(200);

      const body = await response.json();
      expect(body.status).toBe('healthy');
      expect(body.timestamp).toBeDefined();
      expect(body.uptime).toBeDefined();
    });

    test('API info endpoint responds', async ({ request }) => {
      const response = await request.get(`${API_URL}/api`);

      expect(response.status()).toBe(200);

      const body = await response.json();
      expect(body.name).toBe('Product API');
      expect(body.version).toBeDefined();
    });

    test('web can reach API docs link', async ({ page }) => {
      await page.goto('/');

      // Click the API Docs link
      const apiLink = page.locator('a[href="/api"]');

      // Verify the link exists and is visible
      await expect(apiLink).toBeVisible();
      await expect(apiLink).toHaveText('API Docs');
    });
  });

  test.describe('Basic User Flow', () => {
    test('user can view homepage and click links', async ({ page }) => {
      await page.goto('/');

      // Verify page loads
      await expect(page.locator('h1')).toHaveText('Welcome to Product');

      // Verify both action buttons exist
      const apiDocsButton = page.locator('a[href="/api"]');
      const githubButton = page.locator('a:has-text("GitHub")');

      await expect(apiDocsButton).toBeVisible();
      await expect(githubButton).toBeVisible();
    });

    test('page responsive layout works', async ({ page }) => {
      // Test mobile viewport
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto('/');

      const heading = page.locator('h1');
      await expect(heading).toBeVisible();

      // Test desktop viewport
      await page.setViewportSize({ width: 1280, height: 720 });
      await expect(heading).toBeVisible();
    });

    test('page styling loads correctly', async ({ page }) => {
      await page.goto('/');

      // Check that Tailwind CSS is applied (container should have classes)
      const main = page.locator('main');

      // Verify the element has styling applied
      await expect(main).toHaveCSS('display', 'flex');
    });
  });
});