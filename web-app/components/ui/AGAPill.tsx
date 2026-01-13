import React from 'react';

export type PillVariant = 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'neutral';
export type PillSize = 'sm' | 'md' | 'lg';

interface AGAPillProps {
  variant?: PillVariant;
  size?: PillSize;
  children: React.ReactNode;
  className?: string;
}

export const AGAPill: React.FC<AGAPillProps> = ({
  variant = 'primary',
  size = 'md',
  children,
  className = '',
}) => {
  const baseStyles = `
    inline-flex items-center justify-center
    font-medium rounded-full
    whitespace-nowrap
  `;

  const variantStyles = {
    primary: 'bg-primary/10 text-primary',
    secondary: 'bg-secondary/10 text-secondary-dark',
    success: 'bg-green-100 text-green-700',
    warning: 'bg-yellow-100 text-yellow-700',
    danger: 'bg-red-100 text-red-700',
    neutral: 'bg-gray-100 text-gray-700',
  };

  const sizeStyles = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-3 py-1 text-sm',
    lg: 'px-4 py-1.5 text-base',
  };

  return (
    <span
      className={`
        ${baseStyles}
        ${variantStyles[variant]}
        ${sizeStyles[size]}
        ${className}
      `}
    >
      {children}
    </span>
  );
};
