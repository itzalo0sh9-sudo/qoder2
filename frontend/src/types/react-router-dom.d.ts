// Minimal type definitions for React Router DOM to resolve import issues
declare module 'react-router-dom' {
  import * as React from 'react';

  export interface BrowserRouterProps {
    basename?: string;
    children?: React.ReactNode;
    window?: Window;
  }

  export const BrowserRouter: React.FC<BrowserRouterProps>;
  
  export interface RoutesProps {
    children?: React.ReactNode;
  }
  
  export const Routes: React.FC<RoutesProps>;
  
  export interface RouteProps {
    caseSensitive?: boolean;
    children?: React.ReactNode;
    element?: React.ReactElement | null;
    path?: string;
  }
  
  export const Route: React.FC<RouteProps>;
  
  export interface LinkProps
    extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
    reloadDocument?: boolean;
    replace?: boolean;
    state?: any;
    to: string;
    preventScrollReset?: boolean;
  }
  
  export const Link: React.FC<LinkProps>;
  
  export interface NavLinkProps
    extends LinkProps {
    children?: React.ReactNode;
    className?: string | ((props: { isActive: boolean }) => string);
    style?: React.CSSProperties | ((props: { isActive: boolean }) => React.CSSProperties);
    end?: boolean;
  }
  
  export const NavLink: React.FC<NavLinkProps>;
  
  export function useNavigate(): (to: string, options?: { replace?: boolean; state?: any }) => void;
  export function useParams(): Record<string, string>;
  export function useLocation(): {
    pathname: string;
    search: string;
    state: any;
    key: string;
  };
}