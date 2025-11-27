import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/screens/splash/splash_screen.dart';
import 'package:nodhapp/services/supabase_cerdentails.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseCredentials.url,
    anonKey: SupabaseCredentials.anonKey,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: AppConstant.APP_NAME,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppConstant.PRIMARY_COLOR,
        scaffoldBackgroundColor: AppConstant.BACKGROUND_COLOR,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstant.PRIMARY_COLOR,
          background: AppConstant.BACKGROUND_COLOR,
          surface: AppConstant.SURFACE_COLOR,
          brightness: Brightness.dark,
          error: AppConstant.ERROR_COLOR,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}