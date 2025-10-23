import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/home_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SupabaseClient supabase;
  late final Stream<AuthState> _authStream;
  Session? _session;

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    _session = supabase.auth.currentSession;

    // 👇 Listen for Supabase auth state changes (login, logout, verification link)
    _authStream = supabase.auth.onAuthStateChange;
    _authStream.listen((event) {
      final session = event.session;

      if (session != null && mounted) {
        // ✅ Automatically go to HomeScreen when user becomes authenticated
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (mounted) {
        // 🔒 When logged out, return to AuthScreen
        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),

      // 🚀 Define app routes
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/home': (_) => const HomeScreen(),
      },

      // 🧭 Determine initial screen
      home: _session == null ? const AuthScreen() : const HomeScreen(),
    );
  }
}
