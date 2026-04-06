import 'package:flutter/material.dart';
import '../widgets/NewsFeedNavbar.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';
import '../widgets/heroSection.dart';
import '../widgets/news_card_widget.dart';
import '../widgets/NewsFeedFooter.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  final Map<String, String> sectionTitles = const {
    'general': 'Latest Headlines',
    'world': 'World',
    // 'nation': 'Nation',
    // 'business': 'Business',
    // 'technology': 'Technology',
    // 'entertainment': 'Entertainment',
    // 'sports': 'Sports',
  };

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
            //HERO SECTION
            FutureBuilder<NewsItem?>(
              future: fetchHeroArticle(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: MediaQuery.of(context).size.height > 800 ? 500 : MediaQuery.of(context).size.height * 0.5,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Error loading Hero News: ${snapshot.error}'),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return HeroSectionWidget(newsItem: snapshot.data!);
                }
                return const SizedBox.shrink(); 
              },
            ),

            const SizedBox(height: 30),

            //MULTI-CATEGORY SECTIONS
            ...categories.asMap().entries.map((entry) {
              final int index = entry.key;
              final String category = entry.value;
              final String title = sectionTitles[category]!;

              Future<List<NewsItem>> throttledFuture = Future.delayed(
                Duration(milliseconds: 1200 + (index * 1200)),
                () => fetchArticlesByCategory(category),
              );

              return _buildNewsSection(
                context,
                future: throttledFuture, 
                title: title,
              );
            }).toList(),

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
    required Future<List<NewsItem>> future,
    required String title,
  }) {
    return FutureBuilder<List<NewsItem>>(
      future: future, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 250, 
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }

        final articles = snapshot.data ?? [];

        if (snapshot.hasError || articles.isEmpty) {
          String message = snapshot.hasError
              ? 'Error fetching data: ${snapshot.error.toString()}'
              : 'No articles returned by API or articles lack valid images.';

          return Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
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
              // Section Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Horizontal Article List
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: articles
                      .map((article) => NewsCardWidget(article: article))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
