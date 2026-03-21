import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

import '../../domain/entity/entity.dart';

class SurveillanceHistoryCard extends StatelessWidget {
  final SurveillanceHistoryEntity item;
  const SurveillanceHistoryCard({super.key, required this.item});

  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'aprobado':
        return colors.green;
      case 'pendiente':
        return colors.amber;
      case 'rechazado':
        return colors.red;
      default:
        return colors.lead;
    }
  }

  void _showRejectionDialog(
    BuildContext context, {
    required ColorScheme colors,
    required String rejectionReason,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Motivo de rechazo',
                  style: AppTextStyles.mainStyle16Bold(
                    context,
                  ).copyWith(color: colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.red.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.red.withOpacity(0.18)),
                  ),
                  child: Text(
                    rejectionReason,
                    style: AppTextStyles.mainStyle12(
                      context,
                    ).copyWith(color: colors.black, height: 1.4),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.blue,
                      foregroundColor: colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Entendido',
                      style: AppTextStyles.mainStyle12Bold(
                        context,
                      ).copyWith(color: colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(item.estado, colors);

    final bool isRejected = item.estado.toLowerCase() == 'rechazado';
    final bool hasReason =
        item.motivoRechazo != null && item.motivoRechazo!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDate(item.createdAt).toUpperCase(),
                      style: AppTextStyles.mainStyle10Bold(
                        context,
                      ).copyWith(color: colors.lead, letterSpacing: 0.5),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        item.estado.toUpperCase(),
                        style: AppTextStyles.mainStyle10Bold(
                          context,
                        ).copyWith(color: statusColor, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.name,
                  style: AppTextStyles.mainStyle16Bold(
                    context,
                  ).copyWith(color: colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: AppTextStyles.mainStyle12(
                    context,
                  ).copyWith(color: colors.lead.withOpacity(0.9)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isRejected && hasReason)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showRejectionDialog(
                            context,
                            colors: colors,
                            rejectionReason: item.motivoRechazo!,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                                color: colors.red,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Ver motivo',
                                  style: AppTextStyles.mainStyle10(context)
                                      .copyWith(
                                        color: colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Spacer(),

                    GestureDetector(
                      onTap: () {
                        context.router.push(
                          ApplicationDetailsRoute(
                            requestId: item  .requestId, // De tu SurveillanceHistoryDataEntity
                            createdAt: item.createdAt,
                            name: item.name,
                            rol: item.rol,
                            description: item.description,
                            amount: item.amount,
                            evidencia: item.evidencia,
                            status: item.estado,
                            motivoRechazo: item.motivoRechazo,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VER DETALLE',
                            style: AppTextStyles.mainStyleBlue12Bold(context),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
