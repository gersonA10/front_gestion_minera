import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class CurrentShiftCard extends StatelessWidget {
  final String? workerPhoto;
  final TimeOfDay startTime;
  final String Function(TimeOfDay) formatearHora;

  const CurrentShiftCard({
    super.key,
    this.workerPhoto,
    required this.startTime,
    required this.formatearHora,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Color.fromRGBO(0, 0, 0, .04)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: workerPhoto != null && workerPhoto!.isNotEmpty
                ? NetworkImage(workerPhoto!)
                : null,
            child: workerPhoto == null || workerPhoto!.isEmpty
                ? const Icon(Icons.person_outline, size: 30, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TURNO ACTUAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TColors.disabled,
                  ),
                ),

                const SizedBox(height: 8),

                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Entrada: ',
                        style: TextStyle(color: TColors.appMainTextColor),
                      ),

                      TextSpan(
                        text: formatearHora(startTime),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),

                    SizedBox(width: 4),

                    Text(
                      'En planta - Sector Norte',
                      style: TextStyle(color: Colors.green, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}