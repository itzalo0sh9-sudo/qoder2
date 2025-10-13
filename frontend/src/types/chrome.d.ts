// Type definitions for Chrome Extension APIs
// Enhanced definitions to resolve the "use type chrome instead undefined" error

interface ChromeEvent<T extends Function> {
  addListener: (callback: T) => void;
  removeListener: (callback: T) => void;
  hasListener: (callback: T) => boolean;
  removeAllListeners: () => void;
}

declare namespace chrome {
  // Runtime API
  const runtime: {
    id: string;
    lastError?: {
      message: string;
    };
    sendMessage: (message: any, responseCallback?: (response: any) => void) => void;
    onMessage: ChromeEvent<(message: any, sender: any, sendResponse: any) => void>;
    onInstalled: ChromeEvent<(details: { reason: string; previousVersion?: string }) => void>;
    getManifest: () => any;
    getURL: (path: string) => string;
  };
  
  // Tabs API
  const tabs: {
    query: (queryInfo: any, callback: (tabs: any[]) => void) => void;
    create: (createProperties: any, callback?: (tab: any) => void) => void;
    update: (tabId: number | undefined, updateProperties: any, callback?: (tab: any) => void) => void;
    remove: (tabId: number | number[], callback?: () => void) => void;
    onUpdated: ChromeEvent<(tabId: number, changeInfo: any, tab: any) => void>;
  };
  
  // Storage API
  const storage: {
    sync: {
      get: (keys: string | string[] | object | null, callback: (items: { [key: string]: any }) => void) => void;
      set: (items: { [key: string]: any }, callback?: () => void) => void;
      remove: (keys: string | string[], callback?: () => void) => void;
      clear: (callback?: () => void) => void;
    };
    local: {
      get: (keys: string | string[] | object | null, callback: (items: { [key: string]: any }) => void) => void;
      set: (items: { [key: string]: any }, callback?: () => void) => void;
      remove: (keys: string | string[], callback?: () => void) => void;
      clear: (callback?: () => void) => void;
    };
  };
  
  // Extension API
  const extension: {
    getURL: (path: string) => string;
    getBackgroundPage: () => Window | null;
  };
  
  // Browser Action API
  const browserAction: {
    onClicked: ChromeEvent<(tab: any) => void>;
    setBadgeText: (details: { text: string | null }) => void;
    setBadgeBackgroundColor: (details: { color: string | number[] | null }) => void;
  };
  
  // Context Menus API
  const contextMenus: {
    create: (createProperties: any, callback?: Function) => void;
    update: (id: string, updateProperties: any, callback?: Function) => void;
    remove: (menuItemId: string, callback?: Function) => void;
  };
  
  // Notifications API
  const notifications: {
    create: (notificationId: string, options: any, callback?: (notificationId: string) => void) => void;
    clear: (notificationId: string, callback?: (wasCleared: boolean) => void) => void;
  };
  
  // Permissions API
  const permissions: {
    request: (permissions: any, callback?: (granted: boolean) => void) => void;
    contains: (permissions: any, callback: (result: boolean) => void) => void;
  };
  
  // Windows API
  const windows: {
    create: (createData: any, callback?: (window: any) => void) => void;
    update: (windowId: number, updateInfo: any, callback?: (window: any) => void) => void;
  };
  
  // Alarms API
  const alarms: {
    create: (name?: string, alarmInfo?: any) => void;
    onAlarm: ChromeEvent<(alarm: any) => void>;
  };
  
  // Cookies API
  const cookies: {
    get: (details: any, callback: (cookie: any) => void) => void;
    getAll: (details: any, callback: (cookies: any[]) => void) => void;
    set: (details: any, callback?: (cookie: any) => void) => void;
  };
  
  // i18n API
  const i18n: {
    getMessage: (messageName: string, substitutions?: string | string[]) => string;
  };
  
  // Scripting API
  const scripting: {
    executeScript: (details: any, callback?: (results: any[]) => void) => void;
  };
  
  // Action API (Manifest V3 replacement for browserAction)
  const action: {
    onClicked: ChromeEvent<(tab: any) => void>;
    setBadgeText: (details: { text: string | null }) => void;
    setBadgeBackgroundColor: (details: { color: string | number[] | null }) => void;
  };
}

// Global chrome object
declare global {
  interface Window {
    chrome?: typeof chrome;
  }
  
  const chrome: typeof chrome;
}

export {};