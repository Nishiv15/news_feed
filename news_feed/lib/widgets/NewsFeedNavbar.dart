import 'package:flutter/material.dart';
import '../screens/CategoryNewsPage.dart'; 
import '../screens/NewsFeedPage.dart'; 
import '../screens/HomePage.dart'; 
import '../models/news_model.dart';
import '../models/supabase_auth_service.dart';
const Map<String, String> countryMap = {
  'Argentina': 'ar', 'Australia': 'au', 'Bangladesh': 'bd', 'Brazil': 'br', 
  'Canada': 'ca', 'China': 'cn', 'Colombia': 'co', 'Egypt': 'eg', 
  'France': 'fr', 'Germany': 'de', 'Greece': 'gr', 'Hong Kong': 'hk', 
  'India': 'in', 'Indonesia': 'id', 'Ireland': 'ie', 'Israel': 'il', 
  'Italy': 'it', 'Japan': 'jp', 'Malaysia': 'my', 'Mexico': 'mx', 
  'Netherlands': 'nl', 'Norway': 'no', 'Pakistan': 'pk', 'Peru': 'pe', 
  'Philippines': 'ph', 'Portugal': 'pt', 'Romania': 'ro', 'Russia': 'ru', 
  'Singapore': 'sg', 'Spain': 'es', 'Sweden': 'se', 'Switzerland': 'ch', 
  'Taiwan': 'tw', 'Turkey': 'tr', 'Ukraine': 'ua', 'United Kingdom': 'gb', 
  'United States': 'us',
};

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
    final isDesktop = MediaQuery.of(context).size.width > 950;
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

      centerTitle: isDesktop,
      title: isDesktop
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
              ),
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

        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: globalCountry,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A1A2E)),
            dropdownColor: Colors.white,
            onChanged: (String? newValue) {
              if (newValue != null && newValue != globalCountry) {
                globalCountry = newValue;
                // Re-push NewsFeedPage to force rebuild and re-fetch with new country
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsFeedPage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            selectedItemBuilder: (BuildContext context) {
              return countryMap.values.map<Widget>((String value) {
                return Center(
                  child: Text(
                    value.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList();
            },
            items: countryMap.entries.map<DropdownMenuItem<String>>((entry) {
              return DropdownMenuItem<String>(
                value: entry.value,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 150),
                  child: Text(
                    entry.key,
                    softWrap: false,
                    style: const TextStyle(color: Color(0xFF1A1A2E)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.person, color: Color(0xFF1A1A2E)),
          onSelected: (String result) async {
            if (result == 'logout') {
              await SupabaseAuthService.logoutUser();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }
            } else if (result == 'profile') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile coming soon!')));
            } else if (result == 'likes') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Likes coming soon!')));
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: Text('Profile'),
            ),
            const PopupMenuItem<String>(
              value: 'likes',
              child: Text('Likes'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
