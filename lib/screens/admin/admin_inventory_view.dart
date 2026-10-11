import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/inventory_log.dart';
import '../../providers/store_provider.dart';
import '../../theme/cyber_colors.dart';
import '../../utils/currency_helper.dart';

class AdminInventoryView extends StatefulWidget {
  const AdminInventoryView({super.key});

  @override
  State<AdminInventoryView> createState() => _AdminInventoryViewState();
}

class _AdminInventoryViewState extends State<AdminInventoryView> {
  String _viewMode = 'matrix'; // 'matrix', 'ledger', 'warehouses'
  String _searchQuery = '';
  String _stockFilter = 'all'; // 'all', 'low', 'out', 'healthy'
  String _warehouseFilter = 'all';
  String _sortBy = 'stock_asc'; // 'stock_asc', 'stock_desc', 'valuation_desc', 'name'
  String _ledgerFilter = 'all'; // 'all', 'restock', 'orderSale', 'damaged', 'adjustment', 'customerReturn', 'transfer'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;

    // Filter products
    List<Product> products = store.products.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q);
        if (!matches) return false;
      }

      if (_stockFilter == 'low' && !p.isLowStock) return false;
      if (_stockFilter == 'out' && !p.isOutOfStock) return false;
      if (_stockFilter == 'healthy' && (p.isLowStock || p.isOutOfStock)) return false;

      if (_warehouseFilter != 'all') {
        if (!p.warehouseLocation.toLowerCase().contains(_warehouseFilter.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort products
    products.sort((a, b) {
      switch (_sortBy) {
        case 'stock_asc':
          return a.stockQuantity.compareTo(b.stockQuantity);
        case 'stock_desc':
          return b.stockQuantity.compareTo(a.stockQuantity);
        case 'valuation_desc':
          return (b.stockQuantity * b.price).compareTo(a.stockQuantity * a.price);
        case 'name':
        default:
          return a.name.compareTo(b.name);
      }
    });

    final totalUnits = store.products.fold<int>(0, (sum, p) => sum + p.stockQuantity);
    final totalValuation = store.products.fold<double>(0.0, (sum, p) => sum + (p.stockQuantity * p.price));
    final lowStockCount = store.lowStockProducts.length;
    final outOfStockCount = store.products.where((p) => p.isOutOfStock).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Ribbon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Inventory & Fulfillment Command Center',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CyberColors.cyanPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: CyberColors.cyanPrimary.withOpacity(0.4)),
                          ),
                          child: Text(
                            'LIVE SYNC',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.cyanPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Multi-node warehouse allocation, automated replenishment, variant matrices & real-time stock audit.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Mode Switcher Pills
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    _buildModeButton(
                      id: 'matrix',
                      label: 'Stock Matrix',
                      icon: Icons.inventory_2_rounded,
                      isDark: isDark,
                    ),
                    _buildModeButton(
                      id: 'ledger',
                      label: 'Audit Ledger',
                      icon: Icons.receipt_long_rounded,
                      isDark: isDark,
                      badge: store.stockMovements.length.toString(),
                    ),
                    _buildModeButton(
                      id: 'warehouses',
                      label: 'Warehouse Hubs',
                      icon: Icons.hub_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildMetricCard(
                    title: 'Total Stock Units',
                    value: '$totalUnits Units',
                    subtitle: 'Across ${store.products.length} product lines',
                    icon: Icons.widgets_rounded,
                    accentColor: CyberColors.cyanPrimary,
                    isDark: isDark,
                    width: isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                  ),
                  _buildMetricCard(
                    title: 'Inventory Asset Value',
                    value: CurrencyHelper.format(totalValuation),
                    subtitle: 'Current retail valuation',
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: CyberColors.emeraldGreen,
                    isDark: isDark,
                    width: isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                  ),
                  _buildMetricCard(
                    title: 'Low Stock Alerts',
                    value: '$lowStockCount Items',
                    subtitle: 'Stock ≤ safety threshold',
                    icon: Icons.warning_amber_rounded,
                    accentColor: CyberColors.amberWarning,
                    isDark: isDark,
                    width: isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                  ),
                  _buildMetricCard(
                    title: 'Critical Stockouts',
                    value: '$outOfStockCount Depleted',
                    subtitle: 'Zero available inventory',
                    icon: Icons.error_outline_rounded,
                    accentColor: CyberColors.roseDanger,
                    isDark: isDark,
                    width: isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Main View Content
          if (_viewMode == 'matrix')
            _buildStockMatrixView(context, store, products, isDark)
          else if (_viewMode == 'ledger')
            _buildAuditLedgerView(context, store, isDark)
          else
            _buildWarehousesView(context, store, isDark),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String id,
    required String label,
    required IconData icon,
    required bool isDark,
    String? badge,
  }) {
    final isSelected = _viewMode == id;
    return InkWell(
      onTap: () => setState(() => _viewMode = id),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CyberColors.cyanPrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.black
                  : (isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.black
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black.withOpacity(0.2)
                      : (isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : CyberColors.cyanPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? CyberColors.darkTextMuted : CyberColors.lightTextMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockMatrixView(
    BuildContext context,
    StoreProvider store,
    List<Product> products,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action & Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Search Field
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.inter(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search inventory by name, SKU, brand, category...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Warehouse Filter
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _warehouseFilter,
                      decoration: const InputDecoration(
                        labelText: 'Warehouse Node',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Warehouses')),
                        DropdownMenuItem(value: 'Bengaluru', child: Text('BLR Central Hub')),
                        DropdownMenuItem(value: 'Mumbai', child: Text('BOM Tech DC')),
                        DropdownMenuItem(value: 'Delhi', child: Text('DEL Silicon Hub')),
                        DropdownMenuItem(value: 'Hyderabad', child: Text('HYD Quantum Node')),
                      ],
                      onChanged: (val) => setState(() => _warehouseFilter = val ?? 'all'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Sort Dropdown
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: const InputDecoration(
                        labelText: 'Sort By',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'stock_asc', child: Text('Stock: Lowest First')),
                        DropdownMenuItem(value: 'stock_desc', child: Text('Stock: Highest First')),
                        DropdownMenuItem(value: 'valuation_desc', child: Text('Valuation: High to Low')),
                        DropdownMenuItem(value: 'name', child: Text('Product Name (A-Z)')),
                      ],
                      onChanged: (val) => setState(() => _sortBy = val ?? 'stock_asc'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Bulk Replenish Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberColors.amberWarning,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirmBulkReplenishment(context, store),
                    icon: const Icon(Icons.flash_on_rounded, size: 18),
                    label: Text(
                      'Bulk Restock Low Items',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Filter Chips Row
              Row(
                children: [
                  Text(
                    'Status Filter:',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildStatusChip('all', 'All Products (${store.products.length})', isDark),
                  const SizedBox(width: 8),
                  _buildStatusChip('out', 'Out of Stock (${store.products.where((p) => p.isOutOfStock).length})', isDark, color: CyberColors.roseDanger),
                  const SizedBox(width: 8),
                  _buildStatusChip('low', 'Low Stock (≤ 5)', isDark, color: CyberColors.amberWarning),
                  const SizedBox(width: 8),
                  _buildStatusChip('healthy', 'Healthy Stock', isDark, color: CyberColors.emeraldGreen),
                  const Spacer(),
                  Text(
                    'Showing ${products.length} catalog items',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? CyberColors.darkTextMuted : CyberColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Product Stock Table
        if (products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 56, color: isDark ? Colors.white24 : Colors.black26),
                  const SizedBox(height: 16),
                  Text('No products match your filters', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Try adjusting your search query or status filter.', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductInventoryCard(context, store, product, isDark);
            },
          ),
      ],
    );
  }

  Widget _buildStatusChip(String id, String label, bool isDark, {Color? color}) {
    final isSelected = _stockFilter == id;
    final activeColor = color ?? CyberColors.cyanPrimary;

    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? (activeColor == CyberColors.cyanPrimary || activeColor == CyberColors.amberWarning ? Colors.black : Colors.white)
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      selectedColor: activeColor,
      backgroundColor: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
      onSelected: (_) => setState(() => _stockFilter = id),
    );
  }

  Widget _buildProductInventoryCard(
    BuildContext context,
    StoreProvider store,
    Product product,
    bool isDark,
  ) {
    final statusColor = product.isOutOfStock
        ? CyberColors.roseDanger
        : (product.isLowStock ? CyberColors.amberWarning : CyberColors.emeraldGreen);

    final statusText = product.isOutOfStock
        ? 'OUT OF STOCK'
        : (product.isLowStock ? 'CRITICAL LOW (${product.stockQuantity})' : 'HEALTHY (${product.stockQuantity})');

    final progressVal = (product.stockQuantity / 30.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.isOutOfStock
              ? CyberColors.roseDanger.withOpacity(0.5)
              : (product.isLowStock
                  ? CyberColors.amberWarning.withOpacity(0.5)
                  : (isDark ? CyberColors.darkBorder : CyberColors.lightBorder)),
          width: product.isLowStock || product.isOutOfStock ? 1.5 : 1,
        ),
        boxShadow: [
          if (product.isLowStock || product.isOutOfStock)
            BoxShadow(
              color: statusColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.imageUrls.isNotEmpty
                      ? product.imageUrls.first
                      : 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800',
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 68,
                    height: 68,
                    color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                    child: const Icon(Icons.devices_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Product Info & SKU
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.brand.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: CyberColors.cyanPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${product.category}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? CyberColors.darkTextMuted : CyberColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.name,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // SKU chip
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: product.sku));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied SKU ${product.sku} to clipboard!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.qr_code_rounded, size: 12, color: CyberColors.cyanPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  product.sku,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.copy_rounded, size: 10, color: isDark ? Colors.white54 : Colors.black45),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Warehouse Hub Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: CyberColors.purpleAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warehouse_rounded, size: 12, color: CyberColors.purpleAccent),
                              const SizedBox(width: 4),
                              Text(
                                product.warehouseLocation,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: CyberColors.purpleAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stock Status Gauge
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withOpacity(0.4)),
                            ),
                            child: Text(
                              statusText,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          Text(
                            'Threshold: ${product.lowStockThreshold}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark ? CyberColors.darkTextMuted : CyberColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressVal,
                          minHeight: 6,
                          backgroundColor: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Asset Valuation
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyHelper.format(product.price * product.stockQuantity),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '${CurrencyHelper.format(product.price)} / unit',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? CyberColors.darkTextMuted : CyberColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Quick Adjust Steppers & Actions
              Row(
                children: [
                  _buildQuickStepButton(
                    label: '-5',
                    isDark: isDark,
                    onTap: () {
                      final newQty = (product.stockQuantity - 5).clamp(0, 9999);
                      store.adjustStock(
                        product.id,
                        newQty,
                        reason: 'Quick reduction -5 units',
                        type: StockMovementType.adjustment,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildQuickStepButton(
                    label: '-1',
                    isDark: isDark,
                    onTap: () {
                      final newQty = (product.stockQuantity - 1).clamp(0, 9999);
                      store.adjustStock(
                        product.id,
                        newQty,
                        reason: 'Quick reduction -1 unit',
                        type: StockMovementType.adjustment,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildQuickStepButton(
                    label: '+1',
                    isDark: isDark,
                    accent: true,
                    onTap: () {
                      store.adjustStock(
                        product.id,
                        product.stockQuantity + 1,
                        reason: 'Quick stock +1 unit',
                        type: StockMovementType.restock,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildQuickStepButton(
                    label: '+5',
                    isDark: isDark,
                    accent: true,
                    onTap: () {
                      store.adjustStock(
                        product.id,
                        product.stockQuantity + 5,
                        reason: 'Quick stock +5 units',
                        type: StockMovementType.restock,
                      );
                    },
                  ),
                  const SizedBox(width: 10),

                  // Detail Action: Restock / Adjust Modal
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.more_vert_rounded, size: 18),
                    ),
                    onSelected: (val) {
                      if (val == 'adjust') {
                        _showAdjustStockDialog(context, store, product, isDark);
                      } else if (val == 'variants') {
                        _showVariantsStockDialog(context, store, product, isDark);
                      } else if (val == 'restock_25') {
                        store.restockProduct(product.id, 25, reason: 'Manual quick restock 25 units');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added 25 units to ${product.name}!')),
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'adjust',
                        child: Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 16),
                            SizedBox(width: 8),
                            Text('Comprehensive Adjustment / Transfer'),
                          ],
                        ),
                      ),
                      if (product.colorStock.isNotEmpty)
                        const PopupMenuItem(
                          value: 'variants',
                          child: Row(
                            children: [
                              Icon(Icons.palette_rounded, size: 16),
                              SizedBox(width: 8),
                              Text('Variant Finish Stock Matrix'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'restock_25',
                        child: Row(
                          children: [
                            Icon(Icons.add_box_rounded, size: 16, color: CyberColors.emeraldGreen),
                            SizedBox(width: 8),
                            Text('Fast Restock +25 Units'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Variant Stock Matrix row (if variants exist)
          if (product.colorStock.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? CyberColors.darkSurfaceLight.withOpacity(0.5) : CyberColors.lightSurfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.style_outlined, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    'Color Variant Breakdown:',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: product.colorStock.entries.map((entry) {
                        final isLow = entry.value <= 2;
                        final isOut = entry.value == 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOut
                                ? CyberColors.roseDanger.withOpacity(0.15)
                                : (isLow ? CyberColors.amberWarning.withOpacity(0.15) : (isDark ? Colors.black26 : Colors.white)),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isOut
                                  ? CyberColors.roseDanger.withOpacity(0.4)
                                  : (isLow ? CyberColors.amberWarning.withOpacity(0.4) : Colors.transparent),
                            ),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isOut
                                  ? CyberColors.roseDanger
                                  : (isLow ? CyberColors.amberWarning : (isDark ? Colors.white : Colors.black87)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showVariantsStockDialog(context, store, product, isDark),
                    child: Text(
                      'Edit Variants',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: CyberColors.cyanPrimary,
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

  Widget _buildQuickStepButton({
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: accent
              ? CyberColors.cyanPrimary.withOpacity(0.15)
              : (isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: accent
                ? CyberColors.cyanPrimary.withOpacity(0.4)
                : (isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: accent
                ? CyberColors.cyanPrimary
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditLedgerView(BuildContext context, StoreProvider store, bool isDark) {
    List<InventoryLog> movements = store.stockMovements.where((m) {
      if (_ledgerFilter != 'all') {
        if (m.type.name != _ledgerFilter) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return m.productName.toLowerCase().contains(q) ||
            m.sku.toLowerCase().contains(q) ||
            m.reason.toLowerCase().contains(q) ||
            (m.referenceId?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search movement logs by SKU, product name, order ID or note...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _ledgerFilter,
                dropdownColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Events')),
                  DropdownMenuItem(value: 'restock', child: Text('Inbound Restock')),
                  DropdownMenuItem(value: 'orderSale', child: Text('Customer Sale / Order')),
                  DropdownMenuItem(value: 'damaged', child: Text('Damaged / Write-off')),
                  DropdownMenuItem(value: 'adjustment', child: Text('Audit Adjustment')),
                  DropdownMenuItem(value: 'customerReturn', child: Text('RMA Returns')),
                  DropdownMenuItem(value: 'transfer', child: Text('Warehouse Transfers')),
                ],
                onChanged: (val) => setState(() => _ledgerFilter = val ?? 'all'),
              ),
              const SizedBox(width: 16),
              Text(
                'Total Logs: ${movements.length}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (movements.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 56, color: isDark ? Colors.white24 : Colors.black26),
                  const SizedBox(height: 16),
                  Text('No stock movement logs found', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Stock adjustments and orders will automatically register audit events here.', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movements.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final log = movements[index];
              final isPositive = log.quantityDelta > 0;
              Color badgeColor;
              IconData logIcon;

              switch (log.type) {
                case StockMovementType.restock:
                  badgeColor = CyberColors.emeraldGreen;
                  logIcon = Icons.add_circle_outline_rounded;
                  break;
                case StockMovementType.orderSale:
                  badgeColor = CyberColors.cyanPrimary;
                  logIcon = Icons.shopping_bag_outlined;
                  break;
                case StockMovementType.damaged:
                  badgeColor = CyberColors.roseDanger;
                  logIcon = Icons.warning_rounded;
                  break;
                case StockMovementType.customerReturn:
                  badgeColor = CyberColors.purpleAccent;
                  logIcon = Icons.replay_rounded;
                  break;
                case StockMovementType.transfer:
                  badgeColor = CyberColors.amberWarning;
                  logIcon = Icons.sync_alt_rounded;
                  break;
                case StockMovementType.adjustment:
                default:
                  badgeColor = Colors.orange;
                  logIcon = Icons.tune_rounded;
                  break;
              }

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(logIcon, color: badgeColor, size: 20),
                    ),
                    const SizedBox(width: 14),

                    // Log Info
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                log.productName,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  log.sku,
                                  style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            log.reason,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                            ),
                          ),
                          if (log.referenceId != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Ref ID: ${log.referenceId}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                color: CyberColors.cyanPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Warehouse and Operator
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.warehouse,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          Text(
                            'By: ${log.performedBy}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDark ? CyberColors.darkTextMuted : CyberColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity transition
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isPositive ? CyberColors.emeraldGreen : CyberColors.roseDanger).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${isPositive ? '+' : ''}${log.quantityDelta}',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isPositive ? CyberColors.emeraldGreen : CyberColors.roseDanger,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${log.previousQuantity} ➔ ${log.newQuantity} units',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: isDark ? CyberColors.darkTextMuted : CyberColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Timestamp
                    Text(
                      _formatDate(log.timestamp),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: isDark ? CyberColors.darkTextMuted : CyberColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildWarehousesView(BuildContext context, StoreProvider store, bool isDark) {
    final hubs = [
      {
        'name': 'Bengaluru Central Cyber Hub',
        'city': 'Bengaluru, Karnataka',
        'code': 'BLR-01',
        'type': 'Mega Fulfillment Center',
        'color': CyberColors.cyanPrimary,
        'capacity': '94%',
        'icon': Icons.hub_rounded,
      },
      {
        'name': 'Mumbai Tech Freight Node',
        'city': 'Bhiwandi, Mumbai',
        'code': 'BOM-02',
        'type': 'West Coast Distribution Center',
        'color': CyberColors.purpleAccent,
        'capacity': '78%',
        'icon': Icons.local_shipping_rounded,
      },
      {
        'name': 'Delhi NCR Silicon Gateway',
        'city': 'Gurugram, NCR',
        'code': 'DEL-01',
        'type': 'North Express Dispatch Hub',
        'color': CyberColors.amberWarning,
        'capacity': '82%',
        'icon': Icons.flight_takeoff_rounded,
      },
      {
        'name': 'Hyderabad Quantum Node',
        'city': 'HITEC City, Hyderabad',
        'code': 'HYD-03',
        'type': 'Robotic Micro-Fulfillment Node',
        'color': CyberColors.emeraldGreen,
        'capacity': '65%',
        'icon': Icons.precision_manufacturing_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Fulfillment Nodes',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Inventory is distributed across 4 strategic express transit hubs to enable sub-24h delivery nationwide.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 220,
          ),
          itemCount: hubs.length,
          itemBuilder: (ctx, index) {
            final hub = hubs[index];
            final color = hub['color'] as Color;
            final code = hub['code'] as String;

            final hubProducts = store.products
                .where((p) => p.warehouseLocation.toLowerCase().contains((hub['city'] as String).split(',').first.toLowerCase()))
                .toList();

            final hubUnits = hubProducts.fold<int>(0, (s, p) => s + p.stockQuantity);
            final hubValuation = hubProducts.fold<double>(0.0, (s, p) => s + (p.stockQuantity * p.price));

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(hub['icon'] as IconData, color: color, size: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: CyberColors.emeraldGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle, size: 6, color: CyberColors.emeraldGreen),
                            const SizedBox(width: 5),
                            Text(
                              'OPERATIONAL',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: CyberColors.emeraldGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hub['name'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${hub['city']} • Node Code: $code',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STOCK UNITS', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text(
                            hubUnits > 0 ? '$hubUnits Units' : 'Shared Pool',
                            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NODE VALUATION', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text(
                            hubValuation > 0 ? CurrencyHelper.format(hubValuation) : '₹18,50,000',
                            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: CyberColors.cyanPrimary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('STORAGE LOAD', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text(
                            hub['capacity'] as String,
                            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Dialog: Adjust Stock
  void _showAdjustStockDialog(
    BuildContext context,
    StoreProvider store,
    Product product,
    bool isDark,
  ) {
    final qtyCtrl = TextEditingController(text: product.stockQuantity.toString());
    final reasonCtrl = TextEditingController(text: 'Routine warehouse inventory audit');
    StockMovementType movementType = StockMovementType.adjustment;
    String selectedWarehouse = product.warehouseLocation;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.tune_rounded, color: CyberColors.cyanPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Adjust Stock: ${product.name}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Units: ${product.stockQuantity}', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                        Text('SKU: ${product.sku}', style: GoogleFonts.spaceGrotesk(color: CyberColors.cyanPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'New Stock Target (Units)',
                      helperText: 'Enter absolute target inventory count',
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<StockMovementType>(
                    value: movementType,
                    decoration: const InputDecoration(labelText: 'Adjustment Reason / Type'),
                    items: const [
                      DropdownMenuItem(value: StockMovementType.restock, child: Text('Inbound Supplier Restock')),
                      DropdownMenuItem(value: StockMovementType.adjustment, child: Text('Physical Stock Audit Count')),
                      DropdownMenuItem(value: StockMovementType.damaged, child: Text('Damaged / Scrapped Write-off')),
                      DropdownMenuItem(value: StockMovementType.transfer, child: Text('Inter-Warehouse Hub Transfer')),
                      DropdownMenuItem(value: StockMovementType.customerReturn, child: Text('Customer RMA Return Restock')),
                    ],
                    onChanged: (val) => setDialogState(() => movementType = val!),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedWarehouse,
                    decoration: const InputDecoration(labelText: 'Fulfillment Location'),
                    items: {
                      product.warehouseLocation,
                      'Bengaluru Mega Hub - Bay 04',
                      'Mumbai DC - Bay 12',
                      'Delhi NCR Tech Hub - Bay 02',
                      'Hyderabad Silicon Node - Bay 07',
                    }.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                    onChanged: (val) => setDialogState(() => selectedWarehouse = val!),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Audit Memo / Justification',
                      hintText: 'e.g. Received PO-9081 from supplier',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newQty = int.tryParse(qtyCtrl.text.trim()) ?? product.stockQuantity;
                store.adjustStock(
                  product.id,
                  newQty,
                  reason: reasonCtrl.text.trim(),
                  type: movementType,
                  warehouse: selectedWarehouse,
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stock updated for ${product.name}: $newQty units!')),
                );
              },
              child: const Text('Confirm Adjustment'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog: Color Variants Stock Breakdown
  void _showVariantsStockDialog(
    BuildContext context,
    StoreProvider store,
    Product product,
    bool isDark,
  ) {
    final Map<String, TextEditingController> controllers = {};
    for (final entry in product.colorStock.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value.toString());
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          int totalVariantUnits = controllers.values.fold(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));

          return AlertDialog(
            backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.palette_rounded, color: CyberColors.cyanPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Variant Finish Stocks: ${product.name}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CyberColors.cyanPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sum of Variants:',
                            style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$totalVariantUnits Units',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: CyberColors.cyanPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...product.colorStock.keys.map((color) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                                color: _getColorFromName(color),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Text(
                                color,
                                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: controllers[color],
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setDialogState(() {}),
                                decoration: const InputDecoration(
                                  suffixText: 'units',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final Map<String, int> newColorStock = {};
                  for (final entry in controllers.entries) {
                    newColorStock[entry.key] = int.tryParse(entry.value.text) ?? 0;
                  }
                  store.updateVariantStock(product.id, newColorStock);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Updated variant stock matrix for ${product.name}!')),
                  );
                },
                child: const Text('Save Variant Stock'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmBulkReplenishment(BuildContext context, StoreProvider store) {
    final lowAndOutCount = store.products.where((p) => p.isLowStock || p.isOutOfStock).length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.flash_on_rounded, color: CyberColors.amberWarning),
            const SizedBox(width: 10),
            const Text('Automated Bulk Restock'),
          ],
        ),
        content: Text(
          'This will replenish +25 units across all $lowAndOutCount products currently flagged as Low Stock or Out of Stock, registering all audit logs.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CyberColors.amberWarning, foregroundColor: Colors.black),
            onPressed: () {
              store.bulkRestockLowItems(25);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: CyberColors.darkSurfaceLight,
                  content: Text('Successfully replenished +25 units across $lowAndOutCount products!'),
                ),
              );
            },
            child: const Text('Replenish +25 All'),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    final n = name.toLowerCase();
    if (n.contains('black') || n.contains('dark')) return Colors.black87;
    if (n.contains('white') || n.contains('silver')) return Colors.grey.shade300;
    if (n.contains('cyan') || n.contains('blue')) return CyberColors.cyanPrimary;
    if (n.contains('orange')) return Colors.orange;
    if (n.contains('gold')) return Colors.amber;
    if (n.contains('green')) return CyberColors.emeraldGreen;
    return CyberColors.purpleAccent;
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
