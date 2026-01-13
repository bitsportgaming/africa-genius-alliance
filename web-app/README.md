# Africa Genius Alliance - Web App

A production-grade React web application for Africa Genius Alliance, built with Next.js, TypeScript, and Tailwind CSS.

## 🎯 Overview

AGA Web App is the desktop companion to the AGA mobile app, providing a full-featured merit-based leadership platform where:

- **Geniuses** can lead with ideas, post manifestos, go live, and track their impact
- **Supporters** can discover leaders, vote on merit, and shape Africa's future

## ✨ Features

### Landing Page (Public)
- ✅ Hero section with CTAs
- ✅ How It Works (4-step process)
- ✅ Two User Paths (Genius vs Supporter)
- ✅ Transparency & Trust section
- ✅ Footer with email signup

### Authenticated Web App
- ✅ Role-based authentication (Genius / Supporter)
- ✅ Dashboard with role-specific navigation
- 🚧 Genius Home (Impact snapshot, Command Center)
- 🚧 Supporter Home (Stats, Live Streams, Feed)
- 🚧 Explore (Genius discovery with filters)
- 🚧 Vote (Elections & candidate comparison)
- 🚧 Create (Post, Go Live, Proposals)
- 🚧 Impact (Leaderboards & analytics)
- 🚧 Profile (Settings & stats)

## 🛠 Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **State Management**: Zustand + React Context
- **Data Fetching**: TanStack React Query
- **HTTP Client**: Axios
- **Real-time**: Socket.IO Client (optional)
- **Icons**: Lucide React

## 📁 Project Structure

```
web-app/
├── app/                      # Next.js App Router
│   ├── auth/                 # Authentication pages
│   │   ├── login/
│   │   └── signup/
│   ├── dashboard/            # Main dashboard
│   ├── explore/              # Genius discovery
│   ├── vote/                 # Voting interface
│   ├── create/               # Content creation (Genius)
│   ├── impact/               # Impact analytics
│   ├── profile/              # User profile
│   ├── layout.tsx            # Root layout
│   ├── page.tsx              # Landing page
│   └── globals.css           # Global styles
├── components/               # React components
│   ├── ui/                   # Reusable UI components
│   │   ├── AGAButton.tsx
│   │   ├── AGACard.tsx
│   │   ├── AGAPill.tsx
│   │   └── AGAChip.tsx
│   ├── landing/              # Landing page sections
│   │   ├── HeroSection.tsx
│   │   ├── HowItWorksSection.tsx
│   │   ├── TwoPathsSection.tsx
│   │   ├── TransparencySection.tsx
│   │   └── Footer.tsx
│   └── layout/               # Layout components
│       └── DashboardLayout.tsx
├── lib/                      # Utilities & services
│   ├── api/                  # API services
│   │   ├── client.ts         # Axios client
│   │   └── auth.ts           # Auth API
│   ├── store/                # State management
│   │   └── auth-store.tsx    # Auth store (Zustand)
│   ├── constants/            # Constants & config
│   │   └── design-system.ts  # Design tokens
│   └── utils/                # Helper functions
├── types/                    # TypeScript types
│   └── index.ts              # Core types
├── public/                   # Static assets
├── tailwind.config.ts        # Tailwind configuration
├── tsconfig.json             # TypeScript configuration
└── next.config.js            # Next.js configuration
```

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ and npm
- Running AGA backend server (see `/backend`)

### Installation

1. **Install dependencies**
   ```bash
   cd web-app
   npm install
   ```

2. **Set up environment variables**
   Create `.env.local`:
   ```env
   NEXT_PUBLIC_API_URL=http://localhost:3001
   ```

3. **Run the development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   Navigate to [http://localhost:3000](http://localhost:3000)

### Build for Production

```bash
npm run build
npm start
```

## 🎨 Design System

### Colors
- **Primary**: Deep Emerald Green (`#0a4d3c`)
- **Secondary**: Orange/Amber (`#f59e0b`)
- **Background**: Cream (`#fef9e7`) / Navy (`#0f172a`)

### Typography
- **Headings**: 4xl-6xl, font-black
- **Body**: Base, leading-relaxed
- **Small**: sm-xs

### Components
All components follow the AGA design system defined in `/lib/constants/design-system.ts`

## 🔐 Authentication Flow

1. **Landing Page** → User selects role (Genius / Supporter)
2. **Sign Up** → Creates account with role
3. **Login** → Authenticates and stores token
4. **Dashboard** → Role-based home page

### Protected Routes
Routes under `/dashboard`, `/create`, `/vote`, etc. require authentication.

## 📡 API Integration

### Endpoints (Backend)
All endpoints are prefixed with `http://localhost:3001/api`:

#### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login
- `GET /auth/profile/:userId` - Get profile
- `PUT /auth/profile/:userId` - Update profile

#### Posts
- `GET /posts?page=1&limit=20` - Get feed
- `POST /posts` - Create post (multipart)
- `POST /posts/:id/like` - Like/unlike

#### Users
- `GET /users/geniuses` - Browse geniuses
- `POST /users/:id/follow` - Follow/unfollow

#### Voting
- `GET /voting/elections` - Get elections
- `POST /voting/vote` - Cast vote

### API Client Usage

```typescript
import { authAPI } from '@/lib/api/auth';

// Login
const response = await authAPI.login({ email, password });

// Register
const response = await authAPI.register({
  username,
  email,
  password,
  displayName,
  role: 'genius',
});
```

## 🔧 Development Guide

### Adding a New Page

1. Create page file: `app/my-page/page.tsx`
2. Use `'use client'` for client components
3. Wrap protected routes with auth check
4. Follow design system conventions

### Adding a New API Service

1. Create service file: `lib/api/my-service.ts`
2. Use `apiClient` for HTTP requests
3. Define TypeScript interfaces
4. Export service object

### Using the Auth Store

```typescript
import { useAuth } from '@/lib/store/auth-store';

function MyComponent() {
  const { user, isAuthenticated, login, logout } = useAuth();

  // Access user data
  console.log(user?.role);

  // Check authentication
  if (!isAuthenticated) return <LoginPrompt />;

  return <AuthenticatedContent />;
}
```

## 📋 Todo List

See `IMPLEMENTATION_GUIDE.md` for detailed implementation steps.

### High Priority
- [ ] Complete API services (posts, users, voting, live)
- [ ] Build Dashboard Layout component
- [ ] Implement Genius Home page
- [ ] Implement Supporter Home page

### Medium Priority
- [ ] Explore page with filters
- [ ] Create page (Post, Go Live, Proposals)
- [ ] Impact page (Leaderboards & analytics)
- [ ] Vote page (Elections & voting)

### Low Priority
- [ ] Profile page & settings
- [ ] Live streaming integration (Socket.IO)
- [ ] Notifications system
- [ ] Error boundaries
- [ ] Loading states optimization

## 🧪 Testing

```bash
# Run type check
npm run type-check

# Build check
npm run build
```

## 🚢 Deployment

### Vercel (Recommended)

1. Push code to GitHub
2. Import project to Vercel
3. Set environment variables
4. Deploy

### Manual Deployment

```bash
npm run build
npm start
```

## 📖 Key Files Reference

- **Landing Page**: `app/page.tsx`
- **Auth Pages**: `app/auth/login/page.tsx`, `app/auth/signup/page.tsx`
- **Design System**: `lib/constants/design-system.ts`
- **Types**: `types/index.ts`
- **API Client**: `lib/api/client.ts`
- **Auth Store**: `lib/store/auth-store.tsx`

## 🤝 Contributing

1. Follow existing code structure
2. Use TypeScript strictly
3. Match mobile app's UX philosophy
4. Test authentication flows
5. Ensure responsive design

## 📄 License

Proprietary - Africa Genius Alliance

## 🔗 Related Repositories

- **Mobile App**: `/AGA` (iOS, SwiftUI)
- **Backend**: `/backend` (Node.js, Express, MongoDB)
- **Admin Dashboard**: `/admin-dashboard` (React, TypeScript)

---

**Built with ❤️ for Africa's Future**
