import 'package:flutter/material.dart';
import '../models/news_model.dart';

class ArticleContentWidget extends StatelessWidget {
  final NewsItem article;

  const ArticleContentWidget({super.key, required this.article});

  int _estimateReadTime(String text) {
    final wordCount = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final minutes = (wordCount / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final combinedText = '${article.description} ${article.content}';
    final readTime = _estimateReadTime(combinedText);

    // Parse content text to separate potential `... [XXXX chars]` suffix cleanly
    String cleanContent = article.content.trim();
    String? charsRemainingNotice;

    final regex = RegExp(r'(\s*\.\.\.\s*\[\s*\d+\s*chars\s*\])$', caseSensitive: false);
    final match = regex.firstMatch(cleanContent);
    if (match != null) {
      charsRemainingNotice = match.group(0)?.trim();
      cleanContent = cleanContent.substring(0, match.start).trim();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Responsive Title
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Text(
              article.title,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1A2E),
                height: 1.25,
                letterSpacing: -0.5,
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // Read time & stats row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$readTime min read',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Description Lead Callout Box
        if (article.description.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0ECE6),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(
                  color: Color(0xFFD6472B),
                  width: 4,
                ),
              ),
            ),
            child: Text(
              article.description,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: Color(0xFF2C2C3E),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Article Content Body
        if (cleanContent.isNotEmpty) ...[
          Text(
            cleanContent,
            style: const TextStyle(
              fontSize: 17,
              height: 1.7,
              color: Color(0xFF2D2D3F),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Suffix notice if content was truncated by news API
        if (charsRemainingNotice != null && charsRemainingNotice.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFF97316).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFEA580C),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Full story continues at publisher source ($charsRemainingNotice). Use the button below to read the complete article.',
                    style: const TextStyle(
                      color: Color(0xFF9A3412),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
