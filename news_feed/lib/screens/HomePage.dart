import 'package:flutter/material.dart';
import '../widgets/NewsFeedFooter.dart';
import 'NewsFeedPage.dart';
import 'LoginRegisterPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _HomeNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section describing the platform
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 120.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome to NewsFeed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Your ultimate destination for curated, reliable top stories. '
                        'Filter breaking headlines by country, browse by specific categories, and quickly '
                        'catch up with powerful AI-driven article summaries.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                      
                      // Action Buttons
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NewsFeedPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1A1A2E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black45,
                            ),
                            child: const Text(
                              'Explore News',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginRegisterPage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Login / Signup',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Feature Section 1
            _buildLargeFeatureSection(
              icon: Icons.flag,
              title: 'Global, Country-Wise News',
              description: 'Stay connected to the world or zoom into your local region. '
                  'Our integrated region selector lets you seamlessly switch between '
                  'news from the United States, India, the United Kingdom, and dozens of other '
                  'supported countries around the globe. Get the perspective you need, instantly.',
              imageLeft: true,
              backgroundColor: const Color(0xFFD6EAF8), 
            ),
            
            const Divider(height: 1, thickness: 1, color: Colors.black54),
            
            // Feature Section 2
            _buildLargeFeatureSection(
              icon: Icons.category,
              title: 'Robust Category Filtering',
              description: 'Tired of endless noise? Focus solely on what matters to you. '
                  'Our platform enables you to effortlessly filter through topics ranging from '
                  'Business and Technology to Entertainment and Sports. Deep dive into specialized '
                  'feeds designed perfectly to match your interests.',
              imageLeft: false,
              backgroundColor: const Color(0xFFD6EAF8), 
            ),
            
            const Divider(height: 1, thickness: 1, color: Colors.black54),

            // Feature Section 3
            _buildLargeFeatureSection(
              icon: Icons.auto_awesome,
              title: 'Intelligent AI Summarization',
              description: 'Reading long, tedious articles is a thing of the past. '
                  'Save massive amounts of your valuable time with our advanced AI summarization capabilities. '
                  'Instantly generate crisp, accurate, and lightning-fast summaries of any headline '
                  'so you can grasp the core story in mere seconds without skipping a beat.',
              imageLeft: true,
              backgroundColor: const Color(0xFFD6EAF8), 
            ),

            const FooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeFeatureSection({
    required IconData icon,
    required String title,
    required String description,
    required bool imageLeft,
    required Color backgroundColor,
  }) {
    final textContent = Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );

    final iconContent = Expanded(
      flex: 4,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(60),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 120, color: const Color(0xFF1A1A2E)),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Highly responsive fallback for narrow windows / mobile
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E).withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 80, color: const Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            description,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              
              // Full Desktop width layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: imageLeft
                    ? [iconContent, textContent]
                    : [textContent, iconContent],
              );
            },
          ),
        ),
      ),
    );
  }
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
