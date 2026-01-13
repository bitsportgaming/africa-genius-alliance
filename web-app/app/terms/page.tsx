import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function TermsPage() {
  return (
    <StaticPageLayout title="Terms of Service" subtitle="Rules for Using Africa Genius Alliance">
      <div className="bg-white rounded-2xl p-8 shadow-lg">
        <p className="text-text-gray mb-6">Last updated: January 2024</p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">1. Acceptance of Terms</h2>
        <p className="text-text-gray mb-6">
          By accessing or using Africa Genius Alliance (AGA), you agree to be bound by these 
          Terms of Service. If you do not agree, please do not use our platform.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">2. User Accounts</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>You must be at least 18 years old to create an account</li>
          <li>You are responsible for maintaining the security of your account</li>
          <li>One account per person (no duplicate accounts)</li>
          <li>Provide accurate and truthful information</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">3. Genius Accounts</h2>
        <p className="text-text-gray mb-6">
          Geniuses are leaders who create content and seek support on the platform. 
          By registering as a Genius, you agree to maintain transparency, fulfill 
          commitments made to supporters, and follow our community guidelines.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">4. Voting and Donations</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>Votes are final and cannot be reversed</li>
          <li>Vote manipulation or fraud is strictly prohibited</li>
          <li>Donations are voluntary contributions to support Geniuses</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">5. Prohibited Conduct</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>Harassment, hate speech, or discrimination</li>
          <li>Spreading misinformation or false claims</li>
          <li>Impersonation of others</li>
          <li>Spam or unauthorized advertising</li>
          <li>Attempting to manipulate votes or rankings</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">6. Content Ownership</h2>
        <p className="text-text-gray mb-6">
          You retain ownership of content you create. By posting content, you grant AGA 
          a license to display, distribute, and promote your content on the platform.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">7. Termination</h2>
        <p className="text-text-gray mb-6">
          We reserve the right to suspend or terminate accounts that violate these terms 
          or our community guidelines.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">8. Contact</h2>
        <p className="text-text-gray">
          Questions about these terms? Contact{' '}
          <a href="mailto:legal@africageniusalliance.com" className="text-primary hover:underline">
            legal@africageniusalliance.com
          </a>
        </p>
      </div>
    </StaticPageLayout>
  );
}

