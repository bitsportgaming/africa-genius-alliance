import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function MissionPage() {
  return (
    <StaticPageLayout title="Our Mission" subtitle="Empowering Africa Through Merit-Based Leadership">
      <div className="bg-white rounded-2xl p-8 shadow-lg">
        <h2 className="text-2xl font-bold text-text-dark mb-4">Mission Statement</h2>
        <p className="text-text-gray mb-6 text-xl">
          To democratize leadership selection in Africa by creating a transparent, merit-based 
          platform that connects visionary leaders with engaged citizens, fostering accountability 
          and driving sustainable development across the continent.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Our Vision</h2>
        <p className="text-text-gray mb-6">
          An Africa where every person can participate in shaping their future, where leaders 
          are chosen based on their ideas and impact, and where technology bridges the gap 
          between citizens and those who represent them.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">How We Achieve This</h2>
        <div className="grid md:grid-cols-2 gap-6 mb-6">
          <div className="bg-gray-50 p-6 rounded-xl">
            <h3 className="font-bold text-text-dark mb-2">🗳️ Democratic Voting</h3>
            <p className="text-text-gray text-sm">Every citizen can vote for leaders based on their demonstrated capabilities and vision.</p>
          </div>
          <div className="bg-gray-50 p-6 rounded-xl">
            <h3 className="font-bold text-text-dark mb-2">🔍 Transparency</h3>
            <p className="text-text-gray text-sm">All votes and funding are tracked on-chain, ensuring complete transparency.</p>
          </div>
          <div className="bg-gray-50 p-6 rounded-xl">
            <h3 className="font-bold text-text-dark mb-2">💬 Direct Engagement</h3>
            <p className="text-text-gray text-sm">Live streams, posts, and comments create direct connection between leaders and supporters.</p>
          </div>
          <div className="bg-gray-50 p-6 rounded-xl">
            <h3 className="font-bold text-text-dark mb-2">📊 Impact Tracking</h3>
            <p className="text-text-gray text-sm">Leaders are measured by their real-world impact, not just promises.</p>
          </div>
        </div>

        <h2 className="text-2xl font-bold text-text-dark mb-4">2030 Goals</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2">
          <li>50 million active users across Africa</li>
          <li>1,000+ verified Geniuses creating measurable impact</li>
          <li>$100 million in transparent funding distributed</li>
          <li>Active presence in all 54 African countries</li>
        </ul>
      </div>
    </StaticPageLayout>
  );
}

