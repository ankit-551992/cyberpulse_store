import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../providers/store_provider.dart';
import '../../theme/cyber_colors.dart';
import '../../widgets/cyber_badge.dart';
import '../../widgets/responsive_layout.dart';
import '../../data/mock_data.dart';
import '../customer/order_tracking_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0;
  String _productSearchQuery = '';
  String _orderSearchQuery = '';
  OrderStatus? _selectedOrderStatusFilter;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation (Desktop / Tablet)
          if (isDesktop) _buildDesktopSidebar(store, isDark),

          // Main Admin Content Area
          Expanded(
            child: Column(
              children: [
                _buildAdminTopHeader(store, isDark),
                Expanded(
                  child: IndexedStack(
                    index: _selectedNavIndex,
                    children: [
                      _buildOverviewTab(store, isDark),
                      _buildProductsTab(store, isDark),
                      _buildOrdersTab(store, isDark),
                      _buildInventoryTab(store, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _selectedNavIndex,
              onTap: (i) => setState(() => _selectedNavIndex = i),
              backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
              selectedItemColor: CyberColors.cyanPrimary,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
                BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Inventory'),
              ],
            )
          : null,
    );
  }

  // Sidebar for Desktop
  Widget _buildDesktopSidebar(StoreProvider store, bool isDark) {
    final navItems = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.inventory_2_rounded, 'label': 'Products Catalog'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Order Management'},
      {'icon': Icons.warehouse_rounded, 'label': 'Stock & Inventory'},
    ];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C101A) : CyberColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          // Admin Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: CyberColors.neonPurpleGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CYBER ADMIN',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.0,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Mission Control v2.4',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 16),

          // Nav Items List
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = _selectedNavIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? CyberColors.cyanPrimary.withOpacity(0.12) : const Color(0xFFE0F2FE))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? CyberColors.cyanPrimary.withOpacity(0.4) : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: isSelected ? CyberColors.cyanPrimary : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    title: Text(
                      item['label'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    onTap: () => setState(() => _selectedNavIndex = index),
                  ),
                );
              },
            ),
          ),

          // Return to Customer Storefront
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alex Vance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Super Administrator', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => store.setAdminMode(false),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Back to Storefront'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Top header for Admin
  Widget _buildAdminTopHeader(StoreProvider store, bool isDark) {
    final titles = ['Dashboard & Analytics', 'Product Inventory (CRUD)', 'Orders Pipeline', 'Critical Stock Monitor'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                titles[_selectedNavIndex],
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Real-time status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberColors.emeraldGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CyberColors.emeraldGreen.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: CyberColors.emeraldGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live Sync Active',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: CyberColors.emeraldGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Theme Switch
              IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () => store.toggleTheme(),
              ),

              // Return to store for mobile
              if (!ResponsiveLayout.isDesktop(context))
                IconButton(
                  icon: const Icon(Icons.storefront_rounded),
                  tooltip: 'Back to Store',
                  onPressed: () => store.setAdminMode(false),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 1: OVERVIEW & ANALYTICS
  Widget _buildOverviewTab(StoreProvider store, bool isDark) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 Metric KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final cardWidth = isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _metricCard(
                    title: 'Total Revenue',
                    value: currency.format(store.totalRevenue),
                    change: '+24.8% vs last month',
                    icon: Icons.payments_outlined,
                    color: CyberColors.emeraldGreen,
                    width: cardWidth,
                    isDark: isDark,
                  ),
                  _metricCard(
                    title: 'Total Orders',
                    value: '${store.totalOrdersCount}',
                    change: '+14 new this week',
                    icon: Icons.shopping_bag_outlined,
                    color: CyberColors.cyanPrimary,
                    width: cardWidth,
                    isDark: isDark,
                  ),
                  _metricCard(
                    title: 'Active Catalog',
                    value: '${store.activeProductsCount} Items',
                    change: '100% catalog healthy',
                    icon: Icons.inventory_2_outlined,
                    color: CyberColors.purpleNeon,
                    width: cardWidth,
                    isDark: isDark,
                  ),
                  _metricCard(
                    title: 'Low Stock Alerts',
                    value: '${store.lowStockCount} Items',
                    change: store.lowStockCount > 0 ? 'Restock recommended' : 'Healthy inventory',
                    icon: Icons.warning_amber_rounded,
                    color: store.lowStockCount > 0 ? CyberColors.amberWarning : CyberColors.emeraldGreen,
                    width: cardWidth,
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Charts Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildRevenueChart(isDark)),
                        const SizedBox(width: 20),
                        Expanded(flex: 5, child: _buildCategoryDistributionChart(store, isDark)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildRevenueChart(isDark),
                        const SizedBox(height: 20),
                        _buildCategoryDistributionChart(store, isDark),
                      ],
                    );
            },
          ),

          const SizedBox(height: 32),

          // Recent Orders Table
          _buildRecentOrdersSection(store, isDark),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
    required double width,
    required bool isDark,
  }) {
    return Container(
      width: width,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            change,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Revenue Velocity',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberColors.cyanPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Daily Growth Trends',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: CyberColors.cyanPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? CyberColors.darkBorder : Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.grey),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}k',
                          style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 12,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3.2),
                      FlSpot(1, 4.8),
                      FlSpot(2, 4.1),
                      FlSpot(3, 7.5),
                      FlSpot(4, 6.8),
                      FlSpot(5, 9.4),
                      FlSpot(6, 11.2),
                    ],
                    isCurved: true,
                    color: CyberColors.cyanPrimary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          CyberColors.cyanPrimary.withOpacity(0.3),
                          CyberColors.cyanPrimary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionChart(StoreProvider store, bool isDark) {
    final catSales = store.categorySalesRevenue;
    final totalSales = catSales.values.fold(0.0, (s, v) => s + v);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales By Category',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (catSales.isEmpty)
            const Center(child: Text('No orders recorded yet'))
          else
            Column(
              children: catSales.entries.map((entry) {
                final percent = totalSales > 0 ? (entry.value / totalSales) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            '\$${entry.value.toStringAsFixed(0)} (${(percent * 100).toStringAsFixed(1)}%)',
                            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: CyberColors.cyanPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: percent,
                        backgroundColor: isDark ? CyberColors.darkSurfaceLight : Colors.grey[200],
                        color: CyberColors.cyanPrimary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection(StoreProvider store, bool isDark) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final orders = store.orders.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Orders Stream',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedNavIndex = 2),
                child: const Text('View All Orders'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final o = orders[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CyberColors.cyanPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_rounded, size: 20, color: CyberColors.cyanPrimary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.customerName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${o.id} • ${DateFormat.MMMd().format(o.createdAt)}',
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${o.items.length} item(s)',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      currency.format(o.total),
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  CyberBadge.orderStatus(o.status),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // TAB 2: PRODUCTS CRUD
  Widget _buildProductsTab(StoreProvider store, bool isDark) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final products = store.allProducts.where((p) {
      if (_productSearchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_productSearchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_productSearchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_productSearchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Bar: Search & "Add Product" button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    onChanged: (val) => setState(() => _productSearchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search products by name, brand, category...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      suffixIcon: _productSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() => _productSearchQuery = ''),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showProductDialog(context, store, null, isDark),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add New Product'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Products List Table
          Container(
            decoration: BoxDecoration(
              color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = products[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          p.imageUrls.first,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[800],
                            child: const Icon(Icons.devices, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name & Category
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${p.brand} • ${p.category}',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Expanded(
                        flex: 2,
                        child: Text(
                          currency.format(p.price),
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: CyberColors.cyanPrimary,
                          ),
                        ),
                      ),

                      // Stock Status
                      Expanded(
                        flex: 2,
                        child: CyberBadge.stockStatus(p.stockQuantity),
                      ),

                      // Actions: Edit, Restock, Delete
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit Product',
                            onPressed: () => _showProductDialog(context, store, p, isDark),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_box_outlined, size: 18, color: CyberColors.emeraldGreen),
                            tooltip: 'Quick Restock (+10)',
                            onPressed: () {
                              store.restockProduct(p.id, 10);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Restocked 10 units for ${p.name}')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: CyberColors.roseDanger),
                            tooltip: 'Delete Product',
                            onPressed: () => _confirmDeleteProduct(context, store, p),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: ORDERS MANAGEMENT
  Widget _buildOrdersTab(StoreProvider store, bool isDark) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final orders = store.orders.where((o) {
      if (_selectedOrderStatusFilter != null && o.status != _selectedOrderStatusFilter) {
        return false;
      }
      if (_orderSearchQuery.isEmpty) return true;
      return o.id.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
          o.customerName.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
          o.trackingNumber.toLowerCase().contains(_orderSearchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Filters & Search
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    onChanged: (val) => setState(() => _orderSearchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Search orders by ID, customer name, tracking #...',
                      prefixIcon: Icon(Icons.search_rounded, size: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Status filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<OrderStatus?>(
                    value: _selectedOrderStatusFilter,
                    hint: const Text('All Statuses'),
                    items: [
                      const DropdownMenuItem<OrderStatus?>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...OrderStatus.values.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
                      ),
                    ],
                    onChanged: (s) => setState(() => _selectedOrderStatusFilter = s),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Orders List
          Container(
            decoration: BoxDecoration(
              color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final o = orders[index];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Order Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: CyberColors.cyanPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_shipping_outlined, color: CyberColors.cyanPrimary, size: 20),
                      ),
                      const SizedBox(width: 14),

                      // Customer & ID
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.customerName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('ID: ${o.id} • ${DateFormat.yMMMd().format(o.createdAt)}',
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),

                      // Total Price
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currency.format(o.total),
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text('${o.items.length} items', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),

                      // Status Change Dropdown
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<OrderStatus>(
                              value: o.status,
                              isDense: true,
                              items: OrderStatus.values
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.displayName, style: GoogleFonts.spaceGrotesk(fontSize: 12)),
                                      ))
                                  .toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null) {
                                  store.updateOrderStatus(o.id, newStatus);
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Open Live Tracking View
                      IconButton(
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        tooltip: 'View Tracking & Invoice',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(order: o),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // TAB 4: CRITICAL STOCK & INVENTORY
  Widget _buildInventoryTab(StoreProvider store, bool isDark) {
    final lowStockItems = store.lowStockProducts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CyberColors.amberWarning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CyberColors.amberWarning.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 28, color: CyberColors.amberWarning),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Alert System',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CyberColors.amberWarning,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Products with 5 or fewer items remaining are flagged below for fast restock.',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (lowStockItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 48, color: CyberColors.emeraldGreen),
                    const SizedBox(height: 12),
                    Text('All Products Well Stocked!', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('No inventory shortages detected across the catalog.', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ...lowStockItems.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CyberColors.amberWarning.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(p.imageUrls.first, width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Current Stock: ${p.stockQuantity} units remaining',
                                style: GoogleFonts.inter(fontSize: 12, color: CyberColors.amberWarning)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: CyberColors.amberWarning),
                        onPressed: () {
                          store.restockProduct(p.id, 25);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Restocked 25 units for ${p.name}!')),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.black, size: 16),
                        label: const Text('Restock +25 Units', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // Dialog: Add / Edit Product
  void _showProductDialog(BuildContext context, StoreProvider store, Product? existingProduct, bool isDark) {
    final isEdit = existingProduct != null;
    final nameCtrl = TextEditingController(text: existingProduct?.name ?? '');
    final brandCtrl = TextEditingController(text: existingProduct?.brand ?? 'CyberTech');
    final descCtrl = TextEditingController(text: existingProduct?.description ?? '');
    final priceCtrl = TextEditingController(text: existingProduct?.price.toString() ?? '499.00');
    final origPriceCtrl = TextEditingController(text: existingProduct?.originalPrice.toString() ?? '599.00');
    final stockCtrl = TextEditingController(text: existingProduct?.stockQuantity.toString() ?? '20');
    final imageCtrl = TextEditingController(
        text: existingProduct != null && existingProduct.imageUrls.isNotEmpty
            ? existingProduct.imageUrls.first
            : 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800');
    String category = existingProduct?.category ?? 'Laptops';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Product' : 'Add New Tech Product',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: 'Brand'))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: MockData.categories
                              .where((c) => c != 'All')
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => setDialogState(() => category = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (\$)'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: origPriceCtrl, decoration: const InputDecoration(labelText: 'Original Price (\$)'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock Qty'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Image URL')),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(priceCtrl.text) ?? 199.0;
                final origPrice = double.tryParse(origPriceCtrl.text) ?? price;
                final stock = int.tryParse(stockCtrl.text) ?? 10;

                if (isEdit) {
                  final updated = existingProduct.copyWith(
                    name: nameCtrl.text.trim(),
                    brand: brandCtrl.text.trim(),
                    category: category,
                    price: price,
                    originalPrice: origPrice,
                    stockQuantity: stock,
                    description: descCtrl.text.trim(),
                    imageUrls: [imageCtrl.text.trim()],
                  );
                  store.updateProduct(updated);
                } else {
                  final newProd = Product(
                    id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    brand: brandCtrl.text.trim(),
                    category: category,
                    description: descCtrl.text.trim(),
                    price: price,
                    originalPrice: origPrice,
                    stockQuantity: stock,
                    imageUrls: [imageCtrl.text.trim()],
                    isFeatured: true,
                    isTrending: true,
                  );
                  store.addProduct(newProd);
                }
                Navigator.of(ctx).pop();
              },
              child: Text(isEdit ? 'Save Changes' : 'Create Product'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, StoreProvider store, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CyberColors.roseDanger),
            onPressed: () {
              store.deleteProduct(product.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
