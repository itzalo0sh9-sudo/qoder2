// Minimal type definitions for React Redux to resolve import issues
declare module 'react-redux' {
  import * as React from 'react';
  import * as redux from 'redux';

  // Typed version of useSelector
  export function useSelector<TState, TSelected>(
    selector: (state: TState) => TSelected,
    equalityFn?: (left: TSelected, right: TSelected) => boolean
  ): TSelected;

  // Typed version of useDispatch
  export function useDispatch<TDispatch = redux.Dispatch>(): TDispatch;

  // Typed version of useStore
  export function useStore<S = any, A extends redux.Action = redux.Action>(): redux.Store<S, A>;

  export interface ProviderProps<A extends redux.Action = redux.Action> {
    store: redux.Store<any, A>;
    children?: React.ReactNode;
    context?: React.Context<ReactReduxContextValue>;
  }

  export const Provider: React.FC<ProviderProps>;

  export interface ReactReduxContextValue<SS = any, A extends redux.Action = redux.Action> {
    store: redux.Store<SS, A>;
    subscription: Subscription;
  }

  export interface Subscription {
    addNestedSub: (listener: () => void) => void;
    notifyNestedSubs: () => void;
    handleChangeError: (error: any) => void;
    isSubscribed: () => boolean;
  }

  // Connect HOC types
  export interface ConnectProps {
    store?: redux.Store;
  }

  export function connect<
    TStateProps = {},
    TDispatchProps = {},
    TOwnProps = {},
    TState = any,
    TDispatch = redux.Dispatch
  >(
    mapStateToProps?: (state: TState, ownProps: TOwnProps) => TStateProps,
    mapDispatchToProps?: (dispatch: TDispatch, ownProps: TOwnProps) => TDispatchProps,
    mergeProps?: (stateProps: TStateProps, dispatchProps: TDispatchProps, ownProps: TOwnProps) => any,
    options?: any
  ): <TComponent extends React.ComponentType<any>>(
    component: TComponent
  ) => React.ComponentType<Omit<React.ComponentProps<TComponent>, keyof TStateProps & keyof TDispatchProps> & TOwnProps>;
}