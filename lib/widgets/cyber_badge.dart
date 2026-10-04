import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyber_colors.dart';
import '../models/order.dart';

class CyberBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const CyberBadge({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget orderStatus(OrderStatus status) {
    Color bg;
    Color text;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        bg = CyberColors.amberWarning.withOpacity(0.15);
        text = CyberColors.amberWarning;
        icon = Icons.access_time_rounded;
        break;
      case OrderStatus.processing:
        bg = CyberColors.skyInfo.withOpacity(0.15);
        text = CyberColors.skyInfo;
        icon = Icons.sync_rounded;
        break;
      case OrderStatus.shipped:
        bg = CyberColors.purpleNeon.withOpacity(0.15);
        text = CyberColors.purpleNeon;
        icon = Icons.local_shipping_rounded;
        break;
      case OrderStatus.delivered:
        bg = CyberColors.emeraldGreen.withOpacity(0.15);
        text = CyberColors.emeraldGreen;
        icon = Icons.check_circle_rounded;
        break;
      case OrderStatus.cancelled:
        bg = CyberColors.roseDanger.withOpacity(0.15);
        text = CyberColors.roseDanger;
        icon = Icons.cancel_rounded;
        break;
    }

    return CyberBadge(
      label: status.displayName,
      textColor: text,
      backgroundColor: bg,
      icon: icon,
    );
  }

  static Widget stockStatus(int stockQuantity) {
    if (stockQuantity <= 0) {
      return CyberBadge(
        label: 'Out of Stock',
        textColor: CyberColors.roseDanger,
        backgroundColor: CyberColors.roseDanger.withOpacity(0.15),
        icon: Icons.error_outline_rounded,
      );
    } else if (stockQuantity <= 5) {
      return CyberBadge(
        label: 'Only $stockQuantity left!',
        textColor: CyberColors.amberWarning,
        backgroundColor: CyberColors.amberWarning.withOpacity(0.15),
        icon: Icons.bolt_rounded,
      );
    } else {
      return CyberBadge(
        label: 'In Stock ($stockQuantity)',
        textColor: CyberColors.emeraldGreen,
        backgroundColor: CyberColors.emeraldGreen.withOpacity(0.15),
        icon: Icons.check_rounded,
      );
    }
  }
}
