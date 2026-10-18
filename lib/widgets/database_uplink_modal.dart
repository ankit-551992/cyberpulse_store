import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../services/supabase_config.dart';
import '../theme/cyber_colors.dart';

class DatabaseUplinkModal extends StatefulWidget {
  const DatabaseUplinkModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DatabaseUplinkModal(),
    );
  }

  @override
  State<DatabaseUplinkModal> createState() => _DatabaseUplinkModalState();
}

class _DatabaseUplinkModalState extends State<DatabaseUplinkModal> {
  late final TextEditingController _urlController;
  late final TextEditingController _keyController;
  bool _obscureKey = true;
  bool _isTesting = false;
  bool _isSaving = false;
  bool _isSeeding = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: SupabaseConfig.url);
    _keyController = TextEditingController(text: SupabaseConfig.anonKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _handleTestConnection(StoreProvider store) async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final res = await store.testDatabaseConnection();
    if (!mounted) return;

    setState(() {
      _isTesting = false;
      _testSuccess = res['success'] as bool;
      _testResult = res['message'] as String;
    });
  }

  Future<void> _handleSaveCredentials(StoreProvider store) async {
    final url = _urlController.text.trim();
    final key = _keyController.text.trim();

    if (url.isEmpty || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Supabase URL and Anon Key.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final success = await store.connectDatabase(url: url, anonKey: key);
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '⚡ Neural Database Uplink connected to Supabase PostgreSQL!'
              : 'Connection attempt completed with fallback status.',
        ),
        backgroundColor: success ? CyberColors.cyanPrimary : Colors.orangeAccent,
      ),
    );
  }

  Future<void> _handleSeedData(StoreProvider store) async {
    setState(() => _isSeeding = true);
    try {
      final count = await store.seedDatabaseToSupabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ Successfully seeded $count catalog items into Supabase!'),
          backgroundColor: CyberColors.emeraldGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seed failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  Future<void> _handleDisconnect(StoreProvider store) async {
    await store.disconnectDatabase();
    setState(() {
      _urlController.clear();
      _keyController.clear();
      _testResult = 'Disconnected. App is running on Local Cache mode.';
      _testSuccess = null;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disconnected. Running in Local Storage Cache mode.'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isConnected = store.isDatabaseConnected;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 580,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0F18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected ? CyberColors.cyanPrimary : CyberColors.purpleNeon,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isConnected ? CyberColors.cyanPrimary : CyberColors.purpleNeon)
                  .withOpacity(0.25),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                gradient: LinearGradient(
                  colors: [
                    CyberColors.cyanPrimary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isConnected ? CyberColors.emeraldGreen : CyberColors.purpleNeon)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isConnected ? CyberColors.emeraldGreen : CyberColors.purpleNeon,
                      ),
                    ),
                    child: Icon(
                      Icons.storage_rounded,
                      color: isConnected ? CyberColors.emeraldGreen : CyberColors.purpleNeon,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEURAL DATABASE UPLINK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isConnected ? CyberColors.emeraldGreen : Colors.orangeAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isConnected ? CyberColors.emeraldGreen : Colors.orangeAccent)
                                        .withOpacity(0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isConnected
                                  ? 'SUPABASE POSTGRESQL (ACTIVE)'
                                  : 'LOCAL STORAGE CACHE MODE',
                              style: TextStyle(
                                color: isConnected ? CyberColors.emeraldGreen : Colors.orangeAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: CyberColors.cyanPrimary.withOpacity(0.8), size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Connect CyberPulse to your Supabase PostgreSQL project for live catalog sync, real-time orders, and persistent customer data.',
                              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Supabase URL Input
                    const Text(
                      'SUPABASE PROJECT URL',
                      style: TextStyle(
                        color: CyberColors.cyanPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: 'https://xxxxxxxx.supabase.co',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF141824),
                        prefixIcon: const Icon(Icons.link_rounded, color: CyberColors.cyanPrimary, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: CyberColors.cyanPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Supabase Anon Key Input
                    const Text(
                      'SUPABASE ANON PUBLIC KEY',
                      style: TextStyle(
                        color: CyberColors.cyanPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _keyController,
                      obscureText: _obscureKey,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF141824),
                        prefixIcon: const Icon(Icons.key_rounded, color: CyberColors.cyanPrimary, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: Colors.white54,
                            size: 18,
                          ),
                          onPressed: () => setState(() => _obscureKey = !_obscureKey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: CyberColors.cyanPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Test result banner
                    if (_testResult != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (_testSuccess == true
                                  ? CyberColors.emeraldGreen
                                  : Colors.redAccent)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _testSuccess == true
                                ? CyberColors.emeraldGreen
                                : Colors.redAccent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _testSuccess == true
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              color: _testSuccess == true
                                  ? CyberColors.emeraldGreen
                                  : Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _testResult!,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : () => _handleSaveCredentials(store),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.bolt_rounded, size: 18),
                          label: Text(_isSaving ? 'CONNECTING...' : 'SAVE & CONNECT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CyberColors.cyanPrimary,
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isTesting ? null : () => _handleTestConnection(store),
                          icon: _isTesting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: CyberColors.cyanPrimary),
                                )
                              : const Icon(Icons.network_ping_rounded, size: 18),
                          label: Text(_isTesting ? 'PINGING...' : 'TEST PING'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CyberColors.cyanPrimary,
                            side: const BorderSide(color: CyberColors.cyanPrimary),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        if (isConnected) ...[
                          ElevatedButton.icon(
                            onPressed: _isSeeding ? null : () => _handleSeedData(store),
                            icon: _isSeeding
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Icon(Icons.cloud_upload_rounded, size: 18),
                            label: Text(_isSeeding ? 'SEEDING...' : 'SYNC CATALOG TO CLOUD'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CyberColors.emeraldGreen,
                              foregroundColor: Colors.black,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _handleDisconnect(store),
                            icon: const Icon(Icons.link_off_rounded, size: 18),
                            label: const Text('DISCONNECT'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 14),

                    // Quick guide on Supabase schema
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141824),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.terminal_rounded, color: CyberColors.purpleNeon, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'SQL MIGRATION SCRIPT INCLUDED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The complete PostgreSQL schema and seed dataset are located in the repository under "supabase/schema.sql" and "supabase/seed.sql". Paste them in your Supabase SQL Editor to initialize all tables with 1 click.',
                            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(const ClipboardData(
                                text: 'supabase/schema.sql',
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('SQL schema path copied to clipboard.'),
                                  backgroundColor: CyberColors.cyanPrimary,
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.copy_rounded, color: CyberColors.cyanPrimary.withOpacity(0.8), size: 14),
                                const SizedBox(width: 6),
                                const Flexible(
                                  child: Text(
                                    'Path: supabase/schema.sql & supabase/seed.sql',
                                    style: TextStyle(
                                      color: CyberColors.cyanPrimary,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
