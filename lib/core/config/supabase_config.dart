import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://pqbwhulxexwignymqpfv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxYndodWx4ZXh3aWdueW1xcGZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwODQzMjEsImV4cCI6MjA3OTY2MDMyMX0.TL6Fb2i3NlRqcxUN0Mm5FJArnnlKj5aA-E7w4o3Gdj0';

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