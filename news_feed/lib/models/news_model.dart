// lib/news_model.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- IMPORTANT: Replace this with your actual GNews API Key ---
String apiKey = dotenv.env['apikey'] ?? '';
String baseUrl = dotenv.env['baseurl'] ?? '';
const int maxArticles = 10; // Request up to 10 articles per category

// Placeholder URL used if an article image is missing or for broken links
const String placeholderImageUrl =
    'https://placehold.co/600x400/CCCCCC/666666?text=Image+Unavailable';

// CORS Proxy Base URL - Used to bypass cross-origin restrictions on external images.
// Switching to images.weserv.nl, which is highly reliable for image serving and CORS bypassing.
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

  // Factory constructor to create a NewsItem from JSON
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';

    // If image URL is missing, null, or a known bad value like 'None', use the reliable placeholder.
    if (imageUrl.isEmpty || imageUrl == 'None') {
      imageUrl = placeholderImageUrl;
    }
    // If the image URL is a valid external link (not our placeholder), apply the CORS proxy.
    else if (!imageUrl.contains('placehold.co')) {
      try {
        // Use the images.weserv.nl format: [proxy_base_url] + URL encoded original URL
        // Encoding is crucial for complex URLs with parameters.
        final encodedUrl = Uri.encodeComponent(imageUrl);
        imageUrl = '$corsProxyBaseUrl$encodedUrl';
      } catch (e) {
        if (kDebugMode) {
          print('Error processing URL for CORS proxy: $e');
        }
        // Fallback to placeholder if processing fails
        imageUrl = placeholderImageUrl;
      }
    }

    return NewsItem(
      title: json['title'] ?? 'Untitled Article',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '#',
      imageUrl: imageUrl, // Use the proxied or placeholder image URL
      sourceName: json['source']?['name'] ?? 'Unknown Source',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// Fetches a single article for the Hero Section (usually a top headline)
Future<NewsItem?> fetchHeroArticle() async {
  // Use 'top-headlines' endpoint for the hero article
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
  return null; // Return null on failure
}

// Fetches a list of articles for a specific category
Future<List<NewsItem>> fetchArticlesByCategory(String category) async {
  // Use the 'top-headlines' endpoint
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
  return []; // Return an empty list on failure
}

Future<List<NewsItem>> fetchCategory(String category, {int max = 10}) async {
  // Use the 'top-headlines' endpoint
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
  return []; // Return an empty list on failure
}
