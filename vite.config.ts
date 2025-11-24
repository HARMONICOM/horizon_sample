import * as path from 'path'

import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

export default defineConfig({
    build: {
        cssCodeSplit: true,
        emptyOutDir: true,
        outDir: './public',
        rollupOptions: {
            input: {
                admin: './frontend/admin/routes.tsx',
                index: './frontend/routes.tsx',
            },
            output: {
                assetFileNames: (assetInfo) => {
                    if (assetInfo.names[0]?.match(/^(admin|index)/)
                      || assetInfo.originalFileNames[0]?.match(/^(admin|index)/)
                    ){
                        switch (assetInfo.names[0]) {
                            case 'admin.css':
                                return 'admin.css'
                            case 'index.css':
                                return 'index.css'
                        }
                    }
                    return assetInfo.originalFileNames[0] ?? '[name].[ext]'
                },
                entryFileNames: '[name].js',
                manualChunks: {
                    'mui': ['@mui/material'],
                    'mui-x-date-pickers': ['@mui/x-date-pickers'],
                    'react': ['react', 'react-dom/client'],
                    'react-hook-form': ['react-hook-form'],
                    'react-router': ['react-router', 'react-router-dom'],
                },
            },
        },
    },
    plugins: [tailwindcss(), react()],
    publicDir: './static',
    resolve: {
        alias: {
            '@': path.resolve(__dirname, 'frontend'),
        },
    },
})
