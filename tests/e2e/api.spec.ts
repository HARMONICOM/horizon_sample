import { test, expect } from '@playwright/test'

test.describe('APIルート', () => {
    test('GET /api が正常にレスポンスを返す', async ({ request }) => {
        const response = await request.get('/api')

        // ステータスコードが200であることを確認
        expect(response.status()).toBe(200)

        // JSONレスポンスを確認
        const json = await response.json()
        expect(json).toHaveProperty('message')
        expect(json.message).toBe('Hello, World!')
    })

    test('CORSヘッダーが設定されている', async ({ request }) => {
        const response = await request.get('/api')

        // CORSヘッダーの確認
        const headers = response.headers()
        expect(headers['access-control-allow-origin']).toBeTruthy()
    })

    test('OPTIONSリクエストが正常に処理される', async ({ request }) => {
        const response = await request.fetch('/api', {
            method: 'OPTIONS',
        })

        // OPTIONSリクエストが正常に処理されることを確認（CORSミドルウェアは204を返す）
        expect(response.status()).toBe(204)
    })
})

