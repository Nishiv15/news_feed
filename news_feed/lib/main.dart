import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './screens/HomePage.dart';
import './screens/NewsFeedPage.dart';
import './models/news_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final sUrl = dotenv.env['SUPABASE_URL']!
      .replaceAll('"', '')
      .replaceAll("'", "")
      .trim();
  final sKey = dotenv.env['SUPABASE_ANON_KEY']!
      .replaceAll('"', '')
      .replaceAll("'", "")
      .trim();

  await Supabase.initialize(url: sUrl, anonKey: sKey);

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NewsFeed',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: startPage,
    );
  }
}
