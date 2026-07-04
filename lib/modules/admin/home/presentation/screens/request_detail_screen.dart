import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/zoomable_evidence_image.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:intl/intl.dart';

import '../../../../../core/widgets/app_loading_overlay.dart';
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

  bool _isPendiente(RequestDetailEntity d) =>
      d.estadoAdministracion.toLowerCase() == 'pendiente';

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }
    return '??';
  }

  String _shortId(String id) {
    final clean = id.replaceAll('-', '');
    if (clean.isEmpty) return '--------';
    return clean.substring(0, clean.length.clamp(0, 8)).toUpperCase();
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
              backgroundColor: const Color(0xFF15A06A),
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
              backgroundColor: const Color(0xFFE8533F),
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
          final detail = _cachedDetail;
          final showActions = detail != null && _isPendiente(detail);

          return Scaffold(
            backgroundColor: const Color(0xFFF4F6FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF4F6FA),
              elevation: 0,
              scrolledUnderElevation: 0,
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
              message: '',
              loader: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 168,
                  height: 172,
                  child: StaffLoader(label: 'Procesando'),
                ),
              ),
              child: _buildBody(state),
            ),
            bottomNavigationBar: showActions ? _buildActionBar(isLoading) : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(AdminState state) {
    if (state is AdminRequestDetailLoading && _cachedDetail == null) {
      return const StaffLoader();
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

    final vigilanciaSub = detail.vigilanciaAprobadoEl != null
        ? DateFormat('dd MMM, yyyy • hh:mm a', 'es')
              .format(detail.vigilanciaAprobadoEl!.toLocal())
        : null;
    final adminSub = _isPendiente(detail) ? 'Esperando tu decisión' : null;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero: monto + solicitante + estado ──
          _buildHero(detail, dateFormatted, montoFormatted),
          const SizedBox(height: 20),

          // ── Timeline de aprobación ──
          _buildCard(
            title: 'Flujo de aprobación',
            child: Column(
              children: [
                _TimelineStep(
                  label: 'Vigilancia',
                  status: detail.estadoVigilancia,
                  subtitle: vigilanciaSub,
                ),
                _TimelineStep(
                  label: 'Administración',
                  status: detail.estadoAdministracion,
                  subtitle: adminSub,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Descripción ──
          _buildCard(
            title: 'Descripción',
            child: Text(
              detail.descripcion.isEmpty ? 'Sin descripción' : detail.descripcion,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Evidencia (zoomable) ──
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Evidencia adjunta',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B2A),
              ),
            ),
          ),
          ZoomableEvidenceImage(
            imageUrl: detail.evidenciaUrl,
            height: 250,
            heroTag: 'evidence-${detail.requestId}',
          ),
        ],
      ),
    );
  }

  Widget _buildHero(
    RequestDetailEntity detail,
    String dateFormatted,
    String montoFormatted,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF152D49), Color(0xFF20416B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF152D49).withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(detail.solicitante),
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
                      detail.solicitante,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.rol.isEmpty ? 'Sin rol' : detail.rol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _HeroStatusPill(status: detail.estadoAdministracion),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'MONTO SOLICITADO',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Bs $montoFormatted',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.tag_rounded,
                size: 13,
                color: Colors.white.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 4),
              Text(
                _shortId(detail.requestId),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: Colors.white.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  dateFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3557).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _showRejectDialog,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text(
                    'Rechazar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE8533F),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Color(0xFFE8533F), width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _showApproveDialog,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text(
                    'Aprobar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15A06A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

/// Pill de estado para el hero oscuro (colores claros legibles sobre navy).
class _HeroStatusPill extends StatelessWidget {
  final String status;
  const _HeroStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color c;
    String label;
    switch (status.toLowerCase()) {
      case 'aprobado':
        c = const Color(0xFF34D399);
        label = 'Aprobado';
        break;
      case 'rechazado':
        c = const Color(0xFFF87171);
        label = 'Rechazado';
        break;
      default:
        c = const Color(0xFFFBBF24);
        label = 'Pendiente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paso del timeline de aprobación (Vigilancia → Administración).
class _TimelineStep extends StatelessWidget {
  final String label;
  final String status;
  final String? subtitle;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.status,
    this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    IconData icon;
    String statusLabel;
    switch (status.toLowerCase()) {
      case 'aprobado':
        color = const Color(0xFF15A06A);
        bg = const Color(0xFFE7F7F0);
        icon = Icons.check_rounded;
        statusLabel = 'Aprobado';
        break;
      case 'rechazado':
        color = const Color(0xFFE8533F);
        bg = const Color(0xFFFDEDEA);
        icon = Icons.close_rounded;
        statusLabel = 'Rechazado';
        break;
      default:
        color = const Color(0xFFC77700);
        bg = const Color(0xFFFFF7EA);
        icon = Icons.schedule_rounded;
        statusLabel = 'Pendiente';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE8EDF3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
