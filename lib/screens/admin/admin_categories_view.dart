// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/category_item.dart';
import '../../providers/store_provider.dart';
import '../../theme/cyber_colors.dart';
import '../../utils/currency_helper.dart';

class AdminCategoriesView extends StatefulWidget {
  const AdminCategoriesView({super.key});

  @override
  State<AdminCategoriesView> createState() => _AdminCategoriesViewState();
}

class _AdminCategoriesViewState extends State<AdminCategoriesView> {
  String _viewMode = 'grid'; // 'grid' or 'table'
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'active', 'inactive'
  String _sortBy = 'items_desc'; // 'items_desc', 'name_asc', 'stock_desc', 'valuation_desc', 'revenue_desc'
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

    // Filter categories
    List<CategoryItem> categories = store.allCategories.where((cat) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = cat.name.toLowerCase().contains(q) ||
            cat.slug.toLowerCase().contains(q) ||
            cat.description.toLowerCase().contains(q);
        if (!matches) return false;
      }

      if (_statusFilter == 'active' && !cat.isActive) return false;
      if (_statusFilter == 'inactive' && cat.isActive) return false;

      return true;
    }).toList();

    // Sort categories
    categories.sort((a, b) {
      switch (_sortBy) {
        case 'name_asc':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case 'stock_desc':
          return store.getStockUnitsForCategory(b.name).compareTo(store.getStockUnitsForCategory(a.name));
        case 'valuation_desc':
          return store.getValuationForCategory(b.name).compareTo(store.getValuationForCategory(a.name));
        case 'revenue_desc':
          return store.getRevenueForCategory(b.name).compareTo(store.getRevenueForCategory(a.name));
        case 'items_desc':
        default:
          return store.getProductCountForCategory(b.name).compareTo(store.getProductCountForCategory(a.name));
      }
    });

    final totalActive = store.allCategories.where((c) => c.isActive).length;
    final totalUnits = store.allCategories.fold<int>(0, (sum, c) => sum + store.getStockUnitsForCategory(c.name));
    final totalValuation = store.allCategories.fold<double>(0.0, (sum, c) => sum + store.getValuationForCategory(c.name));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _buildHeaderRow(context, store, isDark),
          const SizedBox(height: 24),

          // KPI Summary Cards
          _buildKpiMetrics(store, isDark, totalActive, totalUnits, totalValuation),
          const SizedBox(height: 24),

          // Search, Filter & View Controls
          _buildFilterBar(store, isDark),
          const SizedBox(height: 20),

          // Categories View (Grid or Table)
          if (categories.isEmpty)
            _buildEmptyState(isDark)
          else if (_viewMode == 'grid')
            _buildCategoriesGrid(categories, store, isDark)
          else
            _buildCategoriesTable(categories, store, isDark),

          const SizedBox(height: 32),

          // Category Share Breakdown Section
          _buildValuationShareSection(store, isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, StoreProvider store, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [CyberColors.emeraldGreen, CyberColors.cyanPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.category_rounded, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  'CATEGORY MANAGEMENT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Create, customize, reorganize and analyze product departments with real-time inventory metrics',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showCategoryDialog(context, store),
          icon: const Icon(Icons.add_rounded, size: 18, color: Colors.black),
          label: Text(
            'NEW CATEGORY',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: CyberColors.cyanPrimary,
            elevation: 8,
            shadowColor: CyberColors.cyanPrimary.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiMetrics(
    StoreProvider store,
    bool isDark,
    int totalActive,
    int totalUnits,
    double totalValuation,
  ) {
    final cardBg = isDark ? CyberColors.darkSurface : CyberColors.lightSurface;
    final borderColor = isDark ? CyberColors.darkBorder : CyberColors.lightBorder;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final count = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 2.3 : 1.9,
          children: [
            _buildKpiCard(
              title: 'TOTAL CATEGORIES',
              value: '${store.allCategories.length}',
              subtitle: '$totalActive Active Departments',
              icon: Icons.folder_special_rounded,
              gradient: CyberColors.primaryGradient,
              bg: cardBg,
              border: borderColor,
              isDark: isDark,
            ),
            _buildKpiCard(
              title: 'CATALOG PRODUCTS',
              value: '${store.products.length}',
              subtitle: 'Across all active categories',
              icon: Icons.inventory_2_rounded,
              gradient: CyberColors.neonPurpleGradient,
              bg: cardBg,
              border: borderColor,
              isDark: isDark,
            ),
            _buildKpiCard(
              title: 'TOTAL STOCK UNITS',
              value: '$totalUnits',
              subtitle: 'Stocked across departments',
              icon: Icons.warehouse_rounded,
              gradient: const LinearGradient(
                colors: [CyberColors.amberWarning, Colors.deepOrange],
              ),
              bg: cardBg,
              border: borderColor,
              isDark: isDark,
            ),
            _buildKpiCard(
              title: 'INVENTORY VALUATION',
              value: CurrencyHelper.format(totalValuation),
              subtitle: 'Asset base across categories',
              icon: Icons.monetization_on_rounded,
              gradient: const LinearGradient(
                colors: [CyberColors.emeraldGreen, CyberColors.cyanPrimary],
              ),
              bg: cardBg,
              border: borderColor,
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required Color bg,
    required Color border,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(StoreProvider store, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Input
          SizedBox(
            width: 280,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.spaceGrotesk(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search categories or slugs...',
                hintStyle: GoogleFonts.spaceGrotesk(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? CyberColors.darkBg : CyberColors.lightBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filters and sorting
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Status filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkBg : CyberColors.lightBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    dropdownColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active Only')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive Only')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _statusFilter = val);
                    },
                  ),
                ),
              ),

              // Sort dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkBg : CyberColors.lightBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                    items: const [
                      DropdownMenuItem(value: 'items_desc', child: Text('Sort: Most Products')),
                      DropdownMenuItem(value: 'name_asc', child: Text('Sort: Name (A-Z)')),
                      DropdownMenuItem(value: 'stock_desc', child: Text('Sort: Units Stocked')),
                      DropdownMenuItem(value: 'valuation_desc', child: Text('Sort: Valuation')),
                      DropdownMenuItem(value: 'revenue_desc', child: Text('Sort: Sales Revenue')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortBy = val);
                    },
                  ),
                ),
              ),

              // Grid / Table View switch
              Container(
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkBg : CyberColors.lightBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        size: 18,
                        color: _viewMode == 'grid' ? CyberColors.cyanPrimary : Colors.grey,
                      ),
                      onPressed: () => setState(() => _viewMode = 'grid'),
                      tooltip: 'Grid Matrix View',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.view_headline_rounded,
                        size: 20,
                        color: _viewMode == 'table' ? CyberColors.cyanPrimary : Colors.grey,
                      ),
                      onPressed: () => setState(() => _viewMode = 'table'),
                      tooltip: 'Table List View',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_off_rounded, size: 54, color: Colors.grey[500]),
          const SizedBox(height: 16),
          Text(
            'No Categories Match Your Criteria',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or status filter.',
            style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List<CategoryItem> categories, StoreProvider store, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 700) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1100) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: 310,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category, store, isDark);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(CategoryItem category, StoreProvider store, bool isDark) {
    final productCount = store.getProductCountForCategory(category.name);
    final stockUnits = store.getStockUnitsForCategory(category.name);
    final valuation = store.getValuationForCategory(category.name);
    final revenue = store.getRevenueForCategory(category.name);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.isActive
              ? (isDark ? CyberColors.darkBorder : CyberColors.lightBorder)
              : Colors.grey.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Gradient Accent
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.colors.first.withOpacity(0.25),
                  category.colors.last.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: category.colors),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: category.colors.first.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(category.iconData, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (category.featured) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: CyberColors.amberWarning.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'FEATURED',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: CyberColors.amberWarning,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '/${category.slug}',
                        style: GoogleFonts.firaCode(
                          fontSize: 11,
                          color: CyberColors.cyanPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Active Switch
                Switch(
                  value: category.isActive,
                  activeColor: CyberColors.emeraldGreen,
                  onChanged: (_) => store.toggleCategoryActive(category.id),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              category.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.3,
              ),
            ),
          ),

          const Spacer(),

          // Metrics Grid inside card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? CyberColors.darkBg.withOpacity(0.6) : CyberColors.lightBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? CyberColors.darkBorder.withOpacity(0.5) : CyberColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCardStatItem('Products', '$productCount', isDark),
                _buildCardDivider(isDark),
                _buildCardStatItem('Units', '$stockUnits', isDark),
                _buildCardDivider(isDark),
                _buildCardStatItem('Valuation', CurrencyHelper.format(valuation), isDark),
                _buildCardDivider(isDark),
                _buildCardStatItem('Sales', CurrencyHelper.format(revenue), isDark),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCategoryDialog(context, store, categoryToEdit: category),
                    icon: const Icon(Icons.edit_rounded, size: 14),
                    label: Text(
                      'EDIT',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      side: BorderSide(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: CyberColors.roseDanger, size: 18),
                  tooltip: 'Delete Department',
                  style: IconButton.styleFrom(
                    backgroundColor: CyberColors.roseDanger.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showDeleteCategoryDialog(context, store, category),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
    );
  }

  Widget _buildCardStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTable(List<CategoryItem> categories, StoreProvider store, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 28,
            headingRowColor: WidgetStateProperty.all(
              isDark ? CyberColors.darkBg : CyberColors.lightBg,
            ),
            columns: [
              DataColumn(label: _buildTableHeading('DEPARTMENT', isDark)),
              DataColumn(label: _buildTableHeading('SLUG', isDark)),
              DataColumn(label: _buildTableHeading('PRODUCTS', isDark)),
              DataColumn(label: _buildTableHeading('STOCK UNITS', isDark)),
              DataColumn(label: _buildTableHeading('VALUATION', isDark)),
              DataColumn(label: _buildTableHeading('SALES REVENUE', isDark)),
              DataColumn(label: _buildTableHeading('STATUS', isDark)),
              DataColumn(label: _buildTableHeading('ACTIONS', isDark)),
            ],
            rows: categories.map((cat) {
              final productCount = store.getProductCountForCategory(cat.name);
              final stockUnits = store.getStockUnitsForCategory(cat.name);
              final valuation = store.getValuationForCategory(cat.name);
              final revenue = store.getRevenueForCategory(cat.name);

              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: cat.colors),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(cat.iconData, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cat.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              cat.description,
                              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      '/${cat.slug}',
                      style: GoogleFonts.firaCode(fontSize: 12, color: CyberColors.cyanPrimary),
                    ),
                  ),
                  DataCell(
                    Text(
                      '$productCount items',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '$stockUnits',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      CurrencyHelper.format(valuation),
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        color: CyberColors.emeraldGreen,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      CurrencyHelper.format(revenue),
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        color: CyberColors.purpleNeon,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: cat.isActive,
                          activeColor: CyberColors.emeraldGreen,
                          onChanged: (_) => store.toggleCategoryActive(cat.id),
                        ),
                        Text(
                          cat.isActive ? 'Active' : 'Hidden',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: cat.isActive ? CyberColors.emeraldGreen : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          tooltip: 'Edit Category',
                          onPressed: () => _showCategoryDialog(context, store, categoryToEdit: cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: CyberColors.roseDanger, size: 18),
                          tooltip: 'Delete Category',
                          onPressed: () => _showDeleteCategoryDialog(context, store, cat),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeading(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: isDark ? Colors.grey[400] : Colors.grey[700],
      ),
    );
  }

  Widget _buildValuationShareSection(StoreProvider store, bool isDark) {
    final totalValuation = store.allCategories.fold<double>(0.0, (sum, c) => sum + store.getValuationForCategory(c.name));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.donut_large_rounded, color: CyberColors.cyanPrimary, size: 20),
              const SizedBox(width: 10),
              Text(
                'DEPARTMENT VALUATION & INVENTORY SHARE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...store.allCategories.map((cat) {
            final valuation = store.getValuationForCategory(cat.name);
            final percent = totalValuation > 0 ? (valuation / totalValuation).clamp(0.0, 1.0) : 0.0;
            final productCount = store.getProductCountForCategory(cat.name);
            final stockUnits = store.getStockUnitsForCategory(cat.name);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(cat.iconData, size: 14, color: cat.colors.first),
                          const SizedBox(width: 8),
                          Text(
                            cat.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($productCount products, $stockUnits units)',
                            style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        '${CurrencyHelper.format(valuation)} (${(percent * 100).toStringAsFixed(1)}%)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: isDark ? CyberColors.darkBg : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(cat.colors.first),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // CREATE OR EDIT CATEGORY DIALOG
  void _showCategoryDialog(BuildContext context, StoreProvider store, {CategoryItem? categoryToEdit}) {
    final isDark = store.isDarkMode;
    final isEditing = categoryToEdit != null;

    final nameController = TextEditingController(text: categoryToEdit?.name ?? '');
    final slugController = TextEditingController(text: categoryToEdit?.slug ?? '');
    final descController = TextEditingController(text: categoryToEdit?.description ?? '');

    // Available cyber icons
    final availableIcons = [
      {'icon': Icons.memory_rounded, 'name': 'Hardware'},
      {'icon': Icons.laptop_chromebook_rounded, 'name': 'Laptops'},
      {'icon': Icons.headset_rounded, 'name': 'Audio'},
      {'icon': Icons.keyboard_rounded, 'name': 'Keyboards'},
      {'icon': Icons.smart_toy_rounded, 'name': 'Cyberware'},
      {'icon': Icons.bolt_rounded, 'name': 'Power'},
      {'icon': Icons.videogame_asset_rounded, 'name': 'Gaming'},
      {'icon': Icons.security_rounded, 'name': 'Security'},
      {'icon': Icons.all_inclusive_rounded, 'name': 'Quantum'},
      {'icon': Icons.devices_other_rounded, 'name': 'Devices'},
      {'icon': Icons.remove_red_eye_rounded, 'name': 'Optics'},
      {'icon': Icons.sports_esports_rounded, 'name': 'VR Gear'},
    ];

    // Available vibrant cyberpunk gradients
    final availableGradients = [
      {'name': 'Cyan Glow', 'colors': [0xFF00F2FE, 0xFF4FACFE]},
      {'name': 'Neon Purple', 'colors': [0xFF8B5CF6, 0xFFFF2E93]},
      {'name': 'Emerald Cyber', 'colors': [0xFF10B981, 0xFF00F2FE]},
      {'name': 'Solar Amber', 'colors': [0xFFF59E0B, 0xFFEA580C]},
      {'name': 'Pink Electric', 'colors': [0xFFFF2E93, 0xFF8B5CF6]},
      {'name': 'Hyper Crimson', 'colors': [0xFFEF4444, 0xFFF59E0B]},
    ];

    int selectedIconCodePoint = categoryToEdit?.iconCodePoint ?? Icons.category_rounded.codePoint;
    List<int> selectedGradientColors = categoryToEdit?.gradientColors ?? [0xFF00F2FE, 0xFF4FACFE];
    bool isActive = categoryToEdit?.isActive ?? true;
    bool isFeatured = categoryToEdit?.featured ?? false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
              ),
              child: Container(
                width: 650,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: selectedGradientColors.map((c) => Color(c)).toList(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            CategoryItem.resolveIcon(selectedIconCodePoint),
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'EDIT DEPARTMENT' : 'CREATE NEW CATEGORY',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Configure department identity, icons, visuals and routing',
                                style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Scrollable Form Body
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name & Slug
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildDialogTextField(
                                    controller: nameController,
                                    label: 'Category Name',
                                    hint: 'e.g. Quantum Drives',
                                    isDark: isDark,
                                    onChanged: (val) {
                                      if (!isEditing || slugController.text.isEmpty) {
                                        setDialogState(() {
                                          slugController.text = val
                                              .toLowerCase()
                                              .replaceAll(RegExp(r'[^a-z0-9]'), '-')
                                              .replaceAll(RegExp(r'-+'), '-')
                                              .replaceAll(RegExp(r'^-|-$'), '');
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 2,
                                  child: _buildDialogTextField(
                                    controller: slugController,
                                    label: 'Routing Slug',
                                    hint: 'quantum-drives',
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Description
                            _buildDialogTextField(
                              controller: descController,
                              label: 'Description',
                              hint: 'Describe catalog products and technological focus...',
                              maxLines: 2,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20),

                            // Icon Selection
                            Text(
                              'SELECT DEPARTMENT ICON',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: availableIcons.map((item) {
                                final iconData = item['icon'] as IconData;
                                final isSelected = selectedIconCodePoint == iconData.codePoint;

                                return InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedIconCodePoint = iconData.codePoint;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? CyberColors.cyanPrimary.withOpacity(0.2)
                                          : (isDark ? CyberColors.darkBg : CyberColors.lightBg),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? CyberColors.cyanPrimary
                                            : (isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          iconData,
                                          size: 16,
                                          color: isSelected ? CyberColors.cyanPrimary : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item['name'] as String,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? CyberColors.cyanPrimary : (isDark ? Colors.white70 : Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Color Theme Gradient Selection
                            Text(
                              'SELECT NEON COLOR ACCENT',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: availableGradients.map((grad) {
                                final colors = grad['colors'] as List<int>;
                                final isSelected = selectedGradientColors.first == colors.first;

                                return InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedGradientColors = colors;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark ? CyberColors.darkBg : CyberColors.lightBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: colors.map((c) => Color(c)).toList(),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          grad['name'] as String,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Featured Toggle
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? CyberColors.darkBg : CyberColors.lightBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Featured Department',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Pin as spotlight department on top storefront bars',
                                          style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Switch(
                                    value: isFeatured,
                                    activeColor: CyberColors.amberWarning,
                                    onChanged: (val) {
                                      setDialogState(() => isFeatured = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Active Toggle
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? CyberColors.darkBg : CyberColors.lightBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Department Visibility',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Visible to customers on storefront and filter bars',
                                          style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Switch(
                                    value: isActive,
                                    activeColor: CyberColors.emeraldGreen,
                                    onChanged: (val) {
                                      setDialogState(() => isActive = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 32),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.spaceGrotesk(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a category name')),
                              );
                              return;
                            }

                            final slug = slugController.text.trim().isEmpty
                                ? name.toLowerCase().replaceAll(' ', '-')
                                : slugController.text.trim();

                            if (isEditing) {
                              final updated = categoryToEdit.copyWith(
                                name: name,
                                slug: slug,
                                description: descController.text.trim(),
                                iconCodePoint: selectedIconCodePoint,
                                gradientColors: selectedGradientColors,
                                featured: isFeatured,
                                isActive: isActive,
                              );
                              await store.updateCategory(updated);
                            } else {
                              final newCategory = CategoryItem(
                                id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                slug: slug,
                                description: descController.text.trim(),
                                iconCodePoint: selectedIconCodePoint,
                                gradientColors: selectedGradientColors,
                                featured: isFeatured,
                                isActive: isActive,
                                createdAt: DateTime.now(),
                              );
                              await store.addCategory(newCategory);
                            }

                            if (!context.mounted) return;
                            Navigator.of(dialogCtx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Category "$name" updated successfully'
                                      : 'New category "$name" created',
                                ),
                                backgroundColor: CyberColors.emeraldGreen,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CyberColors.cyanPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            isEditing ? 'SAVE CHANGES' : 'CREATE CATEGORY',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: GoogleFonts.spaceGrotesk(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.grey),
            filled: true,
            fillColor: isDark ? CyberColors.darkBg : CyberColors.lightBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CyberColors.cyanPrimary),
            ),
          ),
        ),
      ],
    );
  }

  // DELETE CATEGORY WITH REASSIGNMENT
  void _showDeleteCategoryDialog(BuildContext context, StoreProvider store, CategoryItem category) {
    final isDark = store.isDarkMode;
    final matchingProducts = store.products
        .where((p) => p.category.toLowerCase() == category.name.toLowerCase())
        .toList();

    final remainingCategories = store.allCategories
        .where((c) => c.id != category.id)
        .map((c) => c.name)
        .toList();

    String? selectedReassignCategory = remainingCategories.isNotEmpty ? remainingCategories.first : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: CyberColors.roseDanger, width: 1.5),
              ),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: CyberColors.roseDanger, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Delete "${category.name}"?',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to delete this department?',
                    style: GoogleFonts.spaceGrotesk(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  if (matchingProducts.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CyberColors.roseDanger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CyberColors.roseDanger.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ ${matchingProducts.length} Products Currently Linked',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: CyberColors.roseDanger,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please select a destination department to safely reassign all existing inventory:',
                            style: GoogleFonts.spaceGrotesk(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          if (remainingCategories.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? CyberColors.darkBg : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedReassignCategory,
                                  isExpanded: true,
                                  dropdownColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: remainingCategories.map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setDialogState(() => selectedReassignCategory = val);
                                  },
                                ),
                              ),
                            )
                          else
                            Text(
                              'Cannot delete the only existing category.',
                              style: GoogleFonts.spaceGrotesk(fontSize: 12, color: CyberColors.roseDanger),
                            ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'No products are mapped to this category. It can be safely removed immediately.',
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, color: CyberColors.emeraldGreen),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.spaceGrotesk(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: (matchingProducts.isNotEmpty && selectedReassignCategory == null)
                      ? null
                      : () async {
                          final success = await store.deleteCategory(
                            category.id,
                            reassignToCategory: selectedReassignCategory,
                          );

                          if (!context.mounted) return;
                          Navigator.of(dialogCtx).pop();

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Department "${category.name}" removed successfully'),
                                backgroundColor: CyberColors.emeraldGreen,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to delete department'),
                                backgroundColor: CyberColors.roseDanger,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberColors.roseDanger,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'CONFIRM DELETE',
                    style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
