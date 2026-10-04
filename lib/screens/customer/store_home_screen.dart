import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/store_provider.dart';
import '../../theme/cyber_colors.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/product_card.dart';
import '../../data/mock_data.dart';
import 'product_detail_screen.dart';

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  final TextEditingController _newsletterController = TextEditingController();

  @override
  void dispose() {
    _newsletterController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context, StoreProvider store, bool isDark) {
    RangeValues currentRange = store.priceRange;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      store.resetFilters();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Reset All'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Price Range: \$${currentRange.start.toInt()} - \$${currentRange.end.toInt()}',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              RangeSlider(
                values: currentRange,
                min: 0,
                max: 5000,
                divisions: 50,
                activeColor: CyberColors.cyanPrimary,
                labels: RangeLabels(
                  '\$${currentRange.start.toInt()}',
                  '\$${currentRange.end.toInt()}',
                ),
                onChanged: (vals) {
                  setSheetState(() => currentRange = vals);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    store.setPriceRange(currentRange);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Apply Filter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final products = store.filteredProducts;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cyber Hero Banner
          _buildHeroBanner(context, isDark, isDesktop),

          // Cyber Promo Strip (Ticker)
          _buildPromoStrip(isDark),

          // Catalog Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Chips Bar
                    _buildCategoryChips(store, isDark),

                    const SizedBox(height: 24),

                    // Controls Row (Product count, Sort dropdown, Filter button)
                    _buildControlsRow(context, store, isDark, products.length),

                    const SizedBox(height: 24),

                    // Product Grid or Empty State
                    if (products.isEmpty)
                      _buildEmptyState(store, isDark)
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isDesktop ? 300 : 260,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(product: product),
                                ),
                              );
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 60),

                    // Trust & Features Badges
                    _buildTrustSection(isDark),

                    const SizedBox(height: 60),

                    // Newsletter & Footer
                    _buildFooter(store, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDark, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF070A10) : const Color(0xFFEBF1F7),
        border: Border(
          bottom: BorderSide(
            color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isDesktop ? 64 : 40,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: CyberColors.cyanPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: CyberColors.cyanPrimary.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded,
                                size: 14, color: CyberColors.cyanPrimary),
                            const SizedBox(width: 8),
                            Text(
                              'NEXT-GEN HARDWARE ARCHITECTURE 2026',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: CyberColors.cyanPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Engineered for Peak Velocity.',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 46 : 30,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Unlock unprecedented performance with next-generation M4 workstations, neural-powered flagships, and quantum gaming displays.',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 16 : 14,
                          height: 1.6,
                          color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<StoreProvider>().setCategory('Laptops');
                            },
                            icon: const Icon(Icons.bolt_rounded, size: 18),
                            label: const Text('Explore Laptops'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<StoreProvider>().setCategory('All');
                            },
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: const Text('View All Tech'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 340,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: CyberColors.cyanPrimary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CyberColors.cyanPrimary.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1000',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: CyberColors.pinkAccent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'FEATURED LAUNCH',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ApexBook Pro 16 Max with Neural Core',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoStrip(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        gradient: CyberColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          '⚡ SPECIAL OFFER: Use code CYBER20 at checkout for 20% OFF all orders above \$500! ⚡',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(StoreProvider store, bool isDark) {
    final categories = MockData.categories;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = store.selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: CyberColors.cyanPrimary,
              backgroundColor: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
              labelStyle: GoogleFonts.spaceGrotesk(
                color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected
                    ? CyberColors.cyanPrimary
                    : (isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
              ),
              onSelected: (_) => store.setCategory(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlsRow(BuildContext context, StoreProvider store, bool isDark, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Product Count
        Text(
          'Showing $count ${store.selectedCategory} Products',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Filter and Sort Actions
        Row(
          children: [
            // Filter Button
            OutlinedButton.icon(
              onPressed: () => _showFilterSheet(context, store, isDark),
              icon: const Icon(Icons.filter_list_rounded, size: 16),
              label: const Text('Filter Price'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(width: 12),

            // Sort Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: store.selectedSort,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  dropdownColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                  items: [
                    'Popular',
                    'Price: Low to High',
                    'Price: High to Low',
                    'Top Rated',
                    'Newest',
                  ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) store.setSortOption(val);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(StoreProvider store, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 16),
            Text(
              'No Gadgets Match Your Search',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search keywords, price range, or category filter.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => store.resetFilters(),
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustSection(bool isDark) {
    final features = [
      {'icon': Icons.bolt_rounded, 'title': 'HyperSpeed Express', 'desc': 'Free 24h tracked dispatch on orders above \$1500'},
      {'icon': Icons.verified_user_rounded, 'title': '2-Year Warranty', 'desc': 'Comprehensive manufacturer protection on all devices'},
      {'icon': Icons.swap_horiz_rounded, 'title': '30-Day Escrow Returns', 'desc': 'No questions asked return guarantee with zero hassle'},
      {'icon': Icons.support_agent_rounded, 'title': '24/7 Expert Engineers', 'desc': 'Direct live technical support for setup and specs'},
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: features.map((f) {
              return SizedBox(
                width: isWide ? (constraints.maxWidth - 72) / 4 : constraints.maxWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CyberColors.cyanPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(f['icon'] as IconData, color: CyberColors.cyanPrimary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f['title'] as String,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f['desc'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildFooter(StoreProvider store, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurfaceLight.withOpacity(0.4) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: CyberColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded, size: 16, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Text(
                'CYBERPULSE HARDWARE LABS',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The frontier of consumer electronics, high-power silicon, and spatial computing.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '© 2026 CyberPulse Store. All rights reserved. Built with Flutter Web & App.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: isDark ? CyberColors.darkTextMuted : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
