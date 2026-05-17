import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class MinutesMemosCardPanelWidget extends StatelessWidget {
  final String tipo;
  final String numero;
  final String titulo;
  final String? descripcion;
  final String? destinatario;
  final String fecha;
  final String estado;
  final String? actualizado;
  final String itemId;

  const MinutesMemosCardPanelWidget({
    super.key,
    required this.itemId,
    required this.tipo,
    required this.numero,
    required this.titulo,
    this.descripcion,
    this.destinatario,
    required this.fecha,
    required this.estado,
    this.actualizado,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMinute = tipo == 'minute';
    final Color tagColor = isMinute ? TColors.appMainColor : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha:  0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isMinute ? 'ACTA NO. $numero' : 'MEMORANDO N° $numero',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, size: 18),
                      splashRadius: 18,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TColors.cardInnerBg,
                  ),
                ),

                const SizedBox(height: 6),
                if (isMinute && descripcion != null) ...[
                  Text(
                    descripcion!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.appDisabledColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                ],

                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      fecha,
                      style: const TextStyle(
                        fontSize: 11,
                        color: TColors.appDisabledColor,
                      ),
                    ),
                  ],
                ),
                if (!isMinute && destinatario != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          destinatario!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: TColors.appDisabledColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          estado.toLowerCase() == 'finalizado'
                              ? Icons.check_circle_outline
                              : Icons.access_time,
                          size: 12,
                          color: TColors.appDisabledColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          estado,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: TColors.appDisabledColor,
                          ),
                        ),
                      ],
                    ),
                    if (actualizado != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        actualizado!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: TColors.appDisabledColor,
                        ),
                      ),
                    ],
                  ],
                ),

           
                  TextButton(
                    onPressed: () {
                      if (isMinute) {
                        context.router.push(
                          ActaDetailsRoute(actaId: itemId),
                        );
                      } else {
                        context.router.push(
                          InternalMemorandumDetailsRoute(memoId: itemId),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: TColors.appMainColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Ver Detalles',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12),
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
