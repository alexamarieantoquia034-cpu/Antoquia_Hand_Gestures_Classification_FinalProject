import 'package:flutter/material.dart';
import 'main.dart' show analytics;
import 'gestures_classes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Home',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5D4A3A),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFAF1E6),
                                ),
                                child: const Center(
                                  child: Text(
                                    '👆',
                                    style: TextStyle(fontSize: 80),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Hand Gestures',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: const Color(0xFF5D4A3A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Identify hand gestures using real-time recognition.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF8B7355),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              _buildFeatureCard(
                                theme: theme,
                                icon: '📸',
                                title: 'Capture Photos',
                                description: 'Take pictures of your hand gestures',
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureCard(
                                theme: theme,
                                icon: '⚡',
                                title: 'Instant Detection',
                                description: 'Get real-time recognition results',
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureCard(
                                theme: theme,
                                icon: '📊',
                                title: 'Track Results',
                                description: 'View your detection history',
                              ),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await analytics.logEvent(name: 'get_started_pressed');
                                    if (!mounted) return;
                                    Navigator.push(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const GesturesClassesPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4A574),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Text(
                                    'GET STARTED',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFAF1E6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAF1E6), Color(0xFFF5E6D3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required ThemeData theme,
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFFFFAF0),
        border: Border.all(
          color: const Color(0xFFE8D4C0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFD4A574).withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5D4A3A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8B7355),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
