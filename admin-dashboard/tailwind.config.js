/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        aga: {
          primary: '#0a4d3c',
          secondary: '#10b981',
          accent: '#f59e0b',
          dark: '#0f172a',
          darker: '#020617',
        }
      }
    },
  },
  plugins: [],
}

