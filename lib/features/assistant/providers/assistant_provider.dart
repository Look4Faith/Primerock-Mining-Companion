import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/assistant_models.dart';
import '../../../services/providers.dart';

final assistantKnowledgeProvider =
    FutureProvider<AssistantKnowledgeBase>((ref) async {
  final service = ref.watch(miningAssistantServiceProvider);
  return service.loadKnowledgeBase();
});

final assistantTypingProvider = StateProvider<bool>((ref) => false);

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier(ref);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier(this._ref) : super([]) {
    _loadHistory();
  }

  final Ref _ref;
  final _uuid = const Uuid();

  void _loadHistory() {
    final history = _ref.read(chatHistoryServiceProvider).load();
    if (history.isNotEmpty) state = history;
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _ref.read(assistantTypingProvider)) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];
    await _persist();

    _ref.read(assistantTypingProvider.notifier).state = true;

    await Future<void>.delayed(const Duration(milliseconds: 600));

    final service = _ref.read(miningAssistantServiceProvider);
    final reply = await service.answer(trimmed);

    _ref.read(assistantTypingProvider.notifier).state = false;
    state = [...state, reply];
    await _persist();
  }

  Future<void> clearChat() async {
    state = [];
    await _ref.read(chatHistoryServiceProvider).clear();
  }

  Future<void> _persist() async {
    await _ref.read(chatHistoryServiceProvider).save(state);
  }
}
