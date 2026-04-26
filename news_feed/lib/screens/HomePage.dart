import 'package:flutter/material.dart';
import '../widgets/NewsFeedFooter.dart';
import 'NewsFeedPage.dart';
import 'LoginRegisterPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _ink    = Color(0xFF12121F);
  static const _accent = Color(0xFFD6472B);
  static const _bg     = Color(0xFFF7F4EF);

  static const _features = [
    _Feature(
      icon: Icons.language_rounded,
      gradient: [Color(0xFF1A3A5C), Color(0xFF2D6EA8)],
      title: 'Global Coverage',
      body: 'Instantly switch between 36+ countries. '
          'From US headlines to Japanese tech news — one tap away.',
    ),
    _Feature(
      icon: Icons.grid_view_rounded,
      gradient: [Color(0xFF3A1A5C), Color(0xFF6E2DA8)],
      title: 'Category Feeds',
      body: 'Filter into Business, Sports, Technology, Entertainment and more. '
          'Only see what actually matters to you.',
    ),
    _Feature(
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFF1A5C2E), Color(0xFF2DA84B)],
      title: 'AI Summaries',
      body: 'Too busy to read? Tap the sparkle icon for a crisp AI-generated '
          'executive summary of any article in seconds.',
    ),
    _Feature(
      icon: Icons.bookmark_rounded,
      gradient: [Color(0xFF5C2E1A), Color(0xFFA84B2D)],
      title: 'Save for Later',
      body: 'Bookmark stories with a heart tap and revisit them any time '
          'from your personal reading list.',
    ),
    _Feature(
      icon: Icons.devices_rounded,
      gradient: [Color(0xFF0D3D3D), Color(0xFF0D7777)],
      title: 'Any Screen',
      body: 'Fluid layouts that look equally stunning on your phone, '
          'tablet, and ultra-wide desktop monitor.',
    ),
    _Feature(
      icon: Icons.trending_up_rounded,
      gradient: [Color(0xFF5C1A3A), Color(0xFFA82D6E)],
      title: 'Load More',
      body: 'Never run out of news. Authenticated users can keep loading '
          'fresh articles in every category.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: const _HomeNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(accent: _accent, ink: _ink),
            _StatsStrip(ink: _ink, accent: _accent),
            _FeaturesGrid(features: _features, bg: _bg, ink: _ink),
            _CtaBanner(accent: _accent),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }
}


class _HeroSection extends StatelessWidget {
  final Color accent;
  final Color ink;
  const _HeroSection({required this.accent, required this.ink});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 720;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ink, const Color(0xFF1E2A4A)],
        ),
      ),
      child: Stack(
        children: [
          // Subtle dot-grid background pattern
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 60,
              vertical: isMobile ? 64 : 100,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  children: [
                    // Eyebrow badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: accent, size: 8),
                          const SizedBox(width: 8),
                          Text(
                            'Real-time news, curated for you',
                            style: TextStyle(
                              color: accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Headline
                    Text(
                      'The News Hub\nYou Deserve',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 40 : 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -1.5,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sub-headline
                    Text(
                      'Breaking headlines from 36+ countries.\n'
                      'Category filters, AI summaries, and a reading list — all in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 19,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 44),

                    // CTA buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _PrimaryButton(
                          label: 'Explore News',
                          icon: Icons.arrow_forward_rounded,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const NewsFeedPage())),
                        ),
                        _GhostButton(
                          label: 'Login / Sign Up',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const LoginRegisterPage())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _StatsStrip extends StatelessWidget {
  final Color ink, accent;
  const _StatsStrip({required this.ink, required this.accent});

  static const _stats = [
    ('36+', 'Countries'),
    ('7', 'Categories'),
    ('AI', 'Summaries'),
    ('∞', 'Headlines'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            runSpacing: 20,
            spacing: 20,
            children: _stats.map((s) => _StatItem(value: s.$1, label: s.$2, accent: accent)).toList(),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final Color accent;
  const _StatItem({required this.value, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w900, color: accent)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
      ],
    );
  }
}


class _FeaturesGrid extends StatelessWidget {
  final List<_Feature> features;
  final Color bg, ink;
  const _FeaturesGrid({required this.features, required this.bg, required this.ink});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section header
              Text('Everything You Need',
                  style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: ink,
                      letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text('Powerful features designed for modern readers.',
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 48),

              // Responsive grid via LayoutBuilder
              LayoutBuilder(builder: (context, constraints) {
                final crossAxis = constraints.maxWidth > 800
                    ? 3
                    : constraints.maxWidth > 500
                        ? 2
                        : 1;
                return _WrapGrid(items: features, columns: crossAxis, ink: ink);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _WrapGrid extends StatelessWidget {
  final List<_Feature> items;
  final int columns;
  final Color ink;
  const _WrapGrid({required this.items, required this.columns, required this.ink});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: items.map((f) {
        return LayoutBuilder(builder: (context, constraints) {
          // Calculate item width from parent
          return SizedBox(
            width: (MediaQuery.of(context).size.width > 1140
                    ? 1100
                    : MediaQuery.of(context).size.width - 40) /
                columns -
                20,
            child: _FeatureCard(feature: f, ink: ink),
          );
        });
      }).toList(),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;
  final Color ink;
  const _FeatureCard({required this.feature, required this.ink});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovered ? 0.10 : 0.04),
              blurRadius: _hovered ? 24 : 12,
              offset: Offset(0, _hovered ? 8 : 4),
            ),
          ],
        ),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient icon box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.feature.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.feature.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 18),
            Text(
              widget.feature.title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: widget.ink,
                  letterSpacing: -0.2),
            ),
            const SizedBox(height: 10),
            Text(
              widget.feature.body,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black54, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}


class _CtaBanner extends StatelessWidget {
  final Color accent;
  const _CtaBanner({required this.accent});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, const Color(0xFFB33520)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 56 : 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Start Reading Today',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: isMobile ? 30 : 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create a free account and unlock the full NewsFeed experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: isMobile ? 14 : 18, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 36),
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginRegisterPage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                elevation: 0,
              ),
              child: const Text('Create Free Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            );
          }),
        ],
      ),
    );
  }
}


class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD6472B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        elevation: 0,
        textStyle:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white38, width: 1.5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        textStyle:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}


class _Feature {
  final IconData icon;
  final List<Color> gradient;
  final String title, body;
  const _Feature(
      {required this.icon,
      required this.gradient,
      required this.title,
      required this.body});
}


class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    const radius = 1.5;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}


class _HomeNavBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeNavBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 1,
      centerTitle: false,
      title: const Text(
        'NewsFeed',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginRegisterPage(),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          ),
          child: const Text(
            'Login / Signup',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
