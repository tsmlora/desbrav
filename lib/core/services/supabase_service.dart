import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  final Future<void> _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() : _initFuture = _initializeSupabase();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Public initialize method for external calls
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _initFuture;
    }
  }

  // Internal initialization logic
  static Future<void> _initializeSupabase() async {
    // Better error messages for missing configuration
    if (supabaseUrl.isEmpty) {
      throw Exception(
          '🔧 SUPABASE_URL não foi configurada. Execute com: flutter run --dart-define-from-file=env.json');
    }

    if (supabaseAnonKey.isEmpty) {
      throw Exception(
          '🔧 SUPABASE_ANON_KEY não foi configurada. Execute com: flutter run --dart-define-from-file=env.json');
    }

    // Validate URL format
    if (!supabaseUrl.startsWith('https://') ||
        !supabaseUrl.contains('supabase.co')) {
      throw Exception(
          '🔧 SUPABASE_URL inválida. Deve ser no formato: https://seu-projeto.supabase.co');
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false, // Set to false for production
      );

      _instance._client = Supabase.instance.client;
      _instance._isInitialized = true;

      print(
          '✅ Supabase initialized successfully for: ${supabaseUrl.split('.')[0].split('//')[1]}');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      print(
          '🔧 Verifique se as credenciais estão corretas e há conexão com a internet');
      print('🔧 URL: $supabaseUrl');
      print(
          '🔧 Key starts with: ${supabaseAnonKey.isEmpty ? "EMPTY" : "${supabaseAnonKey.substring(0, 20)}..."}');
      rethrow;
    }
  }

  // Client getter (async)
  Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      await _initFuture;
    }
    return _client;
  }

  // Synchronous client getter (only use after initialization)
  SupabaseClient get clientSync {
    if (!_isInitialized) {
      throw Exception(
          'SupabaseService não foi inicializado. Aguarde a inicialização ou use client getter assíncrono.');
    }
    return _client;
  }

  // Check initialization status
  bool get isInitialized => _isInitialized;

  // Helper method to check if properly configured
  bool get isProperlyConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl.startsWith('https://') &&
        supabaseUrl.contains('supabase.co');
  }

  // Get configuration status for debugging
  Map<String, dynamic> get configStatus {
    return {
      'isInitialized': _isInitialized,
      'isProperlyConfigured': isProperlyConfigured,
      'hasUrl': supabaseUrl.isNotEmpty,
      'hasKey': supabaseAnonKey.isNotEmpty,
      'urlPreview': supabaseUrl.isEmpty
          ? 'EMPTY'
          : '${supabaseUrl.substring(0, supabaseUrl.length > 30 ? 30 : supabaseUrl.length)}...',
      'keyPreview': supabaseAnonKey.isEmpty
          ? 'EMPTY'
          : '${supabaseAnonKey.substring(0, 20)}...',
    };
  }
}
