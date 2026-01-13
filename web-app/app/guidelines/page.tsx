import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function GuidelinesPage() {
  return (
    <StaticPageLayout title="Community Guidelines" subtitle="Building a Respectful and Impactful Community">
      <div className="bg-white rounded-2xl p-8 shadow-lg">
        <h2 className="text-2xl font-bold text-text-dark mb-4">Our Community Values</h2>
        <p className="text-text-gray mb-6">
          AGA is a space for constructive dialogue, leadership development, and positive change. 
          These guidelines help us maintain a community where everyone can participate safely.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">✅ Do</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>Be respectful and constructive in all interactions</li>
          <li>Share accurate, truthful information</li>
          <li>Engage in good-faith discussions</li>
          <li>Report content that violates these guidelines</li>
          <li>Celebrate diverse perspectives and backgrounds</li>
          <li>Support Geniuses whose vision you believe in</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">❌ Don't</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>Harass, bully, or intimidate other users</li>
          <li>Post hate speech or discriminatory content</li>
          <li>Share misinformation or fake news</li>
          <li>Impersonate other people or organizations</li>
          <li>Spam or post repetitive content</li>
          <li>Attempt to manipulate votes or rankings</li>
          <li>Share explicit or inappropriate content</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">For Geniuses</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>Be transparent about your goals and progress</li>
          <li>Honor commitments made to your supporters</li>
          <li>Provide regular updates on your initiatives</li>
          <li>Respond respectfully to questions and feedback</li>
          <li>Use funds responsibly and transparently</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Enforcement</h2>
        <p className="text-text-gray mb-4">
          Violations of these guidelines may result in:
        </p>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li>Content removal</li>
          <li>Temporary suspension</li>
          <li>Permanent account ban</li>
          <li>Removal of Genius status</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Reporting</h2>
        <p className="text-text-gray">
          To report a violation, use the report button on any post or profile, or email{' '}
          <a href="mailto:safety@africageniusalliance.com" className="text-primary hover:underline">
            safety@africageniusalliance.com
          </a>
        </p>
      </div>
    </StaticPageLayout>
  );
}

