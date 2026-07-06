class Wallpaper {
  final int id;
  final String photographer;
  final String photographerUrl;
  final String originalUrl;
  final String largeUrl;
  final String mediumUrl;
  final String smallUrl;
  final String portraitUrl;
  final int width;
  final int height;
  final String avgColor;

  Wallpaper({
    required this.id,
    required this.photographer,
    required this.photographerUrl,
    required this.originalUrl,
    required this.largeUrl,
    required this.mediumUrl,
    required this.smallUrl,
    required this.portraitUrl,
    required this.width,
    required this.height,
    required this.avgColor,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'],
      photographer: json['photographer'] ?? 'Unknown',
      photographerUrl: json['photographer_url'] ?? '',
      originalUrl: json['src']['original'],
      largeUrl: json['src']['large2x'] ?? json['src']['large'],
      mediumUrl: json['src']['medium'],
      smallUrl: json['src']['small'],
      portraitUrl: json['src']['portrait'],
      width: json['width'],
      height: json['height'],
      avgColor: json['avg_color'] ?? '#8B5CF6',
    );
  }

  double get aspectRatio => width / height;

  /// Choose best URL based on screen width
  String bestUrl(double screenWidth) {
    if (screenWidth > 800) return largeUrl;
    if (screenWidth > 400) return mediumUrl;
    return smallUrl;
  }
}

class PexelsResponse {
  final List<Wallpaper> wallpapers;
  final int totalResults;
  final String? nextPage;

  PexelsResponse({
    required this.wallpapers,
    required this.totalResults,
    this.nextPage,
  });

  factory PexelsResponse.fromJson(Map<String, dynamic> json) {
    return PexelsResponse(
      wallpapers: (json['photos'] as List)
          .map((p) => Wallpaper.fromJson(p))
          .toList(),
      totalResults: json['total_results'],
      nextPage: json['next_page'],
    );
  }
}
