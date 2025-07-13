import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/supabase_service.dart';
import '../widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(errorDetails: details);
  };

  // Initialize Supabase with comprehensive error handling
  bool supabaseInitialized = false;
  try {
    await SupabaseService().initialize();
    supabaseInitialized = true;
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize Supabase: $e');
    debugPrint('🔧 Config status: ${SupabaseService().configStatus}');

    // Show more helpful error message
    if (e.toString().contains('SUPABASE_URL')) {
      debugPrint(
          '🔧 Para executar localmente: flutter run --dart-define-from-file=env.json');
      debugPrint(
          '🔧 Para build: flutter build apk --dart-define-from-file=env.json');
    }

    // Continue app initialization even if Supabase fails
    // This prevents the app from crashing on deployment
  }

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(MyApp(supabaseInitialized: supabaseInitialized));
  });
}

class MyApp extends StatelessWidget {
  final bool supabaseInitialized;

  const MyApp({Key? key, required this.supabaseInitialized}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: Sizer(builder: (context, orientation, screenType) {
          return MaterialApp(
              title: 'Desbrav',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
              builder: (context, child) {
                return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(1.0)),
                    child: child!);
              },
              // 🚨 END CRITICAL SECTION
              debugShowCheckedModeBanner: false,
              initialRoute: AppRoutes.splashScreen,
              onGenerateRoute: (settings) {
                // Handle unknown routes gracefully
                final route = AppRoutes.routes[settings.name];
                if (route != null) {
                  return MaterialPageRoute(
                    builder: route,
                    settings: settings,
                  );
                }
                // Fallback to splash screen for unknown routes
                return MaterialPageRoute(
                  builder: AppRoutes.routes[AppRoutes.splashScreen]!,
                  settings: settings,
                );
              },
              routes: AppRoutes.routes);
        }));
  }
}
