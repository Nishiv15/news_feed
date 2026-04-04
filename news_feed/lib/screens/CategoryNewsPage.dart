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
  final int _maxArticles = 10; 

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    if (_articles.isNotEmpty || !_isLoading) {
      setState(() => _isLoading = true);
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewsFeedNavBar(currentCategory: widget.pageTitle),
      body: _isLoading && _articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? const Center(
              child: Text('Failed to load news. Please check API key/limits.'),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Text(
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
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 450,
                        childAspectRatio: MediaQuery.of(context).size.width < 600 ? 1.2 : 1.6,
                        crossAxisSpacing: 27,
                        mainAxisSpacing: 30,
                      ),
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        return NewsCardWidget(article: _articles[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 70),
                ],
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
