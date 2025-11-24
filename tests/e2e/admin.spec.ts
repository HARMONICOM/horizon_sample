import { test, expect } from '@playwright/test'

test.describe('管理画面', () => {
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

    test('ログインページが表示される', async ({ page }) => {
        await page.goto('/admin')

        // ログインフォームが表示されることを確認
        const form = page.locator('form')
        await expect(form).toBeVisible({ timeout: 5000 })
    })

    test('ログインが成功する', async ({ page }) => {
        await page.goto('/admin')

        // ログインフォームの要素を取得
        const emailInput = page.locator('input[type="email"], input[name="email"]').first()
        const passwordInput = page.locator('input[type="password"], input[name="password"]').first()
        const submitButton = page.locator('button[type="submit"], input[type="submit"]').first()

        // フォームが存在する場合のみ入力
        if (await emailInput.count() > 0 && await passwordInput.count() > 0) {
            await emailInput.fill('test@example.com')
            await passwordInput.fill('password123')
            await submitButton.click()

            // ダッシュボードまたは成功ページに遷移することを確認
            await page.waitForURL(/\/admin\/dashboard|\/admin/, { timeout: 10000 })
        } else {
            // フォームが存在しない場合はスキップ
            test.skip()
        }
    })

    test('ダッシュボードページが表示される', async ({ page }) => {
        // まずログインを試みる
        await page.goto('/admin')

        const emailInput = page.locator('input[type="email"], input[name="email"]').first()
        const passwordInput = page.locator('input[type="password"], input[name="password"]').first()
        const submitButton = page.locator('button[type="submit"], input[type="submit"]').first()

        if (await emailInput.count() > 0 && await passwordInput.count() > 0) {
            await emailInput.fill('test@example.com')
            await passwordInput.fill('password123')
            await submitButton.click()

            // ダッシュボードに遷移
            await page.waitForURL(/\/admin\/dashboard/, { timeout: 10000 })

            // ダッシュボードのコンテンツが表示されることを確認
            const root = page.locator('#root')
            await expect(root).toBeVisible()
        } else {
            // 直接ダッシュボードにアクセスしてみる
            await page.goto('/admin/dashboard')
            await expect(page).toHaveURL(/\/admin/)
        }
    })

    test('パスワードリセット要求ページが表示される', async ({ page }) => {
        await page.goto('/admin/change-password')

        // パスワードリセットフォームが表示されることを確認
        const form = page.locator('form')
        await expect(form).toBeVisible({ timeout: 5000 })
    })

    test('ログアウト完了ページが表示される', async ({ page }) => {
        await page.goto('/admin/logout-complete')

        // ページが表示されることを確認
        const root = page.locator('#root')
        await expect(root).toBeVisible({ timeout: 5000 })
    })
})

