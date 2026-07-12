/// Local-notification-ready stub. Wire flutter_local_notifications later.
/// Do NOT add Firebase here — keep zero monthly cost.
class NotificationService {
  bool _initialized = false;
  bool _enabled = false;

  bool get isInitialized => _initialized;
  bool get enabled => _enabled;

  Future<void> init() async {
    // Placeholder for flutter_local_notifications initialization.
    _initialized = true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
  }

  Future<void> showLocal({
    required String title,
    required String body,
  }) async {
    if (!_enabled || !_initialized) return;
    // Future: show notification plugin call.
  }

  Future<void> scheduleDailyGoldReminder({required int hour}) async {
    if (!_enabled || !_initialized) return;
    // Future: schedule local reminder.
  }
}
