
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/transaction_details_screen.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:share_plus/share_plus.dart';

class LoadedView extends StatefulWidget {
  final dynamic details;

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

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Comprobante de Pago - ${res.referencia}');
    } catch (e) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'No se pudo generar el PDF: ${e.toString()}',
        type: AlertType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.details;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                _AmountHeader(monto: res.monto.toString()),
                const SizedBox(height: 28),
                _InfoCard(
                  concepto: res.concepto,
                  responsable: res.responsablePago,
                  cajaOrigen: res.cajaAfectada,
                  fechaHora: formatDate(res.fechaHora),
                  referencia: res.referencia,
                ),
                const SizedBox(height: 24),
                _AttachmentsSection(
                  imageUrls:
                      (res.comprobantesAdjuntos != null &&
                          res.comprobantesAdjuntos.toString().isNotEmpty)
                      ? res.comprobantesAdjuntos
                            .toString()
                            .split(',')
                            .map<String>((e) => e.trim())
                            .where((String e) => e.isNotEmpty)
                            .toList()
                      : [],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _DownloadButton(isLoading: _isGeneratingPdf, onPressed: _downloadPdf),
      ],
    );
  }
}

class _AmountHeader extends StatelessWidget {
  final String monto;

  const _AmountHeader({required this.monto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Monto Total',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            monto,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 6),
                Text(
                  'Pagado Exitosamente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
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

class _InfoCard extends StatelessWidget {
  final String concepto;
  final String responsable;
  final String cajaOrigen;
  final String fechaHora;
  final String referencia;

  const _InfoCard({
    required this.concepto,
    required this.responsable,
    required this.cajaOrigen,
    required this.fechaHora,
    required this.referencia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: Color(0xFF3B82F6),
              ),
              SizedBox(width: 8),
              Text(
                'Información General',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'Concepto', value: concepto),
          _InfoRow(
            label: 'Responsable',
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  responsable,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Tesorería',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          _InfoRow(label: 'Caja Origen', value: cajaOrigen),
          _InfoRow(label: 'Fecha y Hora', value: fechaHora),
          _InfoRow(
            label: 'ID Referencia',
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                referencia,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: Color(0xFF374151),
                ),
              ),
            ),
            hasDivider: false,
          ),
        ],
      ),
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  final List<String> imageUrls;

  const _AttachmentsSection({required this.imageUrls});

  void _showImagePreview(BuildContext context, String url, int index) {
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
        const Text(
          'Comprobantes Adjuntos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...imageUrls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < imageUrls.length ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _showImagePreview(context, url, index),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 28,
                                    color: Color(0xFFD1D5DB),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha:  0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.zoom_out_map_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
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
                          loadingBuilder: (_, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            final total = loadingProgress.expectedTotalBytes;
                            final current =
                                loadingProgress.cumulativeBytesLoaded;
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
                          errorBuilder: (_, __, ___) => Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 48,
                                  color: Colors.white38,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No se pudo cargar la imagen',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
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
                    color: Colors.black.withValues(alpha:  0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),

            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: MediaQuery.of(context).viewPadding.bottom + 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Contador
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:  0.6),
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}


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
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            disabledBackgroundColor: const Color(0xFF475569),
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
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Generando PDF...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Descargar Comprobante PDF',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child:
                    valueWidget ??
                    Text(
                      value ?? '',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
              ),
            ],
          ),
        ),
        if (hasDivider) const Divider(height: 1, color: Color(0xFFF3F4F6)),
      ],
    );
  }
}
