import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _inrFormatter = NumberFormat.currency(
    symbol: '₹',
    locale: 'en_IN',
    decimalDigits: 0,
  );

  static final NumberFormat _inrWithDecimals = NumberFormat.currency(
    symbol: '₹',
    locale: 'en_IN',
    decimalDigits: 2,
  );

  /// Format a numeric amount into Indian Rupee style, e.g. ₹1,49,999
  static String format(double amount, {bool showDecimals = false}) {
    if (showDecimals && (amount % 1 != 0)) {
      return _inrWithDecimals.format(amount);
    }
    return _inrFormatter.format(amount.roundToDouble());
  }

  /// Compact Indian number format for analytics (e.g. ₹4.8 Lakh, ₹1.2 Cr)
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      return '₹${cr.toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      final lakh = amount / 100000;
      return '₹${lakh.toStringAsFixed(2)} Lakh';
    } else if (amount >= 1000) {
      final k = amount / 1000;
      return '₹${k.toStringAsFixed(1)}k';
    }
    return format(amount);
  }
}

class IndianPincodeInfo {
  final String pincode;
  final String city;
  final String state;
  final String courier;
  final int deliveryDays;
  final bool codAvailable;

  const IndianPincodeInfo({
    required this.pincode,
    required this.city,
    required this.state,
    required this.courier,
    required this.deliveryDays,
    required this.codAvailable,
  });
}

class IndianLocationService {
  static const Map<String, IndianPincodeInfo> knownPincodes = {
    '560001': IndianPincodeInfo(
      pincode: '560001',
      city: 'Bengaluru (MG Road/CBD)',
      state: 'Karnataka',
      courier: 'Delhivery HyperLocal',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '560034': IndianPincodeInfo(
      pincode: '560034',
      city: 'Bengaluru (Koramangala)',
      state: 'Karnataka',
      courier: 'Delhivery HyperLocal',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '560100': IndianPincodeInfo(
      pincode: '560100',
      city: 'Bengaluru (Electronic City)',
      state: 'Karnataka',
      courier: 'Delhivery HyperLocal',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '400001': IndianPincodeInfo(
      pincode: '400001',
      city: 'Mumbai (Fort/Colaba)',
      state: 'Maharashtra',
      courier: 'Blue Dart Apex Express',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '400050': IndianPincodeInfo(
      pincode: '400050',
      city: 'Mumbai (Bandra West)',
      state: 'Maharashtra',
      courier: 'Blue Dart Apex Express',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '110001': IndianPincodeInfo(
      pincode: '110001',
      city: 'New Delhi (Connaught Place)',
      state: 'Delhi NCR',
      courier: 'Delhivery Express Air',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '122001': IndianPincodeInfo(
      pincode: '122001',
      city: 'Gurugram (Cyber City)',
      state: 'Haryana',
      courier: 'Delhivery Express Air',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '201301': IndianPincodeInfo(
      pincode: '201301',
      city: 'Noida (Sector 18)',
      state: 'Uttar Pradesh',
      courier: 'Delhivery Express Air',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '500081': IndianPincodeInfo(
      pincode: '500081',
      city: 'Hyderabad (Hitec City)',
      state: 'Telangana',
      courier: 'Blue Dart Express',
      deliveryDays: 1,
      codAvailable: true,
    ),
    '600002': IndianPincodeInfo(
      pincode: '600002',
      city: 'Chennai (Anna Salai)',
      state: 'Tamil Nadu',
      courier: 'Ekart Logistics Express',
      deliveryDays: 2,
      codAvailable: true,
    ),
    '411001': IndianPincodeInfo(
      pincode: '411001',
      city: 'Pune (Shivajinagar)',
      state: 'Maharashtra',
      courier: 'Blue Dart Express',
      deliveryDays: 2,
      codAvailable: true,
    ),
    '700001': IndianPincodeInfo(
      pincode: '700001',
      city: 'Kolkata (BBD Bagh)',
      state: 'West Bengal',
      courier: 'Delhivery Surface Air',
      deliveryDays: 2,
      codAvailable: true,
    ),
    '380001': IndianPincodeInfo(
      pincode: '380001',
      city: 'Ahmedabad (Navrangpura)',
      state: 'Gujarat',
      courier: 'Blue Dart Express',
      deliveryDays: 2,
      codAvailable: true,
    ),
  };

  static IndianPincodeInfo lookupPincode(String input) {
    final cleaned = input.replaceAll(RegExp(r'\D'), '').trim();
    if (knownPincodes.containsKey(cleaned)) {
      return knownPincodes[cleaned]!;
    }
    if (cleaned.length == 6) {
      String region = 'India';
      final firstDigit = cleaned[0];
      switch (firstDigit) {
        case '1':
          region = 'Delhi / Haryana / Punjab';
          break;
        case '2':
          region = 'Uttar Pradesh / Uttarakhand';
          break;
        case '3':
          region = 'Rajasthan / Gujarat';
          break;
        case '4':
          region = 'Maharashtra / Goa / MP';
          break;
        case '5':
          region = 'Karnataka / AP / Telangana';
          break;
        case '6':
          region = 'Tamil Nadu / Kerala';
          break;
        case '7':
          region = 'West Bengal / Odisha / East';
          break;
        case '8':
          region = 'Bihar / Jharkhand';
          break;
        default:
          region = 'Pan-India Express';
      }
      return IndianPincodeInfo(
        pincode: cleaned,
        city: 'Verified Hub',
        state: region,
        courier: 'Delhivery Pan-India Express',
        deliveryDays: 2,
        codAvailable: true,
      );
    }

    return const IndianPincodeInfo(
      pincode: '560001',
      city: 'Bengaluru Tech Hub',
      state: 'Karnataka',
      courier: 'Delhivery Express',
      deliveryDays: 1,
      codAvailable: true,
    );
  }

  static const List<String> indianStates = [
    'Karnataka',
    'Maharashtra',
    'Delhi NCR',
    'Telangana',
    'Tamil Nadu',
    'Uttar Pradesh',
    'Gujarat',
    'Haryana',
    'West Bengal',
    'Kerala',
    'Rajasthan',
    'Punjab',
    'Madhya Pradesh',
    'Andhra Pradesh',
    'Bihar',
    'Odisha',
    'Goa',
    'Assam',
  ];
}
