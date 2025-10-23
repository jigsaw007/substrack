import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String message = '';

  Future<void> _signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => message = "Please fill in all fields.");
      return;
    }
    if (password != confirm) {
      setState(() => message = "Passwords do not match.");
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        setState(() => message =
            "🎉 Account created! Check your email to verify your account.");
      } else {
        setState(() => message = "Sign-up failed. Try again later.");
      }
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
              // 🌈 Brand / Logo
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

              // 📧 Email
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Email"),
              ),
              const SizedBox(height: 16),

              // 🔒 Password
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Password"),
              ),
              const SizedBox(height: 16),

              // 🔐 Confirm password
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Confirm Password"),
              ),
              const SizedBox(height: 24),

              // 🚀 Signup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF38BDF8),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 🧠 Message (error/success)
              if (message.isNotEmpty)
                Text(
                  message,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 30),

              // 🔁 Back to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?",
                      style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/auth'),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
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
