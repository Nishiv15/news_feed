import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/NewsFeedPage.dart';
import '../screens/HomePage.dart';
import '../screens/LoginRegisterPage.dart';
import '../screens/ProfilePage.dart';
import '../screens/SavedArticlesPage.dart';
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
  'Politics': 'nation',
  'Business': 'business',
  'Technology': 'technology',
  'Sports': 'sports',
  'Entertainment': 'entertainment',
};

// Design tokens 

const _kNavBg      = Color(0xFF12121F);   // deep navy
const _kAccent     = Color(0xFFD6472B);   // editorial red
const _kTextActive = Colors.white;
const _kTextMuted  = Color(0xFF8A8FA8);
const _kDivider    = Color(0xFF2A2A3E);

class NewsFeedNavBar extends StatefulWidget implements PreferredSizeWidget {
  final String? currentCategory;
  final void Function(String)? onCategorySelected;

  const NewsFeedNavBar({
    super.key,
    this.currentCategory,
    this.onCategorySelected,
  });

  @override
  State<NewsFeedNavBar> createState() => _NewsFeedNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _NewsFeedNavBarState extends State<NewsFeedNavBar> {
  final _categoryScrollCtrl = ScrollController();

  // Navigation helpers 
  void _handleCategoryTap(BuildContext context, String category) {
    if (widget.onCategorySelected != null) {
      widget.onCategorySelected!(category);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const NewsFeedPage()),
      (route) => false,
    );
  }

  Future<void> _handleProfileAction(BuildContext context, String result) async {
    if (result == 'logout') {
      await SupabaseAuthService.logoutUser();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } else if (result == 'login') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginRegisterPage()),
      );
    } else if (result == 'profile') {
      final initialCountry = globalCountry;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      ).then((_) {
        if (initialCountry != globalCountry && context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NewsFeedPage()),
            (route) => false,
          );
        }
      });
    } else if (result == 'saved') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SavedArticlesPage()),
      );
    }
  }

  // Category strip 
  Widget _buildCategoryStrip(String activeCategory) {
    final categories = categoryMap.keys.toList();

    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: _kNavBg,
        border: Border(top: BorderSide(color: _kDivider, width: 1)),
      ),
      child: ListView.builder(
        controller: _categoryScrollCtrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isActive = cat == activeCategory;
          return _CategoryChip(
            label: cat,
            isActive: isActive,
            onTap: () => _handleCategoryTap(context, cat),
          );
        },
      ),
    );
  }

  // Country pill 
  Widget _buildCountryPicker(BuildContext context) {
    final currentName = countryMap.entries
        .firstWhere(
          (e) => e.value == globalCountry,
          orElse: () => const MapEntry('US', 'us'),
        )
        .key;

    return PopupMenuButton<String>(
      tooltip: 'Change country',
      position: PopupMenuPosition.under,
      color: const Color(0xFF1E1E30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (newValue) {
        if (newValue != globalCountry) {
          globalCountry = newValue;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NewsFeedPage()),
            (route) => false,
          );
        }
      },
      itemBuilder: (_) => countryMap.entries.map((entry) {
        final isSelected = entry.value == globalCountry;
        return PopupMenuItem<String>(
          value: entry.value,
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check_circle, color: _kAccent, size: 16)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(
                entry.key,
                style: TextStyle(
                  color: isSelected ? _kAccent : Colors.white70,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language_rounded, color: Colors.white70, size: 15),
            const SizedBox(width: 5),
            Text(
              globalCountry.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  // Profile avatar button
  Widget _buildProfileButton(BuildContext context) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final username =
        Supabase.instance.client.auth.currentUser?.userMetadata?['display_name']
            as String? ??
        '';
    final initial =
        username.isNotEmpty ? username[0].toUpperCase() : '?';

    return PopupMenuButton<String>(
      tooltip: 'Account',
      position: PopupMenuPosition.under,
      color: const Color(0xFF1E1E30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (result) => _handleProfileAction(context, result),
      itemBuilder: (_) {
        if (!isLoggedIn) {
          return [
            PopupMenuItem<String>(
              value: 'login',
              child: Row(
                children: const [
                  Icon(Icons.login_rounded, size: 18, color: _kAccent),
                  SizedBox(width: 10),
                  Text('Login / Sign Up',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ];
        }
        return [
          PopupMenuItem<String>(
            enabled: false,
            height: 36,
            child: Text(
              username.isNotEmpty ? 'Hi, $username 👋' : 'My Account',
              style: const TextStyle(
                color: _kTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'profile',
            child: Row(
              children: const [
                Icon(Icons.manage_accounts_outlined,
                    size: 18, color: Colors.white70),
                SizedBox(width: 10),
                Text('Profile', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'saved',
            child: Row(
              children: const [
                Icon(Icons.bookmark_outline, size: 18, color: Colors.white70),
                SizedBox(width: 10),
                Text('Saved Articles',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: const [
                Icon(Icons.logout_rounded, size: 18, color: _kAccent),
                SizedBox(width: 10),
                Text('Logout', style: TextStyle(color: _kAccent)),
              ],
            ),
          ),
        ];
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLoggedIn ? _kAccent : Colors.white12,
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Center(
          child: isLoggedIn
              ? Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white60,
                  size: 18,
                ),
        ),
      ),
    );
  }

  // Build 
  @override
  Widget build(BuildContext context) {
    final activeCategory = widget.currentCategory ?? 'Home';
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: _kNavBg,
      elevation: 0,
      toolbarHeight: 56,
      automaticallyImplyLeading: false,

      title: Row(
        children: [
          // Back button
          if (canPop) ...[
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 18),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Logo + wordmark
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => _handleCategoryTap(context, 'Home'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _kAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'N',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'NewsFeed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        // Country picker
        _buildCountryPicker(context),
        const SizedBox(width: 10),
        // Profile avatar
        _buildProfileButton(context),
        const SizedBox(width: 14),
      ],

      // Category strip as PreferredSize bottom 
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: _buildCategoryStrip(activeCategory),
      ),
    );
  }

  @override
  void dispose() {
    _categoryScrollCtrl.dispose();
    super.dispose();
  }
}

// Category chip

class _CategoryChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _underline;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isActive ? 1.0 : 0.0,
    );
    _underline = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_CategoryChip old) {
    super.didUpdateWidget(old);
    if (widget.isActive != old.isActive) {
      widget.isActive ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _underline,
        builder: (_, __) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border(
                bottom: BorderSide(
                  color: Color.lerp(Colors.transparent, _kAccent,
                      _underline.value)!,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: Color.lerp(
                    _kTextMuted, _kTextActive, _underline.value),
                fontSize: 13,
                fontWeight: widget.isActive
                    ? FontWeight.w700
                    : FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          );
        },
      ),
    );
  }
}
