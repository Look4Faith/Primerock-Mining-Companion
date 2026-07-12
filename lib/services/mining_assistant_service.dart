import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../models/assistant_models.dart';
import 'offline_content_service.dart';

/// Local knowledge-base assistant. Replace [answer] body later with an AI API.
class MiningAssistantService {
  MiningAssistantService(this._content);

  final OfflineContentService _content;
  static const _cacheKey = 'mining_answers';
  final _uuid = const Uuid();

  AssistantKnowledgeBase? _kb;

  Future<AssistantKnowledgeBase> loadKnowledgeBase() async {
    if (_kb != null) return _kb!;
    final json = await _content.loadJson(
      cacheKey: _cacheKey,
      assetPath: AppConstants.miningAnswersAsset,
      remotePath: AppConstants.remoteAnswersPath,
    );
    _kb = AssistantKnowledgeBase.fromJson(json);
    return _kb!;
  }

  Future<ChatMessage> answer(String userText) async {
    final kb = await loadKnowledgeBase();
    final match = _findBest(kb, userText);
    final buffer = StringBuffer();
    if (match != null) {
      buffer.writeln(match.answer);
      if (match.cta != null && match.cta!.isNotEmpty) {
        buffer.writeln();
        buffer.writeln(match.cta);
      }
    } else {
      buffer.write(kb.fallback);
    }
    return ChatMessage(
      id: _uuid.v4(),
      text: buffer.toString().trim(),
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  AssistantAnswer? _findBest(AssistantKnowledgeBase kb, String input) {
    final q = input.toLowerCase().trim();
    AssistantAnswer? best;
    var bestScore = 0;

    for (final a in kb.answers) {
      var score = 0;
      for (final kw in a.keywords) {
        if (q.contains(kw)) score += kw.length;
      }
      if (a.question.toLowerCase().contains(q) ||
          q.contains(a.question.toLowerCase().split(' ').take(3).join(' '))) {
        score += 5;
      }
      if (score > bestScore) {
        bestScore = score;
        best = a;
      }
    }
    return bestScore > 0 ? best : null;
  }
}
