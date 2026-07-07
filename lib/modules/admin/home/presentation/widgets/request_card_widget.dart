import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/admin/home/presentation/bloc/admin_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/entity.dart';

class SolicitudCard extends StatelessWidget {
  final PendingRequestEntity solicitud;
  final int index;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    required this.index,
  });

  String get _shortId {
    final clean = solicitud.requestId.replaceAll('-', '');
    if (clean.isEmpty) return '--------';
    return clean.substring(0, clean.length.clamp(0, 8)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final date = solicitud.fechaRegistro.toLocal();
    final dateFormatted = DateFormat('dd MMM, hh:mm a', 'es').format(date);
    final montoFormatted =
        NumberFormat('#,##0.00', 'es').format(solicitud.monto);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3557).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF1A3557).withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final result = await context.router.push(
              RequestDetailRoute(requestId: solicitud.requestId),
            );
            if (!context.mounted) return;
            if (result == true) {
              context.read<AdminBloc>().add(
                GetPendingRequestsEvent(isRefresh: true),
              );
              context.read<AdminBloc>().add(
                GetRequestHistoryEvent(status: 'todos'),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Encabezado: avatar · nombre/rol · monto ──
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3557), Color(0xFF2A4D78)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        solicitud.initials,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            solicitud.solicitante,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${solicitud.rol.isEmpty ? 'Sin rol' : solicitud.rol} · #$_shortId',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'MONTO',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bs $montoFormatted',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A3557),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Descripción ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          solicitud.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            color: Color(0xFF475569),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Pie: estado de vigilancia · fecha · chevron ──
                Row(
                  children: [
                    _VigilanciaChip(estado: solicitud.estadoVigilancia),
                    const Spacer(),
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormatted,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFFC2CCD9),
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

/// Chip que muestra qué decidió Vigilancia sobre la solicitud — contexto clave
/// para que el Admin decida de un vistazo.
class _VigilanciaChip extends StatelessWidget {
  final String estado;
  const _VigilanciaChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final e = estado.toLowerCase();
    Color color;
    Color bg;
    String label;
    IconData icon;

    if (e.contains('approv') || e.contains('aprob')) {
      color = const Color(0xFF15A06A);
      bg = const Color(0xFFE7F7F0);
      label = 'Vigilancia aprobó';
      icon = Icons.verified_user_outlined;
    } else if (e.contains('reject') || e.contains('rechaz')) {
      color = const Color(0xFFE8533F);
      bg = const Color(0xFFFDEDEA);
      label = 'Vigilancia rechazó';
      icon = Icons.gpp_bad_outlined;
    } else {
      color = const Color(0xFFC77700);
      bg = const Color(0xFFFFF7EA);
      label = 'En vigilancia';
      icon = Icons.shield_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
