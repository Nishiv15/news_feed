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
  NewsItem? _heroArticle;
  String? _heroError;
  bool _isHeroLoading = true;

  List<NewsItem> _generalArticles = [];
  String? _generalError;
  bool _isGeneralLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    // 1. Fetch Hero
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

    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final articles = await fetchCategory('general', max: 10);
      if (mounted) {
        setState(() {
          _generalArticles = articles;
          _isGeneralLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generalError = e.toString();
          _isGeneralLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NewsFeedNavBar(),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
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

                    // LATEST HEADLINES
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                      child: Text(
                        'Latest Headlines',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),

                    if (_isGeneralLoading)
                      const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()))
                    else if (_generalError != null || _generalArticles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _generalError != null 
                              ? 'Error fetching data: $_generalError'
                              : 'No articles returned by API or articles lack valid images.', 
                          style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic)
                        ),
                      )
                    else 
                      Padding(
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
                          itemCount: _generalArticles.length,
                          itemBuilder: (context, index) {
                            return NewsCardWidget(article: _generalArticles[index]);
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
