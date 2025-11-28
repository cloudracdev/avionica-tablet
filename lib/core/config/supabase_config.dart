import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static GoTrueClient get auth => client.auth;
  static SupabaseQueryBuilder table(String name) => client.from(name);
  static User? get currentUser => auth.currentUser;
  static Session? get currentSession => auth.currentSession;
  static bool get isAuthenticated => currentUser != null;
}
