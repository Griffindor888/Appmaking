import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { chromium } from 'playwright';

const baseURL = process.env.CSA_TEST_BASE_URL || 'http://127.0.0.1:4173';
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
const browserErrors = [];

page.on('pageerror', error => browserErrors.push(error.message));
await mkdir('artifacts', { recursive: true });

try {
  await page.goto(`${baseURL}/`, { waitUntil: 'networkidle' });
  assert.equal(await page.locator('.menu').isVisible(), true, 'mobile menu button must be visible');
  assert.equal(await page.locator('.menu').getAttribute('aria-expanded'), 'false');

  await page.locator('.menu').click();
  assert.equal(await page.locator('.menu').getAttribute('aria-expanded'), 'true');
  assert.equal(await page.locator('.navlinks').isVisible(), true, 'opened navigation must be visible');
  assert.equal(await page.locator('.navlinks a').count(), 7, 'all primary navigation links must remain available');
  await page.screenshot({ path: 'artifacts/csa-home-mobile-menu.png', fullPage: true });

  await page.keyboard.press('Escape');
  assert.equal(await page.locator('.menu').getAttribute('aria-expanded'), 'false');
  assert.equal(
    await page.locator('.menu').evaluate(element => element === document.activeElement),
    true,
    'Escape must restore menu focus',
  );

  await page.goto(`${baseURL}/start/`, { waitUntil: 'networkidle' });
  assert.equal(await page.locator('.choice').count(), 4, 'commercial selector must expose four systems');
  assert.equal(await page.locator('.choice .button.primary').count(), 4, 'each system needs one primary action');

  const hrefs = await page.locator('.choice .button.primary').evaluateAll(links => links.map(link => link.getAttribute('href')));
  assert.equal(hrefs.every(href => href?.startsWith('mailto:info@cs-agency.com.au?subject=')), true, 'each primary action must open a structured CSA enquiry');

  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
  assert.ok(overflow <= 1, `390px selector must not overflow horizontally; overflow=${overflow}px`);
  assert.deepEqual(browserErrors, [], `browser errors: ${browserErrors.join('; ')}`);
  await page.screenshot({ path: 'artifacts/csa-start-mobile.png', fullPage: true });
} finally {
  await browser.close();
}
