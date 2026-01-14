import { StaticPageLayout } from '@/components/layout/StaticPageLayout';
import { UserPlus, Vote, TrendingUp, Zap, Shield, Users, Award, Heart } from 'lucide-react';

export default function HowItWorksPage() {
  return (
    <StaticPageLayout
      title="How It Works"
      subtitle="Understanding the Africa Genius Alliance Platform"
    >
      <div className="space-y-12">
        {/* Overview */}
        <div className="bg-gradient-to-br from-primary/5 to-secondary/5 rounded-2xl p-8 border-2 border-primary/20">
          <p className="text-text-gray text-lg leading-relaxed">
            Africa Genius Alliance is a merit-based platform connecting visionary African leaders (Geniuses)
            with engaged citizens (Supporters). Through transparent voting, direct engagement, and measurable
            impact tracking, we're building a new model for leadership selection and civic participation.
          </p>
        </div>

        {/* For Supporters */}
        <div className="bg-white rounded-2xl p-8 shadow-lg">
          <h2 className="text-3xl font-bold text-text-dark mb-8">For Supporters</h2>

          <div className="space-y-8">
            {/* Step 1 */}
            <div className="flex gap-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center">
                  <div className="text-2xl font-black text-primary">1</div>
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <UserPlus className="w-6 h-6 text-primary" />
                  <h3 className="text-xl font-bold text-text-dark">Sign Up & Create Profile</h3>
                </div>
                <p className="text-text-gray mb-4">
                  Create your free account using email or social login. Complete your profile with your
                  country and interests to get personalized recommendations.
                </p>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <p className="text-sm text-text-gray">
                    <strong>Pro Tip:</strong> Verify your email to unlock full voting rights and participation features.
                  </p>
                </div>
              </div>
            </div>

            {/* Step 2 */}
            <div className="flex gap-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center">
                  <div className="text-2xl font-black text-primary">2</div>
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <Users className="w-6 h-6 text-primary" />
                  <h3 className="text-xl font-bold text-text-dark">Discover Geniuses</h3>
                </div>
                <p className="text-text-gray mb-4">
                  Browse through verified Geniuses across different categories: Political, Technical, Oversight,
                  and Civic leaders. Filter by country, category, or trending status.
                </p>
                <div className="grid md:grid-cols-2 gap-3">
                  <div className="bg-gray-50 p-3 rounded-lg">
                    <p className="text-sm font-semibold text-text-dark mb-1">🏛️ Political</p>
                    <p className="text-xs text-text-gray">Policy makers & governance leaders</p>
                  </div>
                  <div className="bg-gray-50 p-3 rounded-lg">
                    <p className="text-sm font-semibold text-text-dark mb-1">👁️ Oversight</p>
                    <p className="text-xs text-text-gray">Accountability & transparency advocates</p>
                  </div>
                  <div className="bg-gray-50 p-3 rounded-lg">
                    <p className="text-sm font-semibold text-text-dark mb-1">⚙️ Technical</p>
                    <p className="text-xs text-text-gray">Innovation & technology leaders</p>
                  </div>
                  <div className="bg-gray-50 p-3 rounded-lg">
                    <p className="text-sm font-semibold text-text-dark mb-1">🤝 Civic</p>
                    <p className="text-xs text-text-gray">Community organizers & activists</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Step 3 */}
            <div className="flex gap-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center">
                  <div className="text-2xl font-black text-primary">3</div>
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <Vote className="w-6 h-6 text-primary" />
                  <h3 className="text-xl font-bold text-text-dark">Cast Your Votes</h3>
                </div>
                <p className="text-text-gray mb-4">
                  Vote for Geniuses whose vision and track record align with your values. Your votes directly
                  influence their ranking and visibility on the platform.
                </p>
                <div className="bg-primary/5 border border-primary/20 p-4 rounded-lg">
                  <p className="text-sm text-text-dark">
                    <Shield className="w-4 h-4 inline mr-2 text-primary" />
                    <strong>Secure & Transparent:</strong> All votes are recorded on-chain for complete transparency
                    and auditability.
                  </p>
                </div>
              </div>
            </div>

            {/* Step 4 */}
            <div className="flex gap-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center">
                  <div className="text-2xl font-black text-primary">4</div>
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <Zap className="w-6 h-6 text-primary" />
                  <h3 className="text-xl font-bold text-text-dark">Engage & Support</h3>
                </div>
                <p className="text-text-gray mb-4">
                  Follow Geniuses to get updates, watch live streams, comment on posts, and contribute to
                  their initiatives through donations or volunteering.
                </p>
                <ul className="space-y-2 text-text-gray text-sm">
                  <li className="flex gap-2">
                    <span className="text-primary">•</span>
                    <span>Watch live Q&A sessions and town halls</span>
                  </li>
                  <li className="flex gap-2">
                    <span className="text-primary">•</span>
                    <span>Comment and discuss policy proposals</span>
                  </li>
                  <li className="flex gap-2">
                    <span className="text-primary">•</span>
                    <span>Track impact and hold leaders accountable</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        {/* For Geniuses */}
        <div className="bg-white rounded-2xl p-8 shadow-lg border-l-4 border-secondary">
          <h2 className="text-3xl font-bold text-text-dark mb-8">For Geniuses</h2>

          <div className="space-y-8">
            {/* Step 1 */}
            <div className="flex gap-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full bg-secondary/10 flex items-center justify-center">
                  <div className="text-2xl font-black text-secondary">1</div>
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <Award className="w-6 h-6 text-secondary" />
                  <h3 className="text-xl font-bold text-text-dark">Apply for Verification</h3>
                </div>
                <p className="text-text-gray mb-4">
                  Submit your application with proof of expertise, credentials, and demonstrated impact in
                  your field. Our team reviews applications based on merit and verifiable achievements.
                </p>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <p className="text-sm font-semibold text-text-dark mb-2">Requirements:</p>
                  <ul className="space-y-1 text-sm text-text-gray">
                    <li>• Demonstrated expertise in your category</li>
                    <li>• Verifiable credentials or certifications</li>
                    <li>• Track record of impact or innovation</li>
                    <li>• Clear vision for African development</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Step 2 */}
            <div className="flex gap-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full bg-secondary/10 flex items-center justify-center">
                  <div className="text-2xl font-black text-secondary">2</div>
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <Users className="w-6 h-6 text-secondary" />
                  <h3 className="text-xl font-bold text-text-dark">Build Your Profile</h3>
                </div>
                <p className="text-text-gray mb-4">
                  Create a compelling profile showcasing your vision, achievements, and goals. Share your
                  story, upload credentials, and outline how you plan to create impact.
                </p>
              </div>
            </div>

            {/* Step 3 */}
            <div className="flex gap-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full bg-secondary/10 flex items-center justify-center">
                  <div className="text-2xl font-black text-secondary">3</div>
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <Zap className="w-6 h-6 text-secondary" />
                  <h3 className="text-xl font-bold text-text-dark">Engage Your Community</h3>
                </div>
                <p className="text-text-gray mb-4">
                  Post regular updates, go live to interact with supporters, share your work, and build
                  a following based on your ideas and impact.
                </p>
              </div>
            </div>

            {/* Step 4 */}
            <div className="flex gap-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full bg-secondary/10 flex items-center justify-center">
                  <div className="text-2xl font-black text-secondary">4</div>
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <TrendingUp className="w-6 h-6 text-secondary" />
                  <h3 className="text-xl font-bold text-text-dark">Grow & Lead</h3>
                </div>
                <p className="text-text-gray mb-4">
                  As you gain votes and support, your visibility increases. Top-ranked Geniuses get featured
                  placement, funding opportunities, and media coverage.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Key Features */}
        <div className="bg-gradient-to-r from-primary to-secondary rounded-2xl p-8 shadow-lg text-white">
          <h2 className="text-3xl font-bold mb-8">Platform Features</h2>

          <div className="grid md:grid-cols-2 gap-6">
            <div className="bg-white/10 backdrop-blur-sm p-6 rounded-xl">
              <Shield className="w-10 h-10 mb-3" />
              <h3 className="font-bold text-xl mb-2">Blockchain-Verified</h3>
              <p className="text-white/90 text-sm">
                All votes and transactions are recorded on-chain for complete transparency and immutability
              </p>
            </div>

            <div className="bg-white/10 backdrop-blur-sm p-6 rounded-xl">
              <Vote className="w-10 h-10 mb-3" />
              <h3 className="font-bold text-xl mb-2">Democratic Voting</h3>
              <p className="text-white/90 text-sm">
                One person, one vote. Every supporter has equal say in who rises to the top
              </p>
            </div>

            <div className="bg-white/10 backdrop-blur-sm p-6 rounded-xl">
              <Zap className="w-10 h-10 mb-3" />
              <h3 className="font-bold text-xl mb-2">Live Engagement</h3>
              <p className="text-white/90 text-sm">
                Real-time interaction through live streams, posts, and direct messaging
              </p>
            </div>

            <div className="bg-white/10 backdrop-blur-sm p-6 rounded-xl">
              <TrendingUp className="w-10 h-10 mb-3" />
              <h3 className="font-bold text-xl mb-2">Impact Metrics</h3>
              <p className="text-white/90 text-sm">
                Track real-world impact with measurable goals and transparent progress updates
              </p>
            </div>
          </div>
        </div>

        {/* CTA */}
        <div className="bg-white rounded-2xl p-8 shadow-lg text-center">
          <h2 className="text-3xl font-bold text-text-dark mb-4">Ready to Get Started?</h2>
          <p className="text-text-gray mb-8 max-w-2xl mx-auto">
            Join thousands of Africans building a merit-based future for our continent.
            Whether you're a supporter or aspiring Genius, there's a place for you here.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="/auth/signup"
              className="px-8 py-4 bg-primary text-white font-bold rounded-aga hover:bg-primary-dark transition-colors"
            >
              Sign Up as Supporter
            </a>
            <a
              href="/auth/signup?role=genius"
              className="px-8 py-4 bg-secondary text-white font-bold rounded-aga hover:bg-secondary-dark transition-colors"
            >
              Apply as Genius
            </a>
          </div>
        </div>
      </div>
    </StaticPageLayout>
  );
}
