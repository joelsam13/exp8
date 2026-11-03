import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_search_service.dart';
import '../widgets/book_details_dialog.dart';
import '../widgets/book_result_card.dart';
import '../widgets/firestore_query_banner.dart';
import '../widgets/search_input_bar.dart';

/// Main interactive screen for searching information in Google Cloud Firestore.
class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedGenre = 'All';
  String _searchMode = 'Prefix'; // 'Prefix' or 'Keywords'

  final List<String> _genres = [
    'All',
    'Software Engineering',
    'Software Architecture',
    'Computer Science',
    'Distributed Systems',
    'Mobile Development',
    'Cloud & APIs',
    'Web Development',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final isbnController = TextEditingController(text: '978-013${DateTime.now().millisecond}000');
    final descController = TextEditingController();
    String dialogGenre = 'Software Engineering';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Document to Firestore'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Book Title *'),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author *'),
              ),
              TextField(
                controller: isbnController,
                decoration: const InputDecoration(labelText: 'ISBN'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                final newBook = Book(
                  isbn: isbnController.text.trim(),
                  title: titleController.text.trim(),
                  author: authorController.text.trim().isEmpty
                      ? 'Anonymous'
                      : authorController.text.trim(),
                  genre: dialogGenre,
                  publishYear: DateTime.now().year,
                  rating: 4.5,
                  description: descController.text.trim(),
                  searchKeywords: Book.generateKeywords(
                    titleController.text.trim(),
                    authorController.text.trim(),
                    dialogGenre,
                  ),
                );
                await FirestoreSearchService.instance.addBook(newBook);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Book added to Firestore! You can now search for it.'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              }
            },
            child: const Text('Save to Firestore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Firestore Search Engine',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            tooltip: 'Seed Firestore Library',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await FirestoreSearchService.instance.seedInitialBooks();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Initial library catalog seeded into Firestore!'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: FirestoreSearchService.instance.searchStream(
          query: _searchQuery,
          selectedGenre: _selectedGenre,
          searchMode: _searchMode,
        ),
        builder: (context, snapshot) {
          final results = snapshot.data ?? [];

          return Column(
            children: [
              // Search Input Box
              SearchInputBar(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),

              // Search Mode Toggle (Prefix vs Keywords)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Strategy: ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    ChoiceChip(
                      label: const Text('Prefix Range (.where >= / <=)'),
                      selected: _searchMode == 'Prefix',
                      selectedColor: Colors.teal[100],
                      onSelected: (val) {
                        if (val) setState(() => _searchMode = 'Prefix');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Keyword Array (arrayContains)'),
                      selected: _searchMode == 'Keywords',
                      selectedColor: Colors.teal[100],
                      onSelected: (val) {
                        if (val) setState(() => _searchMode = 'Keywords');
                      },
                    ),
                  ],
                ),
              ),

              // Active Firestore Query Code Banner
              FirestoreQueryBanner(
                query: _searchQuery,
                genre: _selectedGenre,
                searchMode: _searchMode,
                resultCount: results.length,
              ),

              // Genre Filter Horizontal Chips
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _genres.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final genre = _genres[index];
                    final isSelected = _selectedGenre == genre;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGenre = genre;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.teal[800] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.teal[800]! : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[800],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Search Results List
              Expanded(
                child: results.isEmpty
                    ? _buildNoResultsState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final book = results[index];
                          return BookResultCard(
                            book: book,
                            searchQuery: _searchQuery,
                            onTap: () => BookDetailsDialog.show(context, book),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBookDialog,
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.post_add),
        label: const Text(
          'Add Document',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No Documents in Selected Genre'
                  : 'No matches found for "$_searchQuery"',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with partial titles like "clean", "algorithm", "flutter", or switch the search strategy.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedGenre = 'All';
                });
              },
              child: const Text('Reset Search Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
