import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SupabaseConnectionState {
  disconnected,
  connecting,
  connected,
  fallbackLocal,
  error,
}

class SupabaseConfig {
  static const String _prefUrlKey = 'cyberpulse_supabase_url';
  static const String _prefAnonKeyKey = 'cyberpulse_supabase_anon_key';

  // Environment variables passed via --dart-define
  static const String _envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static String _url = '';
  static String _anonKey = '';
  static SupabaseConnectionState _state = SupabaseConnectionState.disconnected;
  static String? _errorMessage;

  static String get url => _url;
  static String get anonKey => _anonKey;
  static SupabaseConnectionState get state => _state;
  static String? get errorMessage => _errorMessage;
  static bool get isConnected => _state == SupabaseConnectionState.connected;
  static bool get hasCredentials => _url.isNotEmpty && _anonKey.isNotEmpty;

  /// Loads saved credentials from SharedPreferences or environment
  static Future<void> loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_prefUrlKey);
      final savedKey = prefs.getString(_prefAnonKeyKey);

      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _url = savedUrl.trim();
      } else if (_envUrl.isNotEmpty) {
        _url = _envUrl.trim();
      }

      if (savedKey != null && savedKey.trim().isNotEmpty) {
        _anonKey = savedKey.trim();
      } else if (_envAnonKey.isNotEmpty) {
        _anonKey = _envAnonKey.trim();
      }
    } catch (e) {
      debugPrint('SupabaseConfig: error loading credentials: $e');
    }
  }

  /// Initialize Supabase client
  static Future<bool> initialize() async {
    await loadCredentials();

    if (!hasCredentials) {
      _state = SupabaseConnectionState.fallbackLocal;
      debugPrint('⚡ SupabaseConfig: No credentials provided, running in Local Cache Mode.');
      return false;
    }

    _state = SupabaseConnectionState.connecting;

    try {
      // Validate URL format
      final uri = Uri.tryParse(_url);
      if (uri == null || !uri.hasScheme || !uri.host.contains('supabase')) {
        _state = SupabaseConnectionState.error;
        _errorMessage = 'Invalid Supabase Project URL format.';
        return false;
      }

      // If Supabase is already initialized, we re-use or re-initialize
      try {
        Supabase.instance.client;
      } catch (_) {
        await Supabase.initialize(
          url: _url,
          anonKey: _anonKey,
          debug: kDebugMode,
        );
      }

      _state = SupabaseConnectionState.connected;
      _errorMessage = null;
      debugPrint('⚡ SupabaseConfig: Connected successfully to $_url');
      return true;
    } catch (e) {
      _state = SupabaseConnectionState.error;
      _errorMessage = e.toString();
      debugPrint('⚡ SupabaseConfig: connection failed ($e), falling back to Local Cache.');
      return false;
    }
  }

  /// Save new credentials and attempt to re-connect
  static Future<bool> saveCredentials({
    required String newUrl,
    required String newAnonKey,
  }) async {
    _url = newUrl.trim();
    _anonKey = newAnonKey.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUrlKey, _url);
    await prefs.setString(_prefAnonKeyKey, _anonKey);

    return initialize();
  }

  /// Reset credentials back to local mode
  static Future<void> clearCredentials() async {
    _url = '';
    _anonKey = '';
    _state = SupabaseConnectionState.fallbackLocal;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUrlKey);
    await prefs.remove(_prefAnonKeyKey);
  }

  /// Safe accessor for SupabaseClient (returns null if not connected)
  static SupabaseClient? get client {
    if (_state != SupabaseConnectionState.connected) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
