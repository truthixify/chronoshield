# ChronoShield - UI/UX Product Requirements Document

## Product Overview
**What users see:** A prediction market where they bet on outcomes (Yes/No) but nobody can see anyone's positions until the market closes. More private than Polymarket, more fair than traditional betting.

---

## User Flows

### Flow 1: Browse & Discover Markets
```
Landing Page → Market List → Market Details → Place Bet
```

### Flow 2: Create New Market
```
Dashboard → "Create Market" → Fill Form → Submit → View Created Market
```

### Flow 3: Place Bet (Core Flow)
```
Market Details → Choose YES/NO → Enter Amount → Confirm → See Commitment Receipt
```

### Flow 4: Reveal & Claim Winnings
```
Resolved Market → "Reveal Position" Button → Confirm → See Payout Amount → Claim
```

---

## Screens & Components

### 1. LANDING PAGE / HOME

**Purpose:** Show active markets, build trust, explain privacy

**Components:**
- Hero section with tagline: "Bet on anything. Stay private. Win fairly."
- Market categories (Politics, Sports, Crypto, Entertainment)
- Featured markets (3-4 high volume ones)
- Stats banner: Total markets, Total volume, Active traders
- "How it works" (3 simple steps with icons)

**Key UI Elements:**
```
┌────────────────────────────────────┐
│  [Logo] ChronoShield    [Connect Wallet] │
├────────────────────────────────────┤
│                                    │
│     Bet Privately. Win Fairly.     │
│   Your positions stay hidden until │
│         markets resolve            │
│                                    │
│   [Explore Markets]  [Create Market]│
│                                    │
├────────────────────────────────────┤
│  🔥 TRENDING MARKETS               │
│  ┌──────────────────────────────┐ │
│  │ Will BTC hit $100k by 2025?  │ │
│  │ YES: 🟩🟩🟩⬜⬜ 67%           │ │
│  │ Pool: $45,000 • Ends in 5d   │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

---

### 2. MARKET LIST PAGE

**Purpose:** Browse all markets with filters

**Filters:**
- Status: Active / Resolved / Revealing
- Category: Politics / Sports / Crypto / Other
- Sort: Newest / Ending Soon / Highest Volume

**Market Card (repeated):**
```
┌─────────────────────────────────────┐
│ 🏈 Sports                           │
│ Will Liverpool win the Premier League? │
│                                     │
│ Current Odds (hidden positions)     │
│ YES: 58% • NO: 42%                  │
│                                     │
│ 💰 Pool: $12,450                    │
│ ⏰ Ends: Dec 15, 2024               │
│ 👥 253 hidden positions             │
│                                     │
│        [View Market →]              │
└─────────────────────────────────────┘
```

---

### 3. MARKET DETAILS PAGE (Active Market)

**Purpose:** Show market info, place bets, see (limited) market data

**Layout:**
```
┌──────────────────────────────────────────┐
│ ← Back to Markets                        │
├──────────────────────────────────────────┤
│                                          │
│ Will ETH flip BTC by end of 2025?        │
│ Created by 0x742d...3f2a                 │
│                                          │
│ ┌────────────────────────────────────┐  │
│ │    STATUS: ACTIVE                   │  │
│ │    Ends in: 45 days 3 hours         │  │
│ │    Total Pool: $78,900              │  │
│ │    Hidden Positions: 1,247          │  │
│ └────────────────────────────────────┘  │
│                                          │
│ PLACE YOUR BET (PRIVATE)                 │
│ ┌──────────────┐  ┌──────────────┐      │
│ │   YES 65%    │  │   NO 35%     │      │
│ │              │  │              │      │
│ │ [Select YES] │  │ [Select NO]  │      │
│ └──────────────┘  └──────────────┘      │
│                                          │
│ Enter Amount: [______] ETH               │
│                                          │
│ ⚠️ Your position will be hidden until    │
│    market resolves                       │
│                                          │
│        [Confirm Bet] (disabled until     │
│         amount entered)                  │
│                                          │
├──────────────────────────────────────────┤
│ MARKET INFO                              │
│ • Resolution source: Chainlink Oracle    │
│ • Resolution date: Jan 31, 2025          │
│ • Creator: 0x742d...3f2a                 │
└──────────────────────────────────────────┘
```

**After clicking "Confirm Bet":**
- Show wallet signature popup
- Show transaction pending state
- Show success with commitment ID

```
┌────────────────────────────────┐
│ ✅ BET PLACED SUCCESSFULLY     │
│                                │
│ Your position is now hidden    │
│ Commitment ID: #CM-00147       │
│                                │
│ Amount: 0.5 ETH                │
│ Position: YES                  │
│ Status: 🔒 Hidden              │
│                                │
│ [View My Positions]            │
└────────────────────────────────┘
```

---

### 4. MARKET DETAILS PAGE (Resolved - Reveal Phase)

**Purpose:** Show outcome, let users reveal their position, claim winnings

```
┌──────────────────────────────────────────┐
│ Will ETH flip BTC by end of 2025?        │
│                                          │
│ ┌────────────────────────────────────┐  │
│ │  🏆 MARKET RESOLVED                 │  │
│ │  Winning Outcome: NO                │  │
│ │  Resolved by: Oracle at Jan 31      │  │
│ └────────────────────────────────────┘  │
│                                          │
│ YOUR POSITION                            │
│ ┌────────────────────────────────────┐  │
│ │ Commitment ID: #CM-00147           │  │
│ │ Status: 🔒 Not Revealed Yet        │  │
│ │                                    │  │
│ │ [Reveal Position & Claim]          │  │
│ │                                    │  │
│ │ ⚠️ You have 18 hours to reveal     │  │
│ └────────────────────────────────────┘  │
│                                          │
│ FINAL RESULTS (after all reveals)        │
│ • YES positions: 823 (65%)              │
│ • NO positions: 424 (35%)               │
│ • Total pool distributed: $78,900        │
└──────────────────────────────────────────┘
```

**After revealing:**
```
┌────────────────────────────────┐
│ 😢 POSITION REVEALED            │
│                                │
│ Your bet: YES (0.5 ETH)        │
│ Outcome: NO                    │
│                                │
│ Result: You lost this market   │
│                                │
│ Better luck next time!         │
└────────────────────────────────┘
```

**Or if won:**
```
┌────────────────────────────────┐
│ 🎉 YOU WON!                    │
│                                │
│ Your bet: NO (0.5 ETH)         │
│ Outcome: NO                    │
│                                │
│ Payout: 1.24 ETH               │
│ Profit: +0.74 ETH              │
│                                │
│ [Claim Winnings]               │
└────────────────────────────────┘
```

---

### 5. MY POSITIONS PAGE

**Purpose:** Dashboard of all user's bets

**Tabs:**
- Active (positions in live markets)
- Pending Reveal (resolved markets waiting for reveal)
- History (all past positions)

**Position Card:**
```
┌─────────────────────────────────────┐
│ Will BTC hit $100k by 2025?         │
│                                     │
│ Your Position: YES • 0.5 ETH        │
│ Status: 🔒 Hidden                   │
│ Market Status: Active (15 days left)│
│ Commitment ID: #CM-00147            │
│                                     │
│ [View Market]                       │
└─────────────────────────────────────┘
```

---

### 6. CREATE MARKET PAGE

**Purpose:** Let users create new prediction markets

**Form Fields:**
```
┌──────────────────────────────────────────┐
│ CREATE NEW MARKET                        │
├──────────────────────────────────────────┤
│                                          │
│ Market Question *                        │
│ [_________________________________]      │
│ e.g., "Will X happen by Y date?"         │
│                                          │
│ Category *                               │
│ [Dropdown: Politics/Sports/Crypto/...]   │
│                                          │
│ Resolution Date *                        │
│ [Date Picker: MM/DD/YYYY]                │
│                                          │
│ Resolution Source *                      │
│ ( ) Chainlink Oracle                     │
│ ( ) Manual (requires verification)       │
│ ( ) ZK-ML Oracle                         │
│                                          │
│ Initial Liquidity (optional)             │
│ [_____] ETH                              │
│                                          │
│ Market Description                       │
│ [________________________________        │
│  ________________________________        │
│  ________________________________]       │
│                                          │
│ Estimated Cost: 0.05 ETH                 │
│                                          │
│ [Create Market]                          │
└──────────────────────────────────────────┘
```

---

### 7. USER PROFILE / WALLET MENU

**Dropdown when wallet connected:**
```
┌────────────────────────────┐
│ 0x742d...3f2a              │
│ Balance: 12.45 ETH         │
├────────────────────────────┤
│ My Positions               │
│ Create Market              │
│ Transaction History        │
│ Settings                   │
│ Disconnect                 │
└────────────────────────────┘
```

---

## UI States & Feedback

### Loading States
- **Market loading:** Skeleton cards with pulsing animation
- **Transaction pending:** Spinner + "Confirming on blockchain..."
- **Proof generating:** "Generating zero-knowledge proof... 5s"

### Empty States
- **No active positions:** "You haven't placed any bets yet. Explore markets to get started!"
- **No markets in category:** "No markets in this category yet. Be the first to create one!"

### Error States
- **Transaction failed:** Red banner with retry button
- **Insufficient balance:** "Insufficient ETH. You need X more ETH"
- **Market ended:** "This market has already closed for new positions"
- **Reveal deadline passed:** "⚠️ Reveal deadline passed. Position forfeited."

---

## Visual Design Requirements

### Color Palette
- **Primary:** Deep purple/blue (#6366F1) - trust, crypto native
- **Success:** Green (#10B981) - wins, YES votes
- **Danger:** Red (#EF4444) - losses, NO votes
- **Dark mode:** Default (crypto users prefer dark)
- **Accent:** Neon cyan (#06B6D4) - for highlights

### Typography
- **Headings:** Bold, modern sans-serif (Inter, Satoshi)
- **Body:** Clean, readable (15-16px)
- **Numbers/Stats:** Monospace for amounts

### Icons & Imagery
- **Market status:** 🔒 (locked), 🔓 (revealing), 🏆 (resolved)
- **Privacy indicators:** Shield icons, lock symbols
- **Category icons:** Sport emoji, political symbols, crypto logos

### Animations
- **Position commitment:** Lock animation when bet placed
- **Reveal:** Unlock animation with suspense (500ms delay before showing result)
- **Winning:** Confetti or celebration animation
- **Privacy emphasis:** Subtle "blur" effect on hidden positions

---

## Data Requirements (What UI needs from backend/contracts)

### Market Data
```javascript
{
  market_id: "0x123...",
  question: "Will BTC hit $100k?",
  category: "crypto",
  status: "active" | "resolved" | "revealing",
  resolution_time: 1735689600, // timestamp
  reveal_deadline: 1735776000,
  total_pool: "78900000000000000000", // in wei
  hidden_positions_count: 1247,
  current_odds: {
    yes: 0.65,
    no: 0.35
  },
  oracle_address: "0xabc...",
  creator: "0x742d...",
  resolved_outcome: null | 0 | 1 // null if not resolved
}
```

### User Position Data
```javascript
{
  commitment_id: "CM-00147",
  market_id: "0x123...",
  amount: "500000000000000000", // 0.5 ETH in wei
  outcome: 1, // 0=NO, 1=YES
  revealed: false,
  timestamp: 1735603200,
  can_claim: false,
  payout_amount: null | "1240000000000000000"
}
```

### User Profile Data
```javascript
{
  address: "0x742d...3f2a",
  total_positions: 47,
  active_positions: 12,
  total_wagered: "5600000000000000000",
  total_winnings: "6800000000000000000",
  win_rate: 0.58
}
```

---

## API Endpoints Needed (From UI Perspective)

### Markets
- `GET /markets` - List all markets with filters
- `GET /markets/:id` - Get single market details
- `POST /markets` - Create new market

### Positions
- `GET /positions/my` - Get user's positions
- `POST /positions/commit` - Submit position commitment
- `POST /positions/reveal` - Reveal position after resolution
- `POST /positions/claim` - Claim winnings

### User
- `GET /user/:address/stats` - Get user statistics
- `GET /user/:address/history` - Get transaction history

---

## Responsive Design

### Desktop (1200px+)
- 3-column market grid
- Sidebar for filters
- Full data tables

### Tablet (768px - 1199px)
- 2-column market grid
- Collapsible filters
- Simplified tables

### Mobile (< 768px)
- Single column
- Bottom sheet for bet placement
- Swipeable market cards
- Sticky "Place Bet" button

---

## Accessibility
- Keyboard navigation for all actions
- Screen reader labels for wallet addresses
- High contrast mode support
- Focus indicators on interactive elements

---

## MVP Feature Priority

### MUST HAVE (Week 1)
✅ Browse markets  
✅ Place bet (commit position)  
✅ Connect wallet  
✅ View my positions  
✅ Reveal position & claim

### NICE TO HAVE (Week 2)
⭐ Create market  
⭐ Market search/filters  
⭐ Transaction history  
⭐ User stats dashboard

### FUTURE
🔮 Social features (share markets)  
🔮 Advanced charts/analytics  
🔮 Mobile app  
🔮 Notifications

---

## Technical Notes for Frontend Dev

- Use **wagmi/viem** for wallet connection
- **Starknet.js** for Ztarknet contract interactions
- **TanStack Query** for data fetching/caching
- **Tailwind CSS** for styling
- **Framer Motion** for animations
- Store commitment details in **localStorage** (user must reveal later)
