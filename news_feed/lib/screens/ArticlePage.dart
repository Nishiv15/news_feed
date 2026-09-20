import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../widgets/NewsFeedNavbar.dart';
import '../widgets/NewsFeedFooter.dart';
import '../widgets/article_header_widget.dart';
import '../widgets/article_content_widget.dart';
import '../widgets/article_action_buttons.dart';

class ArticlePage extends StatelessWidget {
  final NewsItem article;

  const ArticlePage({super.key, required this.article});

  /// Factory constructor to construct ArticlePage directly from a JSON map response
  factory ArticlePage.fromJson(Map<String, dynamic> json) {
    return ArticlePage(
      article: NewsItem(
        title: json['title'] ?? 'Untitled Article',
        description: json['description'] ?? '',
        content: json['content'] ?? '',
        url: json['url'] ?? '#',
        imageUrl: (json['image'] != null && json['image'].toString().isNotEmpty)
            ? json['image']
            : placeholderImageUrl,
        sourceName: json['source']?['name'] ?? 'Unknown Source',
        publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      ),
    );
  }

  static const Color _bg = Color(0xFFF7F4EF);
  static const Color _bgDark = Color(0xFF121218);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 600 ? 14.0 : 24.0;

    return Scaffold(
      backgroundColor: isDark ? _bgDark : _bg,
      appBar: const NewsFeedNavBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header (Image, source badge, bookmark button, date)
                      ArticleHeaderWidget(article: article),

                      const SizedBox(height: 28),

                      // Content (Title, read time, lead description callout, body content)
                      ArticleContentWidget(article: article),

                      const SizedBox(height: 32),

                      Divider(
                        color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFDDD8D0),
                        height: 1,
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons (AI Summary & Read Original Article)
                      ArticleActionButtons(article: article),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Footer
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FooterWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
