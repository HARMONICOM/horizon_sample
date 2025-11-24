import { test, expect } from '@playwright/test'

test.describe('トップページ', () => {
    test('ページが正常に表示される', async ({ page }) => {
        await page.goto('/')

        // ページタイトルを確認
        await expect(page).toHaveTitle(/Welcome to the World of Zig!/)

        // メッセージが表示されていることを確認
        const message = page.locator('text=Welcome to the World of Zig!')
        await expect(message).toBeVisible()
    })

    test('ページのHTML構造が正しい', async ({ page }) => {
        await page.goto('/')

        // root要素が存在することを確認
        const root = page.locator('#root')
        await expect(root).toBeVisible()
    })
})

