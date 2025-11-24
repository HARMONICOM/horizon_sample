/** @jsxImportSource react */

import { afterEach, describe, expect, it } from 'bun:test'

import { Index } from '../../frontend/index'

import { cleanup, renderWithRouter } from './testUtils'

describe('Index Component', () => {
    afterEach(() => {
        cleanup()
    })

    it('should render message prop correctly', () => {
        const message = 'Test Message'
        const { container } = renderWithRouter(<Index message={message} />)

        const heading = container.querySelector('h2')
        expect(heading).not.toBeNull()
        expect(heading?.textContent).toBe(message)
    })

    it('should render with empty message', () => {
        const { container } = renderWithRouter(<Index message="" />)

        const heading = container.querySelector('h2')
        expect(heading).not.toBeNull()
        expect(heading?.textContent).toBe('')
    })

    it('should have correct CSS classes', () => {
        const { container } = renderWithRouter(<Index message="Test" />)

        const div = container.querySelector('div.mb-8')
        expect(div).not.toBeNull()
    })
})

