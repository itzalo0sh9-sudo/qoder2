// Minimal type definitions for React DOM to resolve import issues
declare module 'react-dom' {
  export function render(
    element: React.ReactElement,
    container: Element | DocumentFragment | null,
    callback?: () => void
  ): void;
  
  export function hydrate(
    element: React.ReactElement,
    container: Element | DocumentFragment,
    callback?: () => void
  ): void;
  
  export function createPortal(
    children: React.ReactNode,
    container: Element | DocumentFragment,
    key?: null | string
  ): React.ReactPortal;
  
  export function unmountComponentAtNode(container: Element): boolean;
  
  export function findDOMNode(
    component: React.Component<any, any> | Element
  ): Element | null | Text;
}

declare module 'react-dom/client' {
  export interface Root {
    render(children: React.ReactNode): void;
    unmount(): void;
  }
  
  export function createRoot(container: Element | DocumentFragment): Root;
  export function hydrateRoot(
    container: Element | DocumentFragment,
    initialChildren: React.ReactNode
  ): Root;
}