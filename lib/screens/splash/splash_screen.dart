import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/screens/auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AuthGate(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.BACKGROUND_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppConstant.APP_NAME,
              style: GoogleFonts.playfairDisplay(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: AppConstant.TEXT_PRIMARY,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Signature Scent',
              style: GoogleFonts.lato(
                fontSize: 16,
                color: AppConstant.PRIMARY_COLOR,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 1500.ms, curve: Curves.easeIn)
            .slideY(begin: 0.2, duration: 1000.ms, curve: Curves.easeOutCubic),
      ),
    );
  }
}