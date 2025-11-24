/** @jsxImportSource react */

import { afterEach, describe, expect, it } from 'bun:test'

import { Admin } from '../../frontend/admin/admin'

import { cleanup, renderWithRouter } from './test-utils'

describe('Admin Component', () => {
    afterEach(() => {
        cleanup()
    })

    it('should render admin dashboard correctly', () => {
        const message = 'Admin Dashboard'
        const { container } = renderWithRouter(<Admin message={message} />)

        const heading = container.querySelector('h1')
        expect(heading).not.toBeNull()
        expect(heading?.textContent).toBe(message)
    })

    it('should display user email when provided', () => {
        const userEmail = 'admin@example.com'
        const { container } = renderWithRouter(
            <Admin message="Dashboard" user_email={userEmail} />,
        )

        const emailSpan = Array.from(container.querySelectorAll('span')).find(
            (span) => span.textContent === userEmail,
        )
        expect(emailSpan).not.toBeUndefined()
    })

    it('should display default email when user_email is not provided', () => {
        const { container } = renderWithRouter(<Admin message="Dashboard" />)

        const emailSpan = Array.from(container.querySelectorAll('span')).find(
            (span) => span.textContent === 'Unknown',
        )
        expect(emailSpan).not.toBeUndefined()
    })

    it('should render user list table when users are provided', () => {
        const users = [
            { email: 'user1@example.com', id: '1', name: 'User 1' },
            { email: 'user2@example.com', id: '2', name: 'User 2' },
        ]
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={users} />,
        )

        const table = container.querySelector('table')
        expect(table).not.toBeNull()

        const rows = container.querySelectorAll('tbody tr')
        expect(rows.length).toBe(2)

        const firstRow = rows[0]
        expect(firstRow.textContent).toContain('1')
        expect(firstRow.textContent).toContain('User 1')
        expect(firstRow.textContent).toContain('user1@example.com')
    })

    it('should display "No users found" when users array is empty', () => {
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={[]} />,
        )

        const noUsersMessage = container.querySelector('.text-gray-500')
        expect(noUsersMessage).not.toBeNull()
        expect(noUsersMessage?.textContent).toContain('No users found')
    })

    it('should display "No users found" when users prop is not provided', () => {
        const { container } = renderWithRouter(<Admin message="Dashboard" />)

        const noUsersMessage = container.querySelector('.text-gray-500')
        expect(noUsersMessage).not.toBeNull()
        expect(noUsersMessage?.textContent).toContain('No users found')
    })

    it('should have logout form with correct action', () => {
        const { container } = renderWithRouter(<Admin message="Dashboard" />)

        const logoutForm = container.querySelector('form')
        expect(logoutForm).not.toBeNull()

        const logoutButton = logoutForm?.querySelector('button[type="submit"]')
        expect(logoutButton).not.toBeNull()
        expect(logoutButton?.textContent).toBe('Logout')
    })

    it('should have change password link', () => {
        const { container } = renderWithRouter(<Admin message="Dashboard" />)

        const link = container.querySelector('a[href="/admin/change-password"]')
        expect(link).not.toBeNull()
        expect(link?.textContent).toBe('Change Password')
    })

    it('should render table headers correctly', () => {
        const users = [
            { email: 'user1@example.com', id: '1', name: 'User 1' },
        ]
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={users} />,
        )

        const headers = container.querySelectorAll('thead th')
        expect(headers.length).toBe(3)
        expect(headers[0]?.textContent?.trim()).toBe('ID')
        expect(headers[1]?.textContent?.trim()).toBe('Name')
        expect(headers[2]?.textContent?.trim()).toBe('Email')
    })
})

