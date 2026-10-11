import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../providers/store_provider.dart';
import '../../theme/cyber_colors.dart';
import '../../widgets/cyber_badge.dart';
import '../../utils/currency_helper.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;
    
    // Find live order from provider in case status was updated
    final liveOrder = store.orders.firstWhere(
      (o) => o.id == order.id,
      orElse: () => order,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status #${liveOrder.id}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CyberBadge.orderStatus(liveOrder.status),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: CyberColors.darkCardGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CyberColors.cyanPrimary.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CyberColors.cyanPrimary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CyberColors.cyanPrimary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          size: 36,
                          color: CyberColors.cyanPrimary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Delivery',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: CyberColors.darkTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d, y').format(liveOrder.estimatedDelivery),
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Tracking: ${liveOrder.trackingNumber}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: CyberColors.cyanPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: liveOrder.trackingNumber));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Tracking number copied!')),
                                    );
                                  },
                                  child: const Icon(Icons.copy_rounded, size: 14, color: CyberColors.cyanPrimary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Tracking Stepper
                Text(
                  'Shipment Timeline',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      _timelineStep(
                        title: 'Order Placed & Confirmed',
                        subtitle: DateFormat.yMMMd().add_jm().format(liveOrder.createdAt),
                        icon: Icons.check_circle_rounded,
                        isCompleted: true,
                        isDark: isDark,
                      ),
                      _timelineLine(isCompleted: _isStepDone(liveOrder.status, 1)),
                      _timelineStep(
                        title: 'Payment Escrow Verified',
                        subtitle: 'Authorized via ${liveOrder.paymentMethod}',
                        icon: Icons.verified_user_rounded,
                        isCompleted: _isStepDone(liveOrder.status, 1),
                        isDark: isDark,
                      ),
                      _timelineLine(isCompleted: _isStepDone(liveOrder.status, 2)),
                      _timelineStep(
                        title: 'Quality Check & Packaging',
                        subtitle: 'Sealed inside anti-shock cyber transport capsule',
                        icon: Icons.inventory_2_rounded,
                        isCompleted: _isStepDone(liveOrder.status, 2),
                        isDark: isDark,
                      ),
                      _timelineLine(isCompleted: _isStepDone(liveOrder.status, 3)),
                      _timelineStep(
                        title: 'Dispatched via Express Courier',
                        subtitle: 'Carrier: Delhivery Surface Express / Blue Dart Air',
                        icon: Icons.flight_takeoff_rounded,
                        isCompleted: _isStepDone(liveOrder.status, 3),
                        isDark: isDark,
                      ),
                      _timelineLine(isCompleted: _isStepDone(liveOrder.status, 4)),
                      _timelineStep(
                        title: 'Delivered',
                        subtitle: liveOrder.status == OrderStatus.delivered
                            ? 'Delivered to recipient at destination'
                            : 'Expected by ${DateFormat.MMMd().format(liveOrder.estimatedDelivery)}',
                        icon: Icons.home_rounded,
                        isCompleted: liveOrder.status == OrderStatus.delivered,
                        isDark: isDark,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Order Items & Financial Details
                Text(
                  'Order Receipt Details',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                      // Items List
                      ...liveOrder.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product.imageUrls.first,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (item.selectedColor != null)
                                        Text(
                                          'Color: ${item.selectedColor}',
                                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${item.quantity} x ${CurrencyHelper.format(item.product.price)}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )),

                      const Divider(height: 32),

                      // Delivery Address
                      Text(
                        'Destination Address',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: CyberColors.cyanPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${liveOrder.customerName}\n${liveOrder.shippingAddress}\n${liveOrder.customerPhone} • ${liveOrder.customerEmail}',
                        style: GoogleFonts.inter(fontSize: 12, height: 1.5),
                      ),

                      const Divider(height: 32),

                      // Financial summary
                      _row('Subtotal', CurrencyHelper.format(liveOrder.subtotal), isDark),
                      if (liveOrder.discount > 0)
                        _row('Discount Applied', '-${CurrencyHelper.format(liveOrder.discount)}', isDark,
                            color: CyberColors.emeraldGreen),
                      _row('Shipping Fee', liveOrder.shippingFee == 0 ? 'FREE' : CurrencyHelper.format(liveOrder.shippingFee), isDark),
                      _row('GST (18% CGST + SGST)', CurrencyHelper.format(liveOrder.tax), isDark),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total Paid',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            CurrencyHelper.format(liveOrder.total),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: CyberColors.cyanPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isStepDone(OrderStatus status, int stepLevel) {
    if (status == OrderStatus.cancelled) return false;
    switch (stepLevel) {
      case 1: // Payment verified
        return true;
      case 2: // Quality check & pack
        return status == OrderStatus.processing ||
            status == OrderStatus.shipped ||
            status == OrderStatus.delivered;
      case 3: // Shipped
        return status == OrderStatus.shipped || status == OrderStatus.delivered;
      case 4: // Delivered
        return status == OrderStatus.delivered;
      default:
        return false;
    }
  }

  Widget _timelineStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required bool isDark,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted ? CyberColors.cyanPrimary : (isDark ? CyberColors.darkSurfaceLight : Colors.grey[200]),
            shape: BoxShape.circle,
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: CyberColors.cyanPrimary.withOpacity(0.3),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isCompleted ? Colors.black : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timelineLine({required bool isCompleted}) {
    return Container(
      margin: const EdgeInsets.only(left: 17, top: 4, bottom: 4),
      alignment: Alignment.centerLeft,
      width: 2,
      height: 30,
      color: isCompleted ? CyberColors.cyanPrimary : Colors.grey.withOpacity(0.3),
    );
  }

  Widget _row(String label, String value, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: isDark ? CyberColors.darkTextSecondary : Colors.grey)),
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
