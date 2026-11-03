import 'package:flutter/material.dart';
import 'screens/book_search_screen.dart';
import 'services/firestore_search_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firestore Search Service with persistence
  await FirestoreSearchService.instance.initialize();

  runApp(const FirestoreSearchApp());
}

/// Root widget for the Google Cloud Firestore Search application.
class FirestoreSearchApp extends StatelessWidget {
  const FirestoreSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Database Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const BookSearchScreen(),
    );
  }
}
