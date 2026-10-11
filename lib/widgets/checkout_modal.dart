import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/currency_helper.dart';
import '../providers/store_provider.dart';
import '../theme/cyber_colors.dart';
import '../models/order.dart';
import '../screens/customer/order_tracking_screen.dart';
import 'auth_modal.dart';

class CheckoutModal extends StatefulWidget {
  const CheckoutModal({super.key});

  @override
  State<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal> {
  int _currentStep = 0;

  // Form Fields
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Aarav Sharma');
  final _emailController = TextEditingController(text: 'aarav.sharma@cyberpulse.in');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _addressController = TextEditingController(text: 'Flat 402, Cyber Heights, Indiranagar 100ft Road');
  final _cityController = TextEditingController(text: 'Bengaluru, Karnataka');
  final _zipController = TextEditingController(text: '560038');

  String _selectedPaymentMethod = 'UPI Instant (GPay / PhonePe / Paytm / BHIM)';
  bool _isProcessing = false;
  OrderModel? _placedOrder;

  @override
  void initState() {
    super.initState();
    final store = Provider.of<StoreProvider>(context, listen: false);
    final user = store.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      if (user.street.isNotEmpty) _addressController.text = user.street;
      if (user.city.isNotEmpty) {
        final stateSuffix = user.state.isNotEmpty ? ', ${user.state}' : '';
        _cityController.text = '${user.city}$stateSuffix';
      }
      if (user.pincode.isNotEmpty) _zipController.text = user.pincode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _submitOrder(StoreProvider store) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final fullAddress = '${_addressController.text.trim()}, ${_cityController.text.trim()} ${_zipController.text.trim()}';

    final order = store.placeOrder(
      customerName: _nameController.text.trim(),
      customerEmail: _emailController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      shippingAddress: fullAddress,
      paymentMethod: _selectedPaymentMethod,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _placedOrder = order;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;

    if (_placedOrder != null) {
      return _buildSuccessScreen(_placedOrder!, isDark);
    }

    return Dialog(
      backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Column(
          children: [
            // Modal Top Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? CyberColors.darkBg : CyberColors.lightSurfaceAlt,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                      gradient: CyberColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Cyber Checkout',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Step ${_currentStep + 1} of 3 • 256-bit SSL Encrypted',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Step Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: isDark ? CyberColors.darkSurfaceLight.withOpacity(0.5) : Colors.grey.withOpacity(0.06),
              child: Row(
                children: [
                  _stepIndicator(0, 'Shipping', Icons.local_shipping_outlined),
                  _stepDivider(0),
                  _stepIndicator(1, 'Payment', Icons.credit_card_rounded),
                  _stepDivider(1),
                  _stepIndicator(2, 'Review', Icons.check_circle_outline_rounded),
                ],
              ),
            ),

            // Modal Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _isProcessing
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            const CircularProgressIndicator(color: CyberColors.cyanPrimary),
                            const SizedBox(height: 24),
                            Text(
                              'Authorizing Quantum Payment...',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Validating cryptographic transaction and allocating stock.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      )
                    : _buildStepContent(store, isDark),
              ),
            ),

            // Modal Bottom Action Bar
            if (!_isProcessing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkBg : CyberColors.lightSurfaceAlt,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Back'),
                      )
                    else
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),

                    ElevatedButton(
                      onPressed: () {
                        if (_currentStep == 0) {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() => _currentStep = 1);
                          }
                        } else if (_currentStep == 1) {
                          setState(() => _currentStep = 2);
                        } else {
                          _submitOrder(store);
                        }
                      },
                      child: Text(
                        _currentStep == 2
                            ? 'Authorize & Pay ${CurrencyHelper.format(store.totalAmount)}'
                            : 'Continue to ${_currentStep == 0 ? "Payment" : "Review"}',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stepIndicator(int stepIndex, String title, IconData icon) {
    final isActive = _currentStep >= stepIndex;
    final isCurrent = _currentStep == stepIndex;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? CyberColors.cyanPrimary : Colors.transparent,
            border: Border.all(
              color: isActive ? CyberColors.cyanPrimary : Colors.grey,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent ? CyberColors.cyanPrimary : (isActive ? Colors.white : Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(int stepIndex) {
    final isDone = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 2,
        color: isDone ? CyberColors.cyanPrimary : Colors.grey.withOpacity(0.3),
      ),
    );
  }

  Widget _buildStepContent(StoreProvider store, bool isDark) {
    if (_currentStep == 0) {
      // Step 1: Shipping Info
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping & Contact Details',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Auth State Banner
            if (store.currentUser != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CyberColors.cyanPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberColors.cyanPrimary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: CyberColors.cyanPrimary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Autofilled for ${store.currentUser!.name} (${store.currentUser!.email})',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Checking out as Guest. Have an account?',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () {
                        AuthModal.show(
                          context,
                          onSuccess: () {
                            final user = store.currentUser;
                            if (user != null) {
                              setState(() {
                                _nameController.text = user.name;
                                _emailController.text = user.email;
                                _phoneController.text = user.phone;
                                if (user.street.isNotEmpty) _addressController.text = user.street;
                                if (user.city.isNotEmpty) _cityController.text = user.city;
                                if (user.pincode.isNotEmpty) _zipController.text = user.pincode;
                              });
                            }
                          },
                        );
                      },
                      child: Text(
                        'Sign In',
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

            const SizedBox(height: 4),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => v == null || v.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                    validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Street Address', prefixIcon: Icon(Icons.home_outlined)),
              validator: (v) => v == null || v.isEmpty ? 'Enter street address' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City & State', prefixIcon: Icon(Icons.location_city)),
                    validator: (v) => v == null || v.isEmpty ? 'Enter city' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    decoration: const InputDecoration(labelText: 'PIN Code (6 digits)'),
                    validator: (v) => v == null || v.isEmpty ? 'Enter ZIP' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (_currentStep == 1) {
      // Step 2: Payment
      final methods = [
        {'title': 'UPI Instant (GPay / PhonePe / Paytm / BHIM)', 'desc': 'Instant zero-fee transfer via any UPI ID or scan QR code', 'icon': Icons.qr_code_scanner_rounded},
        {'title': 'Credit / Debit Card (RuPay, Visa, Mastercard)', 'desc': 'Domestic & International cards with OTP secure verification', 'icon': Icons.credit_card_rounded},
        {'title': 'No-Cost EMI / PayLater', 'desc': 'Flexible zero-interest EMI from ₹1,499/mo on major bank credit cards', 'icon': Icons.calculate_outlined},
        {'title': 'Net Banking (50+ Indian Banks)', 'desc': 'Instant bank transfer via SBI, HDFC, ICICI, Axis & Kotak', 'icon': Icons.account_balance_rounded},
        {'title': 'Cash on Delivery (COD)', 'desc': 'Pay in cash or UPI scan when parcel arrives at your doorstep', 'icon': Icons.payments_rounded},
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Payment Method',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...methods.map((m) {
            final isSelected = _selectedPaymentMethod == m['title'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? CyberColors.cyanPrimary.withOpacity(0.12)
                    : (isDark ? CyberColors.darkSurfaceLight : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? CyberColors.cyanPrimary
                      : (isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                onTap: () => setState(() => _selectedPaymentMethod = m['title'] as String),
                leading: Icon(
                  m['icon'] as IconData,
                  color: isSelected ? CyberColors.cyanPrimary : Colors.grey,
                ),
                title: Text(
                  m['title'] as String,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  m['desc'] as String,
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                trailing: Radio<String>(
                  value: m['title'] as String,
                  groupValue: _selectedPaymentMethod,
                  activeColor: CyberColors.cyanPrimary,
                  onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                ),
              ),
            );
          }),
        ],
      );
    } else {
      // Step 3: Review Order
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary & Review',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Customer details recap
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deliver to:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => setState(() => _currentStep = 0),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                Text('${_nameController.text} • ${_phoneController.text}', style: GoogleFonts.inter(fontSize: 12)),
                Text('${_addressController.text}, ${_cityController.text} ${_zipController.text}',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                    Text(_selectedPaymentMethod,
                        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: CyberColors.cyanPrimary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items summary
          Text('Cart Items (${store.cartCount})', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...store.cart.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        item.product.imageUrls.first,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.devices, size: 24),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: GoogleFonts.inter(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      CurrencyHelper.format(item.totalPrice),
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
          const Divider(height: 24),

          // Cost Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: GoogleFonts.inter(fontSize: 12)),
              Text(CurrencyHelper.format(store.subtotal), style: GoogleFonts.spaceGrotesk(fontSize: 12)),
            ],
          ),
          if (store.discountAmount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discount (${store.appliedPromoCode})',
                    style: GoogleFonts.inter(fontSize: 12, color: CyberColors.emeraldGreen)),
                Text('-${CurrencyHelper.format(store.discountAmount)}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, color: CyberColors.emeraldGreen)),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: GoogleFonts.inter(fontSize: 12)),
              Text(store.shippingFee == 0 ? 'FREE' : CurrencyHelper.format(store.shippingFee),
                  style: GoogleFonts.spaceGrotesk(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GST (18% CGST + SGST)', style: GoogleFonts.inter(fontSize: 12)),
              Text(CurrencyHelper.format(store.estimatedTax), style: GoogleFonts.spaceGrotesk(fontSize: 12)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                CurrencyHelper.format(store.totalAmount),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: CyberColors.cyanPrimary,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSuccessScreen(OrderModel order, bool isDark) {
    return Dialog(
      backgroundColor: isDark ? CyberColors.darkSurface : CyberColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: CyberColors.cyanPrimary, width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: CyberColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CyberColors.cyanPrimary.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.black, size: 42),
              ),
              const SizedBox(height: 20),
              Text(
                'Order Confirmed!',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for your order! Your quantum tech is being prepped for dispatch.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? CyberColors.darkTextSecondary : CyberColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Order Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? CyberColors.darkBg : CyberColors.lightSurfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order ID:', style: GoogleFonts.inter(fontSize: 12)),
                        Text(order.id, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tracking Number:', style: GoogleFonts.inter(fontSize: 12)),
                        Text(order.trackingNumber,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 11, fontWeight: FontWeight.bold, color: CyberColors.cyanPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimated Delivery:', style: GoogleFonts.inter(fontSize: 12)),
                        Text(DateFormat.yMMMd().format(order.estimatedDelivery),
                            style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timeline_rounded, size: 18),
                  label: const Text('Track Order Status Live'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
