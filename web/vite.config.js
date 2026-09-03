import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Output goes to web/build, which is what fxmanifest.lua's ui_page and
// `files {}` block point at. Base is relative so it works inside the
// FiveM NUI browser regardless of resource name.
export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: 'build',
    emptyOutDir: true,
  },
})
