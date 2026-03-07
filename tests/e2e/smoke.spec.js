/**
 * Smoke Tests for E2E Testing
 *
 * These tests verify basic functionality that should always work.
 * Run with: ./scripts/test_e2e.sh --smoke
 */

const { chromium } = require('playwright');

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

describe('Smoke Tests', () => {
  let browser;
  let page;

  beforeAll(async () => {
    browser = await chromium.launch({ headless: true });
    page = await browser.newPage();
  });

  afterAll(async () => {
    await browser.close();
  });

  test('Server responds with 200', async () => {
    const response = await page.goto(BASE_URL);
    expect(response.status()).toBe(200);
  });

  test('Page has a title', async () => {
    await page.goto(BASE_URL);
    const title = await page.title();
    expect(title).toBeTruthy();
    expect(title.length).toBeGreaterThan(0);
  });

  test('No JavaScript console errors', async () => {
    const errors = [];

    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');

    // Filter out known non-critical errors
    const criticalErrors = errors.filter(
      (e) => !e.includes('favicon') && !e.includes('manifest')
    );

    expect(criticalErrors).toHaveLength(0);
  });

  test('Page is responsive', async () => {
    // Desktop
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto(BASE_URL);
    const desktopWidth = await page.evaluate(() => document.body.scrollWidth);
    expect(desktopWidth).toBeLessThanOrEqual(1920);

    // Mobile
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto(BASE_URL);
    const mobileWidth = await page.evaluate(() => document.body.scrollWidth);
    expect(mobileWidth).toBeLessThanOrEqual(375);
  });
});