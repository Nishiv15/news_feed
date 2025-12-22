// lib/category_news_page.dart
// This page handles the view for any single category (World, Sports, Tech, etc.)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';
import '../widgets/news_card_widget.dart';
import '../widgets/NewsFeedFooter.dart';
import '../widgets/NewsFeedNavbar.dart';

class CategoryNewsPage extends StatefulWidget {
  final String apiCategory;
  final String pageTitle;

  const CategoryNewsPage({
    super.key,
    required this.apiCategory,
    required this.pageTitle,
  });

  @override
  State<CategoryNewsPage> createState() => _CategoryNewsPageState();
}

class _CategoryNewsPageState extends State<CategoryNewsPage> {
  List<NewsItem> _articles = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _maxArticles = 10; // Initial number of articles to load
  final int _loadIncrement = 5; // How many more articles to load each time
  final int _maxLimit = 50; // GNews API max limit

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  // Reloads articles whenever the page is pushed/re-initialized
  Future<void> _loadArticles() async {
    // Only show loading indicator if we are performing a new load (not initial state)
    // The build method handles the initial loading screen when _articles is empty.
    if (_articles.isNotEmpty || !_isLoading) {
      setState(() => _isLoading = true);
    }

    // DEBUG: Check what max value is being used for the API call
    debugPrint(
      'DEBUG: Calling API for category ${widget.apiCategory} with max: $_maxArticles',
    );

    try {
      final newArticles = await fetchCategory(
        widget.apiCategory,
        max: _maxArticles,
      );

      setState(() {
        _articles = newArticles;
        _isLoading = false;
        _hasError = false;
        // DEBUG: Confirm the number of articles received
        debugPrint(
          'DEBUG: API call success. Received ${newArticles.length} articles.',
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      debugPrint('Error loading ${widget.pageTitle} news: $e');
    }
  }

  // Logic to load more articles
  void _loadMoreArticles() {
    if (_maxArticles < _maxLimit) {
      // DEBUG: Confirm load more is triggered and the max is incremented
      debugPrint('DEBUG: Load More triggered. Current max: $_maxArticles');

      _maxArticles = (_maxArticles + _loadIncrement).clamp(0, _maxLimit);
      _loadArticles();
    } else {
      debugPrint('DEBUG: Max limit of $_maxLimit reached. Cannot load more.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pass the pageTitle to the navbar to highlight the active category
      appBar: NewsFeedNavBar(currentCategory: widget.pageTitle),
      body: _isLoading && _articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? const Center(
              child: Text('Failed to load news. Please check API key/limits.'),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Text(
                      // This text dynamically shows "World Headlines"
                      '${widget.pageTitle} Headlines',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),

                  // Responsive Grid View
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 900
                            ? 3
                            : MediaQuery.of(context).size.width > 600
                            ? 2
                            : 1,
                        // UPDATED: Aspect ratio set to 2.0 to make the card significantly shorter.
                        childAspectRatio: 2.0,
                        // UPDATED: Increased spacing to 30 to slightly reduce the card width further.
                        crossAxisSpacing: 27,
                        mainAxisSpacing: 30,
                      ),
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        return NewsCardWidget(article: _articles[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Load More Button
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: _articles.isEmpty
                          ? const SizedBox.shrink()
                          : _articles.length >= _maxLimit
                          ? const Text(
                              'You have reached the maximum number of articles (50).',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: _isLoading ? null : _loadMoreArticles,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_downward,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                _isLoading ? 'Loading...' : 'Load More News',
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A2E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                            ),
                    ),
                  ),

                  const FooterWidget(),
                ],
              ),
            ),
    );
  }
}
