import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#0a4d3c',
          dark: '#064e3b',
          light: '#10b981',
        },
        secondary: {
          DEFAULT: '#f59e0b',
          dark: '#d97706',
          light: '#fbbf24',
        },
        background: {
          cream: '#fef9e7',
          navy: '#0f172a',
        },
        text: {
          dark: '#1f2937',
          light: '#ffffff',
        },
      },
      fontFamily: {
        sans: ['var(--font-geist-sans)', 'system-ui', 'sans-serif'],
      },
      backgroundImage: {
        'gradient-primary': 'linear-gradient(135deg, #0a4d3c 0%, #064e3b 100%)',
        'gradient-accent': 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
        'gradient-hero': 'radial-gradient(circle at top left, #f59e0b, #0a4d3c)',
      },
      borderRadius: {
        'aga': '14px',
      },
      boxShadow: {
        'aga': '0 2px 8px rgba(10, 77, 60, 0.1)',
        'aga-lg': '0 4px 16px rgba(10, 77, 60, 0.15)',
      },
    },
  },
  plugins: [],
};

export default config;
