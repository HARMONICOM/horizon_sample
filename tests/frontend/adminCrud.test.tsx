/** @jsxImportSource react */

import { afterEach, describe, expect, it } from 'bun:test'

import { Admin } from '../../frontend/admin/admin'

import { cleanup, renderWithRouter } from './testUtils'

describe('Admin CRUD Operations', () => {
    afterEach(() => {
        cleanup()
    })

    it('should have create user button', () => {
        const { container } = renderWithRouter(<Admin message="Dashboard" />)

        const createButton = container.querySelector('button')
        const buttonText = Array.from(container.querySelectorAll('button')).find(
            (btn) => btn.textContent === 'Add New User',
        )
        expect(buttonText).not.toBeUndefined()
    })

    it('should display edit and delete buttons for each user', () => {
        const users = [
            { email: 'user1@example.com', id: '1', name: 'User 1' },
        ]
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={users} />,
        )

        const editButton = Array.from(container.querySelectorAll('button')).find(
            (btn) => btn.textContent === 'Edit',
        )
        const deleteButton = Array.from(container.querySelectorAll('button')).find(
            (btn) => btn.textContent === 'Delete',
        )

        expect(editButton).not.toBeUndefined()
        expect(deleteButton).not.toBeUndefined()
    })

    it('should not display edit/delete buttons when no users', () => {
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={[]} />,
        )

        const editButton = Array.from(container.querySelectorAll('button')).find(
            (btn) => btn.textContent === 'Edit',
        )
        const deleteButton = Array.from(container.querySelectorAll('button')).find(
            (btn) => btn.textContent === 'Delete',
        )

        expect(editButton).toBeUndefined()
        expect(deleteButton).toBeUndefined()
    })

    it('should display correct number of action buttons per user', () => {
        const users = [
            { email: 'user1@example.com', id: '1', name: 'User 1' },
            { email: 'user2@example.com', id: '2', name: 'User 2' },
        ]
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={users} />,
        )

        const editButtons = Array.from(container.querySelectorAll('button')).filter(
            (btn) => btn.textContent === 'Edit',
        )
        const deleteButtons = Array.from(container.querySelectorAll('button')).filter(
            (btn) => btn.textContent === 'Delete',
        )

        expect(editButtons.length).toBe(2)
        expect(deleteButtons.length).toBe(2)
    })

    it('should have proper table structure for users', () => {
        const users = [
            { email: 'user1@example.com', id: '1', name: 'User 1' },
        ]
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={users} />,
        )

        const table = container.querySelector('table')
        expect(table).not.toBeNull()

        const thead = container.querySelector('thead')
        expect(thead).not.toBeNull()

        const tbody = container.querySelector('tbody')
        expect(tbody).not.toBeNull()

        const headerCells = container.querySelectorAll('thead th')
        expect(headerCells.length).toBeGreaterThan(0)
    })

    it('should include actions column in table headers', () => {
        const users = [
            { email: 'user1@example.com', id: '1', name: 'User 1' },
        ]
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={users} />,
        )

        const headers = container.querySelectorAll('thead th')
        const actionsHeader = Array.from(headers).find(
            (th) => th.textContent?.trim() === 'Actions',
        )
        expect(actionsHeader).not.toBeUndefined()
    })

    it('should render multiple users correctly', () => {
        const users = [
            { email: 'user1@example.com', id: '1', name: 'User 1' },
            { email: 'user2@example.com', id: '2', name: 'User 2' },
            { email: 'user3@example.com', id: '3', name: 'User 3' },
        ]
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={users} />,
        )

        const rows = container.querySelectorAll('tbody tr')
        expect(rows.length).toBe(3)

        // Check each user is rendered
        for (let i = 0; i < users.length; i++) {
            const row = rows[i]
            expect(row.textContent).toContain(users[i].id)
            expect(row.textContent).toContain(users[i].name)
            expect(row.textContent).toContain(users[i].email)
        }
    })

    it('should have proper button styling classes', () => {
        const users = [
            { email: 'user1@example.com', id: '1', name: 'User 1' },
        ]
        const { container } = renderWithRouter(
            <Admin message="Dashboard" users={users} />,
        )

        const editButton = Array.from(container.querySelectorAll('button')).find(
            (btn) => btn.textContent === 'Edit',
        )

        expect(editButton).not.toBeUndefined()
        expect(editButton?.className).toContain('bg-blue-500')
    })
})

