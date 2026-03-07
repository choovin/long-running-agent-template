/**
 * Example E2E Test Template
 *
 * Copy this file and rename it to match your feature ID (e.g., f004.spec.js)
 * Update the test steps to match your feature requirements.
 *
 * Feature: F00X - [Feature Description]
 */

const { chromium } = require('playwright');

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

describe('Feature F00X: [Feature Name]', () => {
  let browser;
  let page;

  beforeAll(async () => {
    browser = await chromium.launch({
      headless: process.env.HEADLESS === 'true',
      slowMo: 100,
    });
    page = await browser.newPage();
  });

  afterAll(async () => {
    await browser.close();
  });

  test('Prerequisite: Server is running', async () => {
    const response = await page.goto(BASE_URL);
    expect(response.status()).toBe(200);
  });

  test('Step 1: [First test step]', async () => {
    await page.goto(BASE_URL);

    // Example: Navigate to a page
    // await page.click('text=Login');

    // Example: Check something is visible
    // await expect(page.locator('.login-form')).toBeVisible();
  });

  test('Step 2: [Second test step]', async () => {
    // Example: Fill a form
    // await page.fill('[name="email"]', 'test@example.com');
    // await page.fill('[name="password"]', 'password123');

    // Example: Submit
    // await page.click('button[type="submit"]');
  });

  test('Step 3: [Verify result]', async () => {
    // Example: Wait for redirect
    // await page.waitForURL('**/dashboard');

    // Example: Check element exists
    // await expect(page.locator('.welcome-message')).toBeVisible();

    // Take screenshot for documentation
    await page.screenshot({
      path: `/tmp/f00x-result-${Date.now()}.png`,
    });
  });

  test('Error handling: [Invalid input shows error]', async () => {
    // Example: Test error case
    // await page.goto(`${BASE_URL}/login`);
    // await page.fill('[name="email"]', 'invalid-email');
    // await page.click('button[type="submit"]');

    // Example: Check error message
    // await expect(page.locator('.error-message')).toBeVisible();
  });
});