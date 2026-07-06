import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/wallpaper.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/wallpaper_card.dart';
import '../widgets/category_chips.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PexelsApiService _api = PexelsApiService();
  final List<Wallpaper> _wallpapers = [];
  final ScrollController _scrollCtrl = ScrollController();
  String _activeCategory = 'curated';
  String _searchQuery = '';
  bool _loading = true;
  bool _loadingMore = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();
    _scrollCtrl.addListener(_onScroll);
    _loadWallpapers();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 300 &&
        !_loadingMore &&
        _api.hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadWallpapers() async {
    setState(() => _loading = true);
    try {
      PexelsResponse res;
      if (_activeCategory == 'curated') {
        res = await _api.fetchCurated();
      } else if (_searchQuery.isNotEmpty) {
        res = await _api.search(_searchQuery);
      } else {
        res = await _api.search(_activeCategory);
      }
      setState(() {
        _wallpapers.clear();
        _wallpapers.addAll(res.wallpapers);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final res = await _api.fetchNextPage();
      setState(() {
        _wallpapers.addAll(res.wallpapers);
        _loadingMore = false;
      });
    } catch (_) {
      setState(() => _loadingMore = false);
    }
  }

  void _onCategoryChanged(String query) {
    _searchQuery = '';
    _activeCategory = query;
    _fadeCtrl.reset();
    _loadWallpapers().then((_) => _fadeCtrl.forward());
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _activeCategory = '';
    _fadeCtrl.reset();
    _loadWallpapers().then((_) => _fadeCtrl.forward());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wallpaper\nHaven',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                height: 1.1,
                              ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, AppTheme.accentGlow],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.wallpaper_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover stunning wallpapers',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    _SearchBar(onSearch: _onSearch),
                    const SizedBox(height: 16),
                    // Categories
                    CategoryChips(
                      selected: _activeCategory,
                      onSelected: _onCategoryChanged,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // ── Grid ──
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: FadeTransition(
                  opacity: _fadeAnim,
                  child: SliverMasonryGrid.count(
                    crossAxisCount: screenWidth > 600 ? 3 : 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childCount: _wallpapers.length,
                    itemBuilder: (context, index) {
                      final wp = _wallpapers[index];
                      // Calculate height based on aspect ratio
                      final cardWidth = (screenWidth - 34) / (screenWidth > 600 ? 3 : 2);
                      final cardHeight = cardWidth / wp.aspectRatio;

                      return SizedBox(
                        height: cardHeight.clamp(140.0, 380.0),
                        child: WallpaperCard(
                          wallpaper: wp,
                          screenWidth: screenWidth,
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  DetailScreen(wallpaper: wp),
                              transitionsBuilder: (_, anim, __, child) =>
                                  FadeTransition(opacity: anim, child: child),
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            // ── Loading more indicator ──
            if (_loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  const _SearchBar({required this.onSearch});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus ? AppTheme.accent : AppTheme.surfaceLight,
          width: 1.2,
        ),
        boxShadow: _focusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.2),
                  blurRadius: 16,
                )
              ]
            : [],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search wallpapers...',
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
                  onPressed: () {
                    _controller.clear();
                    _focusNode.unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (q) => widget.onSearch(q.trim()),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
