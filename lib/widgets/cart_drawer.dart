import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/store_provider.dart';
import '../theme/cyber_colors.dart';
import 'checkout_modal.dart';

class CartDrawer extends StatefulWidget {
  const CartDrawer({super.key});

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  final TextEditingController _promoController = TextEditingController();
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyCoupon(StoreProvider store) {
    if (_promoController.text.trim().isEmpty) return;
    final success = store.applyPromoCode(_promoController.text);
    if (success) {
      setState(() => _promoError = null);
      _promoController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: CyberColors.emeraldGreen,
          content: Text('Promo code applied successfully! 🎉'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() => _promoError = 'Invalid code. Try CYBER20 or FUTURE15');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      width: 440,
      color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: isDark ? CyberColors.darkBg : CyberColors.lightSurfaceAlt,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CyberColors.cyanPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded,
                      color: CyberColors.cyanPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cyber Cart',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        '${store.cartCount} items selected',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? CyberColors.darkTextSecondary
                              : CyberColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (store.cart.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => store.clearCart(),
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: CyberColors.roseDanger),
                    label: Text(
                      'Clear',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: CyberColors.roseDanger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Drawer Body: Items or Empty state
          Expanded(
            child: store.cart.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? CyberColors.darkSurfaceLight
                                  : CyberColors.lightSurfaceAlt,
                            ),
                            child: Icon(
                              Icons.remove_shopping_cart_outlined,
                              size: 56,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Your Cart is Empty',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explore our futuristic gadget collection and add items to your cart.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark
                                  ? CyberColors.darkTextSecondary
                                  : CyberColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.explore_rounded, size: 18),
                            label: const Text('Start Exploring'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: store.cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = store.cart[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? CyberColors.darkSurfaceLight
                              : CyberColors.lightSurfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? CyberColors.darkBorder
                                : CyberColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrls.first,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 64,
                                  color: Colors.grey.withOpacity(0.2),
                                  child: const Icon(Icons.devices),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Info & Controls
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (item.selectedColor != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Color: ${item.selectedColor}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: isDark
                                            ? CyberColors.darkTextMuted
                                            : CyberColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    currency.format(item.product.price),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: CyberColors.cyanPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Stepper
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                  onPressed: () => store.updateCartQuantity(
                                    item.product.id,
                                    item.selectedColor,
                                    item.quantity - 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '${item.quantity}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                                  onPressed: () => store.updateCartQuantity(
                                    item.product.id,
                                    item.selectedColor,
                                    item.quantity + 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Promo Code and Bill Summary (Only if cart not empty)
          if (store.cart.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? CyberColors.darkBg : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Promo Code Input
                  if (store.appliedPromoCode == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _promoController,
                              style: GoogleFonts.spaceGrotesk(fontSize: 12),
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Promo code (e.g. CYBER20)',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                errorText: _promoError,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => _applyCoupon(store),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Quick promo suggestions
                    Row(
                      children: [
                        Text(
                          'Try: ',
                          style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                        InkWell(
                          onTap: () {
                            _promoController.text = 'CYBER20';
                            _applyCoupon(store);
                          },
                          child: Text(
                            'CYBER20 (20% OFF)',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: CyberColors.cyanPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: CyberColors.emeraldGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CyberColors.emeraldGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.discount_rounded,
                              size: 16, color: CyberColors.emeraldGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Coupon: ${store.appliedPromoCode}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: CyberColors.emeraldGreen,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: CyberColors.roseDanger),
                            onPressed: () => store.removePromoCode(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Financial summary
                  _summaryRow('Subtotal', currency.format(store.subtotal), isDark),
                  if (store.discountAmount > 0)
                    _summaryRow(
                      'Discount (${(store.promoDiscountPercent * 100).toInt()}%)',
                      '-${currency.format(store.discountAmount)}',
                      isDark,
                      valueColor: CyberColors.emeraldGreen,
                    ),
                  _summaryRow(
                    'Shipping',
                    store.shippingFee == 0.0 ? 'FREE' : currency.format(store.shippingFee),
                    isDark,
                    valueColor: store.shippingFee == 0.0 ? CyberColors.emeraldGreen : null,
                  ),
                  _summaryRow('Estimated Tax (8%)', currency.format(store.estimatedTax), isDark),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currency.format(store.totalAmount),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..shader = CyberColors.primaryGradient.createShader(
                              const Rect.fromLTWH(0.0, 0.0, 150.0, 30.0),
                            ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Checkout CTA
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close drawer
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const CheckoutModal(),
                        );
                      },
                      icon: const Icon(Icons.lock_outline_rounded, size: 18),
                      label: Text(
                        'Proceed to Checkout (${currency.format(store.totalAmount)})',
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
