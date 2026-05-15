import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
class AttachmentItem {
  final String tipo; 
  final String nombre;
  final String peso;

  AttachmentItem({
    required this.tipo,
    required this.nombre,
    required this.peso,
  });
}

class AttachmentsSectionWidget extends StatelessWidget {
  final List<AttachmentItem> items;

  const AttachmentsSectionWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.attach_file, size: 18, color: Colors.blueGrey), 
            const SizedBox(width: 6),
            Text(
              'Archivos Adjuntos (${items.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TColors.appBackgroundDarkColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Column(
          children: items
              .map((item) => _buildAttachmentItem(item))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAttachmentItem(AttachmentItem item) {
    final isPdf = item.tipo == 'pdf';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPdf ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image,
              color: isPdf ? Colors.red : Colors.blue,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TColors.appMainTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.peso,
                  style: TextStyle(
                    fontSize: 11,
                    color: TColors.appDisabledColor,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}