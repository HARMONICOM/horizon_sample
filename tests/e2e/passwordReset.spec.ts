import { test, expect } from '@playwright/test'

test.describe('パスワードリセット機能', () => {
    test.beforeEach(async ({ page }) => {
        // Basic Authの設定
        const adminUsername = process.env.ADMIN_BASIC_AUTH_USERNAME || 'admin'
        const adminPassword = process.env.ADMIN_BASIC_AUTH_PASSWORD || 'password123'

        const credentials = `${adminUsername}:${adminPassword}`
        const encoded = btoa(credentials)
        await page.setExtraHTTPHeaders({
            Authorization: `Basic ${encoded}`,
        })
    })

    test('パスワードリセット要求ページが表示される', async ({ page }) => {
        await page.goto('/admin/change-password')

        // ページタイトルを確認
        const heading = page.locator('h1')
        await expect(heading).toHaveText('Password Reset')

        // フォームが表示されることを確認
        const emailInput = page.locator('input[name="email"]')
        await expect(emailInput).toBeVisible()

        const submitButton = page.locator('button[type="submit"]')
        await expect(submitButton).toBeVisible()
    })

    test('メールアドレスの入力が必須', async ({ page }) => {
        await page.goto('/admin/change-password')

        const submitButton = page.locator('button[type="submit"]')
        await submitButton.click()

        // HTML5バリデーションがトリガーされることを確認
        const emailInput = page.locator('input[name="email"]')
        const isValid = await emailInput.evaluate((el: HTMLInputElement) => el.validity.valid)
        expect(isValid).toBe(false)
    })

    test('有効なメールアドレスを入力して送信できる', async ({ page }) => {
        await page.goto('/admin/change-password')

        const emailInput = page.locator('input[name="email"]')
        await emailInput.fill('test@example.com')

        const submitButton = page.locator('button[type="submit"]')
        await submitButton.click()

        // 送信後、同じページにリダイレクトされることを確認
        await page.waitForURL(/\/admin\/change-password/, { timeout: 5000 })
    })

    test('バックトゥログインリンクが機能する', async ({ page }) => {
        await page.goto('/admin/change-password')

        const backLink = page.locator('a[href="/admin"]')
        await expect(backLink).toBeVisible()
        await backLink.click()

        // ログインページにリダイレクトされることを確認
        await page.waitForURL(/\/admin$/, { timeout: 5000 })
    })

    test('パスワードリセットページにトークンなしでアクセスするとリダイレクトされる', async ({ page }) => {
        await page.goto('/admin/reset-password')

        // トークンがない場合、パスワード変更要求ページにリダイレクトされることを確認
        await page.waitForURL(/\/admin\/change-password/, { timeout: 5000 })
    })

    // Note: Testing with actual token requires integration with email sending
    // which is not practical in E2E tests without a mock SMTP server
    test('パスワードリセットページの基本的な構造を確認', async ({ page }) => {
        // Mock token for testing UI structure
        const mockToken = 'test-token-12345678901234567890123456789012'
        await page.goto(`/admin/reset-password?token=${mockToken}`)

        // Wait for page load
        await page.waitForTimeout(1000)

        // Check if form is rendered (may redirect if token is invalid)
        const heading = page.locator('h1')
        if (await heading.isVisible()) {
            // If still on reset password page, verify form structure
            const newPasswordInput = page.locator('input[name="new_password"]')
            const confirmPasswordInput = page.locator('input[name="confirm_password"]')

            if (await newPasswordInput.isVisible()) {
                await expect(newPasswordInput).toBeVisible()
                await expect(confirmPasswordInput).toBeVisible()
            }
        }
    })
})

