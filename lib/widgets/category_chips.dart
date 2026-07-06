import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  static const categories = [
    {'label': '🔥 Trending', 'query': 'curated'},
    {'label': '🌿 Nature', 'query': 'nature landscape'},
    {'label': '🌌 Space', 'query': 'space galaxy'},
    {'label': '🏙️ Urban', 'query': 'city urban architecture'},
    {'label': '🎨 Abstract', 'query': 'abstract art'},
    {'label': '🖤 Dark', 'query': 'dark black minimalist'},
    {'label': '💜 Neon', 'query': 'neon synthwave'},
    {'label': '🌊 Ocean', 'query': 'ocean sea water'},
    {'label': '🏔️ Mountains', 'query': 'mountains fog mist'},
  ];

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selected == cat['query'];
          return GestureDetector(
            onTap: () => onSelected(cat['query']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppTheme.accentGlow : Colors.transparent,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: -2,
                        )
                      ]
                    : [],
              ),
              child: Text(
                cat['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
