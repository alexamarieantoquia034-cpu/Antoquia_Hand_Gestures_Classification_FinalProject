import 'package:flutter/material.dart';
import 'models/gesture_class.dart';
import 'widgets/app_footer.dart';
import 'widgets/gesture_image_widget.dart';

class HandPoseGuidePage extends StatefulWidget {
  const HandPoseGuidePage({super.key});

  @override
  State<HandPoseGuidePage> createState() => _HandPoseGuidePageState();
}

class _HandPoseGuidePageState extends State<HandPoseGuidePage> {
  int? _selectedGestureIndex;

  static const Map<String, List<String>> _gestureSteps = {
    'Clap': [
      'Extend both arms to the sides',
      'Bring hands together quickly',
      'Keep palms facing each other',
      'Make a swift clapping motion',
      'Return hands to sides',
    ],
    'Finger Heart': [
      'Raise your hand to chest level',
      'Extend thumb and index finger',
      'Cross them to form a heart shape',
      'Keep other fingers down',
      'Hold position steady',
    ],
    'Fist': [
      'Raise your hand to camera',
      'Curl all fingers inward tightly',
      'Make a compact closed fist',
      'Thumb can be on top or side',
      'Keep wrist straight',
    ],
    'Heart': [
      'Raise both hands to chest level',
      'Form a heart with both index and thumbs',
      'Press both hands together at the center',
      'Create a pointed top and rounded bottom',
      'Hold steady for recognition',
    ],
    'Ok': [
      'Raise hand to camera',
      'Connect thumb and index finger',
      'Form a circle with thumb and index',
      'Keep other three fingers extended upward',
      'Hold hand steady',
    ],
    'Peace': [
      'Raise hand with palm facing camera',
      'Extend index and middle finger upward',
      'Keep other fingers tucked down',
      'Spread the two fingers apart slightly',
      'Hold position steady',
    ],
    'Point': [
      'Raise your hand to camera',
      'Extend only the index finger forward',
      'Keep other fingers curled',
      'Point straight ahead',
      'Hold steady for detection',
    ],
    'Rock': [
      'Raise your hand with fist closed',
      'Extend index and pinky fingers upward',
      'Keep middle and ring fingers down',
      'Make a strong rock gesture',
      'Hold position steady',
    ],
    'Stop': [
      'Raise your hand to camera',
      'Keep palm facing forward',
      'Fingers should be extended upward',
      'Keep hand open and flat',
      'Maintain steady position',
    ],
    'Thumbs up': [
      'Raise your hand to camera',
      'Make a fist with your hand',
      'Extend thumb upward',
      'Keep other fingers curled down',
      'Hold thumb pointing upward',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Hand Pose Guide',
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF5D4A3A),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5D4A3A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            color: const Color(0xFF5D4A3A),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/classes', (route) => route.isFirst);
            },
            tooltip: 'Classes',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _selectedGestureIndex == null
                      ? _buildGestureList(theme)
                      : _buildGestureDetails(theme),
                ),
                AppFooter(currentPageIndex: 3),
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

  Widget _buildGestureList(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFFFFAF0),
                border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC4A06E).withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn Hand Gestures',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5D4A3A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap on any gesture to view detailed step-by-step instructions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8B7355),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: GestureClassData.allGestures.length,
              itemBuilder: (context, index) {
                final gesture = GestureClassData.allGestures[index];
                return _buildGestureSelectCard(gesture, index, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureSelectCard(
    GestureClass gesture,
    int index,
    ThemeData theme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGestureIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFFFFFAF0),
            border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
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
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  gesture.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5D4A3A),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGestureDetails(ThemeData theme) {
    final gesture = GestureClassData.allGestures[_selectedGestureIndex!];
    final steps = _gestureSteps[gesture.name] ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFFFFAF0),
                border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC4A06E).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
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
                        size: 96,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gesture.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5D4A3A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    gesture.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8B7355),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFFFFAF0),
                border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC4A06E).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step-by-Step Guide',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5D4A3A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...steps.asMap().entries.map(
                    (entry) {
                      final stepNumber = entry.key + 1;
                      final stepText = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFD4A574),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC4A06E)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$stepNumber',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  stepText,
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF5D4A3A),
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedGestureIndex = null;
                });
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
                'BACK TO GESTURES',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFAF1E6),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
