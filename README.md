# ⚡ CyberPulse | Next-Gen E-Commerce Flutter Web & App with Admin Panel

A futuristic, high-performance E-Commerce application built with **Flutter 3** & **Dart**, featuring a responsive **Customer Storefront** and a comprehensive **Admin Portal** in a unified codebase. Runs on **Web (Chrome, Safari, Edge)**, **iOS**, **Android**, and **macOS**.

---

## ✨ Features Overview

### 🛍️ Customer Storefront
- **Cyberpunk / Neo-Tech Visual Design System**: Modern dark & light theme modes, glow accents, glassmorphic cards, and custom typography powered by Google Fonts (`Outfit`, `Space Grotesk`, `Inter`).
- **Hero Banner & Tickers**: Dynamic announcements, quick launch category shortcuts, and promotional strips.
- **Search & Multi-Dimensional Filtering**:
  - Instant text search across gadget name, brand, category, and specs.
  - Category filter chips (Laptops, Smartphones, Audio, Wearables, Gaming & VR, Drones).
  - Interactive price range slider filter.
  - Multi-criteria sorting (Popularity, Price Low-High, Price High-Low, Top Rated, Newest).
- **Interactive Product Details**:
  - High-resolution multi-photo gallery carousel.
  - Comprehensive Technical Specifications key-value matrix.
  - Live stock inventory counter (In Stock, "Only X left!", Sold Out).
  - Customer review stream + "Write a Review" modal dialog.
  - Color / hardware variant selector with real-time feedback.
  - Quantity counter with maximum stock safety checks.
- **Full-Featured Cyber Cart**:
  - Slide-over cart drawer with animated badge counter.
  - Instant coupon code engine (try `CYBER20` for 20% off, `FUTURE15` for 15% off, `TECH10` for 10% off).
  - Automated shipping fee calculation (Free above $1500) and sales tax estimation.
- **Multi-Step Checkout & Payment Simulator**:
  - Step 1: Shipping and Contact details.
  - Step 2: Payment Simulator (Apple Pay/Google Pay, Credit/Debit Card, Crypto USDC/Solana, Cash on Delivery).
  - Step 3: Order Review & Instant Authorization.
- **Live Order Tracking**:
  - Interactive status stepper: Placed -> Payment Verified -> Sealed in Anti-Static Pod -> Dispatched -> Delivered.
  - Complete digital invoice receipt with itemized breakdown.

---

### ⚙️ Admin Mission Control (Integrated Admin Panel)
- **1-Click Mode Switcher**: Seamlessly switch between **Storefront Mode** and **Admin Mode** directly from the top navigation bar or mobile drawer.
- **Dashboard & Analytics**:
  - 4 Key Metric KPI Cards: Total Revenue, Total Orders, Active Catalog Items, and Low Stock Alerts.
  - Interactive **Revenue Velocity Line Chart** powered by `fl_chart`.
  - **Category Sales Distribution** bar indicators.
  - Live Recent Orders stream with real-time status pills.
- **Product Management (CRUD)**:
  - Add New Tech Product modal (Title, Brand, Category, Price, Original Price, Stock quantity, Image URL, Specs, Description).
  - Edit existing product details in real-time.
  - 1-Click Quick Restock button (+10 items).
  - Safe Product deletion with confirmation dialog.
- **Order Management Pipeline**:
  - Filter orders by status (Pending, Processing, Shipped, Delivered, Cancelled).
  - Live status updater dropdown (e.g. mark order as "Shipped" or "Delivered" and watch customer tracking update in real-time!).
  - Direct link to customer tracking timeline and receipt.
- **Stock & Inventory Monitor**:
  - Dedicated monitor for low-stock gadgets (<= 5 units remaining).
  - 1-Click Fast Restock action (+25 units).

---

## 🚀 Running the Project

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.20+ recommended)
- Google Chrome (for Flutter Web) or an iOS/Android simulator.

### 1. Launch in Google Chrome (Flutter Web)
```bash
cd cyberpulse_store
flutter run -d chrome
```

### 2. Launch on macOS Desktop
```bash
flutter run -d macos
```

### 3. Launch on iOS Simulator or Android Emulator
```bash
flutter run
```

### 4. Build Production Web Bundle
```bash
flutter build web
# Output bundle is generated in build/web/
```

---

## 📂 Project Architecture

```
cyberpulse_store/
├── lib/
│   ├── main.dart                  # App entrypoint, ThemeProvider & Shell Navigation
│   ├── theme/
│   │   ├── cyber_colors.dart      # Brand color tokens, gradients, dark/light palettes
│   │   └── app_theme.dart         # Material 3 ThemeData with Google Fonts
│   ├── models/
│   │   ├── product.dart           # Product model with specs, stock logic, JSON serialization
│   │   ├── cart_item.dart         # CartItem with quantity and color variant
│   │   ├── order.dart             # OrderModel with OrderStatus enum & tracking codes
│   │   └── review.dart            # Verified customer review model
│   ├── providers/
│   │   └── store_provider.dart    # Central state manager (Cart, Products, Orders, Admin metrics, SharedPreferences persistence)
│   ├── data/
│   │   └── mock_data.dart         # Seed catalog with 10+ tech gadgets, initial orders, and reviews
│   ├── widgets/
│   │   ├── cyber_navbar.dart      # Responsive navigation bar with role switcher & cart badge
│   │   ├── product_card.dart      # Interactive product card with hover animations
│   │   ├── cart_drawer.dart       # Slide-over cart panel with promo codes & checkout CTA
│   │   ├── checkout_modal.dart    # Multi-step checkout modal & success screen
│   │   ├── cyber_badge.dart       # Status badges & stock pills
│   │   └── responsive_layout.dart # Breakpoint utilities (Mobile, Tablet, Desktop)
│   └── screens/
│       ├── customer/
│       │   ├── store_home_screen.dart    # Hero banner, category chips, catalog grid
│       │   ├── product_detail_screen.dart # Image gallery, specs table, reviews
│       │   ├── order_tracking_screen.dart # Live tracking progress stepper & invoice
│       │   └── wishlist_screen.dart      # Saved items grid
│       └── admin/
│           └── admin_dashboard_screen.dart # KPI cards, revenue charts, product CRUD, orders pipeline
```

---

## 🎟️ Demo Promo Codes
Try applying these in the Cart Drawer:
- `CYBER20` - 20% OFF
- `FUTURE15` - 15% OFF
- `TECH10` - 10% OFF
