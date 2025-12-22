// lib/footer_widget.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for basic responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 30,
      ),
      color: const Color(0xFF1A1A2E), // Deep Blue color for a professional footer
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. App Logo/Title
          const Text(
            'NewsFeed',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // 2. Main Content (Links and Social)
          isMobile ? _buildMobileLayout() : _buildDesktopLayout(),

          const Divider(height: 40, color: Colors.white30),

          // 3. Copyright
          Center(
            child: Text(
              '© ${DateTime.now().year} NewsFeed. All rights reserved.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Layout for wide screens
  Widget _buildDesktopLayout() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _LinkColumn(title: 'Company', links: ['About Us', 'Careers', 'Contact']),
        _LinkColumn(title: 'Legal', links: ['Privacy Policy', 'Terms of Use', 'Disclaimer']),
        _LinkColumn(title: 'Support', links: ['FAQ', 'Help Center', 'Accessibility']),
        _SocialIcons(),
      ],
    );
  }

  // Layout for narrow/mobile screens
  Widget _buildMobileLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _LinkColumn(title: 'Company', links: ['About Us', 'Careers', 'Contact'])),
            SizedBox(width: 20),
            Expanded(child: _LinkColumn(title: 'Legal', links: ['Privacy Policy', 'Terms of Use', 'Disclaimer'])),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _LinkColumn(title: 'Support', links: ['FAQ', 'Help Center', 'Accessibility'])),
            SizedBox(width: 20),
            Expanded(child: _SocialIcons(isMobile: true)),
          ],
        ),
      ],
    );
  }
}

// Helper Widget for Link Columns
class _LinkColumn extends StatelessWidget {
  final String title;
  final List<String> links;

  const _LinkColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () {
              // Placeholder: In a real app, this would navigate to a new route.
              debugPrint('Navigating to $link');
            },
            child: Text(
              link,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }
}

// Helper Widget for Social Media Icons
class _SocialIcons extends StatelessWidget {
  final bool isMobile;

  const _SocialIcons({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    // Using built-in Material Icons for compatibility
    final socialIcons = [
      {'icon': Icons.facebook, 'url': 'https://facebook.com/NewsFeed'},
      {'icon': Icons.public, 'url': 'https://twitter.com/NewsFeed'},
      {'icon': Icons.video_library, 'url': 'https://youtube.com/NewsFeed'},
      {'icon': Icons.link, 'url': 'https://linkedin.com/company/NewsFeed'},
    ];

    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        const Text(
          'Connect',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
          children: socialIcons.map((item) {
            return Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: () async {
                  final url = Uri.parse(item['url'] as String);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    debugPrint('Could not launch ${item['url']}');
                  }
                },
                child: Icon(
                  item['icon'] as IconData,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}