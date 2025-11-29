# ChronoShield Web UI

A privacy-first prediction market built with Next.js 14, featuring zero-knowledge position hiding.

## 🎨 What's Built

### ✅ Completed Pages

1. **Landing Page** (`/`)
   - Hero section with gradient background
   - Live stats banner (volume, positions, markets)
   - Trending markets preview (3 cards)
   - "How it Works" section with 3 steps
   - Fully responsive with dark mode

2. **Markets Listing** (`/markets`)
   - Search functionality (UI only, ready for backend)
   - Category filters sidebar
   - Status filters (Active/Resolved)
   - Market cards with:
     - Pool size, odds, end date
     - Hidden positions count
     - Clickable to detail page

3. **Market Detail** (`/markets/[id]`)
   - **Polymarket-style charts** using Recharts
   - Real-time probability visualization (YES/NO)
   - Betting interface with:
     - YES/NO selection buttons
     - Amount input
     - Potential payout calculator
     - Privacy notice
   - Market info section with resolution criteria
   - Status cards (pool, volume, positions)
   - Links to block explorer (ready for integration)

4. **Create Market** (`/create`)
   - Full form with validation
   - Category dropdown (Crypto, Sports, Politics, etc.)
   - Date/time picker for resolution
   - Oracle selection (Chainlink, Manual, ZK-ML)
   - Description textarea
   - Initial liquidity input
   - Cost estimation display

5. **My Positions** (`/positions`)
   - 3 tabs: Active, Pending Reveal, History
   - **Active**: Shows hidden positions with commitment IDs
   - **Pending Reveal**: Action-required cards for resolved markets
   - **History**: Win/loss tracking with profit calculations
   - Full position details for each tab

## 🎨 Design System

### Colors
- **Primary**: `#6366F1` (Indigo) - trust, crypto-native
- **Success**: `#10B981` (Green) - wins, YES votes
- **Destructive**: `#EF4444` (Red) - losses, NO votes
- **Accent**: `#06B6D4` (Cyan) - highlights, categories
- **Dark Background**: `#0f172a` (Slate 900)

### Components (shadcn/ui)
- ✅ Button (with variants: default, outline, ghost, destructive)
- ✅ Card (with Header, Title, Description, Content, Footer)
- ✅ Input
- ✅ Label
- ✅ Select (dropdown)
- ✅ Textarea
- ✅ Custom Header with navigation

### Tech Stack
- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS v4
- **Components**: shadcn/ui (Radix UI primitives)
- **Charts**: Recharts
- **Icons**: Lucide React
- **Wallet**: wagmi + viem (configured, ready to connect)
- **State**: TanStack Query (React Query)

## 🚀 Running the App

```bash
# Development
cd web
npm run dev
# Runs on http://localhost:3000

# Production Build
npm run build
npm start
```

## 📁 File Structure

```
web/
├── app/
│   ├── layout.tsx           # Root layout with Providers
│   ├── page.tsx             # Landing page
│   ├── create/
│   │   └── page.tsx         # Create market form
│   ├── markets/
│   │   ├── page.tsx         # Markets listing
│   │   └── [id]/
│   │       └── page.tsx     # Market detail with charts
│   ├── positions/
│   │   └── page.tsx         # User positions dashboard
│   └── globals.css          # Design system tokens
├── components/
│   ├── ui/                  # shadcn components
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── input.tsx
│   │   ├── label.tsx
│   │   ├── select.tsx
│   │   └── textarea.tsx
│   ├── layout/
│   │   └── header.tsx       # Navigation header
│   └── providers.tsx        # Wagmi + React Query providers
└── lib/
    ├── utils.ts             # cn() helper
    └── wagmi.ts             # Wallet config
```

## 🔌 Ready for Backend Integration

All pages are built with **mock data** that can be easily replaced. Here's what needs to be connected:

### API Endpoints Needed
```typescript
// Markets
GET  /api/markets              // List all markets
GET  /api/markets/:id          // Get market details
POST /api/markets              // Create new market
GET  /api/markets/:id/history  // Chart data

// Positions
GET  /api/positions/my         // User's positions
POST /api/positions/commit     // Place bet (commitment)
POST /api/positions/reveal     // Reveal position
POST /api/positions/claim      // Claim winnings

// User
GET  /api/user/:address/stats  // User statistics
```

### Mock Data Locations to Replace
- `/app/page.tsx` - lines 71-157 (trending markets)
- `/app/markets/page.tsx` - lines 72-149 (all markets)
- `/app/markets/[id]/page.tsx` - lines 10-15 (chart data), entire page mock
- `/app/positions/page.tsx` - lines 10-68 (positions data)

## 🎯 Features Demonstrated

### Privacy-First UI/UX
- 🔒 Lock icons everywhere for hidden positions
- 🛡️ Shield icons for privacy emphasis
- Privacy notices on bet placement
- Commitment ID tracking
- Reveal deadlines with warnings

### Polymarket-Inspired Design
- Clean, modern dark theme
- Interactive probability charts
- Real-time odds display
- Betting interface with payout calculator
- Market status indicators

### Mobile Responsive
- Flexbox/Grid layouts
- Responsive navigation
- Card grids: 3 cols → 2 cols → 1 col
- Bottom sheets ready for mobile betting

## 🎨 Visual Highlights

1. **Gradient Hero** - Eye-catching purple gradient blob
2. **Animated Cards** - Hover effects with border color transitions
3. **Charts** - Area charts with green/red gradients for YES/NO
4. **Stats Banner** - Big numbers with primary color
5. **Custom Scrollbar** - Styled to match dark theme

## 📝 Next Steps

1. **Connect Wallet**
   - Implement `useConnect` hook in Header
   - Show connected address
   - Add disconnect functionality

2. **Fetch Real Data**
   - Replace mock data with API calls
   - Use TanStack Query for caching
   - Add loading states (skeleton implemented)

3. **Smart Contract Integration**
   - Wire up bet placement to contract calls
   - Implement reveal & claim logic
   - Add transaction status tracking

4. **Add More Features**
   - Market search with debounce
   - Category filtering
   - Transaction history modal
   - Notifications for reveals

## 💡 Design Decisions

- **Dark Mode Default**: Crypto users prefer it
- **Monospace for Numbers**: Better readability for crypto amounts
- **Color-Coded Odds**: Green = YES, Red = NO (intuitive)
- **Sticky Header**: Always accessible navigation
- **Privacy Everywhere**: Constant reminders of zero-knowledge benefits

---

**Built with ❤️ for the ChronoShield Hackathon**
