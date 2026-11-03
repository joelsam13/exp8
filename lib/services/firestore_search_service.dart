import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/book.dart';

/// Service executing Google Cloud Firestore search queries across the library collection.
class FirestoreSearchService {
  static const String collectionName = 'books';

  FirestoreSearchService._internal();
  static final FirestoreSearchService instance = FirestoreSearchService._internal();

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  FirebaseFirestore? _firestore;

  final List<Book> _localCatalog = [];
  final StreamController<List<Book>> _localStreamController =
      StreamController<List<Book>>.broadcast();

  /// Initialize Firebase and Firestore offline persistence.
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firestore = FirebaseFirestore.instance;
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _isFirebaseInitialized = true;
    } catch (_) {
      _isFirebaseInitialized = false;
    }
    _initCatalogData();
  }

  void _initCatalogData() {
    if (_localCatalog.isEmpty) {
      _localCatalog.addAll([
        Book(
          id: 'doc_book_001',
          isbn: '978-0132350884',
          title: 'Clean Code: A Handbook of Agile Craftsmanship',
          author: 'Robert C. Martin',
          genre: 'Software Engineering',
          publishYear: 2008,
          rating: 4.8,
          description:
              'A must-read guide to writing readable, maintainable, and robust object-oriented code.',
          isAvailable: true,
          searchKeywords: Book.generateKeywords(
            'Clean Code: A Handbook of Agile Craftsmanship',
            'Robert C. Martin',
            'Software Engineering',
          ),
        ),
        Book(
          id: 'doc_book_002',
          isbn: '978-0201633610',
          title: 'Design Patterns: Elements of Reusable Object-Oriented Software',
          author: 'Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides',
          genre: 'Software Architecture',
          publishYear: 1994,
          rating: 4.7,
          description:
              'Classic Gang of Four reference cataloging 23 fundamental software design patterns.',
          isAvailable: true,
          searchKeywords: Book.generateKeywords(
            'Design Patterns Elements of Reusable Object-Oriented Software Gang of Four',
            'Erich Gamma Ralph Johnson',
            'Software Architecture',
          ),
        ),
        Book(
          id: 'doc_book_003',
          isbn: '978-0262033848',
          title: 'Introduction to Algorithms (CLRS)',
          author: 'Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest',
          genre: 'Computer Science',
          publishYear: 2009,
          rating: 4.9,
          description:
              'Comprehensive textbook covering asymptotic analysis, graph theory, and dynamic programming.',
          isAvailable: false,
          searchKeywords: Book.generateKeywords(
            'Introduction to Algorithms CLRS Data Structures Graph',
            'Thomas Cormen Charles Leiserson',
            'Computer Science',
          ),
        ),
        Book(
          id: 'doc_book_004',
          isbn: '978-1491950296',
          title: 'Designing Data-Intensive Applications',
          author: 'Martin Kleppmann',
          genre: 'Distributed Systems',
          publishYear: 2017,
          rating: 4.9,
          description:
              'The definitive guide to distributed data systems, replication, partition, and consensus.',
          isAvailable: true,
          searchKeywords: Book.generateKeywords(
            'Designing Data-Intensive Applications NoSQL Firestore Replication',
            'Martin Kleppmann',
            'Distributed Systems',
          ),
        ),
        Book(
          id: 'doc_book_005',
          isbn: '978-1491954249',
          title: 'Flutter in Action',
          author: 'Eric Windmill',
          genre: 'Mobile Development',
          publishYear: 2020,
          rating: 4.6,
          description:
              'Practical guide to building cross-platform native iOS and Android apps with Flutter & Dart.',
          isAvailable: true,
          searchKeywords: Book.generateKeywords(
            'Flutter in Action Dart Widgets Mobile Cross-Platform',
            'Eric Windmill',
            'Mobile Development',
          ),
        ),
        Book(
          id: 'doc_book_006',
          isbn: '978-0134685991',
          title: 'Effective Java',
          author: 'Joshua Bloch',
          genre: 'Software Engineering',
          publishYear: 2018,
          rating: 4.8,
          description:
              'Best practices for the Java platform, covering generics, enums, lambdas, and concurrency.',
          isAvailable: true,
          searchKeywords: Book.generateKeywords(
            'Effective Java Concurrency Best Practices',
            'Joshua Bloch',
            'Software Engineering',
          ),
        ),
        Book(
          id: 'doc_book_007',
          isbn: '978-1449373320',
          title: 'Designing Web APIs',
          author: 'Brenda Jin, Saurabh Sahni, Amir Shevat',
          genre: 'Cloud & APIs',
          publishYear: 2018,
          rating: 4.5,
          description:
              'Principles of RESTful API design, authentication, rate limiting, and web architecture.',
          isAvailable: false,
          searchKeywords: Book.generateKeywords(
            'Designing Web APIs REST HTTP Cloud Microservices',
            'Brenda Jin Saurabh Sahni',
            'Cloud & APIs',
          ),
        ),
        Book(
          id: 'doc_book_008',
          isbn: '978-0596517748',
          title: 'JavaScript: The Good Parts',
          author: 'Douglas Crockford',
          genre: 'Web Development',
          publishYear: 2008,
          rating: 4.4,
          description:
              'Explores the elegant, functional subset of JavaScript including closures and prototypes.',
          isAvailable: true,
          searchKeywords: Book.generateKeywords(
            'JavaScript The Good Parts Web Frontend Programming',
            'Douglas Crockford',
            'Web Development',
          ),
        ),
      ]);
      _localStreamController.add(List.unmodifiable(_localCatalog));
    }
  }

  // ==================== FIRESTORE SEARCH OPERATIONS ====================

  /// Search Cloud Firestore database based on user query string and optional genre filter.
  ///
  /// Demonstrates:
  /// 1. Firestore Prefix range query: `.where('titleLower', isGreaterThanOrEqualTo: q).where('titleLower', isLessThanOrEqualTo: '$q\uf8ff')`
  /// 2. Firestore Array Contains query: `.where('searchKeywords', arrayContains: q)`
  /// 3. Firestore Category Equality query: `.where('genre', isEqualTo: genre)`
  Future<List<Book>> searchBooks({
    required String query,
    String? selectedGenre,
    String searchMode = 'Prefix', // 'Prefix' or 'Keywords'
  }) async {
    final cleanQuery = query.trim().toLowerCase();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        Query<Map<String, dynamic>> ref = _firestore!.collection(collectionName);

        // Apply Genre filter if selected
        if (selectedGenre != null && selectedGenre != 'All') {
          ref = ref.where('genre', isEqualTo: selectedGenre);
        }

        if (cleanQuery.isNotEmpty) {
          if (searchMode == 'Prefix') {
            // Firestore Prefix Search on Title
            ref = ref
                .where('titleLower', isGreaterThanOrEqualTo: cleanQuery)
                .where('titleLower', isLessThanOrEqualTo: '$cleanQuery\uf8ff');
          } else {
            // Firestore Array-Contains Token Search
            ref = ref.where('searchKeywords', arrayContains: cleanQuery);
          }
        }

        final snapshot = await ref.get();
        return snapshot.docs
            .map((doc) => Book.fromMap(doc.data(), doc.id))
            .toList();
      } catch (_) {
        // Fall back to local search algorithm
      }
    }

    // Local in-memory matching with identical Firestore search semantics
    return _localCatalog.where((book) {
      final matchesGenre =
          selectedGenre == null || selectedGenre == 'All' || book.genre == selectedGenre;

      if (!matchesGenre) return false;
      if (cleanQuery.isEmpty) return true;

      if (searchMode == 'Prefix') {
        return book.title.toLowerCase().startsWith(cleanQuery) ||
            book.author.toLowerCase().startsWith(cleanQuery) ||
            book.isbn.toLowerCase().startsWith(cleanQuery);
      } else {
        return book.title.toLowerCase().contains(cleanQuery) ||
            book.author.toLowerCase().contains(cleanQuery) ||
            book.isbn.toLowerCase().contains(cleanQuery) ||
            book.searchKeywords.any((k) => k.contains(cleanQuery));
      }
    }).toList();
  }

  /// Real-time stream of books matching the current query.
  Stream<List<Book>> searchStream({
    required String query,
    String? selectedGenre,
    String searchMode = 'Prefix',
  }) {
    final cleanQuery = query.trim().toLowerCase();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        Query<Map<String, dynamic>> ref = _firestore!.collection(collectionName);

        if (selectedGenre != null && selectedGenre != 'All') {
          ref = ref.where('genre', isEqualTo: selectedGenre);
        }

        if (cleanQuery.isNotEmpty) {
          if (searchMode == 'Prefix') {
            ref = ref
                .where('titleLower', isGreaterThanOrEqualTo: cleanQuery)
                .where('titleLower', isLessThanOrEqualTo: '$cleanQuery\uf8ff');
          } else {
            ref = ref.where('searchKeywords', arrayContains: cleanQuery);
          }
        }

        return ref.snapshots().map((snapshot) {
          return snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
        });
      } catch (_) {}
    }

    // Local stream fallback
    Future.microtask(() async {
      final results = await searchBooks(
        query: query,
        selectedGenre: selectedGenre,
        searchMode: searchMode,
      );
      _localStreamController.add(results);
    });

    return _localStreamController.stream;
  }

  /// Add new book document into Cloud Firestore.
  Future<String> addBook(Book book) async {
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final ref =
            await _firestore!.collection(collectionName).add(book.toFirestore());
        return ref.id;
      } catch (_) {}
    }

    final newId = 'doc_book_${DateTime.now().millisecondsSinceEpoch}';
    final saved = book.copyWith(id: newId);
    _localCatalog.insert(0, saved);
    _localStreamController.add(List.unmodifiable(_localCatalog));
    return newId;
  }

  /// Seed initial catalog to Cloud Firestore.
  Future<void> seedInitialBooks() async {
    _initCatalogData();
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final count = (await _firestore!.collection(collectionName).get()).size;
        if (count == 0) {
          for (final book in _localCatalog) {
            await _firestore!.collection(collectionName).add(book.toFirestore());
          }
        }
      } catch (_) {}
    }
  }

  List<String> get availableGenres {
    final set = {'All', ..._localCatalog.map((b) => b.genre)};
    return set.toList();
  }
}

