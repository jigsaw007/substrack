import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'ui/screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sckjpulwhbokgaqdcttj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNja2pwdWx3aGJva2dhcWRjdHRqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExMDU3OTcsImV4cCI6MjA3NjY4MTc5N30.hdKdHhkiM0KFimk6n7urNKYmwogY30Us2YchvzdyPMk',
  );

  runApp(const ProviderScope(child: MyApp()));
}
