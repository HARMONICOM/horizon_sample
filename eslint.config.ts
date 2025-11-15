import js from '@eslint/js'
import json from '@eslint/json'
import stylistic from '@stylistic/eslint-plugin'
import typescriptEslintParser  from '@typescript-eslint/parser'
import jsonc from 'eslint-plugin-jsonc'
import jsxA11y from 'eslint-plugin-jsx-a11y'
import perfectionist from 'eslint-plugin-perfectionist'
import react from 'eslint-plugin-react'
import reactHooks from 'eslint-plugin-react-hooks'
import globals from 'globals'
import tseslint from 'typescript-eslint'

export default [
  {
    ignores: [
      'public/**/*',
      'app/db/drizzle/**/*',
    ],
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    plugins: {
      '@stylistic': stylistic,
      perfectionist,
    },
    rules: {
      '@stylistic/comma-dangle': ['error', 'always-multiline'],
      '@stylistic/comma-spacing': ['error', { 'after': true, 'before': false }],
      '@stylistic/indent': ['error', 4],
      '@stylistic/no-trailing-spaces': 'error',
      '@stylistic/quotes': ['error', 'single'],
      '@stylistic/semi': ['error', 'never'],
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
      '@typescript-eslint/no-empty-object-type': 'off',
      '@typescript-eslint/no-unused-expressions': [
        'error',
        {
          allowShortCircuit: true,
          allowTernary: true,
        },
      ],
      'no-control-regex': 'off',
      'no-multiple-empty-lines': ['error', { 'max': 2, 'maxBOF': 0, 'maxEOF': 1 }],
      'no-useless-catch': 'off',
      'perfectionist/sort-enums': [
        'error',
        {
          ignoreCase: false,
          order: 'asc',
          type: 'natural',
        },
      ],
      'perfectionist/sort-imports': [
        'error',
        {
          groups: [
            'side-effect',
            'builtin',
            'external',
            'internal',
            'parent',
            'sibling',
            'index',
            'object',
            'unknown',
            'type',
            'style',
          ],
          ignoreCase: false,
          newlinesBetween: 'always',
          order: 'asc',
          type: 'natural',
        },
      ],
      'perfectionist/sort-interfaces': [
        'error',
        {
          ignoreCase: false,
          order: 'asc',
          type: 'natural',
        },
      ],
      'perfectionist/sort-jsx-props': [
        'error',
        {
          ignoreCase: false,
          order: 'asc',
          type: 'natural',
        },
      ],
      'perfectionist/sort-object-types': [
        'error',
        {
          ignoreCase: false,
          order: 'asc',
          type: 'natural',
        },
      ],
      'perfectionist/sort-objects': [
        'error',
        {
          ignoreCase: false,
          order: 'asc',
          type: 'natural',
        },
      ],
    },
    settings: {
      'import/extensions': ['.ts', '.js', '.tsx', '.json'],
      'import/parsers': {
        '@typescript-eslint/parser': ['.ts', '.js', '.tsx', '.json'],
      },
      'import/resolver': {
        node: true,
        typescript: true,
      },
    },
  },
  {
    files: [
      '**/*.ts',
      '**/*.js',
    ],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },
      parser: typescriptEslintParser,
      parserOptions: {
        project: './tsconfig.json',
      },
    },
  },
  {
    files: ['**/*.tsx'],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
        project: './tsconfig.json',
      },
    },
    plugins: {
      'jsx-a11y': jsxA11y,
      react,
      'react-hooks': reactHooks,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      ...jsxA11y.configs.recommended.rules,
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-empty-interface': 'off',
      'react/jsx-uses-react': 'off',
      'react/prop-types': 'off',
      'react/react-in-jsx-scope': 'off',
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
  },
  {
    files: ['**/*.json'],
    plugins: {
      json,
      jsonc,
    },
    rules: {
      '@stylistic/comma-dangle': 'off',
      '@stylistic/comma-spacing': 'off',
      '@stylistic/indent': 'off',
      '@stylistic/quotes': ['error', 'double'],
      '@stylistic/semi': 'off',
      '@typescript-eslint/no-unused-expressions': 'off',
      'json/no-duplicate-keys': 'error',
      'jsonc/sort-keys': [
        'error',
        {
          order: {
            natural: true,
            type: 'asc',
          },
          pathPattern: '.*',
        },
      ],
    },
  },
]
