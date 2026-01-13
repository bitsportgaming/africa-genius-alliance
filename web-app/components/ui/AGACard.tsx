import React from 'react';

export type CardVariant = 'default' | 'hero' | 'outlined' | 'elevated';

interface AGACardProps {
  variant?: CardVariant;
  padding?: 'none' | 'sm' | 'md' | 'lg';
  className?: string;
  children: React.ReactNode;
  onClick?: () => void;
  hoverable?: boolean;
}

export const AGACard: React.FC<AGACardProps> = ({
  variant = 'default',
  padding = 'md',
  className = '',
  children,
  onClick,
  hoverable = false,
}) => {
  const baseStyles = `
    rounded-aga
    transition-all duration-200
  `;

  const variantStyles = {
    default: `
      bg-white
      shadow-aga
    `,
    hero: `
      bg-gradient-to-br from-secondary/10 to-primary/10
      border border-primary/20
      shadow-aga-lg
    `,
    outlined: `
      bg-white
      border-2 border-primary/20
    `,
    elevated: `
      bg-white
      shadow-aga-lg
    `,
  };

  const paddingStyles = {
    none: '',
    sm: 'p-4',
    md: 'p-6',
    lg: 'p-8',
  };

  const hoverStyles = hoverable || onClick ? 'hover:shadow-aga-lg hover:scale-[1.02] cursor-pointer' : '';

  return (
    <div
      className={`
        ${baseStyles}
        ${variantStyles[variant]}
        ${paddingStyles[padding]}
        ${hoverStyles}
        ${className}
      `}
      onClick={onClick}
    >
      {children}
    </div>
  );
};
