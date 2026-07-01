import 'package:flutter/material.dart';
import 'package:front_gestion_minera/core/widgets/app_network_image.dart';
import 'package:front_gestion_minera/core/widgets/zoomable_evidence_image.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/detail_maintenance_entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/status_mapper.dart';
import 'package:intl/intl.dart';

class DetailBody extends StatelessWidget {
  final DetailMaintenanceResponseEntity detail;

  const DetailBody({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MachineCard(detail: detail),
          const SizedBox(height: 20),
          const _SectionTitle(
            title: 'Descripción',
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 12),
          _DescriptionCard(description: detail.description),
          const SizedBox(height: 16),
          _CostCard(amount: detail.estimatedAmount),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: 'Evidencia',
            icon: Icons.image_outlined,
          ),
          const SizedBox(height: 12),
          _EvidenceImage(url: detail.evidenceUrl),
        ],
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final DetailMaintenanceResponseEntity detail;

  const _MachineCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNetworkImage(
            url: detail.machine.photoUrl,
            height: 180,
            width: double.infinity,
            errorIcon: Icons.image_not_supported_rounded,
            errorIconSize: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusChip(status: detail.request.globalStatus.toSpanish),
                const SizedBox(height: 10),
                Text(
                  detail.machine.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.tag_rounded,
                        size: 14, color: TColors.textSecondary),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${detail.machine.uniqueCode}  ·  ${detail.machine.type}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: TColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'FECHA DE SOLICITUD',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w700,
                    color: TColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(detail.requestedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
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

String _formatDate(DateTime date) =>
    DateFormat('dd MMM yyyy', 'es').format(date);

/// Formatea un entero como monto en bolivianos con separadores de miles.
String _money(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${value < 0 ? '-' : ''}${buf.toString()} Bs';
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    final text = description.trim();
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Text(
        text.isEmpty ? 'Sin descripción' : text,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: text.isEmpty ? TColors.textSecondary : TColors.textPrimary,
        ),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final int amount;

  const _CostCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_rounded,
                color: TColors.appMainColor, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COSTO ESTIMADO',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w700,
                  color: TColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _money(amount),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceImage extends StatelessWidget {
  final String url;

  const _EvidenceImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: _cardDecoration(),
        child: const Column(
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: TColors.textSecondary, size: 30),
            SizedBox(height: 8),
            Text(
              'Sin evidencia adjunta',
              style: TextStyle(color: TColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ZoomableEvidenceImage(imageUrl: url);
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: TColors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: TColors.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

({Color color, Color bg}) _statusStyle(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
    case 'COMPLETADO':
    case 'APROBADO':
    case 'PAGADO':
      return (color: TColors.success, bg: TColors.successLight);
    case 'PENDING':
    case 'PENDIENTE':
    case 'EN REVISIÓN':
      return (color: TColors.warning, bg: TColors.warningLight);
    case 'REJECTED':
    case 'RECHAZADO':
      return (color: TColors.danger, bg: TColors.dangerLight);
    default:
      return (color: TColors.textSecondary, bg: TColors.background);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final st = _statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: st.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: st.color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: TColors.appMainColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: TColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
