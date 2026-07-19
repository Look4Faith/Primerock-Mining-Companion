import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/constants/storage_keys.dart';
import '../core/errors/app_failure.dart';

class ContentLoadResult {
  const ContentLoadResult({
    required this.data,
    required this.source,
    this.syncedAt,
  });

  final Map<String, dynamic> data;
  final ContentSource source;
  final DateTime? syncedAt;
}

enum ContentSource { remote, cache, asset }

/// Offline-first content loader.
/// Always attempts remote when a free CDN URL is configured and a network
/// attempt is reasonable — does not trust connectivity_plus alone (unreliable on web).
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
    bool forceRefresh = false,
  }) async {
    final result = await loadJsonDetailed(
      cacheKey: cacheKey,
      assetPath: assetPath,
      remotePath: remotePath,
      forceRefresh: forceRefresh,
    );
    return result.data;
  }

  Future<ContentLoadResult> loadJsonDetailed({
    required String cacheKey,
    required String assetPath,
    required String remotePath,
    bool forceRefresh = false,
  }) async {
    final shouldTryRemote = AppConstants.remoteDataBaseUrl.isNotEmpty &&
        (forceRefresh || await _shouldAttemptRemote());

    if (shouldTryRemote) {
      try {
        final remote = await _fetchRemote(remotePath);
        final now = DateTime.now().toUtc();
        await _cache.put(cacheKey, jsonEncode(remote));
        await _cache.put('${cacheKey}_synced_at', now.toIso8601String());
        return ContentLoadResult(
          data: remote,
          source: ContentSource.remote,
          syncedAt: now,
        );
      } catch (e, st) {
        debugPrint('Remote content fetch failed ($remotePath): $e\n$st');
        // Fall through to cache / asset.
      }
    }

    // Prefer Hive cache over bundled assets (cache is usually newer).
    final cached = _cache.get(cacheKey) as String?;
    if (cached != null && cached.isNotEmpty) {
      return ContentLoadResult(
        data: jsonDecode(cached) as Map<String, dynamic>,
        source: ContentSource.cache,
        syncedAt: _parsedSyncedAt(cacheKey),
      );
    }

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      await _cache.put(cacheKey, raw);
      return ContentLoadResult(
        data: decoded,
        source: ContentSource.asset,
        syncedAt: _parsedSyncedAt(cacheKey),
      );
    } catch (e) {
      throw AppFailure('Failed to load $assetPath', cause: e);
    }
  }

  DateTime? _parsedSyncedAt(String cacheKey) {
    final raw = _cache.get('${cacheKey}_synced_at') as String?;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  String? lastSyncedAt(String cacheKey) =>
      _cache.get('${cacheKey}_synced_at') as String?;

  Future<bool> _shouldAttemptRemote() async {
    // On web, connectivity plugins are unreliable — always try.
    if (kIsWeb) return true;
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty) return true; // unknown → try anyway
      if (results.contains(ConnectivityResult.none) && results.length == 1) {
        return false;
      }
      return results.any(
        (r) =>
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.ethernet ||
            r == ConnectivityResult.vpn ||
            r == ConnectivityResult.other,
      );
    } catch (_) {
      return true;
    }
  }

  Future<Map<String, dynamic>> _fetchRemote(String path) async {
    final base = AppConstants.remoteDataBaseUrl;
    // Cache-bust GitHub/CDN (~5 min) so Wi‑Fi opens get fresh JSON.
    final bust = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 60000;
    final uri = Uri.parse('$base$path').replace(
      queryParameters: {'v': '$bust'},
    );
    final response = await _client.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
      },
    ).timeout(AppConstants.remoteTimeout);
    if (response.statusCode != 200) {
      throw AppFailure('Remote fetch failed (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
