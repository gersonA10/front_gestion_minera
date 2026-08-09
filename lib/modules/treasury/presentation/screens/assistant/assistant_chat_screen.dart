import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/voice/voice_dictation_sheet.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/assistant/partners_assistant_service.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../../domain/repositories/treasury_repository.dart';
import '../../assistant/assistant_service.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final List<String> suggestions;
  final AssistantAction action;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.suggestions = const [],
    this.action = AssistantAction.ninguna,
  });
}

@RoutePage()
class AssistantChatScreen extends StatefulWidget {
  /// Rol del usuario: define qué asistente responde ('hacienda' | 'socios').
  final String role;

  const AssistantChatScreen({super.key, this.role = 'hacienda'});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  late final AssistantEngine _service = _buildEngine();

  final _messages = <_ChatMessage>[];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  bool _sending = false;
  String? _lastQuestion;

  AssistantEngine _buildEngine() {
    assert(
      widget.role == 'hacienda' || widget.role == 'socios',
      'Rol de asistente desconocido: "${widget.role}"',
    );
    final getIt = InjectorContainer.getIt;
    if (widget.role == 'socios') {
      return PartnersAssistantService(
        partnersRepository: getIt(),
        distributesRepository: getIt(),
        loanHistoryRepository: getIt(),
        treasuryRepository: getIt<TreasuryRepository>(),
      );
    }
    return AssistantService(repository: getIt<TreasuryRepository>());
  }

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text: _service.welcomeText,
        isUser: false,
        suggestions: _service.welcomeSuggestions,
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _sending) return;

    // "Reintentar" repite la última pregunta real.
    final question =
        text.toLowerCase() == 'reintentar' ? (_lastQuestion ?? text) : text;
    _lastQuestion = question;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _sending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    final reply = await _service.ask(question);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _messages.add(
        _ChatMessage(
          text: reply.text,
          isUser: false,
          isError: reply.isError,
          suggestions: reply.suggestions,
          action: reply.action,
        ),
      );
    });
    _scrollToBottom();
  }

  Future<void> _dictar() async {
    final transcript = await showVoiceDictationSheet(
      context: context,
      title: 'Pregunta por voz',
      hintExample: 'Di por ejemplo: "¿Cuánto oro hay en bóveda?"',
    );
    if (transcript != null && mounted) {
      _send(transcript);
    }
  }

  void _runAction(AssistantAction action) {
    switch (action) {
      case AssistantAction.abrirReportes:
        context.router.push(FinancialReportsRoute());
      case AssistantAction.abrirOro:
        context.router.push(GoldDashboardRoute());
      case AssistantAction.abrirDistribuciones:
        context.router.push(DistributesRoute());
      case AssistantAction.abrirAportes:
        context.router.push(ContributeHistoryRoute());
      case AssistantAction.abrirPrestamosSocio:
        context.router.push(LoanHistoryRoute());
      case AssistantAction.ninguna:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TColors.textPrimary,
            size: 18,
          ),
          onPressed: () => context.router.back(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const _AssistantAvatar(size: 34),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asistente',
                  style: TextStyle(
                    color: TColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Datos del sistema en tiempo real',
                  style: TextStyle(
                    color: TColors.textSecondary.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: TColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const _TypingBubble();
                  }
                  final m = _messages[index];
                  final isLast = index == _messages.length - 1;
                  return _MessageBubble(
                    message: m,
                    showExtras: isLast && !_sending,
                    onSuggestionTap: _send,
                    onActionTap: _runAction,
                  );
                },
              ),
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: TColors.surface,
        border: Border(top: BorderSide(color: TColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: TColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: TColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      minLines: 1,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 14,
                        color: TColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Pregunta algo…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: TColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sending ? null : _dictar,
                    tooltip: 'Preguntar por voz',
                    icon: const Icon(
                      Icons.mic_rounded,
                      color: TColors.warning,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sending ? null : () => _send(_inputController.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _sending
                      ? [TColors.border, TColors.border]
                      : [TColors.primary, TColors.primary.withValues(alpha: 0.8)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets del chat ─────────────────────────────────────────────────────────

class _AssistantAvatar extends StatelessWidget {
  final double size;
  const _AssistantAvatar({this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TColors.primary, Color(0xFF0B33B8)],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: TColors.goldAccent,
        size: size * 0.55,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool showExtras;
  final void Function(String) onSuggestionTap;
  final void Function(AssistantAction) onActionTap;

  const _MessageBubble({
    required this.message,
    required this.showExtras,
    required this.onSuggestionTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: TColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: _AssistantAvatar(),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(right: 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color:
                        message.isError ? TColors.dangerLight : TColors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: message.isError
                          ? TColors.danger.withValues(alpha: 0.3)
                          : TColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isError
                              ? TColors.danger
                              : TColors.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (message.action != AssistantAction.ninguna &&
                          showExtras) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => onActionTap(message.action),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                switch (message.action) {
                                  AssistantAction.abrirReportes =>
                                    'Abrir reportes',
                                  AssistantAction.abrirOro =>
                                    'Abrir inventario de oro',
                                  AssistantAction.abrirDistribuciones =>
                                    'Ver mis dividendos',
                                  AssistantAction.abrirAportes =>
                                    'Ver mis aportes',
                                  AssistantAction.abrirPrestamosSocio =>
                                    'Ver mis préstamos',
                                  AssistantAction.ninguna => '',
                                },
                                style: const TextStyle(
                                  color: TColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: TColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (showExtras && message.suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in message.suggestions)
                    GestureDetector(
                      onTap: () => onSuggestionTap(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: TColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: TColors.primary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _AssistantAvatar(),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: TColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TColors.border),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final phase = (_controller.value * 3 - i).clamp(0.0, 1.0);
                  final bounce =
                      (phase < 0.5 ? phase : 1 - phase) * 2; // 0→1→0
                  return Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      color: TColors.textSecondary
                          .withValues(alpha: 0.35 + 0.65 * bounce),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
