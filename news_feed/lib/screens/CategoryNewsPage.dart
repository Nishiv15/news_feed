import 'package:flutter/material.dart';
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

class _CategoryNewsPageState extends State<CategoryNewsPage>
    with SingleTickerProviderStateMixin {
  List<NewsItem> _articles = [];
  bool _isLoading = true;
  bool _hasError = false;
  final int _maxArticles = 10;

  late AnimationController _shimmerController;

  static const Color _bg = Color(0xFFF7F4EF);
  static const Color _ink = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFFD6472B);

  static const Map<String, _CategoryMeta> _categoryMeta = {
    'business':    _CategoryMeta(Color(0xFF1A3A5C), Color(0xFF2D6EA8), Icons.business_center_outlined),
    'entertainment': _CategoryMeta(Color(0xFF5C1A3A), Color(0xFFA82D6E), Icons.movie_filter_outlined),
    'general':     _CategoryMeta(Color(0xFF1A1A2E), Color(0xFF3A3A6E), Icons.public_outlined),
    'health':      _CategoryMeta(Color(0xFF1A5C2E), Color(0xFF2DA84B), Icons.favorite_outline),
    'science':     _CategoryMeta(Color(0xFF3A1A5C), Color(0xFF6E2DA8), Icons.science_outlined),
    'sports':      _CategoryMeta(Color(0xFF5C2E1A), Color(0xFFA84B2D), Icons.sports_soccer_outlined),
    'technology':  _CategoryMeta(Color(0xFF0D3D3D), Color(0xFF0D7777), Icons.memory_outlined),
  };

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _loadArticles();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
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

  Widget _buildCategoryBanner(_CategoryMeta meta) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [meta.colorDark, meta.colorLight],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(meta.icon, color: Colors.white.withOpacity(0.25), size: 80),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pageTitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.pageTitle} News',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                if (!_isLoading && !_hasError && _articles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Text(
                      '${_articles.length} articles',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Headlines',
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(height: 1, color: const Color(0xFFDDD8D0)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = _categoryMeta[widget.apiCategory.toLowerCase()] ??
        const _CategoryMeta(Color(0xFF1A1A2E), Color(0xFF3A3A6E), Icons.article_outlined);

    return Scaffold(
      appBar: NewsFeedNavBar(currentCategory: widget.pageTitle),
      backgroundColor: _bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCategoryBanner(meta),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDivider(),

                    if (_isLoading && _articles.isEmpty)
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
                    else if (_hasError)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: _ErrorBanner(
                            message:
                                'Failed to load news. Please check your connection or API limits.'),
                      )
                    else if (_articles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: _ErrorBanner(message: 'No articles available right now.'),
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


class _CategoryMeta {
  final Color colorDark;
  final Color colorLight;
  final IconData icon;
  const _CategoryMeta(this.colorDark, this.colorLight, this.icon);
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
