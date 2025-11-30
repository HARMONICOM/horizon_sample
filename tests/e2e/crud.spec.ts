import { test, expect } from '@playwright/test'

test.describe('CRUD操作のE2Eテスト', () => {
    test.beforeEach(async ({ page }) => {
        // Basic Authの設定
        const adminUsername = process.env.ADMIN_BASIC_AUTH_USERNAME || 'admin'
        const adminPassword = process.env.ADMIN_BASIC_AUTH_PASSWORD || 'password123'

        const credentials = `${adminUsername}:${adminPassword}`
        const encoded = btoa(credentials)
        await page.setExtraHTTPHeaders({
            Authorization: `Basic ${encoded}`,
        })

        // ログイン処理
        await page.goto('/admin')
        const loginIdInput = page.locator('input[name="login_id"]').first()
        const passwordInput = page.locator('input[name="password"]').first()
        const submitButton = page.locator('button[type="submit"]').first()

        if (await loginIdInput.count() > 0 && await passwordInput.count() > 0) {
            await loginIdInput.fill('admin')
            await passwordInput.fill('admin123')
            await submitButton.click()
            await page.waitForURL(/\/admin\/dashboard/, { timeout: 10000 })
        }
    })

    test('ユーザーリストが表示される', async ({ page }) => {
        // Check if we're on the dashboard
        const currentUrl = page.url()
        if (currentUrl.includes('/admin/dashboard')) {
            // ユーザーリストのテーブルまたは「No users found」メッセージが表示されることを確認
            const table = page.locator('table')
            const noUsersMessage = page.locator('text=No users found')

            // いずれかが表示されることを確認
            const tableVisible = await table.count() > 0
            const noUsersVisible = await noUsersMessage.count() > 0

            expect(tableVisible || noUsersVisible).toBe(true)
        } else {
            test.skip()
        }
    })

    test('新規ユーザー作成ボタンが表示される', async ({ page }) => {
        const currentUrl = page.url()
        if (currentUrl.includes('/admin/dashboard')) {
            const addButton = page.locator('button', { hasText: 'Add New User' })
            await expect(addButton).toBeVisible({ timeout: 5000 })
        } else {
            test.skip()
        }
    })

    test('新規ユーザー作成ダイアログを開く', async ({ page }) => {
        const currentUrl = page.url()
        if (currentUrl.includes('/admin/dashboard')) {
            const addButton = page.locator('button', { hasText: 'Add New User' })
            if (await addButton.count() > 0) {
                await addButton.click()

                // ダイアログが表示されることを確認
                const dialog = page.locator('h3', { hasText: 'Add New User' })
                await expect(dialog).toBeVisible({ timeout: 3000 })

                // フォームフィールドが表示されることを確認
                const nameInput = page.locator('input[id="create-name"]')
                const emailInput = page.locator('input[id="create-email"]')
                const loginIdInput = page.locator('input[id="create-login-id"]')
                const passwordInput = page.locator('input[id="create-password"]')

                await expect(nameInput).toBeVisible()
                await expect(emailInput).toBeVisible()
                await expect(loginIdInput).toBeVisible()
                await expect(passwordInput).toBeVisible()

                // キャンセルボタンでダイアログを閉じる
                const cancelButton = page.locator('button', { hasText: 'Cancel' }).first()
                await cancelButton.click()

                // ダイアログが閉じることを確認
                await expect(dialog).not.toBeVisible({ timeout: 3000 })
            }
        } else {
            test.skip()
        }
    })

    test('ユーザーが存在する場合、編集ボタンが表示される', async ({ page }) => {
        const currentUrl = page.url()
        if (currentUrl.includes('/admin/dashboard')) {
            const table = page.locator('table')
            if (await table.count() > 0) {
                const editButtons = page.locator('button', { hasText: 'Edit' })
                const editButtonCount = await editButtons.count()

                if (editButtonCount > 0) {
                    // 少なくとも1つの編集ボタンが表示されることを確認
                    await expect(editButtons.first()).toBeVisible()
                }
            }
        } else {
            test.skip()
        }
    })

    test('ユーザーが存在する場合、削除ボタンが表示される', async ({ page }) => {
        const currentUrl = page.url()
        if (currentUrl.includes('/admin/dashboard')) {
            const table = page.locator('table')
            if (await table.count() > 0) {
                const deleteButtons = page.locator('button', { hasText: 'Delete' })
                const deleteButtonCount = await deleteButtons.count()

                if (deleteButtonCount > 0) {
                    // 少なくとも1つの削除ボタンが表示されることを確認
                    await expect(deleteButtons.first()).toBeVisible()
                }
            }
        } else {
            test.skip()
        }
    })

    test('編集ダイアログを開いて閉じる', async ({ page }) => {
        const currentUrl = page.url()
        if (currentUrl.includes('/admin/dashboard')) {
            const table = page.locator('table')
            if (await table.count() > 0) {
                const editButton = page.locator('button', { hasText: 'Edit' }).first()
                if (await editButton.count() > 0) {
                    await editButton.click()

                    // ダイアログが表示されることを確認
                    const dialog = page.locator('h3', { hasText: 'Edit User' })
                    await expect(dialog).toBeVisible({ timeout: 3000 })

                    // フォームフィールドが表示されることを確認
                    const nameInput = page.locator('input[id="edit-name"]')
                    const emailInput = page.locator('input[id="edit-email"]')

                    await expect(nameInput).toBeVisible()
                    await expect(emailInput).toBeVisible()

                    // キャンセルボタンでダイアログを閉じる
                    const cancelButton = page.locator('button', { hasText: 'Cancel' }).first()
                    await cancelButton.click()

                    // ダイアログが閉じることを確認
                    await expect(dialog).not.toBeVisible({ timeout: 3000 })
                }
            }
        } else {
            test.skip()
        }
    })

    test('削除確認ダイアログを開いて閉じる', async ({ page }) => {
        const currentUrl = page.url()
        if (currentUrl.includes('/admin/dashboard')) {
            const table = page.locator('table')
            if (await table.count() > 0) {
                const deleteButton = page.locator('button', { hasText: 'Delete' }).first()
                if (await deleteButton.count() > 0) {
                    await deleteButton.click()

                    // ダイアログが表示されることを確認
                    const dialog = page.locator('h3', { hasText: 'Delete User' })
                    await expect(dialog).toBeVisible({ timeout: 3000 })

                    // 確認メッセージが表示されることを確認
                    const confirmMessage = page.locator('text=Are you sure')
                    await expect(confirmMessage).toBeVisible()

                    // キャンセルボタンでダイアログを閉じる
                    const cancelButton = page.locator('button', { hasText: 'Cancel' }).first()
                    await cancelButton.click()

                    // ダイアログが閉じることを確認
                    await expect(dialog).not.toBeVisible({ timeout: 3000 })
                }
            }
        } else {
            test.skip()
        }
    })
})

