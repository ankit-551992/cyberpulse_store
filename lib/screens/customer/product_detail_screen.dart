import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/currency_helper.dart';
import '../../models/product.dart';
import '../../providers/store_provider.dart';
import '../../theme/cyber_colors.dart';
import '../../widgets/cyber_badge.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/checkout_modal.dart';
import '../../data/mock_data.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String? _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
  }

  void _showAddReviewDialog(BuildContext context, bool isDark) {
    final commentController = TextEditingController();
    final nameController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Write a Review', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: CyberColors.amberWarning,
                    ),
                    onPressed: () => setDialogState(() => rating = index + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share your experience with this tech gadget...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty && commentController.text.trim().isNotEmpty) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: CyberColors.emeraldGreen,
                      content: Text('Review submitted! Thank you for your feedback.'),
                    ),
                  );
                }
              },
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;
    final isWish = store.isWishlisted(widget.product.id);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name, style: GoogleFonts.outfit(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(
              isWish ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isWish ? CyberColors.pinkAccent : null,
            ),
            onPressed: () => store.toggleWishlist(widget.product.id),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Info Section (Split on desktop, stacked on mobile)
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _buildImageGallery(isDark)),
                      const SizedBox(width: 48),
                      Expanded(flex: 6, child: _buildProductDetails(store, isDark)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildImageGallery(isDark),
                      const SizedBox(height: 28),
                      _buildProductDetails(store, isDark),
                    ],
                  ),

                const SizedBox(height: 48),

                // Specifications Section
                _buildSpecificationsSection(isDark),

                const SizedBox(height: 48),

                // Customer Reviews Section
                _buildReviewsSection(isDark),

                const SizedBox(height: 48),

                // Related Products
                _buildRelatedProducts(store, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(bool isDark) {
    final images = widget.product.imageUrls;

    return Column(
      children: [
        // Main Image
        Container(
          height: 420,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              images[_selectedImageIndex],
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) => const Center(child: Icon(Icons.devices, size: 64)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Thumbnails
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              final idx = entry.key;
              final url = entry.value;
              final isSelected = _selectedImageIndex == idx;

              return InkWell(
                onTap: () => setState(() => _selectedImageIndex = idx),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? CyberColors.cyanPrimary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(url, fit: BoxFit.cover),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildProductDetails(StoreProvider store, bool isDark) {
    final inStock = widget.product.isInStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand & Category
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: CyberColors.cyanPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${widget.product.brand.toUpperCase()} • ${widget.product.category.toUpperCase()}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: CyberColors.cyanPrimary,
                ),
              ),
            ),
            CyberBadge.stockStatus(widget.product.stockQuantity),
          ],
        ),

        const SizedBox(height: 12),

        // Title
        Text(
          widget.product.name,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        // Ratings & Reviews count
        Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.product.rating.floor()
                      ? Icons.star_rounded
                      : Icons.star_half_rounded,
                  size: 18,
                  color: CyberColors.amberWarning,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.product.rating} (${widget.product.reviewCount} customer reviews)',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Price Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              CurrencyHelper.format(widget.product.price),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..shader = CyberColors.primaryGradient.createShader(
                    const Rect.fromLTWH(0.0, 0.0, 200.0, 40.0),
                  ),
              ),
            ),
            if (widget.product.originalPrice > widget.product.price) ...[
              const SizedBox(width: 14),
              Text(
                CurrencyHelper.format(widget.product.originalPrice),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  decoration: TextDecoration.lineThrough,
                  color: isDark ? CyberColors.darkTextMuted : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: CyberColors.neonPurpleGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SAVE ${widget.product.discountPercentage}%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),

        // Description
        Text(
          widget.product.description,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.6,
            color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
          ),
        ),

        const SizedBox(height: 24),

        // Color selection
        if (widget.product.colors.isNotEmpty) ...[
          Text(
            'Variant / Color: ${_selectedColor ?? ""}',
            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: widget.product.colors.map((color) {
              final isSelected = _selectedColor == color;
              return ChoiceChip(
                label: Text(color),
                selected: isSelected,
                selectedColor: CyberColors.cyanPrimary,
                backgroundColor: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                labelStyle: GoogleFonts.spaceGrotesk(
                  color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                onSelected: (val) => setState(() => _selectedColor = color),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Quantity selector
        Row(
          children: [
            Text(
              'Quantity:',
              style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$_quantity',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: _quantity < widget.product.stockQuantity
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Action Buttons: Add to Cart and Buy Now
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: inStock
                      ? () {
                          store.addToCart(
                            widget.product,
                            color: _selectedColor,
                            quantity: _quantity,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: CyberColors.darkSurfaceLight,
                              content: Text('Added $_quantity item(s) to your Cyber Cart!'),
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                textColor: CyberColors.cyanPrimary,
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                  label: Text(
                    inStock ? 'Add to Cyber Cart' : 'Currently Unavailable',
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            if (inStock)
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    store.addToCart(widget.product, color: _selectedColor, quantity: _quantity);
                    showDialog(
                      context: context,
                      builder: (_) => const CheckoutModal(),
                    );
                  },
                  child: Text(
                    'Instant Checkout',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 28),

        // Value props badges
        Row(
          children: [
            _badgeItem(Icons.verified_outlined, '2-Year Warranty', isDark),
            const SizedBox(width: 16),
            _badgeItem(Icons.local_shipping_outlined, 'Free Shipping \$1500+', isDark),
            const SizedBox(width: 16),
            _badgeItem(Icons.sync_alt_rounded, '30-Day Returns', isDark),
          ],
        ),
      ],
    );
  }

  Widget _badgeItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: CyberColors.cyanPrimary),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection(bool isDark) {
    if (widget.product.specs.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Specifications',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
            ),
          ),
          child: Column(
            children: widget.product.specs.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? CyberColors.darkBorder.withOpacity(0.5) : CyberColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        entry.value,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? CyberColors.cyanPrimary : const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Verified Customer Feedback',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            OutlinedButton.icon(
              onPressed: () => _showAddReviewDialog(context, isDark),
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Write a Review'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...MockData.sampleReviews.map((rev) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(rev.userAvatar),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rev.userName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(DateFormat.yMMMd().format(rev.date),
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(
                          rev.rating.toInt(),
                          (i) => const Icon(Icons.star_rounded, size: 16, color: CyberColors.amberWarning),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(rev.comment, style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildRelatedProducts(StoreProvider store, bool isDark) {
    final related = store.allProducts
        .where((p) => p.category == widget.product.category && p.id != widget.product.id)
        .take(3)
        .toList();

    if (related.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More in ${widget.product.category}',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: related.map((p) {
            return SizedBox(
              width: 260,
              height: 340,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        p.imageUrls.first,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(CurrencyHelper.format(p.price),
                                style: GoogleFonts.spaceGrotesk(
                                    color: CyberColors.cyanPrimary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
