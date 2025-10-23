import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final supabase = Supabase.instance.client;
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String message = '';

  Future<void> _resetPassword() async {
    final newPassword = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirm.isEmpty) {
      setState(() => message = "Please fill in both fields.");
      return;
    }
    if (newPassword != confirm) {
      setState(() => message = "Passwords do not match.");
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      setState(() => message = "✅ Password updated successfully!");
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/auth');
    } on AuthException catch (e) {
      setState(() => message = e.message);
    } catch (e) {
      setState(() => message = "Something went wrong. Please try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'substrackr',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Reset your password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // New password
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("New Password"),
              ),
              const SizedBox(height: 16),

              // Confirm new password
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Confirm New Password"),
              ),
              const SizedBox(height: 24),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF38BDF8),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              if (message.isNotEmpty)
                Text(
                  message,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/auth'),
                child: const Text(
                  "Back to Login",
                  style: TextStyle(color: Color(0xFF38BDF8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF334155)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF38BDF8)),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
