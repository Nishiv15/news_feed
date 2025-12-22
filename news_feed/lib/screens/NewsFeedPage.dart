import 'package:flutter/material.dart';
import '../widgets/NewsFeedNavbar.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';
import '../widgets/heroSection.dart';
import '../widgets/news_card_widget.dart';
import '../widgets/NewsFeedFooter.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  // Define the sections and their display titles
  // The list of categories remains the same (7 categories)
  final Map<String, String> sectionTitles = const {
    'general': 'Latest Headlines',
    // 'world': 'World',
    // 'nation': 'Nation',
    // 'business': 'Business',
    // 'technology': 'Technology',
    // 'entertainment': 'Entertainment',
    // 'sports': 'Sports',
  };

  @override
  Widget build(BuildContext context) {
    // Convert the keys to a list to use index for throttling
    final List<String> categories = sectionTitles.keys.toList();

    return Scaffold(
      appBar: const NewsFeedNavBar(),

      // Use a FutureBuilder only for the Hero Section
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- 1. HERO SECTION (Single Article) ---
            FutureBuilder<NewsItem?>(
              // START CHANGE: Add a small delay (100ms) to the hero request to prevent collision with the first category call.
              future: Future.delayed(
                const Duration(milliseconds: 100),
                fetchHeroArticle,
              ),
              // END CHANGE
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a temporary placeholder container while loading
                  return Container(
                    height: 700,
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
                return const SizedBox.shrink(); // Hide if no hero article is available
              },
            ),

            const SizedBox(height: 30),

            // --- 2. MULTI-CATEGORY SECTIONS (Throttled) ---
            // Loop through all predefined categories to build sections with a delay
            ...categories.asMap().entries.map((entry) {
              final int index = entry.key;
              final String category = entry.value;
              final String title = sectionTitles[category]!;

              // START CHANGE: Throttling Logic
              // Create a Future that waits for 500ms * index before executing the fetch.
              // This ensures requests are staggered (0ms, 500ms, 1000ms, 1500ms, etc.).
              Future<List<NewsItem>> throttledFuture = Future.delayed(
                Duration(milliseconds: index * 1000),
                () => fetchArticlesByCategory(category),
              );

              return _buildNewsSection(
                context,
                future: throttledFuture, // Pass the new throttled Future
                title: title,
              );
              // END CHANGE
            }).toList(),

            const SizedBox(height: 40),
            FooterWidget(),
          ],
        ),
      ),
    );
  }

  // Refactored widget to build a section.
  // The 'category' parameter is now removed and replaced by 'future'.
  Widget _buildNewsSection(
    BuildContext context, {
    required Future<List<NewsItem>> future,
    required String title,
  }) {
    return FutureBuilder<List<NewsItem>>(
      future: future, // Use the throttled future passed in
      builder: (context, snapshot) {
        // Handle loading state by showing a placeholder, but including the title
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Note: The UI for this will now stay in the loading state longer due to the deliberate delay.
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Title while loading
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 250, // Reduced height for better flow
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }

        final articles = snapshot.data ?? [];

        // Diagnostic check - show error/empty state instead of hiding the section entirely
        if (snapshot.hasError || articles.isEmpty) {
          String message = snapshot.hasError
              ? 'Error fetching data: ${snapshot.error.toString()}'
              // The API often returns 0 articles for a category. This message is more accurate now.
              : 'No articles returned by API or articles lack valid images.';

          // Show the section title with the error/empty message for debugging
          return Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title (still displayed, but dimmed to indicate an issue)
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
                // Error/Empty Message
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
        // END CHANGE

        // If data is available, build the full section
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
