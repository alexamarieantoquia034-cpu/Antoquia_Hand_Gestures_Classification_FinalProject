import 'package:flutter/material.dart';
import '../main.dart' show analytics;

class AppFooter extends StatelessWidget {
  final int currentPageIndex;

  const AppFooter({
    super.key,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE8D4C0),
            width: 1.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFooterButton(
              icon: Icons.category_outlined,
              label: 'Classes',
              isActive: currentPageIndex == 0,
              onTap: () async {
                if (currentPageIndex != 0) {
                  await analytics.logEvent(name: 'classes_clicked');
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/classes',
                    (route) => route.isFirst,
                  );
                }
              },
              theme: theme,
            ),
            _buildFooterButton(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              isActive: currentPageIndex == 1,
              onTap: () async {
                if (currentPageIndex != 1) {
                  await analytics.logEvent(name: 'gallery_clicked');
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/gallery',
                    (route) => route.isFirst,
                  );
                }
              },
              theme: theme,
            ),
            _buildFooterButton(
              icon: Icons.bar_chart_outlined,
              label: 'Analytics',
              isActive: currentPageIndex == 2,
              onTap: () async {
                if (currentPageIndex != 2) {
                  await analytics.logEvent(name: 'analytics_clicked');
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/analytics',
                    (route) => route.isFirst,
                  );
                }
              },
              theme: theme,
            ),
            _buildFooterButton(
              icon: Icons.school_outlined,
              label: 'Guide',
              isActive: currentPageIndex == 3,
              onTap: () async {
                if (currentPageIndex != 3) {
                  await analytics.logEvent(name: 'hand_pose_guide_clicked');
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/hand-pose-guide',
                    (route) => route.isFirst,
                  );
                }
              },
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFC4A06E) : const Color(0xFF8B7355),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive ? const Color(0xFFC4A06E) : const Color(0xFF8B7355),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
