import React from 'react';

interface AGAChipProps {
  selected?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
  className?: string;
}

export const AGAChip: React.FC<AGAChipProps> = ({
  selected = false,
  onClick,
  children,
  className = '',
}) => {
  const baseStyles = `
    inline-flex items-center justify-center
    px-4 py-2
    font-medium text-sm
    rounded-full
    border-2
    transition-all duration-200
    cursor-pointer
    select-none
  `;

  const selectedStyles = selected
    ? 'bg-primary border-primary text-white shadow-aga'
    : 'bg-white border-gray-200 text-gray-700 hover:border-primary/50 hover:bg-primary/5';

  return (
    <button
      type="button"
      className={`
        ${baseStyles}
        ${selectedStyles}
        ${className}
      `}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
