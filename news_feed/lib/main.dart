import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './screens/NewsFeedPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for FlutterConfig or other async calls
  await dotenv.load(fileName: ".env"); // Load the .env file
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const NewsFeedPage(),
    );
  }
}
