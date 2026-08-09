import 'package:flutter/material.dart';
import 'package:front_gestion_minera/core/voice/voice_dictation_service.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

/// Bottom sheet genérico de dictado por voz. Escucha, muestra el transcript
/// en vivo y devuelve el texto final (o null si se canceló).
///
/// Cualquier formulario puede usarlo para autorellenarse:
///   final texto = await showVoiceDictationSheet(context: context,
///       hintExample: 'Di: "egreso de 500 bolivianos por compra de diésel"');
Future<String?> showVoiceDictationSheet({
  required BuildContext context,
  String? title,
  String? hintExample,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _VoiceDictationSheet(
      title: title ?? 'Dictado por voz',
      hintExample: hintExample,
    ),
  );
}

class _VoiceDictationSheet extends StatefulWidget {
  final String title;
  final String? hintExample;

  const _VoiceDictationSheet({required this.title, this.hintExample});

  @override
  State<_VoiceDictationSheet> createState() => _VoiceDictationSheetState();
}

class _VoiceDictationSheetState extends State<_VoiceDictationSheet>
    with SingleTickerProviderStateMixin {
  final _voice = VoiceDictationService();

  String _transcript = '';
  String? _errorMessage;

  // Evita el doble cierre: al presionar "Listo", stop() hace que el
  // reconocedor emita un último resultado final que volvería a llamar
  // _finish() y haría pop de la pantalla de abajo.
  bool _finished = false;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _startListening();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voice.cancel();
    super.dispose();
  }

  Future<void> _startListening() async {
    _finished = false;
    setState(() {
      _transcript = '';
      _errorMessage = null;
    });

    final ok = await _voice.init(
      onError: (message) {
        if (!mounted) return;
        setState(() => _errorMessage = message);
      },
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _errorMessage =
            'No se pudo iniciar el micrófono. Verifica el permiso en los ajustes.';
      });
      return;
    }

    await _voice.listen(
      onResult: (text, isFinal) {
        if (!mounted || _finished) return;
        setState(() => _transcript = text);
        if (isFinal && text.trim().isNotEmpty) {
          _finish();
        }
      },
    );
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    await _voice.stop();
    if (!mounted) return;
    final text = _transcript.trim();
    if (text.isEmpty) {
      _finished = false;
      setState(() {
        _errorMessage = 'No se entendió el dictado. Intenta de nuevo.';
      });
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasError
                    ? _errorMessage!
                    : (widget.hintExample ?? 'Habla ahora…'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: hasError ? TColors.danger : TColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ScaleTransition(
                scale: _pulseController,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: hasError
                        ? TColors.dangerLight
                        : TColors.warningLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasError ? Icons.mic_off_rounded : Icons.mic_rounded,
                    size: 38,
                    color: hasError ? TColors.danger : TColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_transcript.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TColors.border),
                  ),
                  child: Text(
                    _transcript,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TColors.textPrimary,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await _voice.cancel();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.textPrimary,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: TColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: hasError ? _startListening : _finish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        hasError ? Icons.refresh_rounded : Icons.check_rounded,
                        size: 18,
                      ),
                      label: Text(
                        hasError ? 'Reintentar' : 'Listo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
