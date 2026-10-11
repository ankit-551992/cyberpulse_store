# ⚡ CyberPulse: Cyberpunk E-Commerce Platform (India Edition)

A high-performance, neon-infused Cyberpunk e-commerce web & mobile platform built with **Flutter**, crafted for the Indian market with native Indian Rupee (`₹`) pricing, GST calculation, Indian Pincode validator, and UPI / RuPay checkout flows.

---

## 🚀 Quick Start

### 1. Run in Browser (Development)
```bash
flutter run -d chrome --web-port 8090
```

### 2. Run as Native macOS Desktop App
```bash
flutter run -d macos
```

### 3. Run Test Suite
```bash
flutter test
```

### 4. Build Production Web Bundle
```bash
flutter build web --release
```

---

## 💎 Features

### 🇮🇳 Indian Localization
- **Indian Rupee (₹) Display & Formatting**: Formats prices using Indian grouping (e.g., `₹1,29,999` and `₹1.3 Lakh`).
- **GST 18% Calculation Engine**: Automatic tax calculation with itemized breakdown.
- **Indian Pincode Lookup**: Instant verification for Bengaluru, Mumbai, Delhi NCR, Hyderabad, Chennai, Pune, etc.
- **Payment Options**: UPI (Google Pay / PhonePe / Paytm), RuPay / Debit Card, NetBanking (SBI, HDFC, ICICI, Axis), and Cash on Delivery.
- **Promo Codes**: `CYBERINDIA` (₹2,500 off) and `RUPAY10` (10% off).

### 🌌 Cyberpunk 2077 Visual Design
- Sleek dark theme (`#08090D`) with neon cyan (`#00F0FF`), purple (`#BD00FF`), laser crimson (`#FF0055`), and gold accents.
- Holographic angled badges and live animated flash deals countdown ticker.
- Color variant selectors and responsive desktop / mobile layout.

### 🔐 Neural Authentication & Role-Based Access Control
- **Two User Roles**: Verified Customer (`CYBER CITIZEN`) & Super Administrator (`SUPER ADMIN`).
- **Cyberpunk Auth Modal**:
  - Seamless animated tabs: **Sign In** and **Create Identity**.
  - Form validations (email format, minimum password length, phone).
  - 1-Click Instant Demo Evaluation buttons:
    - ⚡ **Demo Customer**: `aarav.sharma@cyberpulse.in` (Password: `password123`)
    - 🛡️ **Demo Admin**: `admin@cyberpulse.in` (Password: `admin2077`)
- **Admin Security Gate**: Attempting to switch to Admin Mission Control without admin credentials automatically triggers the administrative clearance challenge.
- **Persistent Sessions**: User session state saved across browser refreshes via `SharedPreferences`.
- **Checkout Autofill**: Automatically populates customer name, email, phone, and saved shipping address from active user profile.
- **User Profile Modal**: Interactive dialog showing user initials with glowing neon halo, full address, orders count, wishlist count, 1-click order tracking, switch accounts, and sign out.

### 🛡 Admin Portal & Department Suite
- **Department & Category Management Engine**:
  - Real-time analytics: total active departments, SKU counts, total stock units, inventory valuation in Lakhs (`₹`), and catalog revenue contribution percentage bars.
  - Interactive Creation & Editing: custom department name, auto-slug generator, rich description, icon picker (laptops, phones, audio, chips, drones, gaming, robotics, wearables, security, etc.), and multi-color neon gradient presets.
  - Lifecycle Controls: Active/Hidden status toggle, Featured department spotlighting, safe category deletion with product reassignment safeguards.
  - Dual Presentation: Adaptive Grid view and dense Table / List view with instant search and status filtering.
- **Inventory Intelligence & Stock Replenishment**:
  - Real-time stock audit trails, low stock & out-of-stock alert tags.
  - Quick replenishment and audit logging.
- **Live Order & Fulfillment Pipeline**:
  - Order status updates (Processing, Dispatched, In Transit, Delivered) with tracking timeline.
  - Revenue analytics in Lakhs (`₹`) with GST tax accounting.

---

## 🌐 100% Free Hosting

Because CyberPulse compiles to static web files (`build/web`), it can be hosted completely free of cost with global CDNs and free SSL:

### Option A: GitHub Pages (Automatic CI/CD)
The included workflow [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) automatically tests, builds, and deploys every push to `main`:
1. Push to your GitHub repo.
2. In GitHub repo Settings → Pages, set Source to `gh-pages` branch.
3. Access at `https://<username>.github.io/cyberpulse_store/`.

### Option B: Vercel (Instant Zero-Config)
The included [`vercel.json`](vercel.json) handles SPA routing automatically:
1. Import repository on [Vercel](https://vercel.com).
2. Set Build Command: `flutter build web --release`.
3. Set Output Directory: `build/web`.

### Option C: Firebase Hosting (Google Cloud Free Tier)
```bash
flutter build web --release
npx firebase-tools init hosting  # Set public directory to build/web
npx firebase-tools deploy
```

---

## 🧪 Testing

**31 comprehensive unit and widget tests (100% passing)** covering:
- **Authentication & Security Gates**:
  - Demo Customer & Demo Admin credential verification.
  - Invalid password rejection with error feedback.
  - User registration & local database persistence.
  - Duplicate email collision rejection.
  - Session clearance & admin panel mode security lockout on logout.
  - Admin access gate preventing customer role escalation.
  - AuthModal & UserProfileModal rendering and tab interaction tests.
- **Category & Department Lifecycle**: CRUD operations, slug creation, icon resolver fallback, and active/featured toggling.
- **Product Cascade**: Category renaming updates products; deletion requires and handles reassigning products to an alternate category.
- **Department Analytics Engine**: Stock unit aggregation, inventory valuation calculations, and revenue share distribution.
- **Admin Category UI Widget Tests**: KPI metric cards, catalog rendering, search filtering, and New Category modal dialog submission.
- **E-Commerce & Indian Localization**:
  - Indian Rupee (`₹`) number grouping, Lakhs & Crores compact formatting.
  - Indian pincode lookup and delivery estimations.
  - Cart additions, quantity updates, GST 18%, and coupon discounts.
  - Order placement, stock deduction, and inventory audit logs.
  - Full smoke test.
