import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/actas_theme.dart';

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

  bool get _isMinute => tipo == 'minute';
  Color get _accent => _isMinute ? AC.acta : AC.memo;

  void _openDetail(BuildContext context) {
    if (_isMinute) {
      context.router.push(ActaDetailsRoute(actaId: itemId));
    } else {
      context.router.push(InternalMemorandumDetailsRoute(memoId: itemId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFinalizado = estado.toLowerCase() == 'finalizado';
    final statusColor = isFinalizado ? AC.green : AC.amber;
    final statusBg = isFinalizado ? AC.greenBg : AC.amberBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AC.border),
        boxShadow: const [
          BoxShadow(color: AC.cardShadow, blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _accent,
                            Color.lerp(_accent, Colors.white, 0.3)!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isMinute
                            ? Icons.article_rounded
                            : Icons.mail_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isMinute
                                ? 'ACTA N.° $numero'
                                : 'MEMORANDO N.° $numero',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _accent,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AC.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isMinute && descripcion != null && descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    descripcion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AC.textSecondary,
                    ),
                  ),
                ],
                if (!_isMinute &&
                    destinatario != null &&
                    destinatario!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AC.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          destinatario!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AC.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1, color: AC.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // El estado (Pendiente/Finalizado) aplica solo a memorandos.
                    // En actas no se muestra.
                    if (!_isMinute) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFinalizado
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                              size: 12,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              estado,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: AC.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        actualizado ?? fecha,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AC.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: _accent,
                        ),
                      ],
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
