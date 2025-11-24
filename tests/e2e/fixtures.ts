import { test as base, type Page } from '@playwright/test'

/**
 * Test fixtures for E2E tests
 */

export interface TestFixtures {
    authenticatedPage: Page
}

/**
 * Fixture for authenticated admin user
 */
export const test = base.extend<TestFixtures>({
    authenticatedPage: async ({ page }, use) => {
        // Navigate to admin login page
        await page.goto('/admin')

        // Fill in Basic Auth credentials
        // Note: Basic Auth is handled by browser prompt, so we need to set it via context
        const adminUsername = process.env.ADMIN_BASIC_AUTH_USERNAME || 'admin'
        const adminPassword = process.env.ADMIN_BASIC_AUTH_PASSWORD || 'password123'

        // Set Basic Auth header
        const credentials = `${adminUsername}:${adminPassword}`
        const encoded = btoa(credentials)
        await page.setExtraHTTPHeaders({
            Authorization: `Basic ${encoded}`,
        })

        // Navigate to login page again with auth
        await page.goto('/admin')

        // Wait for login form to be visible
        await page.waitForSelector('form', { timeout: 5000 })

        // Fill login form (assuming email/password fields exist)
        const emailInput = page.locator('input[type="email"], input[name="email"]').first()
        const passwordInput = page.locator('input[type="password"], input[name="password"]').first()
        const submitButton = page.locator('button[type="submit"], input[type="submit"]').first()

        if (await emailInput.count() > 0) {
            await emailInput.fill('test@example.com')
        }
        if (await passwordInput.count() > 0) {
            await passwordInput.fill('password123')
        }
        if (await submitButton.count() > 0) {
            await submitButton.click()
        }

        // Wait for navigation to dashboard or successful login
        await page.waitForURL(/\/admin\/dashboard|\/admin/, { timeout: 10000 })

        await use(page)
    },
})

export { expect } from '@playwright/test'

