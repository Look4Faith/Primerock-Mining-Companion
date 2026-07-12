import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/storage_keys.dart';
import '../models/assistant_models.dart';

class ChatHistoryService {
  Box get _box => Hive.box(StorageKeys.hiveBoxChat);

  static const _messagesKey = 'messages';

  List<ChatMessage> load() {
    final raw = _box.get(_messagesKey);
    if (raw is! String || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<ChatMessage> messages) async {
    await _box.put(
      _messagesKey,
      jsonEncode(messages.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> clear() async => _box.delete(_messagesKey);
}
