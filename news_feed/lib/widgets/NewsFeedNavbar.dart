import 'package:flutter/material.dart';
import '../screens/CategoryNewsPage.dart'; 
import '../screens/NewsFeedPage.dart'; 


const Map<String, String> categoryMap = {
  'Home': 'general',
  'World': 'world',
  'Politics':
      'nation', 
  'Business': 'business',
  'Technology': 'technology',
  'Sports': 'sports',
  'Entertainment': 'entertainment',
};

class NewsFeedNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? currentCategory;

  const NewsFeedNavBar({super.key, this.currentCategory});

  void _handleCategoryTap(BuildContext context, String category) {
    if (category == 'Home') {
      Navigator.popUntil(context, (route) => route.isFirst);
      if (ModalRoute.of(context)?.settings.name != null &&
          ModalRoute.of(context)?.settings.name != '/') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NewsFeedPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
    else {
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
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final activeCategory = currentCategory ?? 'Home';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,

      leadingWidth: isDesktop ? 180 : 120,
      leading: Padding(
        padding: EdgeInsets.only(left: isDesktop ? 20.0 : 10.0),
        child: InkWell(
          onTap: () => _handleCategoryTap(context, 'Home'),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'NewsFeed',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

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
          : null, 
      actions: <Widget>[
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
          icon: const Icon(Icons.person, color: Color(0xFF1A1A2E)),
          onPressed: () {
            debugPrint('Person button pressed');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
