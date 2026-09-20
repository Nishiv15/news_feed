import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './screens/HomePage.dart';
import './screens/NewsFeedPage.dart';
import './models/news_model.dart';
import './models/theme_notifier.dart';
import './widgets/install_app_banner_stub.dart'
if (dart.library.js_interop) './widgets/install_app_banner.dart';

const _supabaseUrl = 'https://pkbdqykzmjegdcvcllrs.supabase.co';
const _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBrYmRxeWt6bWplZ2RjdmNsbHJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzOTU4MDIsImV4cCI6MjA5MDk3MTgwMn0._UdB1doC0fzB8QY2X3EihHT_Y-oNZfzLVoryW0HMCsw';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await themeNotifier.init();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Check for a persisted session and restore user state
  final session = Supabase.instance.client.auth.currentSession;
  Widget startPage = const HomePage();

  if (session != null) {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userData = await Supabase.instance.client
            .from('userinfo')
            .select('country, isActive')
            .eq('id', user.id)
            .maybeSingle();

        if (userData != null) {
          final bool isActive = userData['isActive'] ?? true;
          if (isActive) {
            final country = userData['country'] as String?;
            if (country != null && country.isNotEmpty) {
              globalCountry = country;
            }
            startPage = const NewsFeedPage();
          } else {
            await Supabase.instance.client.auth.signOut();
          }
        } else {
          startPage = const NewsFeedPage();
        }
      }
    } catch (e) {
      debugPrint('Session restore error: $e');
    }
  }

  runApp(MyApp(startPage: startPage));
}

class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NewsFeed',
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F4EF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD6472B),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121218),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD6472B),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E2E),
            ),
          ),
          builder: (context, child) {
            return InstallAppBanner(child: child ?? const SizedBox.shrink());
          },
          home: startPage,
        );
      },
    );
  }
}

