# 🚀 AGA Web App - Quick Start Guide

Get the AGA Web App running in 5 minutes.

## Prerequisites

- ✅ Node.js 18+ installed ([Download](https://nodejs.org))
- ✅ npm or yarn package manager
- ✅ AGA Backend server running (see `/backend/README.md`)

## Step 1: Install Dependencies

```bash
cd web-app
npm install
```

This will install all required packages (~200MB).

## Step 2: Configure Environment

```bash
# Create environment file
cp .env.example .env.local
```

Your `.env.local` should contain:
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```

**Note**: Ensure your backend is running on port 3001.

## Step 3: Start Development Server

```bash
npm run dev
```

You should see:
```
✓ Ready in 2s
○ Local:   http://localhost:3000
```

## Step 4: Open in Browser

Navigate to [http://localhost:3000](http://localhost:3000)

You should see the AGA landing page! 🎉

## Step 5: Test Authentication

1. Click **"Join the Beta"** or go to [/auth/signup](http://localhost:3000/auth/signup)
2. Select your role (Genius or Supporter)
3. Fill in account details
4. Submit form (this will create account in backend)
5. You'll be redirected to `/dashboard`

## What You Can Do Now

### ✅ Currently Working

- **Landing Page**: Browse all sections
- **Sign Up**: Create Genius or Supporter account
- **Login**: Access your account
- **Auth State**: Session persistence across page reloads

### 🚧 In Progress (See IMPLEMENTATION_GUIDE.md)

- Dashboard Home (Genius/Supporter views)
- Explore Geniuses
- Voting Interface
- Create Posts (Genius)
- Impact Analytics
- Profile Management

## Project Structure Overview

```
web-app/
├── app/                    # Next.js pages
│   ├── auth/              # Login & Signup
│   ├── page.tsx           # Landing page ✓
│   └── layout.tsx         # Root layout ✓
├── components/
│   ├── ui/                # Reusable components ✓
│   └── landing/           # Landing page sections ✓
├── lib/
│   ├── api/               # API services ✓
│   ├── store/             # State management ✓
│   └── constants/         # Design system ✓
└── types/                 # TypeScript types ✓
```

## Common Issues & Solutions

### Port 3000 Already in Use

```bash
# Kill process on port 3000
npx kill-port 3000

# Or use different port
PORT=3001 npm run dev
```

### Backend Not Running

```bash
# Start backend in separate terminal
cd ../backend
npm start
```

### Module Not Found Errors

```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```

### Build Errors

```bash
# Type check
npx tsc --noEmit

# Clean Next.js cache
rm -rf .next
npm run dev
```

## Development Workflow

### Making Changes

1. Edit files in `app/`, `components/`, or `lib/`
2. Save file (auto-reload enabled)
3. Check browser for updates
4. Hot Module Replacement (HMR) works automatically

### Adding New Page

```bash
# Create page file
mkdir -p app/my-page
touch app/my-page/page.tsx
```

```typescript
// app/my-page/page.tsx
export default function MyPage() {
  return <div>My Page Content</div>;
}
```

Navigate to: `http://localhost:3000/my-page`

### Using Components

```typescript
import { AGAButton, AGACard } from '@/components/ui';

export default function MyComponent() {
  return (
    <AGACard variant="hero" padding="lg">
      <AGAButton variant="primary">Click Me</AGAButton>
    </AGACard>
  );
}
```

### Using Auth

```typescript
'use client';

import { useAuth } from '@/lib/store/auth-store';

export default function AuthExample() {
  const { user, isAuthenticated, logout } = useAuth();

  if (!isAuthenticated) return <div>Please login</div>;

  return (
    <div>
      <p>Welcome, {user?.displayName}!</p>
      <button onClick={logout}>Logout</button>
    </div>
  );
}
```

## Next Steps

1. **Read Documentation**
   - `README.md` - Complete project overview
   - `IMPLEMENTATION_GUIDE.md` - Step-by-step implementation guide
   - `PROJECT_SUMMARY.md` - What's done and what's next

2. **Start Building**
   - Follow priority order in `IMPLEMENTATION_GUIDE.md`
   - Start with Dashboard Layout component
   - Then build Genius/Supporter home pages

3. **Test Integration**
   - Create test accounts (Genius and Supporter)
   - Test auth flow
   - Verify API connections

## Useful Commands

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm start                # Run production build

# Code Quality
npx tsc --noEmit        # Type check
npx next lint           # Lint code

# Cleanup
rm -rf .next            # Clear Next.js cache
rm -rf node_modules     # Remove dependencies
npm install             # Reinstall dependencies
```

## Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:3001` | Backend API URL |

**Note**: All `NEXT_PUBLIC_*` variables are exposed to the browser.

## Backend API Endpoints

Ensure these endpoints work:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/register` | POST | Create account |
| `/api/auth/login` | POST | Login |
| `/api/auth/profile/:id` | GET | Get profile |
| `/api/posts` | GET | Get feed |
| `/api/users/geniuses` | GET | Browse geniuses |

Test with:
```bash
curl http://localhost:3001/api/posts
```

## Design System Quick Reference

### Colors
```typescript
bg-primary         // Emerald green
bg-secondary       // Orange
bg-background-cream  // Cream background
text-text-dark     // Dark text
```

### Components
```typescript
<AGAButton variant="primary" size="lg">Text</AGAButton>
<AGACard variant="hero">Content</AGACard>
<AGAPill variant="success">Badge</AGAPill>
<AGAChip selected={true}>Filter</AGAChip>
```

### Spacing
```typescript
p-4   // Padding
gap-6 // Gap
mb-8  // Margin bottom
```

## Keyboard Shortcuts (Browser)

- `Ctrl/Cmd + K` - Search (when implemented)
- `Esc` - Close modals
- `Tab` - Navigate focus
- `Enter` - Submit forms

## Getting Help

1. Check `IMPLEMENTATION_GUIDE.md` for code examples
2. Review mobile app (`/AGA`) for UX patterns
3. Inspect backend (`/backend`) for API details
4. Check browser console for errors
5. Review Network tab for API calls

## Production Build

When ready to deploy:

```bash
# Build
npm run build

# Test production build locally
npm start

# Deploy to Vercel (recommended)
vercel deploy
```

## Success Checklist

- ✅ Landing page loads
- ✅ Can signup as Genius
- ✅ Can signup as Supporter
- ✅ Can login with created account
- ✅ Session persists on refresh
- ✅ Can logout
- ✅ No console errors

If all checked, you're ready to build! 🎉

---

**Need more details?** See `README.md` and `IMPLEMENTATION_GUIDE.md`

**Happy coding! 🚀**
