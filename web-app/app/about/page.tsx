import { StaticPageLayout } from '@/components/layout/StaticPageLayout';

export default function AboutPage() {
  return (
    <StaticPageLayout title="About AGA" subtitle="Building Africa's Future Through Merit-Based Leadership">
      <div className="bg-white rounded-2xl p-8 shadow-lg">
        <h2 className="text-2xl font-bold text-text-dark mb-4">Our Story</h2>
        <p className="text-text-gray mb-6">
          Africa Genius Alliance (AGA) was founded with a bold vision: to transform how Africa 
          identifies, supports, and elevates its brightest minds. We believe that merit should 
          be the foundation of leadership, and that every African has the potential to contribute 
          to the continent's future.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">What We Do</h2>
        <p className="text-text-gray mb-6">
          AGA is a platform that connects visionary leaders (Geniuses) with supporters who 
          believe in their mission. Through transparent voting, direct engagement, and 
          accountability mechanisms, we create a new model for civic participation and 
          leadership development.
        </p>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Our Values</h2>
        <ul className="list-disc list-inside text-text-gray space-y-2 mb-6">
          <li><strong>Transparency:</strong> Every vote, every action is recorded and verifiable</li>
          <li><strong>Merit:</strong> Success is earned through demonstrated impact and community support</li>
          <li><strong>Inclusivity:</strong> Every voice matters, regardless of background or location</li>
          <li><strong>Accountability:</strong> Leaders are held to their commitments</li>
          <li><strong>Innovation:</strong> We embrace technology to solve Africa's unique challenges</li>
        </ul>

        <h2 className="text-2xl font-bold text-text-dark mb-4">Join the Movement</h2>
        <p className="text-text-gray">
          Whether you're a leader with a vision or a supporter looking to make an impact, 
          AGA provides the tools and platform to drive meaningful change. Together, we're 
          building an Africa where leadership is defined by capability, not connections.
        </p>
      </div>
    </StaticPageLayout>
  );
}

