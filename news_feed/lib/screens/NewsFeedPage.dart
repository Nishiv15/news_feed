import 'package:flutter/material.dart';
import '../widgets/NewsFeedNavbar.dart';
import '../models/news_model.dart';
import '../widgets/heroSection.dart';
import '../widgets/news_card_widget.dart';
import '../widgets/NewsFeedFooter.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage>
    with SingleTickerProviderStateMixin {
  NewsItem? _heroArticle;
  String? _heroError;
  bool _isHeroLoading = true;

  List<NewsItem> _generalArticles = [];
  String? _generalError;
  bool _isGeneralLoading = true;

  int _currentPage = 1;
  bool _isLoadingMore = false;

  late AnimationController _shimmerController;

  static const Color _bg = Color(0xFFF7F4EF);
  static const Color _accent = Color(0xFFD6472B);
  static const Color _ink = Color(0xFF1A1A2E);
  static const Color _muted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _loadNews();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    // Fetch Hero
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

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final moreArticles = await fetchCategory('general', max: 10, page: nextPage);
      if (mounted && moreArticles.isNotEmpty) {
        setState(() {
          _generalArticles.addAll(moreArticles);
          _currentPage = nextPage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load more articles: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // Shimmer skeleton 
  Widget _buildShimmerBlock({double height = 20, double? width, double radius = 6}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _shimmerController.value * 3, 0),
              end: Alignment(0.5 + _shimmerController.value * 3, 0),
              colors: const [
                Color(0xFFE0DDD8),
                Color(0xFFF0ECE6),
                Color(0xFFE0DDD8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSkeleton(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildShimmerBlock(
          height: h > 800 ? 520 : h * 0.52,
          radius: 20,
        ),
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _buildShimmerBlock(height: 160, radius: 0),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBlock(height: 14),
                const SizedBox(height: 8),
                _buildShimmerBlock(height: 14, width: 140),
                const SizedBox(height: 12),
                _buildShimmerBlock(height: 11, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section header 
  Widget _buildSectionHeader(String label, {bool live = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _ink,
              letterSpacing: -0.5,
            ),
          ),
          if (live) ...[
            const SizedBox(width: 10),
            _LiveBadge(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NewsFeedNavBar(),
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // HERO 
                    const SizedBox(height: 20),
                    if (_isHeroLoading)
                      _buildHeroSkeleton(context)
                    else if (_heroError != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _ErrorBanner(message: 'Could not load top story.'),
                      )
                    else if (_heroArticle != null)
                      HeroSectionWidget(newsItem: _heroArticle!)
                    else
                      const SizedBox.shrink(),

                    // LATEST HEADLINES 
                    _buildSectionHeader('Latest Headlines', live: true),

                    const _SectionDivider(),

                    if (_isGeneralLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 450,
                            mainAxisExtent: 310,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: 6,
                          itemBuilder: (_, __) => _buildCardSkeleton(),
                        ),
                      )
                    else if (_generalError != null || _generalArticles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _ErrorBanner(
                          message: _generalError != null
                              ? 'Error fetching headlines: $_generalError'
                              : 'No articles available right now.',
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 450,
                            mainAxisExtent: 320,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: _generalArticles.length,
                          itemBuilder: (context, index) {
                            return NewsCardWidget(
                              article: _generalArticles[index],
                            );
                          },
                        ),
                      ),

                    // Load More button
                    if (!_isGeneralLoading && _generalError == null && _generalArticles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
                        child: Center(
                          child: SizedBox(
                            width: 220,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingMore ? null : _loadMoreNews,
                              icon: _isLoadingMore
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.expand_more_rounded, size: 22),
                              label: Text(
                                _isLoadingMore ? 'Loading...' : 'Load More',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _ink,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _ink.withOpacity(0.5),
                                disabledForegroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
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

// Reusable helpers 

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFD6472B),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Container(height: 1, color: const Color(0xFFDDD8D0)),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6472B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD6472B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7A2A1A),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
