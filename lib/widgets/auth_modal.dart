import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyber_colors.dart';
import '../providers/store_provider.dart';

class AuthModal extends StatefulWidget {
  final bool requireAdmin;
  final VoidCallback? onSuccess;

  const AuthModal({
    super.key,
    this.requireAdmin = false,
    this.onSuccess,
  });

  /// Static helper to show the AuthModal dialog cleanly anywhere
  static Future<bool?> show(
    BuildContext context, {
    bool requireAdmin = false,
    VoidCallback? onSuccess,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AuthModal(
        requireAdmin: requireAdmin,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  bool _obscureSignInPassword = true;

  // Sign Up controllers
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  UserRole _signUpRole = UserRole.customer;
  bool _obscureSignUpPassword = true;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.requireAdmin) {
      _signInEmailController.text = 'admin@cyberpulse.in';
      _signInPasswordController.text = 'admin2077';
    } else {
      _signInEmailController.text = 'aarav.sharma@cyberpulse.in';
      _signInPasswordController.text = 'password123';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPhoneController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(StoreProvider store) async {
    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await store.signIn(email, password);

    if (!mounted) return;

    if (result.isSuccess) {
      if (widget.requireAdmin && !result.user!.isAdmin) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Access Denied: This account does not have Administrative clearance.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _successMessage = 'Access Granted. Welcome, ${result.user!.name}!';
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      widget.onSuccess?.call();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage ?? 'Authentication failed.';
      });
    }
  }

  Future<void> _handleSignUp(StoreProvider store) async {
    final name = _signUpNameController.text.trim();
    final email = _signUpEmailController.text.trim();
    final phone = _signUpPhoneController.text.trim();
    final password = _signUpPasswordController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await store.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone.isEmpty ? '+91 98765 43210' : phone,
      role: _signUpRole,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _isLoading = false;
        _successMessage = 'Identity Created! Welcome to CyberPulse.';
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      widget.onSuccess?.call();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage ?? 'Registration failed.';
      });
    }
  }

  Future<void> _quickLoginCustomer(StoreProvider store) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await store.loginAsDemoCustomer();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _successMessage = 'Logged in as Aarav Sharma (Customer)';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    widget.onSuccess?.call();
    Navigator.of(context).pop(true);
  }

  Future<void> _quickLoginAdmin(StoreProvider store) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await store.loginAsDemoAdmin();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _successMessage = 'Logged in as Alex Vance (Administrator)';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    widget.onSuccess?.call();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = store.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1420) : CyberColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.requireAdmin
                  ? CyberColors.purpleNeon
                  : CyberColors.cyanPrimary.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.requireAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary)
                    .withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 40,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header with Branding
                  _buildHeader(isDark),

                  // Notification Messages (Error or Success)
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: CyberColors.pinkAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CyberColors.pinkAccent.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: CyberColors.pinkAccent, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_successMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: CyberColors.emeraldGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CyberColors.emeraldGreen.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: CyberColors.emeraldGreen, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Tabs Switcher
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? CyberColors.darkSurfaceLight : CyberColors.lightSurfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        gradient: widget.requireAdmin
                            ? CyberColors.neonPurpleGradient
                            : CyberColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: widget.requireAdmin ? Colors.white : Colors.black,
                      unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                      labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(text: '⚡ SIGN IN'),
                        Tab(text: '✨ CREATE IDENTITY'),
                      ],
                    ),
                  ),

                  // Tab Views
                  SizedBox(
                    height: 360,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSignInTab(store, isDark),
                        _buildSignUpTab(store, isDark),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Quick Demo Accounts Section
                  _buildQuickDemoSection(store, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090C14) : CyberColors.lightSurfaceAlt,
        border: Border(
          bottom: BorderSide(
            color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: widget.requireAdmin
                  ? CyberColors.neonPurpleGradient
                  : CyberColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (widget.requireAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary)
                      .withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              widget.requireAdmin ? Icons.shield_rounded : Icons.lock_open_rounded,
              size: 22,
              color: widget.requireAdmin ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.requireAdmin ? 'ADMIN SECURITY GATE' : 'CYBER ACCESS',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.2,
                        color: widget.requireAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.requireAdmin
                      ? 'Administrative privileges required for Mission Control'
                      : 'Sign in to access personalized orders & neural wishlist',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(false),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildSignInTab(StoreProvider store, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'user@cyberpulse.in',
              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
              filled: true,
              fillColor: isDark ? CyberColors.darkSurfaceLight : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.requireAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Password Field
          TextField(
            controller: _signInPasswordController,
            obscureText: _obscureSignInPassword,
            style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'Access Password',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.password_rounded, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignInPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureSignInPassword = !_obscureSignInPassword),
              ),
              filled: true,
              fillColor: isDark ? CyberColors.darkSurfaceLight : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? CyberColors.darkBorder : CyberColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.requireAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign In Action Button
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: widget.requireAdmin
                  ? CyberColors.neonPurpleGradient
                  : CyberColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (widget.requireAdmin ? CyberColors.purpleNeon : CyberColors.cyanPrimary)
                      .withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : () => _handleSignIn(store),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.requireAdmin ? Icons.verified_user_rounded : Icons.bolt_rounded,
                          color: widget.requireAdmin ? Colors.white : Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.requireAdmin ? 'AUTHORIZE ADMIN ACCESS' : 'AUTHENTICATE ACCESS',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: widget.requireAdmin ? Colors.white : Colors.black,
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

  Widget _buildSignUpTab(StoreProvider store, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name Field
            TextField(
              controller: _signUpNameController,
              style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'e.g. Arjun Sharma',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                filled: true,
                fillColor: isDark ? CyberColors.darkSurfaceLight : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Email Field
            TextField(
              controller: _signUpEmailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'arjun@example.com',
                prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
                filled: true,
                fillColor: isDark ? CyberColors.darkSurfaceLight : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Phone Field
            TextField(
              controller: _signUpPhoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Mobile Phone',
                hintText: '+91 98765 43210',
                prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 18),
                filled: true,
                fillColor: isDark ? CyberColors.darkSurfaceLight : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Password Field
            TextField(
              controller: _signUpPasswordController,
              obscureText: _obscureSignUpPassword,
              style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Set Password (min 6 characters)',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureSignUpPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscureSignUpPassword = !_obscureSignUpPassword),
                ),
                filled: true,
                fillColor: isDark ? CyberColors.darkSurfaceLight : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Role selection
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  'Account Role: ',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                ChoiceChip(
                  label: const Text('Customer'),
                  selected: _signUpRole == UserRole.customer,
                  onSelected: (val) {
                    if (val) setState(() => _signUpRole = UserRole.customer);
                  },
                ),
                ChoiceChip(
                  label: const Text('Administrator'),
                  selected: _signUpRole == UserRole.admin,
                  onSelected: (val) {
                    if (val) setState(() => _signUpRole = UserRole.admin);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Register Action Button
            Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: CyberColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: _isLoading ? null : () => _handleSignUp(store),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        'CREATE CYBER IDENTITY',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDemoSection(StoreProvider store, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: isDark ? const Color(0xFF090D15) : CyberColors.lightSurfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, size: 14, color: CyberColors.amberWarning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '1-CLICK DEMO ACCOUNTS (INSTANT EVALUATION)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    side: BorderSide(color: CyberColors.cyanPrimary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.person_rounded, size: 16, color: CyberColors.cyanPrimary),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Demo Customer',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Aarav Sharma',
                        style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                  onPressed: _isLoading ? null : () => _quickLoginCustomer(store),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    side: BorderSide(color: CyberColors.purpleNeon.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.shield_rounded, size: 16, color: CyberColors.purpleNeon),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Demo Admin',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Alex Vance',
                        style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                  onPressed: _isLoading ? null : () => _quickLoginAdmin(store),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
