import 'package:flutter/material.dart';
import 'main.dart' show analytics, GestureHomePage;
import 'models/gesture_class.dart';
import 'widgets/app_footer.dart';
import 'widgets/gesture_image_widget.dart';

class GesturesClassesPage extends StatefulWidget {
  const GesturesClassesPage({super.key});

  @override
  State<GesturesClassesPage> createState() => _GesturesClassesPageState();
}

class _GesturesClassesPageState extends State<GesturesClassesPage> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Classes',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5D4A3A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                        _buildGestureClassesSection(theme),
                      ],
                    ),
                  ),
                ),
                AppFooter(currentPageIndex: 0),
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

  Widget _buildGestureClassesSection(ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final childAspectRatio = screenWidth > 600 ? 0.85 : 0.9;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap on any class to start classifying',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8B7355),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: GestureClassData.allGestures.length,
            itemBuilder: (context, index) {
              final gesture = GestureClassData.allGestures[index];
              return _buildGestureCard(gesture, theme);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              'v1.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFFC4946E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureCard(GestureClass gesture, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await analytics.logEvent(name: 'capture_started');
          if (!mounted) return;
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => GestureHomePage(gestureClass: gesture),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFFFFAF0),
            border: Border.all(
              color: const Color(0xFFE8D4C0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC4A06E).withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFE8D1),
                    border: Border.all(
                      color: const Color(0xFFFFD4B3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: GestureImageWidget(
                      imagePath: gesture.imagePath,
                      size: 55,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        gesture.name,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5D4A3A),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gesture.description,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF8B7355),
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to analyze',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFB88A5C),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
