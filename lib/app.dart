import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/signup_screen.dart';
import 'ui/screens/reset_password_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'SubTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/signup': (_) => const SignupScreen(),
        '/reset': (_) => const ResetPasswordScreen(),
        '/home': (_) => const HomeScreen(),
      },
      home: session == null ? const AuthScreen() : const HomeScreen(),
    );
  }
}
