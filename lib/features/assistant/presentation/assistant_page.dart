import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/assistant_models.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/skeleton_loader.dart';
import '../providers/assistant_provider.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? text]) async {
    final message = text ?? _controller.text;
    if (message.trim().isEmpty) return;
    _controller.clear();
    await ref.read(chatMessagesProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isTyping = ref.watch(assistantTypingProvider);
    final kbAsync = ref.watch(assistantKnowledgeProvider);

    ref.listen(chatMessagesProvider, (_, __) => _scrollToBottom());
    ref.listen(assistantTypingProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mining Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear chat',
              onPressed: () => ref.read(chatMessagesProvider.notifier).clearChat(),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? kbAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: SkeletonLoader(height: 60, count: 4),
                      ),
                      error: (e, _) => ErrorState(message: e.toString()),
                      data: (kb) => _SuggestedView(
                        kb: kb,
                        onQuestion: _send,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isTyping && index == messages.length) {
                          return const _TypingIndicator();
                        }
                        return _ChatBubble(message: messages[index]);
                      },
                    ),
            ),
            if (messages.isNotEmpty)
              kbAsync.maybeWhen(
                data: (kb) => _SuggestedChips(
                  questions: kb.suggestedQuestions.take(3).toList(),
                  onTap: _send,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            _InputBar(
              controller: _controller,
              isTyping: isTyping,
              onSend: () => _send(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedView extends StatelessWidget {
  const _SuggestedView({required this.kb, required this.onQuestion});

  final AssistantKnowledgeBase kb;
  final ValueChanged<String> onQuestion;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                    ),
                    child: const Icon(Icons.smart_toy, color: AppColors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ask me about mining, assays, or Primerock services.',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.accentSoft(context),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 20),
        Text(
          'Suggested questions',
          style: TextStyle(
            color: AppColors.accent(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...kb.suggestedQuestions.map(
          (q) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              onTap: () => onQuestion(q),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: AppColors.gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      q,
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestedChips extends StatelessWidget {
  const _SuggestedChips({required this.questions, required this.onTap});

  final List<String> questions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: questions
            .map(
              (q) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(q, overflow: TextOverflow.ellipsis),
                  onPressed: () => onTap(q),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        decoration: BoxDecoration(
          color: isUser ? AppColors.gold.withValues(alpha: 0.2) : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser ? AppColors.gold.withValues(alpha: 0.4) : AppColors.divider,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? AppColors.goldLight : AppColors.textPrimary(context),
            height: 1.45,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(delay: (i * 150).ms, duration: 400.ms)
                .then()
                .fadeOut(duration: 400.ms);
          }),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isTyping,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: isTyping ? null : (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Ask a mining question…',
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.gold,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isTyping ? null : onSend,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.send_rounded,
                    color: isTyping ? AppColors.black.withValues(alpha: 0.4) : AppColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
