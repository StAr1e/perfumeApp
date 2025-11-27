import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/layouts/main_layout.dart';
import 'package:nodhapp/services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  final _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool _isLogin = true;
  bool _passwordVisible = false;

  // ----------------------------------------------------------
  // -------------------- AUTH HANDLER ------------------------
  // ----------------------------------------------------------
  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (!_isLogin && _usernameController.text.isEmpty)) {
      _showError('Please fill all fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _supabaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _supabaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );

        if (mounted) {
          _showSuccess("Account created! Check your email.");
          setState(() => _isLogin = true);
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------
  // ----------------- FORGOT PASSWORD ------------------------
  // ----------------------------------------------------------
  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showError("Enter your email above.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabaseService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      _showSuccess("Reset link sent! Check your email.");
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------
  // ----------------------- HELPERS --------------------------
  // ----------------------------------------------------------
  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppConstant.ERROR_COLOR,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // ------------------------ UI ------------------------------
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.BACKGROUND_COLOR,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstant.PADDING_LARGE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----------------- APP TITLE -----------------
              Text(
                AppConstant.APP_NAME,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: AppConstant.TEXT_PRIMARY,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Experience Luxury",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: AppConstant.FONT_SUBTITLE,
                  color: AppConstant.PRIMARY_COLOR,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 50),

              // ----------------- USERNAME (SIGNUP ONLY) -----------------
              if (!_isLogin)
                ...[
                  _buildTextField(
                    controller: _usernameController,
                    label: "Username",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                ],

              // ----------------- EMAIL -----------------
              _buildTextField(
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // ----------------- PASSWORD -----------------
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 30),

              // ----------------- SUBMIT BUTTON -----------------
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppConstant.PRIMARY_COLOR,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstant.PRIMARY_COLOR,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstant.BORDER_RADIUS,
                          ),
                        ),
                      ),
                      child: Text(
                        _isLogin ? "LOGIN" : "SIGN UP",
                        style: GoogleFonts.lato(
                          fontSize: AppConstant.FONT_SUBTITLE,
                          color: AppConstant.BACKGROUND_COLOR,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              const SizedBox(height: 15),

              // ----------------- TOGGLE + FORGOT -----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? "Create account" : "Have account?",
                      style: const TextStyle(color: AppConstant.TEXT_SECONDARY),
                    ),
                  ),
                  _isLogin
                      ? TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: AppConstant.PRIMARY_COLOR),
                          ),
                        )
                      : TextButton(
                          onPressed: _skipLogin,
                          child: const Text(
                            "Skip for now",
                            style: TextStyle(color: AppConstant.TEXT_SECONDARY),
                          ),
                        ),
                ],
              ),
            ]
                .animate(interval: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.4),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ----------------- CUSTOM TEXT FIELD ----------------------
  // ----------------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_passwordVisible,
      style: const TextStyle(color: AppConstant.TEXT_PRIMARY),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppConstant.TEXT_SECONDARY),
        prefixIcon: Icon(icon, color: AppConstant.TEXT_SECONDARY),
        filled: true,
        fillColor: AppConstant.SURFACE_COLOR,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
          borderSide: const BorderSide(color: AppConstant.PRIMARY_COLOR),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppConstant.TEXT_SECONDARY,
                ),
                onPressed: () {
                  setState(() => _passwordVisible = !_passwordVisible);
                },
              )
            : null,
      ),
    );
  }
}
