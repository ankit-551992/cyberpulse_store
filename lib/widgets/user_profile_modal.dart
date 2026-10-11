import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyber_colors.dart';
import '../providers/store_provider.dart';
import '../screens/customer/order_tracking_screen.dart';
import 'auth_modal.dart';

class UserProfileModal extends StatelessWidget {
  const UserProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const UserProfileModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final user = store.currentUser;
    final isDark = store.isDarkMode;

    if (user == null) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 54, color: Colors.grey),
              const SizedBox(height: 12),
              Text('You are currently browsing as Guest', style: GoogleFonts.outfit(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign In / Register'),
                onPressed: () {
                  Navigator.of(context).pop();
                  AuthModal.show(context);
                },
              ),
            ],
          ),
        ),
      );
    }

    final myOrders = store.myOrders;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1420) : CyberColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: user.isAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (user.isAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary)
                    .withOpacity(0.25),
                blurRadius: 28,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Profile Banner
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: user.isAdmin
                            ? [const Color(0xFF1F0B2E), const Color(0xFF0F1420)]
                            : [const Color(0xFF082635), const Color(0xFF0F1420)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar Halo
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: user.isAdmin
                                ? CyberColors.neonPurpleGradient
                                : CyberColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: (user.isAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary)
                                    .withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: user.isAdmin ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name & Role
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (user.isAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: (user.isAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary)
                                        .withOpacity(0.6),
                                  ),
                                ),
                                child: Text(
                                  user.role.badgeLabel,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: user.isAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // User Info Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Details list
                        _buildInfoRow(
                          icon: Icons.alternate_email_rounded,
                          title: 'Email',
                          value: user.email,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                          icon: Icons.phone_iphone_rounded,
                          title: 'Phone',
                          value: user.phone,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          title: 'Default Address',
                          value: user.fullAddress,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 18),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${myOrders.length}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: CyberColors.cyanPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Orders',
                                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${store.wishlistIds.length}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: CyberColors.pinkAccent,
                                      ),
                                    ),
                                    Text(
                                      'Wishlist',
                                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${store.cartCount}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: CyberColors.amberWarning,
                                      ),
                                    ),
                                    Text(
                                      'In Cart',
                                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Action 1: If Admin, Go to Admin Panel
                        if (user.isAdmin) ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CyberColors.purpleNeon,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.admin_panel_settings_rounded),
                            label: Text(
                              store.isAdminMode ? 'You are in Admin Mission Control' : 'Open Admin Mission Control',
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (!store.isAdminMode) {
                                store.setAdminMode(true);
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Action 2: View Recent Orders
                        if (myOrders.isNotEmpty) ...[
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.receipt_long_rounded, color: CyberColors.cyanPrimary),
                            label: Text(
                              'Track Latest Order (${myOrders.first.id})',
                              style: GoogleFonts.spaceGrotesk(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderTrackingScreen(order: myOrders.first),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Action 3: Switch Account / Sign In as another user
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.switch_account_rounded, size: 18),
                          label: const Text('Switch Account / Demo User'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            AuthModal.show(context);
                          },
                        ),
                        const SizedBox(height: 10),

                        // Action 4: Sign Out
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.12),
                            foregroundColor: Colors.redAccent,
                            shadowColor: Colors.transparent,
                            side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Sign Out'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await store.signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
