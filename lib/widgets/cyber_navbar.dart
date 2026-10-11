import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyber_colors.dart';
import '../providers/store_provider.dart';
import 'responsive_layout.dart';
import 'auth_modal.dart';
import 'user_profile_modal.dart';

class CyberNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenCart;
  final VoidCallback onOpenWishlist;
  final VoidCallback? onOpenDrawer;

  const CyberNavbar({
    super.key,
    required this.onOpenCart,
    required this.onOpenWishlist,
    this.onOpenDrawer,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? CyberColors.darkSurface.withOpacity(0.92)
            : CyberColors.lightSurface.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Mobile Menu Drawer Button
            if (!isDesktop && onOpenDrawer != null) ...[
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: onOpenDrawer,
                tooltip: 'Open Menu',
              ),
              const SizedBox(width: 8),
            ],

            // Brand Logo
            InkWell(
              onTap: () {
                store.setCategory('All');
                store.setSearchQuery('');
                if (store.isAdminMode) {
                  store.setAdminMode(false);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: CyberColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: CyberColors.cyanPrimary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CYBER',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'PULSE',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      foreground: Paint()
                        ..shader = CyberColors.primaryGradient.createShader(
                          const Rect.fromLTWH(0.0, 0.0, 100.0, 30.0),
                        ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Search Bar (Desktop / Tablet)
            if (isDesktop) ...[
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  height: 42,
                  child: TextField(
                    onChanged: (val) => store.setSearchQuery(val),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search next-gen gear, chips, headsets, specs...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: store.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => store.setSearchQuery(''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      filled: true,
                      fillColor: isDark
                          ? CyberColors.darkSurfaceLight
                          : CyberColors.lightSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark
                              ? CyberColors.darkBorder
                              : CyberColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark
                              ? CyberColors.darkBorder
                              : CyberColors.lightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: CyberColors.cyanPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ] else ...[
              const Spacer(),
            ],

            // Action: Switch Role (Admin / Storefront)
            Container(
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: store.isAdminMode
                    ? CyberColors.neonPurpleGradient
                    : CyberColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: (store.isAdminMode
                            ? CyberColors.purpleNeon
                            : CyberColors.cyanPrimary)
                        .withOpacity(0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: store.isAdminMode ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: Icon(
                  store.isAdminMode
                      ? Icons.storefront_rounded
                      : Icons.admin_panel_settings_rounded,
                  size: 18,
                ),
                label: Text(
                  store.isAdminMode ? 'Storefront' : 'Admin Panel',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () {
                  if (store.isAdminMode) {
                    store.setAdminMode(false);
                  } else {
                    if (store.isCurrentUserAdmin) {
                      store.setAdminMode(true);
                    } else {
                      AuthModal.show(
                        context,
                        requireAdmin: true,
                        onSuccess: () => store.setAdminMode(true),
                      );
                    }
                  }
                },
              ),
            ),

            // User Profile / Authentication Button
            _buildUserAuthButton(context, store, isDark, isDesktop),

            // Theme Toggle
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? CyberColors.amberWarning : Colors.grey[800],
              ),
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () => store.toggleTheme(),
            ),

            // Wishlist Button (Only in Storefront)
            if (!store.isAdminMode) ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      store.wishlistIds.isNotEmpty
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: store.wishlistIds.isNotEmpty
                          ? CyberColors.pinkAccent
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    tooltip: 'Wishlist',
                    onPressed: onOpenWishlist,
                  ),
                  if (store.wishlistIds.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: CyberColors.pinkAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${store.wishlistIds.length}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              // Cart Button with Badge
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    tooltip: 'Shopping Cart',
                    onPressed: onOpenCart,
                  ),
                  if (store.cartCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CyberColors.cyanPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: CyberColors.cyanPrimary.withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        child: Text(
                          '${store.cartCount}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserAuthButton(
    BuildContext context,
    StoreProvider store,
    bool isDark,
    bool isDesktop,
  ) {
    final user = store.currentUser;

    if (user != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => UserProfileModal.show(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 10 : 6,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: user.isAdmin
                    ? CyberColors.purpleNeon.withOpacity(0.6)
                    : CyberColors.cyanPrimary.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: user.isAdmin
                        ? CyberColors.neonPurpleGradient
                        : CyberColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: user.isAdmin ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 8),
                  Text(
                    user.name.split(' ').first,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    user.isAdmin ? Icons.shield_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: user.isAdmin ? CyberColors.purpleNeon : Colors.grey,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Guest / Not logged in
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 36,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
          side: const BorderSide(color: CyberColors.cyanPrimary, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: const Icon(Icons.login_rounded, size: 16, color: CyberColors.cyanPrimary),
        label: isDesktop
            ? Text(
                'Sign In',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CyberColors.cyanPrimary,
                ),
              )
            : const SizedBox.shrink(),
        onPressed: () => AuthModal.show(context),
      ),
    );
  }
}
