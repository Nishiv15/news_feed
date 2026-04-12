import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../models/supabase_auth_service.dart';
import '../widgets/news_card_widget.dart';
import '../widgets/NewsFeedFooter.dart';
import '../widgets/NewsFeedNavbar.dart';

class SavedArticlesPage extends StatefulWidget {
  const SavedArticlesPage({super.key});

  @override
  State<SavedArticlesPage> createState() => _SavedArticlesPageState();
}

class _SavedArticlesPageState extends State<SavedArticlesPage> {
  List<NewsItem> _savedArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPersistedBookmarks();
  }

  Future<void> _fetchPersistedBookmarks() async {
    try {
      final rawArticles = await SupabaseAuthService.fetchSavedArticles();
      final loadedArticles = rawArticles.map((json) {
        return NewsItem(
          title: json['title'] ?? 'Untitled',
          description: json['description'] ?? '',
          content: json['content'] ?? '',
          url: json['url'] ?? '#',
          imageUrl: json['imageUrl'] ?? placeholderImageUrl,
          sourceName: json['sourceName'] ?? 'Saved Article',
          publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _savedArticles = loadedArticles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch saved articles: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removeArticleFromView(String url) {
    setState(() {
      _savedArticles.removeWhere((article) => article.url == url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const NewsFeedNavBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                            child: Text(
                              'My Saved Articles',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),

                          _savedArticles.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Center(
                                    child: Text(
                                      "You haven't saved any articles yet! Click the heart icon on any article to save it securely here.",
                                      style: TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 450,
                                      mainAxisExtent: 320,
                                      crossAxisSpacing: 27,
                                      mainAxisSpacing: 30,
                                    ),
                                    itemCount: _savedArticles.length,
                                    itemBuilder: (context, index) {
                                      final article = _savedArticles[index];
                                      return NewsCardWidget(
                                        article: article,
                                        onUnsave: () => _removeArticleFromView(article.url),
                                      );
                                    },
                                  ),
                                ),

                          const SizedBox(height: 70),
                        ],
                      ),
                    ),
                  ),
                ),
                
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
