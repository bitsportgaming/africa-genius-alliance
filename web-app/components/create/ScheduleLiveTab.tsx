'use client';

import { useState } from 'react';
import { AGAButton, AGAPill } from '@/components/ui';
import { Calendar, Clock, AlertCircle, CheckCircle } from 'lucide-react';

export function ScheduleLiveTab() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [date, setDate] = useState('');
  const [time, setTime] = useState('');
  const [scheduled, setScheduled] = useState(false);

  const handleSchedule = () => {
    // TODO: Implement backend scheduling
    setScheduled(true);
    setTimeout(() => {
      setScheduled(false);
      setTitle('');
      setDescription('');
      setDate('');
      setTime('');
    }, 3000);
  };

  const minDate = new Date().toISOString().split('T')[0];

  return (
    <div className="space-y-6">
      {/* Success Message */}
      {scheduled && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-aga text-green-700 flex items-center gap-2">
          <CheckCircle className="w-5 h-5" />
          <span className="font-medium">Live stream scheduled successfully!</span>
        </div>
      )}

      {/* Info Banner */}
      <div className="p-4 bg-blue-50 border border-blue-200 rounded-aga flex items-start gap-3">
        <AlertCircle className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" />
        <div>
          <h3 className="font-semibold text-blue-900 mb-1">
            Schedule a Live Stream
          </h3>
          <p className="text-sm text-blue-700">
            Plan ahead and notify your followers in advance. Scheduled streams appear in their calendar and send reminders.
          </p>
        </div>
      </div>

      {/* Stream Title */}
      <div>
        <label className="block text-sm font-semibold text-text-dark mb-2">
          Stream Title *
        </label>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="e.g., Monthly Town Hall Meeting"
          className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
        />
      </div>

      {/* Stream Description */}
      <div>
        <label className="block text-sm font-semibold text-text-dark mb-2">
          Description *
        </label>
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="What will you discuss? Why should supporters join?"
          rows={4}
          className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none resize-none transition-all"
        />
      </div>

      {/* Date & Time */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold text-text-dark mb-2">
            Date *
          </label>
          <div className="relative">
            <Calendar className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              min={minDate}
              className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-semibold text-text-dark mb-2">
            Time *
          </label>
          <div className="relative">
            <Clock className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="time"
              value={time}
              onChange={(e) => setTime(e.target.value)}
              className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
            />
          </div>
        </div>
      </div>

      {/* Settings */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="p-4 border border-gray-200 rounded-aga">
          <h4 className="font-semibold text-text-dark mb-3">Duration</h4>
          <select className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20">
            <option>30 minutes</option>
            <option>1 hour</option>
            <option>2 hours</option>
            <option>3 hours</option>
          </select>
        </div>

        <div className="p-4 border border-gray-200 rounded-aga">
          <h4 className="font-semibold text-text-dark mb-3">Reminders</h4>
          <div className="space-y-2">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                defaultChecked
                className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
              />
              <span className="text-sm text-text-gray">1 day before</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                defaultChecked
                className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
              />
              <span className="text-sm text-text-gray">1 hour before</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                defaultChecked
                className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
              />
              <span className="text-sm text-text-gray">At start time</span>
            </label>
          </div>
        </div>
      </div>

      {/* Preview */}
      {title && date && time && (
        <div className="p-4 bg-primary/5 border border-primary/20 rounded-aga">
          <h4 className="font-semibold text-text-dark mb-3">Preview</h4>
          <div className="flex items-start gap-4">
            <div className="w-16 h-16 rounded-xl bg-gradient-to-br from-secondary to-secondary-dark flex items-center justify-center flex-shrink-0">
              <Calendar className="w-8 h-8 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="font-bold text-text-dark mb-1">{title}</h3>
              <p className="text-sm text-text-gray mb-2">
                {description || 'No description provided'}
              </p>
              <div className="flex items-center gap-4 text-sm">
                <AGAPill variant="primary" size="sm">
                  {new Date(date).toLocaleDateString('en-US', {
                    weekday: 'short',
                    month: 'short',
                    day: 'numeric',
                  })}
                </AGAPill>
                <AGAPill variant="secondary" size="sm">
                  {time}
                </AGAPill>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Schedule Button */}
      <div className="flex items-center justify-between pt-4 border-t border-gray-200">
        <div className="text-sm text-text-gray">
          All followers will receive calendar invites
        </div>
        <AGAButton
          variant="primary"
          size="lg"
          onClick={handleSchedule}
          disabled={!title.trim() || !description.trim() || !date || !time}
          leftIcon={<Calendar className="w-5 h-5" />}
        >
          Schedule Stream
        </AGAButton>
      </div>

      {/* Upcoming Scheduled Streams */}
      <div className="pt-6 border-t border-gray-200">
        <h3 className="font-bold text-text-dark mb-4">
          Upcoming Scheduled Streams
        </h3>
        <div className="text-center py-8 text-text-gray">
          <Calendar className="w-12 h-12 text-gray-300 mx-auto mb-2" />
          <p>No scheduled streams yet</p>
        </div>
      </div>
    </div>
  );
}
