import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['apikey'] ?? '';
String baseUrl = dotenv.env['baseurl'] ?? '';
const int maxArticles = 10; 

const String placeholderImageUrl =
    'https://placehold.co/600x400/CCCCCC/666666?text=Image+Unavailable';

String corsProxyBaseUrl = dotenv.env['corsproxy'] ?? '';

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

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';

    if (imageUrl.isEmpty || imageUrl == 'None') {
      imageUrl = placeholderImageUrl;
    }
    else if (!imageUrl.contains('placehold.co')) {
      try {
        final encodedUrl = Uri.encodeComponent(imageUrl);
        imageUrl = '$corsProxyBaseUrl$encodedUrl';
      } catch (e) {
        if (kDebugMode) {
          print('Error processing URL for CORS proxy: $e');
        }
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
  final url = Uri.parse(
    '${baseUrl}top-headlines?category=general&lang=en&country=us&max=1&apikey=$apiKey',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data['articles'] as List;

      if (articles.isNotEmpty) {
        return NewsItem.fromJson(articles.first);
      }
    } else {
      if (kDebugMode) {
        print('Hero API Request failed with status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
      throw Exception(
        'Failed to load hero article: Status ${response.statusCode}',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error during Hero API fetch: $e');
    }
  }
  return null; 
}

Future<List<NewsItem>> fetchArticlesByCategory(String category) async {
  final url = Uri.parse(
    '${baseUrl}top-headlines?category=$category&lang=en&country=us&max=$maxArticles&apikey=$apiKey',
  );

  try {
    if (kDebugMode) {
      print('Fetching articles for category: $category');
    }

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data['articles'] as List;

      List<NewsItem> newsItems = articles
          .map((json) => NewsItem.fromJson(json))
          .toList();
      return newsItems;
    } else {
      if (kDebugMode) {
        print(
          'Category API Request failed for $category with status: ${response.statusCode}',
        );
        print('Response Body: ${response.body}');
      }
      throw Exception(
        'Failed to load $category news: Status ${response.statusCode}',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error during $category API fetch: $e');
    }
  }
  return []; 
}

Future<List<NewsItem>> fetchCategory(String category, {int max = 10}) async {
  final url = Uri.parse(
    '${baseUrl}top-headlines?category=$category&lang=en&country=us&max=$max&apikey=$apiKey',
  );

  try {
    if (kDebugMode) {
      print('Fetching articles for category: $category with max=$max');
    }

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data['articles'] as List;

      List<NewsItem> newsItems = articles
          .map((json) => NewsItem.fromJson(json))
          .toList();
      return newsItems;
    } else {
      if (kDebugMode) {
        print(
          'Category API Request failed for $category with status: ${response.statusCode}',
        );
      }
      throw Exception(
        'Failed to load $category news: Status ${response.statusCode}',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error during $category API fetch: $e');
    }
  }
  return [];
}
