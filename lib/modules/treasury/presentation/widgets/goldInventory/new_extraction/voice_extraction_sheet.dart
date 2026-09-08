import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/idempotency/gold_operation_key_store.dart';
import 'package:front_gestion_minera/core/voice/voice_dictation_service.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/voice/extraction_voice_parser.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'image_source_option_widget.dart';

/// Lo que el usuario dictó, para prellenar el formulario cuando elige
/// "Editar" en la confirmación.
class VoiceExtractionEditRequest {
  final double? peso;
  final double? pureza;
  final String observaciones;

  const VoiceExtractionEditRequest({
    required this.peso,
    required this.pureza,
    required this.observaciones,
  });
}

/// Abre el flujo de registro de extracción por voz: dicta los datos y
/// adjunta la evidencia fotográfica (obligatoria) en la confirmación.
/// Devuelve: [VoiceExtractionEditRequest] si eligió "Editar", `true` si
/// registró con éxito, o null si canceló.
Future<Object?> showUrgentVoiceExtractionSheet({
  required BuildContext context,
  required TreasuryBloc bloc,
}) {
  return showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) =>
        BlocProvider.value(value: bloc, child: const _VoiceExtractionSheet()),
  );
}

enum _VoicePhase { listening, review, submitting, success }

class _VoiceExtractionSheet extends StatefulWidget {
  const _VoiceExtractionSheet();

  @override
  State<_VoiceExtractionSheet> createState() => _VoiceExtractionSheetState();
}

class _VoiceExtractionSheetState extends State<_VoiceExtractionSheet>
    with SingleTickerProviderStateMixin {
  final _voice = VoiceDictationService();

  _VoicePhase _phase = _VoicePhase.listening;
  // Evita procesar dos veces el dictado: al detener el micrófono el
  // reconocedor emite un último resultado final que re-dispararía el cierre.
  bool _finishedListening = false;
  String _transcript = '';
  String? _errorMessage;
  ExtractionVoiceResult? _result;
  File? _evidencia;
  String _batchCode = '';
  String _successMessage = '';
  bool _successWasRecovered = false;
  GoldOperationKeyStore? _operationKeyStore;
  String? _activeIdempotencyKey;

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
    _finishedListening = false;
    _pulseController.repeat(reverse: true);
    setState(() {
      _phase = _VoicePhase.listening;
      _transcript = '';
      _errorMessage = null;
      _result = null;
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
        if (!mounted || _finishedListening) return;
        setState(() => _transcript = text);
        if (isFinal && text.trim().isNotEmpty) {
          _finishListening();
        }
      },
    );
  }

  Future<void> _finishListening() async {
    if (_finishedListening) return;
    _finishedListening = true;
    await _voice.stop();
    if (!mounted) return;
    if (_transcript.trim().isEmpty) {
      _finishedListening = false;
      setState(() {
        _errorMessage = 'No se entendió el dictado. Intenta de nuevo.';
      });
      return;
    }
    _pulseController.stop();
    setState(() {
      _result = ExtractionVoiceParser.parse(_transcript);
      _phase = _VoicePhase.review;
    });
  }

  Future<void> _pickEvidencia(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;
    final file = File(picked.path);
    final size = await file.length();
    if (!mounted) return;
    if (size > 5 * 1024 * 1024) {
      CustomAlert.show(
        context,
        title: 'Atención',
        message: 'La imagen no debe superar los 5MB',
        type: AlertType.error,
      );
      return;
    }
    setState(() => _evidencia = file);
  }

  void _showEvidenciaSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const Text(
              'Evidencia fotográfica',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ImageSourceOption(
              icon: Icons.camera_alt_rounded,
              label: 'Tomar foto',
              color: TColors.primary,
              onTap: () {
                Navigator.pop(ctx);
                _pickEvidencia(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            ImageSourceOption(
              icon: Icons.photo_library_rounded,
              label: 'Galería',
              color: TColors.goldAccent,
              onTap: () {
                Navigator.pop(ctx);
                _pickEvidencia(ImageSource.gallery);
              },
            ),
            SizedBox(height: MediaQuery.of(ctx).viewPadding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Future<GoldOperationKeyStore> _getOperationKeyStore() async {
    return _operationKeyStore ??= await GoldOperationKeyStore.create();
  }

  Future<void> _confirm() async {
    final result = _result;
    final evidencia = _evidencia;
    // Guard de doble envío: un segundo tap antes de que llegue
    // NewExtractionLoading duplicaría el lote.
    if (_phase == _VoicePhase.submitting) return;
    if (result == null || !result.isValid || evidencia == null) return;
    setState(() => _phase = _VoicePhase.submitting);

    final extractionDate = DateFormat(
      'yyyy-MM-dd',
    ).format(result.extractionDate);
    final observations = 'Registro por voz. Dictado: "${result.transcript}"';
    final store = await _getOperationKeyStore();
    final idempotencyKey = await store.getOrCreate(
      type: GoldOperationType.extraction,
      fingerprint: GoldOperationFingerprint.extraction(
        extractionDate: extractionDate,
        grossWeightGrams: result.weightGrams!,
        purityPercent: result.purityPercent,
        observations: observations,
      ),
    );
    if (!mounted) return;
    _activeIdempotencyKey = idempotencyKey;

    context.read<TreasuryBloc>().add(
      NewExtractionEvent(
        newExtractionRequets: NewExtractionRequetsEntity(
          extractionDate: extractionDate,
          grossWeightGrams: result.weightGrams!.toString(),
          purityPercent: result.purityPercent.toString(),
          observations: observations,
          evidencia: evidencia.path,
          idempotencyKey: idempotencyKey,
        ),
      ),
    );
  }

  void _edit() {
    final result = _result;
    Navigator.of(context).pop(
      VoiceExtractionEditRequest(
        peso: result?.weightGrams,
        pureza: result != null && result.purityIsValid
            ? result.purityPercent
            : null,
        observaciones:
            'Registro por voz. Dictado: "${result?.transcript ?? _transcript}"',
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TreasuryBloc, TreasuryState>(
      listener: (listenerContext, state) async {
        if (state is NewExtractionLoading) {
          setState(() => _phase = _VoicePhase.submitting);
        } else if (state is NewExtractionLoaded) {
          final completedKey = _activeIdempotencyKey;
          if (completedKey != null) {
            await (await _getOperationKeyStore()).complete(completedKey);
          }
          if (!listenerContext.mounted) return;
          setState(() {
            _phase = _VoicePhase.success;
            _batchCode = state.newExtraction.batchCode;
            _successWasRecovered = state.newExtraction.isIdempotent;
            _successMessage = state.newExtraction.isIdempotent
                ? 'La extracción ya estaba registrada. Recuperamos el lote sin duplicarlo.'
                : 'Extracción registrada correctamente en el inventario.';
            _activeIdempotencyKey = null;
          });
        } else if (state is NewExtractionError) {
          final failedKey = _activeIdempotencyKey;
          if (state.isConflict && failedKey != null) {
            await (await _getOperationKeyStore()).complete(failedKey);
            _activeIdempotencyKey = null;
          }
          if (!listenerContext.mounted) return;
          setState(() {
            _phase = _VoicePhase.review;
            _errorMessage = state.message;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                switch (_phase) {
                  _VoicePhase.listening => _buildListening(),
                  _VoicePhase.review => _buildReview(),
                  _VoicePhase.submitting => _buildSubmitting(),
                  _VoicePhase.success => _buildSuccess(),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Fase: escuchando ────────────────────────────────────────────────────
  Widget _buildListening() {
    final hasError = _errorMessage != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Registro urgente por voz',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hasError
              ? _errorMessage!
              : 'Di por ejemplo: "Registrar extracción de oro 15 gramos, pureza 96"',
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
              color: hasError ? TColors.dangerLight : TColors.warningLight,
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
              child: _SheetButton(
                label: 'Cancelar',
                outlined: true,
                onTap: () async {
                  await _voice.cancel();
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: hasError
                  ? _SheetButton(
                      label: 'Reintentar',
                      icon: Icons.refresh_rounded,
                      onTap: _startListening,
                    )
                  : _SheetButton(
                      label: 'Listo',
                      icon: Icons.check_rounded,
                      onTap: _finishListening,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Fase: revisar y confirmar ───────────────────────────────────────────
  Widget _buildReview() {
    final result = _result!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '¿Registrar esta extracción?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '"${result.transcript}"',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: TColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TColors.border),
          ),
          child: Column(
            children: [
              _ReviewRow(
                label: 'Peso',
                value: result.hasWeight
                    ? '${result.weightGrams!.toStringAsFixed(2)} g'
                    : 'No entendido',
                isError: !result.hasWeight,
              ),
              const SizedBox(height: 10),
              _ReviewRow(
                label: 'Pureza',
                value: result.purityIsValid
                    ? '${result.purityPercent.toStringAsFixed(0)}%'
                          '${result.purityWasSaid ? '' : ' (por defecto)'}'
                    : '${result.purityPercent.toStringAsFixed(0)}% (debe estar entre 90 y 99)',
                isError: !result.purityIsValid,
              ),
              const SizedBox(height: 10),
              _ReviewRow(
                label: 'Fecha',
                value:
                    _formatDate(result.extractionDate) +
                    (result.dateWasSaid ? '' : ' (hoy)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildEvidenciaPicker(),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: TColors.danger),
          ),
        ],
        const SizedBox(height: 20),
        if (result.isValid) ...[
          _SheetButton(
            label: _evidencia == null
                ? 'Agrega la evidencia para registrar'
                : 'Confirmar y registrar',
            icon: _evidencia == null
                ? Icons.add_a_photo_rounded
                : Icons.check_rounded,
            expanded: true,
            enabled: _evidencia != null,
            onTap: _confirm,
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: _SheetButton(
                label: 'Reintentar',
                icon: Icons.mic_rounded,
                outlined: true,
                onTap: _startListening,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SheetButton(
                label: 'Editar',
                icon: Icons.edit_rounded,
                outlined: true,
                onTap: _edit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Selector de evidencia dentro de la confirmación ────────────────────
  Widget _buildEvidenciaPicker() {
    final evidencia = _evidencia;
    if (evidencia == null) {
      return GestureDetector(
        onTap: _showEvidenciaSourceSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: TColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: TColors.primary.withValues(alpha: 0.35),
              width: 1.4,
            ),
          ),
          child: const Column(
            children: [
              Icon(Icons.add_a_photo_rounded, size: 30, color: TColors.primary),
              SizedBox(height: 8),
              Text(
                'Agregar evidencia fotográfica',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Obligatoria · cámara o galería',
                style: TextStyle(fontSize: 11.5, color: TColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              evidencia,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evidencia adjunta',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lista para enviar',
                  style: TextStyle(fontSize: 11.5, color: TColors.success),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showEvidenciaSourceSheet,
            icon: const Icon(
              Icons.autorenew_rounded,
              size: 20,
              color: TColors.textSecondary,
            ),
            tooltip: 'Cambiar foto',
          ),
          IconButton(
            onPressed: () => setState(() => _evidencia = null),
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: TColors.danger,
            ),
            tooltip: 'Quitar foto',
          ),
        ],
      ),
    );
  }

  // ── Fase: enviando ──────────────────────────────────────────────────────
  Widget _buildSubmitting() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffLoader(),
          SizedBox(height: 16),
          Text(
            'Registrando extracción…',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Fase: éxito ─────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: TColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 36,
            color: TColors.success,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _successWasRecovered
              ? 'Extracción recuperada'
              : 'Extracción registrada',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _successMessage.isNotEmpty
              ? '$_successMessage — Lote $_batchCode'
              : 'Se registró el lote $_batchCode.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: TColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        _SheetButton(
          label: 'Volver al Inventario',
          icon: Icons.inventory_rounded,
          expanded: true,
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? TColors.danger : TColors.textPrimary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: TColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool outlined;
  final bool expanded;
  final bool enabled;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.outlined = false,
    this.expanded = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );

    final button = SizedBox(
      width: expanded ? double.infinity : null,
      height: 48,
      child: outlined
          ? OutlinedButton(
              onPressed: enabled ? onTap : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.textPrimary,
                side: const BorderSide(color: TColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: enabled ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: TColors.primary.withValues(
                  alpha: 0.35,
                ),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: child,
            ),
    );
    return button;
  }
}
