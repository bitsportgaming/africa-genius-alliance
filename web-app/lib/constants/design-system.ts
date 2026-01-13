// Design System Constants - Matching AGA Mobile App

export const Colors = {
  // Primary Colors
  primary: {
    DEFAULT: '#0a4d3c',
    dark: '#064e3b',
    light: '#10b981',
  },

  // Secondary Colors
  secondary: {
    DEFAULT: '#f59e0b',
    dark: '#d97706',
    light: '#fbbf24',
  },

  // Background Colors
  background: {
    cream: '#fef9e7',
    navy: '#0f172a',
    white: '#ffffff',
    gray: '#f3f4f6',
  },

  // Text Colors
  text: {
    dark: '#1f2937',
    light: '#ffffff',
    gray: '#6b7280',
    muted: '#9ca3af',
  },

  // Semantic Colors
  success: '#10b981',
  error: '#ef4444',
  warning: '#f59e0b',
  info: '#3b82f6',
} as const;

export const Gradients = {
  primary: 'linear-gradient(135deg, #0a4d3c 0%, #064e3b 100%)',
  accent: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
  genius: 'linear-gradient(135deg, #f59e0b 0%, #fbbf24 100%)',
  background: 'linear-gradient(180deg, #0a4d3c 0%, #064e3b 100%)',
  card: 'linear-gradient(135deg, rgba(10, 77, 60, 0.05) 0%, rgba(10, 77, 60, 0.02) 100%)',
  hero: 'radial-gradient(circle at top left, #f59e0b, #0a4d3c)',
} as const;

export const Typography = {
  sizes: {
    xs: '0.75rem',      // 12px
    sm: '0.875rem',     // 14px
    base: '1rem',       // 16px
    lg: '1.125rem',     // 18px
    xl: '1.25rem',      // 20px
    '2xl': '1.5rem',    // 24px
    '3xl': '1.875rem',  // 30px
    '4xl': '2.25rem',   // 36px
    '5xl': '3rem',      // 48px
    '6xl': '3.75rem',   // 60px
  },
  weights: {
    normal: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
    black: '900',
  },
  lineHeights: {
    tight: '1.25',
    normal: '1.5',
    relaxed: '1.75',
  },
} as const;

export const Spacing = {
  xs: '0.25rem',   // 4px
  sm: '0.5rem',    // 8px
  md: '0.75rem',   // 12px
  lg: '1rem',      // 16px
  xl: '1.25rem',   // 20px
  '2xl': '1.5rem', // 24px
  '3xl': '2rem',   // 32px
  '4xl': '3rem',   // 48px
  '5xl': '4rem',   // 64px
} as const;

export const BorderRadius = {
  sm: '0.375rem',  // 6px
  md: '0.5rem',    // 8px
  lg: '0.875rem',  // 14px (AGA standard)
  xl: '1rem',      // 16px
  '2xl': '1.5rem', // 24px
  full: '9999px',
} as const;

export const Shadows = {
  sm: '0 1px 2px rgba(10, 77, 60, 0.05)',
  DEFAULT: '0 2px 8px rgba(10, 77, 60, 0.1)',
  md: '0 4px 12px rgba(10, 77, 60, 0.1)',
  lg: '0 4px 16px rgba(10, 77, 60, 0.15)',
  xl: '0 8px 24px rgba(10, 77, 60, 0.2)',
} as const;

export const Breakpoints = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px',
} as const;

export const ZIndex = {
  base: 0,
  dropdown: 1000,
  sticky: 1020,
  fixed: 1030,
  modalBackdrop: 1040,
  modal: 1050,
  popover: 1060,
  tooltip: 1070,
} as const;

export const Transitions = {
  fast: '150ms ease-in-out',
  normal: '200ms ease-in-out',
  slow: '300ms ease-in-out',
  spring: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
} as const;
