import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function CareersPage() {
  const positions = [
    { title: 'Senior Full Stack Developer', location: 'Remote (Africa)', type: 'Full-time' },
    { title: 'Product Designer', location: 'Remote (Africa)', type: 'Full-time' },
    { title: 'Community Manager', location: 'Lagos, Nigeria', type: 'Full-time' },
    { title: 'Marketing Lead', location: 'Remote (Africa)', type: 'Full-time' },
  ];

  return (
    <StaticPageLayout title="Careers" subtitle="Join Us in Shaping Africa's Future">
      <div className="bg-white rounded-2xl p-8 shadow-lg">
        <h2 className="text-2xl font-bold text-text-dark mb-4">Why Work at AGA?</h2>
        <p className="text-text-gray mb-6">
          At AGA, you'll work on meaningful problems that directly impact millions of 
          Africans. We offer competitive compensation, remote work flexibility, and 
          the opportunity to be part of something transformative.
        </p>

        <div className="grid md:grid-cols-3 gap-4 mb-8">
          <div className="bg-primary/10 p-4 rounded-xl text-center">
            <div className="text-3xl mb-2">🌍</div>
            <h3 className="font-bold text-text-dark">Remote-First</h3>
            <p className="text-sm text-text-gray">Work from anywhere in Africa</p>
          </div>
          <div className="bg-secondary/10 p-4 rounded-xl text-center">
            <div className="text-3xl mb-2">💰</div>
            <h3 className="font-bold text-text-dark">Competitive Pay</h3>
            <p className="text-sm text-text-gray">Market-rate compensation</p>
          </div>
          <div className="bg-green-500/10 p-4 rounded-xl text-center">
            <div className="text-3xl mb-2">🚀</div>
            <h3 className="font-bold text-text-dark">Growth</h3>
            <p className="text-sm text-text-gray">Learn and grow with us</p>
          </div>
        </div>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Open Positions</h2>
        <div className="space-y-4">
          {positions.map((position, index) => (
            <div key={index} className="border border-gray-200 rounded-xl p-4 hover:border-primary transition-colors">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="font-bold text-text-dark">{position.title}</h3>
                  <p className="text-sm text-text-gray">{position.location} • {position.type}</p>
                </div>
                <button className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-primary-dark transition-colors">
                  Apply
                </button>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-8 p-6 bg-gray-50 rounded-xl">
          <h3 className="font-bold text-text-dark mb-2">Don't see a fit?</h3>
          <p className="text-text-gray text-sm">
            Send your resume to <a href="mailto:careers@africageniusalliance.com" className="text-primary hover:underline">careers@africageniusalliance.com</a> 
            and tell us how you'd like to contribute.
          </p>
        </div>
      </div>
    </StaticPageLayout>
  );
}

