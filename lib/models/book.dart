/// Model class representing a Book document in the Google Cloud Firestore library collection.
class Book {
  final String? id; // Firestore document ID
  final String isbn; // e.g. '978-0134685991'
  final String title;
  final String author;
  final String genre;
  final int publishYear;
  final double rating;
  final String description;
  final bool isAvailable;
  final List<String> searchKeywords;

  const Book({
    this.id,
    required this.isbn,
    required this.title,
    required this.author,
    required this.genre,
    required this.publishYear,
    required this.rating,
    required this.description,
    this.isAvailable = true,
    required this.searchKeywords,
  });

  /// Generate lowercase search tokens for array-contains search in Firestore.
  static List<String> generateKeywords(String title, String author, String genre) {
    final combined = '$title $author $genre'.toLowerCase();
    final words = combined.split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();
    return words.toList();
  }

  /// Convert Book to a Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      'isbn': isbn,
      'title': title,
      'titleLower': title.toLowerCase(),
      'author': author,
      'authorLower': author.toLowerCase(),
      'genre': genre,
      'publishYear': publishYear,
      'rating': rating,
      'description': description,
      'isAvailable': isAvailable,
      'searchKeywords': searchKeywords,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Factory from Map and document ID.
  factory Book.fromMap(Map<String, dynamic> map, String id) {
    final keywordsList = map['searchKeywords'];
    final List<String> parsedKeywords = keywordsList is List
        ? keywordsList.map((e) => e.toString()).toList()
        : [];

    return Book(
      id: id,
      isbn: map['isbn'] as String? ?? 'N/A',
      title: map['title'] as String? ?? 'Untitled',
      author: map['author'] as String? ?? 'Unknown',
      genre: map['genre'] as String? ?? 'General',
      publishYear: (map['publishYear'] as num?)?.toInt() ?? 2020,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.0,
      description: map['description'] as String? ?? '',
      isAvailable: map['isAvailable'] as bool? ?? true,
      searchKeywords: parsedKeywords,
    );
  }

  Book copyWith({
    String? id,
    String? isbn,
    String? title,
    String? author,
    String? genre,
    int? publishYear,
    double? rating,
    String? description,
    bool? isAvailable,
    List<String>? searchKeywords,
  }) {
    return Book(
      id: id ?? this.id,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      publishYear: publishYear ?? this.publishYear,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      searchKeywords: searchKeywords ?? this.searchKeywords,
    );
  }
}

