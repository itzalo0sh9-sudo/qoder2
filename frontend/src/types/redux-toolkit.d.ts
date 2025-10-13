// Updated type definitions for Redux Toolkit to match actual library behavior
declare module '@reduxjs/toolkit' {
  import { Action, Reducer, Store, Dispatch } from 'redux';

  // Define a type for the combined reducer map
  type ReducerMapObject = { [key: string]: Reducer<any, any> };

  export interface ConfigureStoreOptions<S = any, A extends Action = Action> {
    reducer: Reducer<S, A> | ReducerMapObject;
    middleware?: any[];
    devTools?: boolean | object;
    preloadedState?: S;
    enhancers?: any[];
  }

  export function configureStore<S = any, A extends Action = Action>(
    options: ConfigureStoreOptions<S, A>
  ): Store<S, A> & { dispatch: Dispatch<A> };

  export type PayloadAction<P = void, T extends string = string> = {
    payload: P;
    type: T;
  };

  // Define proper types for createSlice
  export type CaseReducer<State, Action extends PayloadAction<any>> = (state: State, action: Action) => void | State;
  
  export type SliceCaseReducers<State> = {
    [K: string]: CaseReducer<State, PayloadAction<any>>;
  };

  export interface ActionReducerMapBuilder<State> {
    addCase<Action extends PayloadAction<any>>(
      type: Action['type'],
      reducer: CaseReducer<State, Action>
    ): ActionReducerMapBuilder<State>;
    addCase<Action extends PayloadAction<any>>(
      actionCreator: ActionCreator<Action>,
      reducer: CaseReducer<State, Action>
    ): ActionReducerMapBuilder<State>;
    addMatcher<A extends Action>(
      matcher: (action: any) => action is A,
      reducer: CaseReducer<State, A>
    ): ActionReducerMapBuilder<State>;
    addDefaultCase(reducer: CaseReducer<State, Action>): ActionReducerMapBuilder<State>;
  }

  export function createSlice<
    State,
    CaseReducers extends SliceCaseReducers<State>,
    Name extends string = string
  >(options: {
    name: Name;
    initialState: State;
    reducers: CaseReducers;
    extraReducers?: (builder: ActionReducerMapBuilder<State>) => void | ActionReducerMapBuilder<State>;
  }): Slice<State, CaseReducers, Name>;

  export interface Slice<
    State,
    CaseReducers extends SliceCaseReducers<State>,
    Name extends string = string
  > {
    name: Name;
    reducer: Reducer<State, Action>;
    actions: {
      [K in keyof CaseReducers]: CaseReducers[K] extends CaseReducer<State, infer Action> 
        ? (payload: Action extends PayloadAction<infer P> ? P : never) => Action
        : never;
    };
    caseReducers: CaseReducers;
  }

  export interface CreateAsyncThunkOptions<ThunkArg, ThunkApiConfig = {}> {
    condition?(
      arg: ThunkArg,
      api: { getState: () => any; extra: any }
    ): boolean | undefined;
    dispatchConditionRejection?: boolean;
  }

  export type AsyncThunkPayloadCreator<Returned, ThunkArg, ThunkApiConfig = {}> = (
    arg: ThunkArg,
    api: GetThunkAPI<ThunkApiConfig>
  ) => Promise<Returned>;

  export type GetThunkAPI<ThunkApiConfig> = {
    dispatch: any;
    getState: () => any;
    extra: any;
    rejectWithValue: (value: any) => any;
  };

  export interface AsyncThunk<Returned, ThunkArg, ThunkApiConfig> {
    (
      arg: ThunkArg,
      options?: { rejectValue: any }
    ): any;
    pending: any;
    fulfilled: any;
    rejected: any;
  }

  export function createAsyncThunk<
    Returned,
    ThunkArg = void,
    ThunkApiConfig = {}
  >(
    typePrefix: string,
    payloadCreator: AsyncThunkPayloadCreator<Returned, ThunkArg, ThunkApiConfig>,
    options?: CreateAsyncThunkOptions<ThunkArg, ThunkApiConfig>
  ): AsyncThunk<Returned, ThunkArg, ThunkApiConfig>;

  export type ActionCreator<Action extends PayloadAction<any>> = 
    Action extends PayloadAction<infer P> 
      ? (payload: P) => Action
      : () => Action;
}