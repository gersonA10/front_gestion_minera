import 'package:flutter/material.dart';
import 'package:front_gestion_minera/core/widgets/zoomable_evidence_image.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/detail_maintenance_entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/status_mapper.dart';

class DetailBody extends StatelessWidget {
  final DetailMaintenanceResponseEntity detail;

  const DetailBody({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _MachineCard(detail: detail),

          const SizedBox(height: 16),

          _SectionTitle(title: "Descripción"),
          SizedBox(height: 12),
          _DescriptionCard(description: detail.description),

          const SizedBox(height: 16),

          _CostCard(amount: detail.estimatedAmount),

          const SizedBox(height: 20),

          _SectionTitle(title: "Evidencia"),
          SizedBox(height: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              detail.machine.photoUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusChip(
                   status: detail.request.globalStatus.toSpanish,
                ),

                const SizedBox(height: 8),

                Text(
                  detail.machine.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "FECHA DE SOLICITUD",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                Text(
                  _formatDate(detail.requestedAt),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Text(description),
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
          const CircleAvatar(
            backgroundColor: TColors.primary,
            child: Icon(Icons.wallet),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "COSTO ESTIMADO",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "${amount.toStringAsFixed(2)} Bs",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
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
    if (url.isEmpty) {
      return const Text("Sin evidencia");
    }

    return ZoomableEvidenceImage(
      imageUrl: url,
      // child: ClipRRect(
      //   borderRadius: BorderRadius.circular(12),
      //   child: Image.network(
      //     url,
      //     height: 180,
      //     width: double.infinity,
      //     fit: BoxFit.cover,
      //   ),
      // ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}


class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status.toLowerCase()) {
      case "completed":
      case "completado":
        color = Colors.green;
        break;
      case "pending":
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.description_outlined, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}