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

class SearchResult {
  final List<NewsItem> articles;
  final int totalArticles;

  SearchResult({required this.articles, required this.totalArticles});
}

Future<SearchResult> searchNewsWithResult(String query, {int max = 10, int page = 1}) async {
  final cleanQuery = query.trim();
  if (cleanQuery.isEmpty) return SearchResult(articles: [], totalArticles: 0);

  // 1. Attempt edge function with search query parameter
  try {
    final response = await Supabase.instance.client.functions.invoke(
      'fetch-news',
      body: {
        'q': cleanQuery,
        'query': cleanQuery,
        'country': globalCountry,
        'max': max,
        'page': page,
      },
    );
    final data = response.data as Map<String, dynamic>?;
    if (data != null && data['articles'] is List) {
      final articlesList = data['articles'] as List;
      final total = (data['totalArticles'] ?? data['totalResults'] ?? articlesList.length) as int;
      final List<NewsItem> newsItems = await Future.wait(
        articlesList.map((json) => NewsItem.fromJsonAsync(json as Map<String, dynamic>)),
      );
      return SearchResult(articles: newsItems, totalArticles: total);
    }
  } catch (_) {}

  // 2. Fallback to direct GNews API search if edge function doesn't return articles
  try {
    final apiKey = await SecretsService.gnewsApiKey;
    final baseUrl = await SecretsService.gnewsBaseUrl;
    if (apiKey.isNotEmpty) {
      final rootUrl = baseUrl.isNotEmpty
          ? baseUrl.replaceAll(RegExp(r'/(top-headlines|search)\??.*$'), '')
          : 'https://gnews.io/api/v4';
      final searchUri = Uri.parse(
        '$rootUrl/search?q=${Uri.encodeComponent(cleanQuery)}&country=$globalCountry&max=$max&page=$page&apikey=$apiKey',
      );
      final response = await http.get(searchUri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['articles'] is List) {
          final articlesList = data['articles'] as List;
          final total = (data['totalArticles'] ?? data['totalResults'] ?? articlesList.length) as int;
          final List<NewsItem> newsItems = await Future.wait(
            articlesList.map((json) => NewsItem.fromJsonAsync(json as Map<String, dynamic>)),
          );
          return SearchResult(articles: newsItems, totalArticles: total);
        }
      }
    }
  } catch (_) {}

  // 3. Fallback: filter general category articles locally
  try {
    final generalArticles = await fetchCategory('general', max: 30);
    final lowerQuery = cleanQuery.toLowerCase();
    final matched = generalArticles.where((article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
          article.description.toLowerCase().contains(lowerQuery) ||
          article.content.toLowerCase().contains(lowerQuery) ||
          article.sourceName.toLowerCase().contains(lowerQuery);
    }).toList();
    return SearchResult(articles: matched, totalArticles: matched.length);
  } catch (_) {}

  return SearchResult(articles: [], totalArticles: 0);
}

Future<List<NewsItem>> searchNews(String query, {int max = 10, int page = 1}) async {
  final result = await searchNewsWithResult(query, max: max, page: page);
  return result.articles;
}


