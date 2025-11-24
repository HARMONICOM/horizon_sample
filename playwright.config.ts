import { defineConfig, devices } from '@playwright/test'

/**
 * Playwright設定ファイル
 * E2Eテストの実行環境を定義
 */
export default defineConfig({
    // 各テストの実行前後のフック
    fullyParallel: true,

    // テスト対象のブラウザー
    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },
        {
            name: 'firefox',
            use: { ...devices['Desktop Firefox'] },
        },
        {
            name: 'webkit',
            use: { ...devices['Desktop Safari'] },
        },
    ],

    // レポーター設定
    reporter: [
        ['list'],
    ],

    // CIでのリトライ設定
    retries: process.env.CI ? 2 : 0,

    // テストディレクトリ
    testDir: './tests/e2e',

    // テストのタイムアウト（30秒）
    timeout: 10000,

    // 共通設定
    use: {
        // ベースURL
        baseURL: 'http://localhost:5000',

        // スクリーンショット設定（失敗時のみ）
        screenshot: 'only-on-failure',

        // トレース設定（失敗時のみ記録）
        trace: 'on-first-retry',

        // ビデオ設定（失敗時のみ）
        video: 'retain-on-failure',
    },

    // 並列実行数
    workers: process.env.CI ? 1 : undefined,
})

