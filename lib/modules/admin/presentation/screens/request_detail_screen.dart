import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/zoomable_evidence_image.dart';
import '../../domain/entity/entity.dart';
import '../bloc/admin_bloc.dart';

@RoutePage()
class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late final AdminBloc _adminBloc;

  @override
  void initState() {
    super.initState();
    // 1. Obtenemos una nueva instancia del bloc desde tu inyector
    _adminBloc = InjectorContainer.getIt<AdminBloc>();
    // 2. Disparamos el evento
    _adminBloc.add(GetRequestDetailEvent(widget.requestId));
  }

  @override
  void dispose() {
    _adminBloc.close(); // Cerramos esta instancia local cuando salimos de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3. Proveemos el bloc localmente a esta vista
    return BlocProvider.value(
      value: _adminBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA), // Mismo fondo que tu Home
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1A3557)),
          title: const Text(
            'Detalle de la Solicitud',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A3557),
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          buildWhen: (previous, current) => 
              current is AdminRequestDetailLoading || 
              current is AdminRequestDetailLoaded || 
              current is AdminRequestDetailError,
          builder: (context, state) {
            if (state is AdminRequestDetailLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1A3557)));
            }
            if (state is AdminRequestDetailError) {
              return _buildError(state.message);
            }
            if (state is AdminRequestDetailLoaded) {
              return _buildContent(context, state.detail);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RequestDetailEntity detail) {
    final dateFormatted = DateFormat('dd MMM, yyyy • hh:mm a', 'es') .format(detail.fechaRegistro.toLocal());
    final montoFormatted =  NumberFormat('#,##0.00', 'es').format(detail.monto);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A3557).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: #${detail.requestId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        detail.rol.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Solicitante',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                Text(
                  detail.solicitante,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _buildInfoRow(Icons.calendar_today_outlined, 'Fecha', dateFormatted),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.receipt_long_outlined, 'Descripción', detail.descripcion),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.attach_money_outlined, 'Monto', 'Bs $montoFormatted', isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── TARJETA DE ESTADOS ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A3557).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de Aprobaciones',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusRow('Vigilancia', detail.estadoVigilancia),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _buildStatusRow('Administración', detail.estadoAdministracion),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── EVIDENCIA VISUAL ──
          const Text(
            'Evidencia Adjunta',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 12),
          ZoomableEvidenceImage(
            imageUrl: detail.evidenciaUrl,
            height: 250,
            heroTag: 'evidencia_${detail.requestId}',
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE8533F)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: Lógica para rechazar
                  },
                  child: const Text(
                    'Rechazar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE8533F),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF10B981), // Verde
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // TODO: Lógica para aprobar
                  },
                  child: const Text(
                    'Aprobar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status) {
    Color statusColor;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'aprobado':
        statusColor = const Color(0xFF10B981);
        bgColor = const Color(0xFFECFDF5);
        break;
      case 'rechazado':
        statusColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEF2F2);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFFFBEB);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: statusColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => _adminBloc.add(GetRequestDetailEvent(widget.requestId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1A3557)),
            ),
          ],
        ),
      ),
    );
  }
}