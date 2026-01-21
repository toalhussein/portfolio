import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'services/supabase_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/locale_provider.dart';

/// Main entry point of the Flutter Web Portfolio
/// 
/// This portfolio showcases the work of Alhussein AbdelSabour (@toalhussein),
/// a Mobile App Developer specializing in Flutter development.
/// 
/// Features:
/// - Home page with About Me and Skills sections
/// - Projects page displaying portfolio projects from Supabase
/// - Contact form that stores messages in Supabase
/// - Admin dashboard for managing projects and viewing messages
/// - RTL support (Arabic) with English toggle
/// - Responsive design for all screen sizes
/// - Blue theme with smooth animations and glow effects
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase connection
  await SupabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root application widget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Alhussein AbdelSabour - Portfolio',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration with blue theme and dark mode
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark, // Default to dark theme
      
      // Localization configuration (Arabic RTL by default, toggleable to English)
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // Arabic (RTL)
        Locale('en'), // English (LTR)
      ],
      
      // Router configuration with GoRouter
      routerConfig: router,
    );
  }
}
