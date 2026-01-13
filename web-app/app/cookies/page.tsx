import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function CookiesPage() {
  return (
    <StaticPageLayout title="Cookie Policy" subtitle="How We Use Cookies">
      <div className="bg-white rounded-2xl p-8 shadow-lg">
        <p className="text-text-gray mb-6">Last updated: January 2024</p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">What Are Cookies?</h2>
        <p className="text-text-gray mb-6">
          Cookies are small text files stored on your device when you visit websites. 
          They help us provide a better experience by remembering your preferences 
          and understanding how you use our platform.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Types of Cookies We Use</h2>
        
        <div className="space-y-4 mb-6">
          <div className="bg-gray-50 p-4 rounded-xl">
            <h3 className="font-bold text-text-dark mb-2">Essential Cookies</h3>
            <p className="text-text-gray text-sm">
              Required for the platform to function. These keep you logged in and 
              enable core features. Cannot be disabled.
            </p>
          </div>
          
          <div className="bg-gray-50 p-4 rounded-xl">
            <h3 className="font-bold text-text-dark mb-2">Analytics Cookies</h3>
            <p className="text-text-gray text-sm">
              Help us understand how users interact with AGA so we can improve 
              the platform. Data is anonymized and aggregated.
            </p>
          </div>
          
          <div className="bg-gray-50 p-4 rounded-xl">
            <h3 className="font-bold text-text-dark mb-2">Preference Cookies</h3>
            <p className="text-text-gray text-sm">
              Remember your settings and preferences, such as language and 
              display options.
            </p>
          </div>
        </div>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Managing Cookies</h2>
        <p className="text-text-gray mb-6">
          You can control cookies through your browser settings. Note that disabling 
          certain cookies may affect your ability to use some features of the platform.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Third-Party Cookies</h2>
        <p className="text-text-gray mb-6">
          We may use third-party services (like analytics providers) that set their 
          own cookies. These are governed by their respective privacy policies.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Contact</h2>
        <p className="text-text-gray">
          Questions about our cookie policy? Contact{' '}
          <a href="mailto:privacy@africageniusalliance.com" className="text-primary hover:underline">
            privacy@africageniusalliance.com
          </a>
        </p>
      </div>
    </StaticPageLayout>
  );
}

