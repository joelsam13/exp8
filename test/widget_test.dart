import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firestore_search_app/main.dart';
import 'package:firestore_search_app/services/firestore_search_service.dart';

void main() {
  setUp(() async {
    await FirestoreSearchService.instance.initialize();
  });

  testWidgets('Renders FirestoreSearchApp, executes search query and displays results',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FirestoreSearchApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AppBar title
    expect(find.text('Firestore Search Engine'), findsOneWidget);

    // Verify search input field exists
    expect(find.text('Search library by Title, Author, or Keyword...'), findsOneWidget);

    // Verify Firestore query banner
    expect(find.text('Active Firestore Query'), findsOneWidget);

    // Enter search text "clean"
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'clean');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Clean Code is shown in results
    expect(find.text('Clean Code: A Handbook of Agile Craftsmanship'), findsOneWidget);
  });
}
