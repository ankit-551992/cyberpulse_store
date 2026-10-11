import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'theme/cyber_colors.dart';
import 'providers/store_provider.dart';
import 'screens/customer/store_home_screen.dart';
import 'screens/customer/wishlist_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'widgets/cyber_navbar.dart';
import 'widgets/cart_drawer.dart';
import 'widgets/auth_modal.dart';
import 'widgets/user_profile_modal.dart';
import 'data/mock_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => StoreProvider(),
      child: const CyberPulseApp(),
    ),
  );
}

class CyberPulseApp extends StatelessWidget {
  const CyberPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return MaterialApp(
      title: 'CyberPulse | Next-Gen Tech Store & Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: store.themeMode,
      home: const MainStoreShell(),
    );
  }
}

class MainStoreShell extends StatefulWidget {
  const MainStoreShell({super.key});

  @override
  State<MainStoreShell> createState() => _MainStoreShellState();
}

class _MainStoreShellState extends State<MainStoreShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openCart() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openWishlist() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WishlistScreen()),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;

    if (store.isLoading) {
      return Scaffold(
        backgroundColor: CyberColors.darkBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: CyberColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CyberColors.cyanPrimary.withOpacity(0.4),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded, size: 48, color: Colors.black),
              ),
              const SizedBox(height: 24),
              Text(
                'CYBERPULSE',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Initializing Neural Commerce Engine...',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  color: CyberColors.cyanPrimary,
                  backgroundColor: CyberColors.darkSurfaceLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Role Switch: Admin Panel Mode
    if (store.isAdminMode) {
      return const AdminDashboardScreen();
    }

    // Customer Storefront Mode
    return Scaffold(
      key: _scaffoldKey,
      appBar: CyberNavbar(
        onOpenCart: _openCart,
        onOpenWishlist: _openWishlist,
        onOpenDrawer: _openDrawer,
      ),
      drawer: _buildMobileDrawer(context, store, isDark),
      endDrawer: const CartDrawer(),
      body: const StoreHomeScreen(),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, StoreProvider store, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header / User Profile
            Padding(
              padding: const EdgeInsets.all(16),
              child: store.currentUser != null
                  ? InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        UserProfileModal.show(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: store.currentUser!.isAdmin
                                ? CyberColors.purpleNeon.withOpacity(0.5)
                                : CyberColors.cyanPrimary.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: store.currentUser!.isAdmin
                                    ? CyberColors.neonPurpleGradient
                                    : CyberColors.primaryGradient,
                              ),
                              child: Center(
                                child: Text(
                                  store.currentUser!.initials,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    color: store.currentUser!.isAdmin ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.currentUser!.name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    store.currentUser!.role.badgeLabel,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: store.currentUser!.isAdmin
                                          ? CyberColors.purpleNeon
                                          : CyberColors.cyanPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        side: const BorderSide(color: CyberColors.cyanPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.login_rounded, color: CyberColors.cyanPrimary, size: 18),
                      label: Text(
                        'Sign In / Register',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          color: CyberColors.cyanPrimary,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        AuthModal.show(context);
                      },
                    ),
            ),
            const Divider(height: 1),

            // Navigation Links
            ListTile(
              leading: const Icon(Icons.storefront_rounded),
              title: const Text('All Products'),
              selected: store.selectedCategory == 'All',
              onTap: () {
                store.setCategory('All');
                Navigator.of(context).pop();
              },
            ),
            ...MockData.categories.where((c) => c != 'All').map((cat) {
              return ListTile(
                leading: const Icon(Icons.arrow_right_rounded),
                title: Text(cat),
                selected: store.selectedCategory == cat,
                onTap: () {
                  store.setCategory(cat);
                  Navigator.of(context).pop();
                },
              );
            }),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.favorite_rounded, color: CyberColors.pinkAccent),
              title: const Text('Saved Wishlist'),
              trailing: store.wishlistIds.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: CyberColors.pinkAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${store.wishlistIds.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                _openWishlist();
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag_rounded, color: CyberColors.cyanPrimary),
              title: const Text('Cyber Cart'),
              trailing: store.cartCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: CyberColors.cyanPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${store.cartCount}',
                        style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                _openCart();
              },
            ),

            const Spacer(),

            // Role Switch to Admin Portal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: CyberColors.neonPurpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
                  label: Text(
                    'Access Admin Portal',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (store.isCurrentUserAdmin) {
                      store.setAdminMode(true);
                    } else {
                      AuthModal.show(
                        context,
                        requireAdmin: true,
                        onSuccess: () => store.setAdminMode(true),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
