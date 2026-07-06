import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';

class PexelsApiService {
  // Free Pexels API key — rate limited to 200 req/hour
  static const String _apiKey = 'YOUR_PEXELS_API_KEY';
  static const String _baseUrl = 'https://api.pexels.com/v1';
  static const int _perPage = 30;

  int _currentPage = 1;
  String? _nextPageUrl;
  bool _isLoading = false;

  Future<PexelsResponse> fetchCurated({int page = 1}) async {
    _isLoading = true;
    try {
      final uri = Uri.parse('$_baseUrl/curated')
          .replace(queryParameters: {'per_page': '$_perPage', 'page': '$page'});
      final res = await http.get(uri, headers: {'Authorization': _apiKey});
      if (res.statusCode == 200) {
        final data = PexelsResponse.fromJson(jsonDecode(res.body));
        _nextPageUrl = data.nextPage;
        _currentPage = page;
        return data;
      }
      throw Exception('Pexels API: ${res.statusCode}');
    } finally {
      _isLoading = false;
    }
  }

  Future<PexelsResponse> search(String query, {int page = 1}) async {
    _isLoading = true;
    try {
      final uri = Uri.parse('$_baseUrl/search').replace(
          queryParameters: {
            'query': query,
            'per_page': '$_perPage',
            'page': '$page'
          });
      final res = await http.get(uri, headers: {'Authorization': _apiKey});
      if (res.statusCode == 200) {
        final data = PexelsResponse.fromJson(jsonDecode(res.body));
        _nextPageUrl = data.nextPage;
        _currentPage = page;
        return data;
      }
      throw Exception('Pexels API: ${res.statusCode}');
    } finally {
      _isLoading = false;
    }
  }

  Future<PexelsResponse> fetchNextPage() async {
    if (_nextPageUrl == null) {
      return PexelsResponse(wallpapers: [], totalResults: 0);
    }
    _isLoading = true;
    try {
      final res = await http.get(
        Uri.parse(_nextPageUrl!),
        headers: {'Authorization': _apiKey},
      );
      if (res.statusCode == 200) {
        final data = PexelsResponse.fromJson(jsonDecode(res.body));
        _nextPageUrl = data.nextPage;
        return data;
      }
      throw Exception('Pexels pagination: ${res.statusCode}');
    } finally {
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
  bool get hasMore => _nextPageUrl != null;
}
