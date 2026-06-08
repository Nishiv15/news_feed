import 'dart:convert';
import 'package:http/http.dart' as http;
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

Future<NewsItem?> fetchHeroArticle() async {
  final apiKey = await SecretsService.gnewsApiKey;
  final baseUrl = await SecretsService.gnewsBaseUrl;
  final corsProxy = await SecretsService.corsProxy;

  if (apiKey.isEmpty || baseUrl.isEmpty) return null;

  final gnewsUrl =
      '${baseUrl}top-headlines?category=general&lang=en&country=$globalCountry&max=1&apikey=$apiKey';
  final url = Uri.parse(
    corsProxy.isNotEmpty ? '$corsProxy${Uri.encodeComponent(gnewsUrl)}' : gnewsUrl,
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data['articles'] as List;

      if (articles.isNotEmpty) {
        return await NewsItem.fromJsonAsync(articles.first);
      }
    } else {
      throw Exception(
        'Failed to load hero article: Status ${response.statusCode}',
      );
    }
  } catch (_) {}
  return null;
}

Future<List<NewsItem>> fetchCategory(String category, {int max = 10, int page = 1}) async {
  final apiKey = await SecretsService.gnewsApiKey;
  final baseUrl = await SecretsService.gnewsBaseUrl;
  final corsProxy = await SecretsService.corsProxy;

  if (apiKey.isEmpty || baseUrl.isEmpty) return [];

  final gnewsUrl =
      '${baseUrl}top-headlines?category=$category&lang=en&country=$globalCountry&max=$max&page=$page&apikey=$apiKey';
  final url = Uri.parse(
    corsProxy.isNotEmpty ? '$corsProxy${Uri.encodeComponent(gnewsUrl)}' : gnewsUrl,
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data['articles'] as List;

      final List<NewsItem> newsItems = await Future.wait(
        articles.map((json) => NewsItem.fromJsonAsync(json)),
      );
      return newsItems;
    } else {
      throw Exception(
        'Failed to load $category news: Status ${response.statusCode}',
      );
    }
  } catch (_) {}
  return [];
}
