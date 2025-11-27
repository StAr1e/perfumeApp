import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nodhapp/screens/login/login_page.dart';
import 'package:nodhapp/layouts/main_layout.dart';
import 'package:nodhapp/widgets/shimmer_widget.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: ShimmerWidget(width: 100, height: 100),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data?.session != null) {
          return const MainLayout();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}