import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/booking_service.dart';
import '../services/calc_history_service.dart';
import '../services/chat_history_service.dart';
import '../services/gold_price_service.dart';
import '../services/knowledge_service.dart';
import '../services/news_service.dart';
import '../services/laboratory_service.dart';
import '../services/mining_assistant_service.dart';
import '../services/mining_records_service.dart';
import '../services/notification_service.dart';
import '../services/offline_content_service.dart';
import '../services/pdf_export_service.dart';
import '../services/settings_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main()');
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(sharedPreferencesProvider));
});

final offlineContentServiceProvider = Provider<OfflineContentService>((ref) {
  return OfflineContentService();
});

final goldPriceServiceProvider = Provider<GoldPriceService>((ref) {
  return GoldPriceService(ref.watch(offlineContentServiceProvider));
});

final knowledgeServiceProvider = Provider<KnowledgeService>((ref) {
  return KnowledgeService(ref.watch(offlineContentServiceProvider));
});

final newsServiceProvider = Provider<NewsService>((ref) {
  return NewsService(ref.watch(offlineContentServiceProvider));
});

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

final laboratoryServiceProvider = Provider<LaboratoryService>((ref) {
  return LaboratoryService(ref.watch(offlineContentServiceProvider));
});

final miningAssistantServiceProvider = Provider<MiningAssistantService>((ref) {
  return MiningAssistantService(ref.watch(offlineContentServiceProvider));
});

final miningRecordsServiceProvider = Provider<MiningRecordsService>((ref) {
  return MiningRecordsService();
});

final calcHistoryServiceProvider = Provider<CalcHistoryService>((ref) {
  return CalcHistoryService();
});

final chatHistoryServiceProvider = Provider<ChatHistoryService>((ref) {
  return ChatHistoryService();
});

final pdfExportServiceProvider = Provider<PdfExportService>((ref) {
  return PdfExportService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier(ref.watch(settingsServiceProvider));
});

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier(this._settings) : super(_settings.darkMode);

  final SettingsService _settings;

  Future<void> setDark(bool value) async {
    await _settings.setDarkMode(value);
    state = value;
  }
}
