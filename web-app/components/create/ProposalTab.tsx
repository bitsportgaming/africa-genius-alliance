'use client';

import { useState } from 'react';
import { AGAButton, AGAPill } from '@/components/ui';
import { FileEdit, Save, Eye, AlertCircle } from 'lucide-react';
import { useAuth } from '@/lib/store/auth-store';

export function ProposalTab() {
  const { user } = useAuth();
  const [title, setTitle] = useState('');
  const [vision, setVision] = useState('');
  const [keyPolicies, setKeyPolicies] = useState('');
  const [implementation, setImplementation] = useState('');
  const [preview, setPreview] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  const totalWords = (vision + keyPolicies + implementation)
    .split(/\s+/)
    .filter((word) => word.length > 0).length;

  const handleSave = async () => {
    setIsSaving(true);

    // TODO: Implement API call to save manifesto
    setTimeout(() => {
      setIsSaving(false);
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    }, 1000);
  };

  if (preview) {
    return (
      <div className="space-y-6">
        {/* Preview Header */}
        <div className="flex items-center justify-between pb-4 border-b border-gray-200">
          <h3 className="text-2xl font-black text-text-dark">Preview Mode</h3>
          <AGAButton
            variant="outline"
            size="sm"
            onClick={() => setPreview(false)}
          >
            ← Back to Edit
          </AGAButton>
        </div>

        {/* Preview Content */}
        <div className="prose max-w-none">
          {/* Title */}
          <h1 className="text-4xl font-black text-text-dark mb-4">
            {title || 'Untitled Proposal'}
          </h1>

          <div className="flex items-center gap-3 mb-6">
            <div className="w-12 h-12 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold">
              {user?.displayName?.[0]}
            </div>
            <div>
              <p className="font-semibold text-text-dark">
                {user?.displayName}
              </p>
              <p className="text-sm text-text-gray">
                {user?.geniusPosition || 'Position'}
              </p>
            </div>
          </div>

          {/* Vision */}
          {vision && (
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-text-dark mb-3">
                Vision Statement
              </h2>
              <div className="whitespace-pre-wrap text-text-gray">
                {vision}
              </div>
            </div>
          )}

          {/* Key Policies */}
          {keyPolicies && (
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-text-dark mb-3">
                Key Policies & Initiatives
              </h2>
              <div className="whitespace-pre-wrap text-text-gray">
                {keyPolicies}
              </div>
            </div>
          )}

          {/* Implementation */}
          {implementation && (
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-text-dark mb-3">
                Implementation Plan
              </h2>
              <div className="whitespace-pre-wrap text-text-gray">
                {implementation}
              </div>
            </div>
          )}

          {!vision && !keyPolicies && !implementation && (
            <div className="text-center py-12 text-text-gray">
              <FileEdit className="w-16 h-16 text-gray-300 mx-auto mb-3" />
              <p>Start writing to see your proposal preview</p>
            </div>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Success Message */}
      {saved && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-aga text-green-700 flex items-center gap-2">
          <Save className="w-5 h-5" />
          <span className="font-medium">Proposal saved successfully!</span>
        </div>
      )}

      {/* Info Banner */}
      <div className="p-4 bg-blue-50 border border-blue-200 rounded-aga flex items-start gap-3">
        <AlertCircle className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" />
        <div>
          <h3 className="font-semibold text-blue-900 mb-1">
            Write Your Manifesto
          </h3>
          <p className="text-sm text-blue-700">
            Your proposal is your promise to supporters. Detail your vision, policies, and implementation plan. This will be featured prominently on your profile.
          </p>
        </div>
      </div>

      {/* Title */}
      <div>
        <label className="block text-sm font-semibold text-text-dark mb-2">
          Proposal Title *
        </label>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="e.g., A New Vision for Healthcare Reform"
          className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all text-xl font-semibold"
        />
      </div>

      {/* Vision Statement */}
      <div>
        <label className="block text-sm font-semibold text-text-dark mb-2">
          Vision Statement *
        </label>
        <p className="text-xs text-text-gray mb-2">
          What is your overarching vision? What change do you want to see?
        </p>
        <textarea
          value={vision}
          onChange={(e) => setVision(e.target.value)}
          placeholder="Describe your vision for the future..."
          rows={6}
          className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none resize-none transition-all"
        />
      </div>

      {/* Key Policies */}
      <div>
        <label className="block text-sm font-semibold text-text-dark mb-2">
          Key Policies & Initiatives *
        </label>
        <p className="text-xs text-text-gray mb-2">
          What specific policies will you implement? What are your priorities?
        </p>
        <textarea
          value={keyPolicies}
          onChange={(e) => setKeyPolicies(e.target.value)}
          placeholder="List your key policies, one per line or paragraph..."
          rows={8}
          className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none resize-none transition-all"
        />
      </div>

      {/* Implementation Plan */}
      <div>
        <label className="block text-sm font-semibold text-text-dark mb-2">
          Implementation Plan *
        </label>
        <p className="text-xs text-text-gray mb-2">
          How will you execute these policies? What's your timeline and strategy?
        </p>
        <textarea
          value={implementation}
          onChange={(e) => setImplementation(e.target.value)}
          placeholder="Outline your implementation strategy..."
          rows={8}
          className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none resize-none transition-all"
        />
      </div>

      {/* Word Count */}
      <div className="flex items-center justify-between py-3 px-4 bg-gray-50 rounded-aga">
        <span className="text-sm text-text-gray">Total Words</span>
        <AGAPill
          variant={totalWords < 100 ? 'warning' : totalWords < 300 ? 'neutral' : 'success'}
          size="sm"
        >
          {totalWords} words
        </AGAPill>
      </div>

      {/* Action Buttons */}
      <div className="flex items-center justify-between pt-4 border-t border-gray-200">
        <AGAButton
          variant="outline"
          size="md"
          onClick={() => setPreview(true)}
          leftIcon={<Eye className="w-5 h-5" />}
        >
          Preview
        </AGAButton>

        <div className="flex gap-3">
          <AGAButton
            variant="ghost"
            size="md"
            onClick={() => {
              setTitle('');
              setVision('');
              setKeyPolicies('');
              setImplementation('');
            }}
          >
            Clear All
          </AGAButton>
          <AGAButton
            variant="primary"
            size="md"
            onClick={handleSave}
            loading={isSaving}
            disabled={!title.trim() || !vision.trim() || !keyPolicies.trim() || !implementation.trim()}
            leftIcon={<Save className="w-5 h-5" />}
          >
            Save Proposal
          </AGAButton>
        </div>
      </div>

      {/* Writing Tips */}
      <div className="p-4 bg-gray-50 rounded-aga">
        <h4 className="font-semibold text-text-dark mb-2">
          💡 Writing Tips
        </h4>
        <ul className="space-y-1 text-sm text-text-gray">
          <li>• Be specific and concrete rather than vague and abstract</li>
          <li>• Use data and examples to support your claims</li>
          <li>• Address potential challenges and how you'll overcome them</li>
          <li>• Make your vision relatable to everyday citizens</li>
          <li>• Aim for 500-1000 words for optimal engagement</li>
          <li>• Proofread carefully before publishing</li>
        </ul>
      </div>
    </div>
  );
}
