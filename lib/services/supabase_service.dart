import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    String urlFinal = url;
    if (!urlFinal.startsWith('https://')) {
      urlFinal = 'https://$urlFinal';
    }
    if (!urlFinal.contains('.supabase.co')) {
      urlFinal = '$urlFinal.supabase.co';
    }
    
    await Supabase.initialize(
      url: urlFinal,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) throw Exception('Supabase no inicializado');
    return _client!;
  }

  static Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> logout() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}