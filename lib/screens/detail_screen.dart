import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/wallpaper.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final Wallpaper wallpaper;
  const DetailScreen({super.key, required this.wallpaper});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  bool _downloading = false;
  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleInfo() => setState(() => _showInfo = !_showInfo);

  Future<void> _downloadAndSet() async {
    setState(() => _downloading = true);
    try {
      final url = widget.wallpaper.originalUrl;
      final res = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/wallpaper_${widget.wallpaper.id}.jpg');
      await file.writeAsBytes(res.bodyBytes);

      if (mounted) {
        // Use platform channel to set wallpaper
        const platform = MethodChannel('com.adwa.wallpaperhaven/wallpaper');
        await platform.invokeMethod('setWallpaper', {'path': file.path});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                SizedBox(width: 10),
                Text('Wallpaper set successfully! ✨',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: AppTheme.surfaceLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen image with hero ──
          Hero(
            tag: 'wallpaper-${widget.wallpaper.id}',
            child: GestureDetector(
              onTap: _toggleInfo,
              child: AnimatedBuilder(
                animation: _fadeAnim,
                builder: (_, child) => Opacity(opacity: _fadeAnim.value, child: child),
                child: CachedNetworkImage(
                  imageUrl: widget.wallpaper.originalUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, __) => Container(
                    color: AppTheme.surface,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.surface,
                    child: const Icon(Icons.broken_image, color: AppTheme.textSecondary, size: 64),
                  ),
                ),
              ),
            ),
          ),

          // ── Back button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: AnimatedBuilder(
              animation: _slideAnim,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -_slideAnim.value * 0.5),
                child: Opacity(opacity: _fadeAnim.value, child: child),
              ),
              child: _GlassButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),

          // ── Bottom info bar ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            bottom: _showInfo ? 0 : -200,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _slideAnim,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _slideAnim.value * 0.5),
                child: Opacity(opacity: _fadeAnim.value, child: child),
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, 24, 20, MediaQuery.of(context).padding.bottom + 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photographer
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, AppTheme.accentGlow],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.wallpaper.photographer,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${widget.wallpaper.width} × ${widget.wallpaper.height}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Set Wallpaper',
                            icon: Icons.wallpaper_rounded,
                            color: AppTheme.accent,
                            loading: _downloading,
                            onTap: _downloadAndSet,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _GlassButton(
                          icon: _showInfo
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onTap: _toggleInfo,
                          size: 48,
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

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        if (!widget.loading) widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
