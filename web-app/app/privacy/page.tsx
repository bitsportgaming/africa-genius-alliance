import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function PrivacyPage() {
  return (
    <StaticPageLayout title="Privacy Policy" subtitle="How We Protect Your Data">
      <div className="bg-white rounded-2xl p-8 shadow-lg">
        <p className="text-text-gray mb-6">Last updated: January 2024</p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">1. Information We Collect</h2>
        <p className="text-text-gray mb-4">We collect information you provide directly:</p>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>Account information (name, email, country)</li>
          <li>Profile information (bio, position, category)</li>
          <li>Content you create (posts, comments, votes)</li>
          <li>Usage data (how you interact with the platform)</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">2. How We Use Your Information</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>To provide and improve our services</li>
          <li>To personalize your experience</li>
          <li>To communicate with you about your account</li>
          <li>To ensure platform security and prevent fraud</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">3. Information Sharing</h2>
        <p className="text-text-gray mb-6">
          We do not sell your personal information. We may share data with service providers 
          who help us operate the platform, and when required by law.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">4. Data Security</h2>
        <p className="text-text-gray mb-6">
          We implement industry-standard security measures to protect your data, including 
          encryption, secure servers, and regular security audits.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">5. Your Rights</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>Access your personal data</li>
          <li>Correct inaccurate data</li>
          <li>Request deletion of your data</li>
          <li>Export your data</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">6. Contact Us</h2>
        <p className="text-text-gray">
          For privacy-related questions, contact us at{' '}
          <a href="mailto:privacy@africageniusalliance.com" className="text-primary hover:underline">
            privacy@africageniusalliance.com
          </a>
        </p>
      </div>
    </StaticPageLayout>
  );
}

