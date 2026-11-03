import 'package:flutter/material.dart';

/// Informational banner displaying the actual Google Cloud Firestore query being executed.
class FirestoreQueryBanner extends StatelessWidget {
  final String query;
  final String genre;
  final String searchMode;
  final int resultCount;

  const FirestoreQueryBanner({
    super.key,
    required this.query,
    required this.genre,
    required this.searchMode,
    required this.resultCount,
  });

  String _buildQueryCode() {
    final buffer = StringBuffer("db.collection('books')");
    if (genre != 'All') {
      buffer.write("\n  .where('genre', isEqualTo: '$genre')");
    }
    if (query.isNotEmpty) {
      final q = query.trim().toLowerCase();
      if (searchMode == 'Prefix') {
        buffer.write(
            "\n  .where('titleLower', isGreaterThanOrEqualTo: '$q')\n  .where('titleLower', isLessThanOrEqualTo: '$q\\uf8ff')");
      } else {
        buffer.write("\n  .where('searchKeywords', arrayContains: '$q')");
      }
    }
    buffer.write('\n  .snapshots()');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.terminal, color: Colors.tealAccent, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Active Firestore Query',
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$resultCount Docs Retrieved',
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _buildQueryCode(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'monospace',
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

