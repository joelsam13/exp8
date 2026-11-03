import 'package:flutter/material.dart';
import '../models/book.dart';

/// Card widget presenting a single book search result retrieved from Firestore.
class BookResultCard extends StatelessWidget {
  final Book book;
  final String searchQuery;
  final VoidCallback onTap;

  const BookResultCard({
    super.key,
    required this.book,
    required this.searchQuery,
    required this.onTap,
  });

  Color _getGenreColor(String genre) {
    switch (genre) {
      case 'Software Engineering':
        return Colors.blue[700]!;
      case 'Software Architecture':
        return Colors.purple[700]!;
      case 'Computer Science':
        return Colors.deepPurple[700]!;
      case 'Distributed Systems':
        return Colors.teal[700]!;
      case 'Mobile Development':
        return Colors.indigo[700]!;
      case 'Web Development':
        return Colors.amber[900]!;
      default:
        return Colors.teal[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final genreColor = _getGenreColor(book.genre);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Icon Container
              Container(
                width: 58,
                height: 76,
                decoration: BoxDecoration(
                  color: genreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: genreColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_stories, color: genreColor, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${book.publishYear}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: genreColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Genre Badge + Availability
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: genreColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.genre,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: genreColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: book.isAvailable
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.isAvailable ? 'Available' : 'Borrowed',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: book.isAvailable
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Book Title
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Author
                    Text(
                      'By ${book.author}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Rating and ISBN
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          book.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.qr_code, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(
                          book.isbn,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

