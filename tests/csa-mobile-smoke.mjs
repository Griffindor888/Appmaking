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

  const pathways = await page.locator('.choice .button.primary').evaluateAll(
    links => links.map(link => link.getAttribute('data-pathway'))
  );
  assert.deepEqual(pathways, ['wardale', 'solurius', 'autto', 'csia']);

  let intakeRequests = 0;
  await page.route('**/rest/v1/rpc/submit_csa_commercial_enquiry', async route => {
    intakeRequests += 1;
    if (intakeRequests === 1) {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([{
          receipt_id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          pathway: 'solurius',
          status: 'new',
          correlation_id: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
        }]),
      });
      return;
    }
    await route.fulfill({ status: 503, contentType: 'application/json', body: '{}' });
  });

  await page.locator('[data-pathway="solurius"]').click();
  assert.equal(await page.locator('[name="pathway"]').inputValue(), 'solurius');
  await page.locator('[name="organisation"]').fill('Synthetic Organisation');
  await page.locator('[name="contact_name"]').fill('Synthetic Founder');
  await page.locator('[name="email"]').fill('synthetic@example.com');
  await page.locator('[name="timeframe"]').selectOption('immediate');
  await page.locator('[name="requirement"]').fill('Run a bounded workforce assurance pilot.');
  await page.locator('[name="consent"]').check();
  await page.locator('#csa-commercial-enquiry [type="submit"]').click();
  await page.locator('[data-form-status][data-state="success"]').waitFor();
  assert.match(await page.locator('[data-form-status]').textContent(), /aaaaaaaa-aaaa/);

  await page.locator('[name="pathway"]').selectOption('wardale');
  await page.locator('[name="organisation"]').fill('Synthetic Organisation');
  await page.locator('[name="contact_name"]').fill('Synthetic Founder');
  await page.locator('[name="email"]').fill('synthetic@example.com');
  await page.locator('[name="timeframe"]').selectOption('30_days');
  await page.locator('[name="requirement"]').fill('Assess governed AI deployment requirements.');
  await page.locator('[name="consent"]').check();
  await page.locator('#csa-commercial-enquiry [type="submit"]').click();
  await page.locator('[data-form-status][data-state="error"]').waitFor();
  assert.equal(await page.locator('[data-email-fallback]').isVisible(), true);
  assert.match(await page.locator('[data-form-status]').textContent(), /No false success/);

  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
  assert.ok(overflow <= 1, `390px selector must not overflow horizontally; overflow=${overflow}px`);
  await page.screenshot({ path: 'artifacts/csa-start-mobile.png', fullPage: true });

  const routes = [
    '/', '/accessibility/', '/company/', '/contact/', '/ecosystem/', '/engagement/',
    '/governance/', '/industries/', '/knowledge/', '/platforms/autto-connect/',
    '/platforms/csia/', '/platforms/solurius/', '/platforms/wardale/', '/privacy/',
    '/research/', '/security/', '/start/', '/technology/', '/terms/', '/trust/',
  ];

  for (const route of routes) {
    const response = await page.goto(`${baseURL}${route}`, { waitUntil: 'networkidle' });
    assert.equal(response?.status(), 200, `${route} must return 200`);
    assert.equal(await page.locator('main').count(), 1, `${route} must contain one main landmark`);
    const routeOverflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
    assert.ok(routeOverflow <= 1, `${route} must not overflow at 390px; overflow=${routeOverflow}px`);
  }

  assert.deepEqual(browserErrors, [], `browser errors: ${browserErrors.join('; ')}`);
} finally {
  await browser.close();
}
