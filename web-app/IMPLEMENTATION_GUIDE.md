# AGA Web App - Implementation Guide

This guide provides a comprehensive overview of the completed implementation and instructions for completing the remaining features.

## ✅ COMPLETED

### 1. Project Setup
- ✅ Next.js 15 + TypeScript + Tailwind CSS
- ✅ Design system matching mobile app
- ✅ TypeScript types mirroring backend/mobile
- ✅ Project structure with app router

### 2. Design System
- ✅ `/lib/constants/design-system.ts` - All colors, gradients, typography, spacing
- ✅ Tailwind config with AGA branding
- ✅ Global CSS with custom scrollbar and base styles

### 3. UI Components
- ✅ `AGAButton` - Primary, secondary, outline, ghost variants
- ✅ `AGACard` - Default, hero, outlined, elevated variants
- ✅ `AGAPill` - Badge/tag component with color variants
- ✅ `AGAChip` - Selectable filter button

### 4. Landing Page (PRODUCTION READY)
- ✅ Hero Section with animated background
- ✅ How It Works Section (4 steps)
- ✅ Two User Paths (Genius vs Supporter)
- ✅ Transparency & Trust Section
- ✅ Footer with email signup, links, social

### 5. Authentication Infrastructure
- ✅ API Client with axios (request/response interceptors)
- ✅ Auth API service (register, login, profile management)
- ✅ Zustand store with persistence for auth state
- ✅ AuthProvider with React Context

### 6. Type System
- ✅ All types match backend MongoDB schemas
- ✅ User, Post, Comment, Vote, Election, GeniusProfile
- ✅ API response wrappers
- ✅ Enums for roles, categories, statuses

---

## 📝 REMAINING WORK

### Phase 1: Authentication Pages (NEXT PRIORITY)

#### `/app/auth/login/page.tsx`
```typescript
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/store/auth-store';
import { AGAButton, AGACard } from '@/components/ui';
import Link from 'next/link';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { login, isLoading, error } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await login({ email, password });
      router.push('/dashboard');
    } catch (err) {
      // Error handled in store
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-primary px-4">
      <AGACard className="max-w-md w-full" padding="lg">
        <h1 className="text-3xl font-black text-center mb-6">Welcome Back</h1>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-aga text-red-700 text-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-semibold mb-2">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold mb-2">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none"
            />
          </div>

          <AGAButton type="submit" variant="primary" fullWidth loading={isLoading}>
            Sign In
          </AGAButton>
        </form>

        <p className="mt-6 text-center text-sm text-gray-600">
          Don't have an account?{' '}
          <Link href="/auth/signup" className="text-primary font-semibold hover:underline">
            Sign up
          </Link>
        </p>
      </AGACard>
    </div>
  );
}
```

#### `/app/auth/signup/page.tsx`
Similar structure with role selection (genius vs supporter)

### Phase 2: Additional API Services

Create these files in `/lib/api/`:

1. **posts.ts** - Post CRUD, likes, comments
2. **users.ts** - User discovery, follow/unfollow, genius browsing
3. **voting.ts** - Elections, voting, candidates
4. **live.ts** - Live streaming (Socket.IO integration)
5. **comments.ts** - Comment CRUD, threading

Example structure:
```typescript
// /lib/api/posts.ts
import { apiClient } from './client';
import type { Post, APIResponse, PaginatedResponse } from '@/types';

export const postsAPI = {
  async getFeed(page = 1, limit = 20): Promise<PaginatedResponse<Post>> {
    return apiClient.get(`/posts?page=${page}&limit=${limit}`);
  },

  async createPost(data: {
    content: string;
    files?: File[];
    postType?: string;
  }): Promise<APIResponse<Post>> {
    const formData = new FormData();
    formData.append('content', data.content);
    if (data.postType) formData.append('postType', data.postType);
    data.files?.forEach(file => formData.append('files', file));

    return apiClient.uploadFile('/posts', formData);
  },

  async likePost(postId: string): Promise<APIResponse<{ liked: boolean }>> {
    return apiClient.post(`/posts/${postId}/like`);
  },

  async deletePost(postId: string): Promise<APIResponse<void>> {
    return apiClient.delete(`/posts/${postId}`);
  },
};
```

### Phase 3: Protected Route Wrapper

Create `/components/layout/ProtectedRoute.tsx`:
```typescript
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/store/auth-store';
import { UserRole } from '@/types';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRole?: UserRole;
}

export function ProtectedRoute({ children, requiredRole }: ProtectedRouteProps) {
  const { user, isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    } else if (requiredRole && user?.role !== requiredRole) {
      router.push('/dashboard');
    }
  }, [isAuthenticated, user, requiredRole, router]);

  if (!isAuthenticated || (requiredRole && user?.role !== requiredRole)) {
    return null;
  }

  return <>{children}</>;
}
```

### Phase 4: Dashboard Layout

Create `/components/layout/DashboardLayout.tsx`:
```typescript
'use client';

import { useAuth } from '@/lib/store/auth-store';
import { UserRole } from '@/types';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Home, Compass, Vote, PlusCircle, TrendingUp,
  User, Bell, Menu, X
} from 'lucide-react';
import { useState } from 'react';

export function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const isGenius = user?.role === UserRole.GENIUS;

  const navigation = [
    { name: 'Home', href: '/dashboard', icon: Home, show: true },
    { name: 'Explore', href: '/explore', icon: Compass, show: true },
    { name: 'Vote', href: '/vote', icon: Vote, show: !isGenius },
    { name: 'Create', href: '/create', icon: PlusCircle, show: isGenius },
    { name: 'Impact', href: '/impact', icon: TrendingUp, show: true },
    { name: 'Profile', href: '/profile', icon: User, show: true },
  ].filter(item => item.show);

  return (
    <div className="min-h-screen bg-background-cream">
      {/* Top Navigation */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-40">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <Link href="/dashboard" className="text-2xl font-black text-primary">
              AGA
            </Link>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center gap-6">
              {navigation.map((item) => {
                const Icon = item.icon;
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`flex items-center gap-2 px-3 py-2 rounded-lg font-medium transition-colors ${
                      isActive
                        ? 'bg-primary text-white'
                        : 'text-gray-700 hover:bg-gray-100'
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                    <span>{item.name}</span>
                  </Link>
                );
              })}
            </div>

            {/* Right Side */}
            <div className="flex items-center gap-4">
              <button className="relative p-2 hover:bg-gray-100 rounded-full">
                <Bell className="w-6 h-6 text-gray-700" />
                <span className="absolute top-1 right-1 w-2 h-2 bg-secondary rounded-full" />
              </button>

              <div className="flex items-center gap-2">
                <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold">
                  {user?.displayName?.[0] || 'U'}
                </div>
              </div>

              <button
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="md:hidden p-2"
              >
                {mobileMenuOpen ? <X /> : <Menu />}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden border-t border-gray-200 py-4 px-4 space-y-2">
            {navigation.map((item) => {
              const Icon = item.icon;
              const isActive = pathname === item.href;
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`flex items-center gap-3 px-4 py-3 rounded-lg font-medium ${
                    isActive
                      ? 'bg-primary text-white'
                      : 'text-gray-700 hover:bg-gray-100'
                  }`}
                  onClick={() => setMobileMenuOpen(false)}
                >
                  <Icon className="w-5 h-5" />
                  <span>{item.name}</span>
                </Link>
              );
            })}
            <button
              onClick={logout}
              className="w-full text-left px-4 py-3 text-red-600 hover:bg-red-50 rounded-lg font-medium"
            >
              Logout
            </button>
          </div>
        )}
      </nav>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        {children}
      </main>
    </div>
  );
}
```

### Phase 5: Dashboard Pages

#### Genius Home (`/app/dashboard/page.tsx` - for Genius role)
Key sections:
1. **Impact Snapshot** - 4 stat cards (Votes, Followers, Rank, Profile Views) with 24h delta
2. **Command Center** - 6 action cards (Post, Go Live, Analytics, Inbox, Campaign, Settings)
3. **Alerts & Opportunities** - Recent notifications
4. **Leaderboard Preview** - Top 5 geniuses with sparkline charts

#### Supporter Home (`/app/dashboard/page.tsx` - for Supporter role)
Key sections:
1. **Quick Stats** - Votes Cast, Following, Donated
2. **Live Streams** - Active live streams with viewer count
3. **Trending Geniuses** - Horizontal carousel
4. **Category Browse** - Grid of categories
5. **Feed** - Posts feed with filters (For You, Following, Trending, Live)

#### Explore Page (`/app/explore/page.tsx`)
- Grid/list view toggle
- Filters: Country, Category, Position
- Search bar
- Genius cards with stats
- Pagination

#### Vote Page (`/app/vote/page.tsx` - Supporter only)
- Active elections list
- Election details with candidates
- Candidate comparison table
- Vote slider (1-4 votes per candidate)
- Vote confirmation modal
- Transaction hash display (blockchain-ready)

#### Create Page (`/app/create/page.tsx` - Genius only)
Tabs:
1. **Post** - Text area (500 char), image/video upload, preview
2. **Go Live** - Camera setup, title, description, start button
3. **Schedule Live** - Date/time picker (UI only if backend not ready)
4. **Proposal** - Long-form manifesto editor

#### Impact Page (`/app/impact/page.tsx`)
**Supporter View:**
- Leaderboard table (rank, name, category, votes, followers, trend)
- Filter by country/category
- Rising Geniuses section

**Genius View:**
- Rank card with 7d/24h momentum
- Stats grid (Votes, Followers, Views, Comments)
- Vote trend chart (recharts line chart)
- Follower trend chart
- Comparison with peer geniuses
- CTA: "Increase Impact" → redirects to Create

#### Profile Page (`/app/profile/page.tsx`)
- Avatar upload
- Bio editor
- Stats display
- Settings accordion
- Logout button

### Phase 6: Socket.IO Integration (Optional for MVP)

Create `/lib/socket/client.ts`:
```typescript
import { io, Socket } from 'socket.io-client';

class SocketClient {
  private socket: Socket | null = null;

  connect(token: string) {
    this.socket = io(process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001', {
      auth: { token },
      transports: ['websocket'],
    });

    this.socket.on('connect', () => {
      console.log('Socket connected');
    });

    this.socket.on('disconnect', () => {
      console.log('Socket disconnected');
    });

    return this.socket;
  }

  disconnect() {
    this.socket?.disconnect();
    this.socket = null;
  }

  emit(event: string, data: any) {
    this.socket?.emit(event, data);
  }

  on(event: string, callback: (data: any) => void) {
    this.socket?.on(event, callback);
  }

  off(event: string) {
    this.socket?.off(event);
  }
}

export const socketClient = new SocketClient();
```

---

## 🎨 STYLING GUIDELINES

### Spacing
- Container: `container mx-auto px-4`
- Section padding: `py-20 md:py-32`
- Card padding: `p-6` (default), `p-8` (large)
- Gap between elements: `gap-4` (small), `gap-8` (medium)

### Typography
- Page titles: `text-4xl md:text-5xl font-black`
- Section titles: `text-3xl font-bold`
- Card titles: `text-xl font-semibold`
- Body text: `text-base leading-relaxed`

### Colors
- Primary actions: `bg-primary` or `bg-gradient-primary`
- Secondary actions: `bg-secondary` or `bg-gradient-accent`
- Backgrounds: `bg-background-cream` (light), `bg-background-navy` (dark)
- Text: `text-text-dark` (primary), `text-text-gray` (secondary)

### Responsive Breakpoints
- Mobile: default
- Tablet: `md:` (768px)
- Desktop: `lg:` (1024px)
- Large: `xl:` (1280px)

---

## 🔧 ENVIRONMENT VARIABLES

Create `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```

---

## 🚀 DEPLOYMENT CHECKLIST

1. ✅ Install dependencies: `npm install`
2. ✅ Run backend: `cd ../backend && npm start`
3. ⬜ Complete auth pages
4. ⬜ Complete API services
5. ⬜ Complete dashboard pages
6. ⬜ Test all user flows
7. ⬜ Add error boundaries
8. ⬜ Add loading states
9. ⬜ Optimize images
10. ⬜ Run `npm run build`
11. ⬜ Deploy to Vercel/Netlify

---

## 📦 QUICK START

```bash
# Install dependencies
cd web-app
npm install

# Run development server
npm run dev

# Open http://localhost:3000
```

## 🎯 PRIORITY ORDER

1. Auth pages (login/signup) - CRITICAL
2. Dashboard layout - CRITICAL
3. API services (posts, users, voting) - HIGH
4. Genius home page - HIGH
5. Supporter home page - HIGH
6. Explore page - MEDIUM
7. Create page (Genius) - MEDIUM
8. Impact page - MEDIUM
9. Vote page (Supporter) - MEDIUM
10. Profile page - LOW
11. Live streaming - OPTIONAL

---

## 🔗 BACKEND ENDPOINTS REFERENCE

All endpoints are prefixed with `/api`:

**Auth:**
- POST `/auth/register`
- POST `/auth/login`
- GET `/auth/profile/:userId`
- PUT `/auth/profile/:userId`

**Posts:**
- GET `/posts?page=1&limit=20`
- POST `/posts` (multipart)
- GET `/posts/:id`
- POST `/posts/:id/like`
- DELETE `/posts/:id`

**Users:**
- GET `/users/geniuses?category=X`
- POST `/users/:id/follow`

**Voting:**
- POST `/voting/vote`
- GET `/voting/elections`

**Comments:**
- POST `/comments`
- GET `/posts/:postId/comments`

**Live:**
- POST `/live/start`
- POST `/live/end/:streamId`
- GET `/live/active`

---

This guide provides everything needed to complete the AGA web app. Follow the priority order for efficient development.
