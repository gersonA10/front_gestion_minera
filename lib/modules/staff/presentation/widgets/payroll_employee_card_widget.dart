import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class PayrollEmployeeCardWidget extends StatelessWidget {
  final String name;
  final String position;
  final String employeeId;
  final String amount;
  final bool paid;
  final String? imageUrl;
  final VoidCallback? onTap;

  const PayrollEmployeeCardWidget({
    super.key,
    required this.name,
    required this.position,
    required this.employeeId,
    required this.amount,
    required this.paid,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = paid ? TColors.green : TColors.amber;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.greyShade200),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!paid) Container(width: 4, color: TColors.amber),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: TColors.greyShade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl != null && imageUrl!.trim().isNotEmpty
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: TColors.appDisabledColor,
                                ),
                              )
                            : const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: TColors.appDisabledColor,
                              ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: TColors.appMainDarkColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$position • ID: #$employeeId',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Bs $amount',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: TColors.appMainDarkColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              paid ? 'PAGADO' : 'PENDIENTE',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
