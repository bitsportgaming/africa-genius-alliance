# UI Reference Implementation Guide

## 🎨 Design System Updates

### ✅ **Completed:**
1. **Color Palette Updated** - Changed to emerald green (#0a4d3c) and orange (#f59e0b)
2. **Gradients Updated** - Orange and green gradients matching reference
3. **Profile Images Created** - 10 placeholder images with orange gradients and initials

### 🔄 **Remaining Tasks:**

---

## 📱 Screen-by-Screen Implementation

### **1. Welcome/Splash Screen** (Screen 1)
**Reference**: Dark green background, Africa map icon, "Get Started" orange button

**Current Status**: ✅ Partially done
**Needs**:
- [ ] Africa map icon/logo (yellow gradient)
- [ ] "Welcome to Africa Genius Alliance" text in yellow
- [ ] Orange "Get Started" button
- [ ] Deep emerald green background

**File**: `AGA/AGA/Views/SplashScreenView.swift`

---

### **2. Home Feed - "Hire Genius, By Genius"** (Screen 2)
**Reference**: Orange background, large profile image, "Hire Genius, By Genius" text

**Current Status**: ❌ Not implemented
**Needs**:
- [ ] Orange gradient background
- [ ] Large circular profile image (200x200px)
- [ ] "Hire Genius, By Genius" headline
- [ ] Genius bio text
- [ ] "Join Waitlist" button
- [ ] Stats row (Followers, Quests, Likes)

**Suggested File**: Create `HireGeniusView.swift`

---

### **3. Profile Screen** (Screens 3 & 4)
**Reference**: Orange background, circular profile, stats, action buttons

**Current Status**: ✅ Partially done
**Needs**:
- [ ] Orange gradient background (not green)
- [ ] Large circular profile image
- [ ] Username display
- [ ] "Join Waitlist" button (orange)
- [ ] "I'm Genius Me" button (outline)
- [ ] Stats row with icons (Followers, Quests, Likes)
- [ ] Cream/beige variant for light mode

**File**: `AGA/AGA/Views/Profile/ProfileView.swift`

---

### **4. Browse Geniuses** (Screen 5)
**Reference**: Cream background, list of genius cards with avatars

**Current Status**: ✅ Exists as SupporterDashboardView
**Needs**:
- [ ] Cream/beige background (#fef9e7)
- [ ] Filter tabs (Founders, Activists, etc.)
- [ ] Genius cards with:
  - Circular avatar (left)
  - Name and position
  - Bio snippet
  - Arrow icon (right)

**File**: `AGA/AGA/Views/Feed/SupporterDashboardView.swift`

---

### **5. Post Detail - Video/Image** (Screen 6)
**Reference**: Green background, large image/video, engagement buttons

**Current Status**: ✅ Partially done
**Needs**:
- [ ] Full-width image/video display
- [ ] "Video, Tueta" title overlay
- [ ] Engagement row (Followers, Quests, Likes)
- [ ] Bottom action buttons (Share, URL, Like)
- [ ] Green background

**File**: `AGA/AGA/Views/Feed/ModernPostCardView.swift`

---

### **6. Comments View** (Screen 7)
**Reference**: Orange background, threaded comments

**Current Status**: ✅ Exists
**Needs**:
- [ ] Orange gradient background
- [ ] Comment cards with avatars
- [ ] Nested replies
- [ ] "Reply" button on each comment

**File**: `AGA/AGA/Views/Feed/CommentsView.swift`

---

### **7. Own Post View** (Screen 8)
**Reference**: Orange background, post preview with actions

**Current Status**: ❌ Not implemented
**Needs**:
- [ ] Orange background
- [ ] Post preview card
- [ ] Edit/Delete buttons
- [ ] Share options

**Suggested File**: Create `OwnPostView.swift`

---

### **8. Menu/Navigation** (Screen 9)
**Reference**: Orange background, menu items with icons

**Current Status**: ❌ Not implemented (using tab bar)
**Needs**:
- [ ] Orange gradient background
- [ ] Menu items:
  - Home
  - Browse Geniuses
  - Notifications
  - My Posts
  - Settings
- [ ] Icons for each item

**Suggested File**: Create `MenuView.swift` or update tab bar

---

### **9. Search/Categories** (Screen 10 & 13)
**Reference**: Cream background, category list with counts

**Current Status**: ❌ Not implemented
**Needs**:
- [ ] Search bar at top
- [ ] Category filters (Founders, Geniuses, etc.)
- [ ] Category list with post counts
- [ ] Cream background

**Suggested File**: Create `SearchView.swift`

---

### **10. Sign Up** (Screen 11)
**Reference**: Cream background, form fields, image upload

**Current Status**: ✅ Exists
**Needs**:
- [ ] Cream background
- [ ] Profile image upload section
- [ ] Form fields (Name, Username, Password, etc.)
- [ ] Orange "Sign Up" button

**File**: `AGA/AGA/Views/Auth/ModernSignUpView.swift`

---

### **11. Genius Profile Detail** (Screen 12 & 14)
**Reference**: Green background, large profile, detailed stats

**Current Status**: ✅ Partially done
**Needs**:
- [ ] Green gradient background
- [ ] Large circular profile image
- [ ] Genius name and title
- [ ] Detailed bio
- [ ] Stats (Votes, Supporters)
- [ ] "Route" button (orange)
- [ ] Supporter avatars row

**File**: `AGA/AGA/Views/Profile/GeniusProfileView.swift`

---

### **12. Settings** (Screen 15)
**Reference**: Cream background, settings list

**Current Status**: ✅ Exists
**Needs**:
- [ ] Cream background
- [ ] Settings items with icons
- [ ] Arrow indicators

**File**: `AGA/AGA/Views/Profile/ProfileView.swift` (settings section)

---

### **13. Login** (Screen 16)
**Reference**: Green background, Africa map, login form

**Current Status**: ✅ Exists
**Needs**:
- [ ] Green gradient background
- [ ] Africa map icon
- [ ] Form fields
- [ ] Orange "Login" button

**File**: `AGA/AGA/Views/Auth/LoginView.swift`

---

## 🎯 Priority Implementation Order

1. **High Priority** (Core UX):
   - [ ] Update color scheme throughout app
   - [ ] Add profile images to all views
   - [ ] Update splash screen
   - [ ] Fix profile screen background (orange)

2. **Medium Priority** (Key Features):
   - [ ] Implement "Hire Genius" home screen
   - [ ] Update browse geniuses view
   - [ ] Add search/categories view

3. **Low Priority** (Nice to Have):
   - [ ] Add menu/navigation drawer
   - [ ] Implement own post view
   - [ ] Add advanced animations

---

## 📦 Assets Needed

### **Images:**
- [ ] Africa map icon (SVG or PNG)
- [ ] Real profile photos (or keep placeholders)
- [ ] Post images (already have sample_*)

### **Icons:**
- [ ] Menu icons (can use SF Symbols)
- [ ] Action icons (share, like, comment)
- [ ] Stats icons (followers, quests, likes)

---

## 🚀 Quick Start

1. **Delete the app** from simulator
2. **Run the app** - Sample data with images will load
3. **Verify images** appear in feed and profiles
4. **Start implementing** screens in priority order

