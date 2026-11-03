import 'package:flutter/material.dart';
import '../models/book.dart';

/// Dialog displaying full Firestore document fields for a selected book.
class BookDetailsDialog extends StatelessWidget {
  final Book book;

  const BookDetailsDialog({super.key, required this.book});

  static void show(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (_) => BookDetailsDialog(book: book),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              book.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Author: ${book.author}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Genre: ${book.genre} • Published: ${book.publishYear}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            const Text(
              'Synopsis / Description:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              book.description,
              style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.3),
            ),
            const Divider(height: 24),
            const Text(
              'Firestore Metadata:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Document Reference: /books/${book.id ?? "local_cache"}',
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.teal),
            ),
            const SizedBox(height: 4),
            Text(
              'ISBN: ${book.isbn}',
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 4),
            Text(
              'Search Tokens: ${book.searchKeywords.take(6).join(", ")}...',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

