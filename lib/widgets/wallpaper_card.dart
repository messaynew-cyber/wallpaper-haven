import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';

class WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;
  final VoidCallback onTap;
  final double screenWidth;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    required this.onTap,
    this.screenWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'wallpaper-${wallpaper.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: wallpaper.portraitUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppTheme.surfaceLight,
                  highlightColor: AppTheme.surface.withOpacity(0.5),
                  child: Container(color: AppTheme.surface),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.surfaceLight,
                  child: const Icon(Icons.broken_image, color: AppTheme.textSecondary),
                ),
              ),
              // Gradient overlay at bottom for photographer name
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    wallpaper.photographer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
