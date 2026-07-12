import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/storage_keys.dart';
import '../models/booking_request.dart';

class BookingService {
  BookingService();

  final _uuid = const Uuid();
  Box get _box => Hive.box(StorageKeys.hiveBoxBookings);

  List<BookingRequest> getAll() {
    final list = <BookingRequest>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is String) {
        list.add(BookingRequest.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } else if (raw is Map) {
        list.add(BookingRequest.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<BookingRequest> save(BookingRequest draft) async {
    final saved = BookingRequest(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      name: draft.name,
      phone: draft.phone,
      serviceInterest: draft.serviceInterest,
      preferredDate: draft.preferredDate,
      notes: draft.notes,
      createdAt: draft.createdAt,
    );
    await _box.put(saved.id, jsonEncode(saved.toJson()));
    return saved;
  }
}
