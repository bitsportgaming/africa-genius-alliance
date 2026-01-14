import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function MissionPage() {
  return (
    <StaticPageLayout title="Our Mission" subtitle="Empowering Africa Through Merit-Based Leadership">
      <div className="space-y-8">
        {/* Mission Statement */}
        <div className="bg-white rounded-2xl p-8 shadow-lg">
          <h2 className="text-2xl font-bold text-text-dark mb-4">Mission Statement</h2>
          <p className="text-text-gray mb-6 text-xl">
            To democratize leadership selection in Africa by creating a transparent, merit-based
            platform that connects visionary leaders with engaged citizens, fostering accountability
            and driving sustainable development across the continent.
          </p>
        </div>

        {/* Vision */}
        <div className="bg-gradient-to-br from-primary/5 to-secondary/5 rounded-2xl p-8 shadow-lg border-2 border-primary/20">
          <h2 className="text-3xl font-bold text-text-dark mb-6">Vision</h2>
          <p className="text-text-gray mb-6 text-lg leading-relaxed">
            An Africa where every person can participate in shaping their future, where leaders
            are chosen based on their ideas and impact, and where technology bridges the gap
            between citizens and those who represent them.
          </p>
          <div className="grid md:grid-cols-3 gap-4 mt-6">
            <div className="bg-white/80 p-4 rounded-xl">
              <div className="text-3xl mb-2">🌍</div>
              <h3 className="font-bold text-text-dark mb-2">Pan-African Unity</h3>
              <p className="text-text-gray text-sm">A connected continent where borders don't limit opportunity</p>
            </div>
            <div className="bg-white/80 p-4 rounded-xl">
              <div className="text-3xl mb-2">⚡</div>
              <h3 className="font-bold text-text-dark mb-2">Innovation First</h3>
              <p className="text-text-gray text-sm">Technology-driven solutions for age-old challenges</p>
            </div>
            <div className="bg-white/80 p-4 rounded-xl">
              <div className="text-3xl mb-2">🎯</div>
              <h3 className="font-bold text-text-dark mb-2">Merit Over Politics</h3>
              <p className="text-text-gray text-sm">Competence and impact as the only currencies that matter</p>
            </div>
          </div>
        </div>

        {/* Manifesto */}
        <div className="bg-white rounded-2xl p-8 shadow-lg">
          <h2 className="text-3xl font-bold text-text-dark mb-6">Manifesto</h2>
          <div className="space-y-6">
            <div>
              <h3 className="text-xl font-bold text-primary mb-3">We Believe...</h3>
              <ul className="space-y-3 text-text-gray">
                <li className="flex gap-3">
                  <span className="text-primary font-bold">•</span>
                  <span>In the power of African genius and the untapped potential of our continent</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-primary font-bold">•</span>
                  <span>That leadership should be earned through demonstrated excellence, not inherited or bought</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-primary font-bold">•</span>
                  <span>That transparency and accountability are non-negotiable in public service</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-primary font-bold">•</span>
                  <span>That every African deserves a voice in shaping their future</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-primary font-bold">•</span>
                  <span>That technology can bridge the gap between citizens and leaders</span>
                </li>
              </ul>
            </div>

            <div>
              <h3 className="text-xl font-bold text-primary mb-3">We Commit To...</h3>
              <ul className="space-y-3 text-text-gray">
                <li className="flex gap-3">
                  <span className="text-secondary font-bold">•</span>
                  <span>Building a platform free from corruption and external influence</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-secondary font-bold">•</span>
                  <span>Empowering the next generation of African leaders</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-secondary font-bold">•</span>
                  <span>Creating opportunities for meaningful civic engagement</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-secondary font-bold">•</span>
                  <span>Measuring success by real impact, not vanity metrics</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-secondary font-bold">•</span>
                  <span>Remaining accountable to our community above all else</span>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* Constitution */}
        <div className="bg-white rounded-2xl p-8 shadow-lg border-l-4 border-primary">
          <h2 className="text-3xl font-bold text-text-dark mb-6">Constitution</h2>

          <div className="space-y-8">
            <section>
              <h3 className="text-xl font-bold text-text-dark mb-4">Article I: Core Principles</h3>
              <ol className="list-decimal list-inside space-y-3 text-text-gray ml-4">
                <li><strong>Merit-Based Selection:</strong> All Geniuses must demonstrate verifiable expertise and impact in their field</li>
                <li><strong>Transparency:</strong> All votes, funding, and activities shall be publicly recorded and auditable</li>
                <li><strong>Non-Discrimination:</strong> Participation is open to all Africans regardless of nationality, gender, religion, or background</li>
                <li><strong>Independence:</strong> The platform shall remain free from government, corporate, or external control</li>
              </ol>
            </section>

            <section>
              <h3 className="text-xl font-bold text-text-dark mb-4">Article II: Rights of Members</h3>
              <ol className="list-decimal list-inside space-y-3 text-text-gray ml-4">
                <li><strong>Right to Vote:</strong> Every verified supporter may vote for Geniuses in their categories</li>
                <li><strong>Right to Information:</strong> Access to complete records of votes, funding, and Genius activities</li>
                <li><strong>Right to Participate:</strong> Freedom to post, comment, and engage in community discussions</li>
                <li><strong>Right to Privacy:</strong> Personal data protection and control over information sharing</li>
              </ol>
            </section>

            <section>
              <h3 className="text-xl font-bold text-text-dark mb-4">Article III: Responsibilities of Geniuses</h3>
              <ol className="list-decimal list-inside space-y-3 text-text-gray ml-4">
                <li><strong>Accountability:</strong> Regular reporting on goals, progress, and use of resources</li>
                <li><strong>Engagement:</strong> Active communication with supporters through posts, live streams, and updates</li>
                <li><strong>Impact:</strong> Demonstrable contribution to African development and community welfare</li>
                <li><strong>Integrity:</strong> Adherence to ethical standards and community guidelines</li>
              </ol>
            </section>

            <section>
              <h3 className="text-xl font-bold text-text-dark mb-4">Article IV: Governance</h3>
              <ol className="list-decimal list-inside space-y-3 text-text-gray ml-4">
                <li><strong>Community-Driven:</strong> Major platform decisions shall involve community consultation</li>
                <li><strong>Regular Reviews:</strong> Constitution may be amended with community consensus</li>
                <li><strong>Dispute Resolution:</strong> Fair and transparent process for addressing conflicts</li>
                <li><strong>Enforcement:</strong> Clear consequences for violations of community standards</li>
              </ol>
            </section>
          </div>
        </div>

        {/* How We Achieve This */}
        <div className="bg-white rounded-2xl p-8 shadow-lg">
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
        </div>

        {/* 2030 Goals */}
        <div className="bg-gradient-to-r from-primary to-secondary rounded-2xl p-8 shadow-lg text-white">
          <h2 className="text-3xl font-bold mb-6">2030 Goals</h2>
          <div className="grid md:grid-cols-2 gap-6">
            <div className="flex items-center gap-4">
              <div className="text-4xl font-black opacity-50">50M</div>
              <div>Active users across Africa</div>
            </div>
            <div className="flex items-center gap-4">
              <div className="text-4xl font-black opacity-50">1K+</div>
              <div>Verified Geniuses creating measurable impact</div>
            </div>
            <div className="flex items-center gap-4">
              <div className="text-4xl font-black opacity-50">$100M</div>
              <div>In transparent funding distributed</div>
            </div>
            <div className="flex items-center gap-4">
              <div className="text-4xl font-black opacity-50">54</div>
              <div>Active presence in all African countries</div>
            </div>
          </div>
        </div>
      </div>
    </StaticPageLayout>
  );
}

