import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/currency_helper.dart';
import '../models/product.dart';
import '../providers/store_provider.dart';
import '../theme/cyber_colors.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;
    final isWish = store.isWishlisted(widget.product.id);
    

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -6, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? CyberColors.cyanPrimary.withOpacity(0.8)
                : (isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? CyberColors.cyanPrimary.withOpacity(0.2)
                  : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container with Badges
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: isDark
                            ? CyberColors.darkSurfaceLight
                            : CyberColors.lightSurfaceAlt,
                        child: Image.network(
                          widget.product.imageUrls.isNotEmpty
                              ? widget.product.imageUrls.first
                              : 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.devices_other_rounded,
                              size: 48,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CyberColors.cyanPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Discount Tag
                    if (widget.product.discountPercentage > 0)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: CyberColors.neonPurpleGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.pinkAccent.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            '-${widget.product.discountPercentage}%',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Wishlist Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => store.toggleWishlist(widget.product.id),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWish ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18,
                              color: isWish
                                  ? CyberColors.pinkAccent
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Stock Tag if low
                    if (widget.product.isLowStock)
                      Positioned(
                        bottom: 8,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CyberColors.amberWarning.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Only ${widget.product.stockQuantity} left!',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Info
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category & Rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.product.category.toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: CyberColors.cyanPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: CyberColors.amberWarning,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${widget.product.rating}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Product Name
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Mini specs pill
                          if (widget.product.specs.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? CyberColors.darkSurfaceLight
                                    : CyberColors.lightSurfaceAlt,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.product.specs.values.first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: isDark
                                      ? CyberColors.darkTextSecondary
                                      : CyberColors.lightTextSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Price and Add to Cart Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.product.originalPrice > widget.product.price)
                                  Text(
                                    CurrencyHelper.format(widget.product.originalPrice),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                      color: isDark
                                          ? CyberColors.darkTextMuted
                                          : CyberColors.lightTextMuted,
                                    ),
                                  ),
                                Text(
                                  CurrencyHelper.format(widget.product.price),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Add to Cart Button
                          widget.product.isInStock
                              ? Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      store.addToCart(widget.product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          width: 320,
                                          backgroundColor: CyberColors.darkSurfaceLight,
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle_rounded,
                                                  color: CyberColors.emeraldGreen, size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  '${widget.product.name} added to cart',
                                                  style: GoogleFonts.inter(fontSize: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: CyberColors.cyanPrimary,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CyberColors.cyanPrimary.withOpacity(0.3),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.add_shopping_cart_rounded,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Sold Out',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
