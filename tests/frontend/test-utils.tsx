/** @jsxImportSource react */

import { JSDOM } from 'jsdom'
import { flushSync } from 'react-dom'
import { createRoot, type Root } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'

// Setup DOM environment using jsdom
const dom = new JSDOM('<!DOCTYPE html><html><body></body></html>', {
    pretendToBeVisual: true,
    resources: 'usable',
    url: 'http://localhost',
})

// Set up global DOM objects
if (typeof globalThis.document === 'undefined') {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.document = dom.window.document as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.window = dom.window as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.navigator = dom.window.navigator as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLElement = dom.window.HTMLElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLDivElement = dom.window.HTMLDivElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLInputElement = dom.window.HTMLInputElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLButtonElement = dom.window.HTMLButtonElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLFormElement = dom.window.HTMLFormElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLAnchorElement = dom.window.HTMLAnchorElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLTableElement = dom.window.HTMLTableElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLTableRowElement = dom.window.HTMLTableRowElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLTableHeaderCellElement = dom.window.HTMLTableHeaderCellElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLTableDataCellElement = dom.window.HTMLTableDataCellElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.HTMLTableSectionElement = dom.window.HTMLTableSectionElement as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.Element = dom.window.Element as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    globalThis.Node = dom.window.Node as any
}

/**
 * Test utility for rendering React components with necessary providers
 */
export const renderWithRouter = (component: React.ReactElement): {
    container: HTMLDivElement
    root: Root
} => {
    const container = document.createElement('div')
    container.id = 'root'
    document.body.appendChild(container)

    const wrappedComponent = (
        <BrowserRouter>
            {component}
        </BrowserRouter>
    )

    const root = createRoot(container)
    flushSync(() => {
        root.render(wrappedComponent)
    })
    return { container, root }
}

/**
 * Cleanup utility for tests
 */
export const cleanup = () => {
    document.body.innerHTML = ''
}

