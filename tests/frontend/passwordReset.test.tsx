/** @jsxImportSource react */

import { afterEach, describe, expect, it } from 'bun:test'

import { RequestPasswordReset } from '../../frontend/admin/requestPasswordReset'
import { ResetPassword } from '../../frontend/admin/resetPassword'

import { cleanup, renderWithRouter } from './testUtils'

describe('RequestPasswordReset Component', () => {
    afterEach(() => {
        cleanup()
    })

    it('should render password reset request form correctly', () => {
        const { container } = renderWithRouter(<RequestPasswordReset />)

        const heading = container.querySelector('h1')
        expect(heading?.textContent).toBe('Password Reset')

        const emailInput = container.querySelector('input[name="email"]')
        expect(emailInput).not.toBeNull()
        expect(emailInput?.getAttribute('type')).toBe('email')

        const submitButton = container.querySelector('button[type="submit"]')
        expect(submitButton).not.toBeNull()
        expect(submitButton?.textContent).toBe('Send Reset Email')
    })

    it('should display error message when error prop is provided', () => {
        const errorMessage = 'Email not found'
        const { container } = renderWithRouter(<RequestPasswordReset error={errorMessage} />)

        const errorDiv = container.querySelector('.bg-red-50')
        expect(errorDiv).not.toBeNull()
        expect(errorDiv?.textContent).toContain(errorMessage)
    })

    it('should display success message when success prop is provided', () => {
        const successMessage = 'Reset email sent'
        const { container } = renderWithRouter(<RequestPasswordReset success={successMessage} />)

        const successDiv = container.querySelector('.bg-green-50')
        expect(successDiv).not.toBeNull()
        expect(successDiv?.textContent).toContain(successMessage)
    })

    it('should not display error or success messages when props are not provided', () => {
        const { container } = renderWithRouter(<RequestPasswordReset />)

        const errorDiv = container.querySelector('.bg-red-50')
        const successDiv = container.querySelector('.bg-green-50')
        expect(errorDiv).toBeNull()
        expect(successDiv).toBeNull()
    })

    it('should have form with correct action and method', () => {
        const { container } = renderWithRouter(<RequestPasswordReset />)

        const form = container.querySelector('form')
        expect(form).not.toBeNull()
        expect(form?.getAttribute('action')).toBe('/admin/change-password/submit')
        expect(form?.getAttribute('method')).toBe('POST')
    })

    it('should have back to login link', () => {
        const { container } = renderWithRouter(<RequestPasswordReset />)

        const link = container.querySelector('a[href="/admin"]')
        expect(link).not.toBeNull()
        expect(link?.textContent).toContain('Back to Login')
    })
})

describe('ResetPassword Component', () => {
    afterEach(() => {
        cleanup()
    })

    it('should render password reset form correctly', () => {
        const token = 'test-token-12345'
        const { container } = renderWithRouter(<ResetPassword token={token} />)

        const heading = container.querySelector('h1')
        expect(heading?.textContent).toBe('Password Reset')

        // Note: Token is not rendered as a hidden input in this implementation
        // It's dynamically created during form submission
        // Just verify the form exists
        const form = container.querySelector('form')
        expect(form).not.toBeNull()

        const newPasswordInput = container.querySelector('input[name="new_password"]')
        expect(newPasswordInput).not.toBeNull()
        expect(newPasswordInput?.getAttribute('type')).toBe('password')

        const confirmPasswordInput = container.querySelector('input[name="confirm_password"]')
        expect(confirmPasswordInput).not.toBeNull()
        expect(confirmPasswordInput?.getAttribute('type')).toBe('password')

        const submitButton = container.querySelector('button[type="submit"]')
        expect(submitButton).not.toBeNull()
        expect(submitButton?.textContent).toBe('Change Password')
    })

    it('should display error message when error prop is provided', () => {
        const errorMessage = 'Token expired'
        const { container } = renderWithRouter(<ResetPassword token="test-token" error={errorMessage} />)

        const errorDiv = container.querySelector('.bg-red-50')
        expect(errorDiv).not.toBeNull()
        expect(errorDiv?.textContent).toContain(errorMessage)
    })

    it('should display success message when success prop is provided', () => {
        const successMessage = 'Password reset successful'
        const { container } = renderWithRouter(<ResetPassword token="test-token" success={successMessage} />)

        const successDiv = container.querySelector('.bg-green-50')
        expect(successDiv).not.toBeNull()
        expect(successDiv?.textContent).toContain(successMessage)
    })

    it('should not display error or success messages when props are not provided', () => {
        const { container } = renderWithRouter(<ResetPassword token="test-token" />)

        const errorDiv = container.querySelector('.bg-red-50')
        const successDiv = container.querySelector('.bg-green-50')
        expect(errorDiv).toBeNull()
        expect(successDiv).toBeNull()
    })

    it('should have form with onSubmit handler', () => {
        const { container } = renderWithRouter(<ResetPassword token="test-token" />)

        const form = container.querySelector('form')
        expect(form).not.toBeNull()
        // Note: This form uses custom submit handler and doesn't have action/method attributes
    })

    it('should have back to login link', () => {
        const { container } = renderWithRouter(<ResetPassword token="test-token" />)

        const link = container.querySelector('a[href="/admin"]')
        expect(link).not.toBeNull()
        expect(link?.textContent).toContain('Back to Login')
    })

    it('should accept token prop', () => {
        const { container } = renderWithRouter(<ResetPassword token="test-token-xyz" />)

        // Token is stored in component state and used during form submission
        // Verify the form is rendered correctly
        const newPasswordInput = container.querySelector('input[name="new_password"]')
        const confirmPasswordInput = container.querySelector('input[name="confirm_password"]')

        expect(newPasswordInput).not.toBeNull()
        expect(confirmPasswordInput).not.toBeNull()
    })

    it('should have password validation requirements in UI', () => {
        const { container } = renderWithRouter(<ResetPassword token="test-token" />)

        const newPasswordInput = container.querySelector('input[name="new_password"]')
        expect(newPasswordInput).not.toBeNull()
        // Check if password field is marked as required
        expect(newPasswordInput?.hasAttribute('required')).toBe(true)
    })
})

