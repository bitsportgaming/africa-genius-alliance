import type { Metadata } from 'next';
import './globals.css';
import { Providers } from './providers';

export const metadata: Metadata = {
  metadataBase: new URL('https://africageniusalliance.com'),
  title: {
    default: 'Africa Genius Alliance | Merit-Based Leadership Platform',
    template: '%s | Africa Genius Alliance'
  },
  description: 'Africa Genius Alliance identifies, elevates, and supports Africa\'s most capable minds through transparency, ideas, and measurable impact. Join the movement for merit-based leadership.',
  keywords: [
    'Africa leadership',
    'merit-based platform',
    'African innovation',
    'genius recognition',
    'transparent voting',
    'impact measurement',
    'African excellence',
    'leadership platform',
    'talent discovery',
    'Africa development'
  ],
  authors: [{ name: 'Africa Genius Alliance', url: 'https://africageniusalliance.com' }],
  creator: 'Africa Genius Alliance',
  publisher: 'Africa Genius Alliance',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://africageniusalliance.com',
    siteName: 'Africa Genius Alliance',
    title: 'Africa Genius Alliance | Leadership Earned by Merit. Not Politics.',
    description: 'Join Africa\'s premier platform for identifying and supporting exceptional talent. Transparent, merit-based, and impact-driven.',
    images: [
      {
        url: 'https://africageniusalliance.com/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Africa Genius Alliance - Merit-Based Leadership Platform',
        type: 'image/png',
      }
    ],
  },
  twitter: {
    card: 'summary_large_image',
    site: '@AfricaGenius',
    creator: '@AfricaGenius',
    title: 'Africa Genius Alliance | Leadership Earned by Merit',
    description: 'Join Africa\'s premier platform for identifying and supporting exceptional talent through transparent, merit-based recognition.',
    images: ['https://africageniusalliance.com/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  icons: {
    icon: '/Aga.png',
    shortcut: '/Aga.png',
    apple: '/apple-touch-icon.png',
  },
  manifest: '/site.webmanifest',
  verification: {
    // Add your verification codes when available
    // google: 'your-google-verification-code',
    // yandex: 'your-yandex-verification-code',
    // bing: 'your-bing-verification-code',
  },
  alternates: {
    canonical: 'https://africageniusalliance.com',
  },
  category: 'technology',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'Africa Genius Alliance',
    alternateName: 'AGA',
    url: 'https://africageniusalliance.com',
    logo: 'https://africageniusalliance.com/Aga.png',
    description: 'Africa Genius Alliance identifies, elevates, and supports Africa\'s most capable minds through transparency, ideas, and measurable impact.',
    foundingDate: '2024',
    sameAs: [
      'https://twitter.com/AfricaGenius',
      'https://linkedin.com/company/africa-genius-alliance',
    ],
    contactPoint: {
      '@type': 'ContactPoint',
      contactType: 'customer support',
      email: 'support@africageniusalliance.com',
    },
  };

  return (
    <html lang="en">
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
