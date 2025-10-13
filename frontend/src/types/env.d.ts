// Type definitions for environment variables
interface ProcessEnv {
  REACT_APP_SALES_API_URL: string;
  // Add other environment variables here
}

interface NodeJS {
  ProcessEnv: ProcessEnv;
}

// Fallback for import.meta.env usage
interface ImportMetaEnv {
  readonly REACT_APP_SALES_API_URL: string;
  // Add other environment variables here
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

// Global process variable
declare var process: {
  env: ProcessEnv;
};