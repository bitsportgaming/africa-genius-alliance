import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function TeamPage() {
  const team = [
    { name: 'Founding Team', role: 'Leadership', desc: 'A diverse group of African technologists, entrepreneurs, and civic leaders.' },
  ];

  return (
    <StaticPageLayout title="Our Team" subtitle="The People Behind Africa Genius Alliance">
      <div className="bg-white rounded-2xl p-8 shadow-lg">
        <h2 className="text-2xl font-bold text-text-dark mb-4">Leadership</h2>
        <p className="text-text-gray mb-6">
          AGA is led by a passionate team of Africans who believe in the power of 
          technology to transform leadership and civic engagement on the continent.
        </p>

        <div className="bg-gradient-to-br from-primary/10 to-secondary/10 p-8 rounded-xl mb-8 text-center">
          <div className="w-24 h-24 bg-gradient-accent rounded-full flex items-center justify-center text-white text-4xl font-bold mx-auto mb-4">
            🌍
          </div>
          <h3 className="text-xl font-bold text-text-dark mb-2">Built by Africans, for Africa</h3>
          <p className="text-text-gray">
            Our team spans across the continent, bringing diverse perspectives and 
            deep understanding of Africa's unique challenges and opportunities.
          </p>
        </div>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Join Our Team</h2>
        <p className="text-text-gray mb-4">
          We're always looking for passionate individuals who want to make a difference. 
          If you believe in our mission and want to contribute, we'd love to hear from you.
        </p>
        <a 
          href="/careers" 
          className="inline-block bg-primary text-white px-6 py-3 rounded-lg font-semibold hover:bg-primary-dark transition-colors"
        >
          View Open Positions
        </a>
      </div>
    </StaticPageLayout>
  );
}

