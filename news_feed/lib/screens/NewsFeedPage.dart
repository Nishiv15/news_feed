import 'package:flutter/material.dart';
import '../widgets/NewsFeedNavbar.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';
import '../widgets/heroSection.dart';
import '../widgets/news_card_widget.dart';
import '../widgets/NewsFeedFooter.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final Map<String, String> sectionTitles = const {
    'general': 'Latest Headlines',
    'world': 'World',
    'nation': 'Nation',
    'business': 'Business',
    'technology': 'Technology',
    'entertainment': 'Entertainment',
    'sports': 'Sports',
  };

  NewsItem? _heroArticle;
  String? _heroError;
  bool _isHeroLoading = true;

  Map<String, List<NewsItem>> _categoryArticles = {};
  Map<String, String> _categoryErrors = {};
  Map<String, bool> _categoryLoading = {};

  @override
  void initState() {
    super.initState();
    for (var key in sectionTitles.keys) {
      _categoryLoading[key] = true;
    }
    _loadAllNewsSequentially();
  }

  Future<void> _loadAllNewsSequentially() async {
    try {
      final hero = await fetchHeroArticle();
      if (mounted) {
        setState(() {
          _heroArticle = hero;
          _isHeroLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _heroError = e.toString();
          _isHeroLoading = false;
        });
      }
    }

    for (var entry in sectionTitles.entries) {
      final category = entry.key;
      
      await Future.delayed(const Duration(milliseconds: 2000));
      
      try {
        final articles = await fetchArticlesByCategory(category);
        if (mounted) {
          setState(() {
            _categoryArticles[category] = articles;
            _categoryLoading[category] = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _categoryErrors[category] = e.toString();
            _categoryLoading[category] = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = sectionTitles.keys.toList();

    return Scaffold(
      appBar: const NewsFeedNavBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // HERO SECTION
                    if (_isHeroLoading)
                      Container(
                        height: MediaQuery.of(context).size.height > 800 ? 500 : MediaQuery.of(context).size.height * 0.5,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (_heroError != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: Text('Error loading Hero News: $_heroError')),
                      )
                    else if (_heroArticle != null)
                      HeroSectionWidget(newsItem: _heroArticle!)
                    else
                      const SizedBox.shrink(),

                    const SizedBox(height: 30),

                    // MULTI-CATEGORY SECTIONS
                    ...categories.map((category) {
                      final String title = sectionTitles[category]!;
                      return _buildNewsSection(
                        context,
                        category: category, 
                        title: title,
                      );
                    }),

                    const SizedBox(height: 40),
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

  Widget _buildNewsSection(
    BuildContext context, {
    required String category,
    required String title,
  }) {
    final isLoading = _categoryLoading[category] ?? true;
    final error = _categoryErrors[category];
    final articles = _categoryArticles[category] ?? [];

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    if (error != null || articles.isEmpty) {
      String message = error != null
          ? 'Error fetching data: $error'
          : 'No articles returned by API or articles lack valid images.';

      return Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(message, style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: articles.map((article) => NewsCardWidget(article: article)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
