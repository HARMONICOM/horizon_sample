import * as path from 'path'

import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    emptyOutDir: true,
    outDir: './public',
    rollupOptions: {
      input: {
        index: './frontend/routes.tsx',
      },
      output: {
        entryFileNames: '[name].js',
        manualChunks: {
          'date-fns': ['date-fns'],
          'mui': ['@mui/material'],
          'mui-x-date-pickers': ['@mui/x-date-pickers'],
          'react': ['react', 'react-dom/client'],
          'react-hook-form': ['react-hook-form'],
          'react-router': ['react-router', 'react-router-dom'],
          'react-syntax-highlighter': [
            'react-syntax-highlighter',
            'react-syntax-highlighter/dist/esm/languages/prism/json',
          ],
          'react-syntax-highlighter-style': [
            'react-syntax-highlighter/dist/esm/styles/prism/prism',
            'react-syntax-highlighter/dist/esm/styles/prism/night-owl',
          ],
          'zod': ['zod', '@hookform/resolvers/zod'],
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
