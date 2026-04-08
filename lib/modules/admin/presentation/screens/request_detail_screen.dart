import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_loading_overlay.dart';
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
  RequestDetailEntity? _cachedDetail;

  @override
  void initState() {
    super.initState();
    _adminBloc = InjectorContainer.getIt<AdminBloc>();
    _adminBloc.add(GetRequestDetailEvent(widget.requestId));
  }

  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Aprobar Solicitud',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3557),
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas aprobar esta solicitud? Pasará a la siguiente fase de revisión.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);

              _adminBloc.add(
                ProcessAdminRequestEvent(
                  id: widget.requestId,
                  action: 'aprobado',
                ),
              );
            },
            child: const Text(
              'Confirmar Aprobación',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Rechazar Solicitud',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3557),
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Por favor, indica el motivo del rechazo.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ej. Falta de evidencia, monto incorrecto...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1A3557)),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'El motivo es obligatorio'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (!mounted) return;
                  _adminBloc.add(
                    ProcessAdminRequestEvent(
                      id: widget.requestId,
                      action: 'rechazado',
                      reason: reasonController.text.trim(),
                    ),
                  );
                });
              }
            },
            child: const Text(
              'Confirmar Rechazo',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _adminBloc,
      child: BlocConsumer<AdminBloc, AdminState>(
        listenWhen: (previous, current) =>
            current is AdminActionSuccess || current is AdminActionError,
        listener: (context, state) {
          if (state is AdminActionError) {
            CustomAlert.show(
              context,
              title: 'Error',
              message: state.message,
              type: AlertType.error,
            );
          } else if (state is AdminActionSuccess) {
            CustomAlert.show(
              context,
              title: 'Éxito',
              message: state.response.message,
              type: AlertType.success,
            );
            context.router.maybePop(true);
          }
        },
        builder: (context, state) {
          if (state is AdminRequestDetailLoaded) {
            _cachedDetail = state.detail;
          }

          final isLoading = state is AdminActionLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF4F6FA),
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
            body: AppLoadingOverlay(
              isLoading: isLoading,
              message: 'Procesando solicitud...',
              loader: const ExcavatorLoader(),
              child: _buildBody(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(AdminState state) {
    if (state is AdminRequestDetailLoading && _cachedDetail == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A3557)),
      );
    }

    if (state is AdminRequestDetailError && _cachedDetail == null) {
      return _buildError(state.message);
    }

    if (_cachedDetail != null) {
      return _buildContent(context, _cachedDetail!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, RequestDetailEntity detail) {
    final dateFormatted = DateFormat(
      'dd MMM, yyyy • hh:mm a',
      'es',
    ).format(detail.fechaRegistro.toLocal());
    final montoFormatted = NumberFormat('#,##0.00', 'es').format(detail.monto);

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
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Solicitante',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
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
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Fecha',
                  dateFormatted,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.receipt_long_outlined,
                  'Descripción',
                  detail.descripcion,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.attach_money_outlined,
                  'Monto',
                  'Bs $montoFormatted',
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: detail.evidenciaUrl.isNotEmpty
                ? Image.network(
                    detail.evidenciaUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A3557),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: const Color(0xFFF8FAFC),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Error al cargar la imagen',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: 150,
                    color: const Color(0xFFF8FAFC),
                    child: const Center(
                      child: Text(
                        'Sin evidencia adjunta',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          if (detail.estadoAdministracion.toLowerCase() == 'pendiente') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE8533F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _showRejectDialog,
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
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _showApproveDialog,
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
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
  }) {
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
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () =>
                  _adminBloc.add(GetRequestDetailEvent(widget.requestId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1A3557),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
