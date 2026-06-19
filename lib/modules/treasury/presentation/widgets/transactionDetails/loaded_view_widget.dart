import 'package:flutter/material.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/transaction_details_screen.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/entity/entity.dart';

class _C {
  static const primary = Color(0xFF1A56FF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
  static const surface = Color(0xFFFFFFFF);
}

class _TypeStyle {
  final Color c1;
  final Color c2;
  final String sign;
  final IconData icon;
  final String label;
  const _TypeStyle(this.c1, this.c2, this.sign, this.icon, this.label);
}

_TypeStyle _typeStyle(String t) {
  final s = t.toLowerCase();
  if (s.contains('income') || s.contains('ingreso')) {
    return const _TypeStyle(Color(0xFF17A05D), Color(0xFF0E7A47), '+',
        Icons.south_west_rounded, 'Ingreso');
  }
  if (s.contains('transfer')) {
    return const _TypeStyle(Color(0xFF475569), Color(0xFF1E293B), '',
        Icons.swap_horiz_rounded, 'Transferencia');
  }
  return const _TypeStyle(_C.primary, Color(0xFF0B33B8), '-',
      Icons.north_east_rounded, 'Egreso');
}

String _money(num v) => 'Bs ${NumberFormat('#,##0.00', 'en_US').format(v)}';

class LoadedView extends StatefulWidget {
  final TransactionDetailsResponseEntity details;

  const LoadedView({super.key, required this.details});

  @override
  State<LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<LoadedView> {
  bool _isGeneratingPdf = false;

  Future<void> _downloadPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final res = widget.details;
      final file = await TransactionPdfService.generateComprobante(
        concepto: res.concepto,
        responsable: res.responsablePago,
        cajaOrigen: res.cajaAfectada,
        fechaHora: formatDate(res.fechaHora),
        referencia: res.referencia,
        monto: res.monto.toString(),
        estado: 'Pagado Exitosamente',
      );
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Comprobante de Pago - ${res.referencia}',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'No se pudo generar el PDF: ${e.toString()}',
        type: AlertType.error,
      );
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.details;
    final attachments = (res.comprobantesAdjuntos ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Hero(monto: res.monto, tipoOperacion: res.tipoOperacion),
                const SizedBox(height: 20),
                _InfoCard(details: res),
                const SizedBox(height: 20),
                if (attachments.isEmpty)
                  const _NoAttachments()
                else
                  _AttachmentsSection(imageUrls: attachments),
              ],
            ),
          ),
        ),
        _DownloadButton(isLoading: _isGeneratingPdf, onPressed: _downloadPdf),
      ],
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final int monto;
  final String tipoOperacion;
  const _Hero({required this.monto, required this.tipoOperacion});

  Widget _circle(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c),
      );

  @override
  Widget build(BuildContext context) {
    final st = _typeStyle(tipoOperacion);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [st.c1, st.c2],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: st.c1.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -24,
            child: _circle(110, Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(st.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  'Monto de la transacción',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${st.sign}${_money(monto)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 15, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '${st.label} · Completada',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

// ─── Info ────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final TransactionDetailsResponseEntity details;
  const _InfoCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final st = _typeStyle(details.tipoOperacion);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: _C.primary),
              SizedBox(width: 8),
              Text(
                'Información general',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Concepto', value: details.concepto),
          _InfoRow(label: 'Tipo de operación', value: st.label),
          if (details.solicitanteOriginal.trim().isNotEmpty)
            _InfoRow(label: 'Solicitante', value: details.solicitanteOriginal),
          _InfoRow(
            label: 'Responsable',
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  details.responsablePago,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Tesorería',
                  style: TextStyle(fontSize: 11.5, color: _C.textSecondary),
                ),
              ],
            ),
          ),
          _InfoRow(label: 'Caja afectada', value: details.cajaAfectada),
          _InfoRow(label: 'Fecha y hora', value: formatDate(details.fechaHora)),
          _InfoRow(
            label: 'ID Referencia',
            hasDivider: false,
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _C.border),
              ),
              child: Text(
                details.referencia,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: _C.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool hasDivider;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.hasDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _C.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: valueWidget ??
                    Text(
                      value ?? '',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
              ),
            ],
          ),
        ),
        if (hasDivider) const Divider(height: 1, color: _C.border),
      ],
    );
  }
}

// ─── Adjuntos ────────────────────────────────────────────────────────────────

class _NoAttachments extends StatelessWidget {
  const _NoAttachments();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 30, color: _C.textSecondary),
          SizedBox(height: 10),
          Text(
            'Sin comprobante adjunto',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Esta transacción no tiene evidencia o es una transferencia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _C.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  final List<String> imageUrls;
  const _AttachmentsSection({required this.imageUrls});

  void _showImagePreview(BuildContext context, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) =>
          _ImagePreviewDialog(imageUrls: imageUrls, initialIndex: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Comprobantes adjuntos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${imageUrls.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _C.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final url = imageUrls[index];
              return GestureDetector(
                onTap: () => _showImagePreview(context, index),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _C.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image_rounded,
                              size: 28, color: _C.textSecondary),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.zoom_out_map_rounded,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ImagePreviewDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ImagePreviewDialog({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.imageUrls[i],
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            final total = progress.expectedTotalBytes;
                            final current = progress.cumulativeBytesLoaded;
                            return SizedBox(
                              width: 200,
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: total != null ? current / total : null,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, _, _) => Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_rounded,
                                    size: 48, color: Colors.white38),
                                SizedBox(height: 8),
                                Text(
                                  'No se pudo cargar la imagen',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).viewPadding.top + 12,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: MediaQuery.of(context).viewPadding.bottom + 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

// ─── Botón descargar ─────────────────────────────────────────────────────────

class _DownloadButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _DownloadButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F2D4D),
            disabledBackgroundColor: const Color(0xFF64748B),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Generando PDF...',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Descargar comprobante PDF',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}
