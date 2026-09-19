import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';
import '../models/supabase_auth_service.dart';

class ArticleHeaderWidget extends StatefulWidget {
  final NewsItem article;

  const ArticleHeaderWidget({super.key, required this.article});

  @override
  State<ArticleHeaderWidget> createState() => _ArticleHeaderWidgetState();
}

class _ArticleHeaderWidgetState extends State<ArticleHeaderWidget> {
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkSavedState();
  }

  Future<void> _checkSavedState() async {
    final saved = await SupabaseAuthService.isArticleSaved(widget.article.url);
    if (mounted) {
      setState(() {
        _isSaved = saved;
      });
    }
  }

  Future<void> _toggleSave() async {
    if (_isSaving) return;
    final newSavedState = !_isSaved;

    setState(() {
      _isSaved = newSavedState;
      _isSaving = true;
    });

    final articleMap = {
      'title': widget.article.title,
      'description': widget.article.description,
      'url': widget.article.url,
      'imageUrl': widget.article.imageUrl,
    };

    try {
      await SupabaseAuthService.toggleSavedArticle(articleMap, newSavedState);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newSavedState
                  ? 'Article saved to your bookmarks!'
                  : 'Article removed from bookmarks.',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaved = !newSavedState;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM d, yyyy • h:mm a').format(widget.article.publishedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source & Date Header (Responsive Wrap prevents overflow on mobile)
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD6472B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD6472B).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.newspaper_rounded,
                    size: 14,
                    color: Color(0xFFD6472B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.article.sourceName.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFD6472B),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Hero Image Container with Widescreen 16:9 Aspect Ratio (Fits naturally on mobile & desktop)
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE5E7EB),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Image unavailable',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD6472B),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Subtle gradient overlay at bottom of image
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),

            // Bookmark Button Top Right
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _isSaved ? const Color(0xFFD6472B) : Colors.white,
                    size: 24,
                  ),
                  tooltip: _isSaved ? 'Remove bookmark' : 'Save article',
                  onPressed: _toggleSave,
                ),
              ),
            ),

            // Image Source Caption Badge Bottom Left
            Positioned(
              bottom: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Source: ${widget.article.sourceName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
