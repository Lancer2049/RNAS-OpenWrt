import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  timeout: 30000,
  retries: 1,
  webServer: [
    {
      command: '/home/lancer/projects/AIRadius/backend/venv/bin/uvicorn mock_server:app --host 0.0.0.0 --port 8099',
      cwd: '../api',
      port: 8099,
      timeout: 15000,
      reuseExistingServer: true,
    },
    {
      command: 'npx vite --port 5173 --strictPort',
      port: 5173,
      timeout: 15000,
      reuseExistingServer: true,
    },
  ],
  use: {
    baseURL: 'http://localhost:5173',
    headless: true,
  },
});
