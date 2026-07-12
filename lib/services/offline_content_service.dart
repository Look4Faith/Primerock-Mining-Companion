import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/constants/storage_keys.dart';
import '../core/errors/app_failure.dart';

/// Offline-first content loader.
/// Order: remote (if online + URL configured) → Hive cache → bundled asset.
class OfflineContentService {
  OfflineContentService({
    http.Client? client,
    Connectivity? connectivity,
  })  : _client = client ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  final http.Client _client;
  final Connectivity _connectivity;

  Box get _cache => Hive.box(StorageKeys.hiveBoxCache);

  Future<Map<String, dynamic>> loadJson({
    required String cacheKey,
    required String assetPath,
    required String remotePath,
  }) async {
    final online = await _isOnline();
    if (online && AppConstants.remoteDataBaseUrl.isNotEmpty) {
      try {
        final remote = await _fetchRemote(remotePath);
        await _cache.put(cacheKey, jsonEncode(remote));
        await _cache.put('${cacheKey}_synced_at', DateTime.now().toIso8601String());
        return remote;
      } catch (_) {
        // Fall through to cache / asset.
      }
    }

    final cached = _cache.get(cacheKey) as String?;
    if (cached != null && cached.isNotEmpty) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      await _cache.put(cacheKey, raw);
      return decoded;
    } catch (e) {
      throw AppFailure('Failed to load $assetPath', cause: e);
    }
  }

  Future<Map<String, dynamic>> _fetchRemote(String path) async {
    final uri = Uri.parse('${AppConstants.remoteDataBaseUrl}$path');
    final response = await _client
        .get(uri)
        .timeout(AppConstants.remoteTimeout);
    if (response.statusCode != 200) {
      throw AppFailure('Remote fetch failed (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty) return false;
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  String? lastSyncedAt(String cacheKey) =>
      _cache.get('${cacheKey}_synced_at') as String?;
}
