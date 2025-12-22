// lib/navbar_widget.dart

import 'package:flutter/material.dart';
import '../screens/CategoryNewsPage.dart'; // Import the new generic page
import '../screens/NewsFeedPage.dart'; // Import NewsFeedPage (assuming it's here for navigation)

// This map holds the display name and the corresponding GNews API category key.
// 'Home' maps to 'general' primarily for consistent highlighting, but its navigation is handled separately.
const Map<String, String> categoryMap = {
  'Home': 'general',
  'World': 'world',
  'Politics':
      'nation', // GNews uses 'nation' for US/National news, which works for 'Politics' context
  'Business': 'business',
  'Technology': 'technology',
  'Sports': 'sports',
  'Entertainment': 'entertainment',
};

class NewsFeedNavBar extends StatelessWidget implements PreferredSizeWidget {
  // New optional parameter to indicate the currently active category (e.g., 'World', 'Home')
  final String? currentCategory;

  const NewsFeedNavBar({super.key, this.currentCategory});

  // Handles navigation for all categories
  void _handleCategoryTap(BuildContext context, String category) {
    // --- SPECIAL CASE: HOME ---
    if (category == 'Home') {
      // This correctly returns to the multi-section NewsFeedPage,
      // avoiding navigation to a single-category view.
      Navigator.popUntil(context, (route) => route.isFirst);
      // If we are already on the home page, the line above does nothing, so we ensure a navigation if needed.
      if (ModalRoute.of(context)?.settings.name != null &&
          ModalRoute.of(context)?.settings.name != '/') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NewsFeedPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
    // --- STANDARD CATEGORIES ---
    else {
      // Navigates to the single CategoryNewsPage for the selected category.
      final apiCategory = categoryMap[category]!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CategoryNewsPage(apiCategory: apiCategory, pageTitle: category),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are on a large screen for desktop layout
    final isDesktop = MediaQuery.of(context).size.width > 900;

    // Determine the category to highlight. Default to 'Home' if none is specified.
    final activeCategory = currentCategory ?? 'Home';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,

      // --- Leading Widget (NewsDaily Logo) ---
      leadingWidth: isDesktop ? 180 : 120,
      leading: Padding(
        padding: EdgeInsets.only(left: isDesktop ? 20.0 : 10.0),
        child: InkWell(
          onTap: () => _handleCategoryTap(context, 'Home'),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'NewsDaily',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      // --- Title Widget (The main navigation links for Desktop) ---
      title: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: categoryMap.keys.map((category) {
                final isSelected = category == activeCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextButton(
                    onPressed: () => _handleCategoryTap(context, category),
                    child: Text(
                      category,
                      style: TextStyle(
                        // Highlight the selected category
                        color: isSelected
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey[700],
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w600,
                        decoration: isSelected
                            ? TextDecoration.underline
                            : null,
                        decorationColor: const Color(0xFF1A1A2E),
                        decorationThickness: 3,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          : null, // Title is null on mobile, letting actions handle navigation
      // --- Actions (Search Icon and Mobile Menu) ---
      actions: <Widget>[
        // If not desktop, show all categories in a dropdown menu
        if (!isDesktop)
          PopupMenuButton<String>(
            onSelected: (String result) => _handleCategoryTap(context, result),
            icon: const Icon(Icons.menu, color: Color(0xFF1A1A2E)),
            itemBuilder: (BuildContext context) {
              return categoryMap.keys.map((String category) {
                return PopupMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: TextStyle(
                      fontWeight: category == activeCategory
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: category == activeCategory
                          ? const Color(0xFF1A1A2E)
                          : Colors.black,
                    ),
                  ),
                );
              }).toList();
            },
          ),

        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF1A1A2E)),
          onPressed: () {
            // Placeholder for search functionality
            debugPrint('Search button pressed');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
