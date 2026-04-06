import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../models/gemini_service.dart';

void showAISummaryPanel(BuildContext context, NewsItem article) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "AISummaryPanel",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width > 400 ? 350 : MediaQuery.of(context).size.width * 0.85,
            height: double.infinity,
            color: Colors.white,
            child: AISummaryContentView(article: article),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Starts off screen from the right
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}

class AISummaryContentView extends StatefulWidget {
  final NewsItem article;
  const AISummaryContentView({super.key, required this.article});

  @override
  State<AISummaryContentView> createState() => _AISummaryContentViewState();
}

class _AISummaryContentViewState extends State<AISummaryContentView> {
  String? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    final summary = await GeminiService.generateSummary(
      title: widget.article.title, 
      description: widget.article.description,
    );
    if (mounted) {
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'AI Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Divider(height: 30),
                  const Text(
                    'Brief Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Analyzing article data...'),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      _summary ?? 'No summary available.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
