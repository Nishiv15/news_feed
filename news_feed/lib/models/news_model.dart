import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secrets_service.dart';

const int maxArticles = 10;

String globalCountry = 'us';

const String placeholderImageUrl =
    'https://placehold.co/600x400/CCCCCC/666666?text=Image+Unavailable';

class NewsItem {
  final String title;
  final String description;
  final String content;
  final String url;
  final String imageUrl;
  final String sourceName;
  final DateTime publishedAt;

  NewsItem({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  static Future<NewsItem> fromJsonAsync(Map<String, dynamic> json) async {
    final corsProxy = await SecretsService.corsProxy;
    String imageUrl = json['image'] ?? '';

    if (imageUrl.isEmpty || imageUrl == 'None') {
      imageUrl = placeholderImageUrl;
    } else if (!imageUrl.contains('placehold.co')) {
      try {
        final encodedUrl = Uri.encodeComponent(imageUrl);
        imageUrl = '$corsProxy$encodedUrl';
      } catch (_) {
        imageUrl = placeholderImageUrl;
      }
    }

    return NewsItem(
      title: json['title'] ?? 'Untitled Article',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '#',
      imageUrl: imageUrl,
      sourceName: json['source']?['name'] ?? 'Unknown Source',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

Future<Map<String, dynamic>?> _fetchViaEdgeFunction({
  required String category,
  required int max,
  int page = 1,
}) async {
  try {
    final response = await Supabase.instance.client.functions.invoke(
      'fetch-news',
      body: {
        'category': category,
        'country': globalCountry,
        'max': max,
        'page': page,
      },
    );
    return response.data as Map<String, dynamic>?;
  } catch (_) {
    return null;
  }
}

Future<NewsItem?> fetchHeroArticle() async {
  final data = await _fetchViaEdgeFunction(category: 'general', max: 1);
  if (data == null) return null;

  try {
    final articles = data['articles'] as List;
    if (articles.isNotEmpty) {
      return await NewsItem.fromJsonAsync(articles.first);
    }
  } catch (_) {}
  return null;
}

Future<List<NewsItem>> fetchCategory(String category, {int max = 10, int page = 1}) async {
  final data = await _fetchViaEdgeFunction(category: category, max: max, page: page);
  if (data == null) return [];

  try {
    final articles = data['articles'] as List;
    final List<NewsItem> newsItems = await Future.wait(
      articles.map((json) => NewsItem.fromJsonAsync(json as Map<String, dynamic>)),
    );
    return newsItems;
  } catch (_) {}
  return [];
}
