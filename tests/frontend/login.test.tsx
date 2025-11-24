/** @jsxImportSource react */

import { afterEach, describe, expect, it } from 'bun:test'

import { Login } from '../../frontend/admin/login'

import { cleanup, renderWithRouter } from './testUtils'

describe('Login Component', () => {
    afterEach(() => {
        cleanup()
    })

    it('should render login form correctly', () => {
        const { container } = renderWithRouter(<Login />)

        const heading = container.querySelector('h1')
        expect(heading?.textContent).toBe('Admin Login')

        const loginIdInput = container.querySelector('input[name="login_id"]')
        expect(loginIdInput).not.toBeNull()
        expect(loginIdInput?.getAttribute('type')).toBe('text')

        const passwordInput = container.querySelector('input[name="password"]')
        expect(passwordInput).not.toBeNull()
        expect(passwordInput?.getAttribute('type')).toBe('password')

        const submitButton = container.querySelector('button[type="submit"]')
        expect(submitButton).not.toBeNull()
        expect(submitButton?.textContent).toBe('Login')
    })

    it('should display error message when error prop is provided', () => {
        const errorMessage = 'Invalid credentials'
        const { container } = renderWithRouter(<Login error={errorMessage} />)

        const errorDiv = container.querySelector('.bg-red-50')
        expect(errorDiv).not.toBeNull()
        expect(errorDiv?.textContent).toContain(errorMessage)
    })

    it('should display success message when success prop is provided', () => {
        const successMessage = 'Login successful'
        const { container } = renderWithRouter(<Login success={successMessage} />)

        const successDiv = container.querySelector('.bg-green-50')
        expect(successDiv).not.toBeNull()
        expect(successDiv?.textContent).toContain(successMessage)
    })

    it('should not display error or success messages when props are not provided', () => {
        const { container } = renderWithRouter(<Login />)

        const errorDiv = container.querySelector('.bg-red-50')
        const successDiv = container.querySelector('.bg-green-50')
        expect(errorDiv).toBeNull()
        expect(successDiv).toBeNull()
    })

    it('should have form with correct action and method', () => {
        const { container } = renderWithRouter(<Login />)

        const form = container.querySelector('form')
        expect(form).not.toBeNull()
        expect(form?.getAttribute('action')).toBe('/admin')
        expect(form?.getAttribute('method')).toBe('POST')
    })

    it('should have change password link', () => {
        const { container } = renderWithRouter(<Login />)

        const link = container.querySelector('a[href="/admin/change-password"]')
        expect(link).not.toBeNull()
        expect(link?.textContent).toContain('Change Password')
    })
})

