import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './screens/HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await dotenv.load(fileName: ".env"); 
  final sUrl = dotenv.env['SUPABASE_URL']!.replaceAll('"', '').replaceAll("'", "").trim();
  final sKey = dotenv.env['SUPABASE_ANON_KEY']!.replaceAll('"', '').replaceAll("'", "").trim();

  await Supabase.initialize(
    url: sUrl,
    anonKey: sKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NewsFeed',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const HomePage(),
    );
  }
}
