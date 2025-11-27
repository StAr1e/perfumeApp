import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/layouts/main_layout.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.BACKGROUND_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.check_circle_outline,
              color: AppConstant.PRIMARY_COLOR,
              size: 120,
            ),
            const SizedBox(height: AppConstant.PADDING_LARGE),
            Text(
              'Thank You!',
              style: GoogleFonts.playfairDisplay(
                fontSize: AppConstant.FONT_DISPLAY,
                color: AppConstant.TEXT_PRIMARY,
              ),
            ),
            const SizedBox(height: AppConstant.PADDING_SMALL),
            Text(
              'Your order has been placed successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: AppConstant.FONT_SUBTITLE,
                color: AppConstant.TEXT_SECONDARY,
              ),
            ),
            const SizedBox(height: AppConstant.PADDING_LARGE * 2),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainLayout()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstant.PRIMARY_COLOR,
                foregroundColor: AppConstant.BACKGROUND_COLOR,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstant.PADDING_LARGE, vertical: AppConstant.PADDING_MEDIUM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
                ),
              ),
              child: Text(
                'Continue Shopping',
                style: GoogleFonts.lato(fontSize: AppConstant.FONT_SUBTITLE, fontWeight: FontWeight.bold),
              ),
            ),
          ].animate(interval: 100.ms).slideY(begin: 0.2).fadeIn(),
        ),
      ),
    );
  }
}