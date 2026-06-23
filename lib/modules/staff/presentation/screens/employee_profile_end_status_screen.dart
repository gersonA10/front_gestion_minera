import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/employee_entity.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/employee_balance_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_report_screen.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/employee_profile_end_status_widgets.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:intl/intl.dart';

@RoutePage()
class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  late final StaffBloc _bloc;
  WorkerStatusWidget _selectedStatus = WorkerStatusWidget.activo;
  String? _shiftType;
  String? _department;
  double? _baseSalary;
  bool _saving = false;
  bool _formInit = false;
  EmployeeBalanceEntity? _balance;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    _bloc.add(GetEmployeeProfileEvent(widget.employeeId));
    _bloc.add(GetEmployeeBalanceEvent(widget.employeeId));
  }

  String _statusToApi(WorkerStatusWidget status) {
    switch (status) {
      case WorkerStatusWidget.activo:
        return 'ACTIVO';
      case WorkerStatusWidget.descanso:
        return 'DESCANSO';
      case WorkerStatusWidget.inactivo:
        return 'INACTIVO';
    }
  }

  String _statusLabel(String apiStatus) {
    switch (apiStatus.toUpperCase()) {
      case 'ACTIVO':
        return 'Activo';
      case 'DESCANSO':
        return 'En descanso';
      case 'INACTIVO':
        return 'Inactivo';
      default:
        return apiStatus;
    }
  }

  Future<void> _editShift() async {
    final controller = TextEditingController(text: _shiftType ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar turno'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Ej: 7x7 Rotativo'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _shiftType = result);
    }
  }

  Future<void> _editDepartment() async {
    final controller = TextEditingController(text: _department ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar departamento'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Ej: Operaciones'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _department = result);
    }
  }

  Future<void> _editSalary() async {
    final current = _baseSalary ?? 0;
    final controller = TextEditingController(
      text: current == 0 ? '' : current.toStringAsFixed(0),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar sueldo base'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: 'Bs ',
            hintText: 'Mayor a 0',
          ),
          onSubmitted: (v) => Navigator.pop(ctx, double.tryParse(v.trim())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, double.tryParse(controller.text.trim())),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      setState(() => _baseSalary = result);
    }
  }

  Future<void> _save(EmployeeEntity e) async {
    final newStatus = _statusToApi(_selectedStatus);
    final newShift = (_shiftType ?? e.shiftType).trim();
    final newDept = (_department ?? e.department).trim();
    final newSalary = _baseSalary ?? e.baseMonthlySalary;

    final statusChanged = newStatus != e.status.toUpperCase();
    final shiftChanged = newShift != e.shiftType.trim();
    final deptChanged = newDept != e.department.trim();
    final salaryChanged = newSalary != e.baseMonthlySalary;

    final changes = <String>[
      if (statusChanged) 'Estado: ${_statusLabel(newStatus)}',
      if (shiftChanged) 'Turno: $newShift',
      if (deptChanged) 'Departamento: $newDept',
      if (salaryChanged) 'Sueldo base: ${StaffUi.money(newSalary)}',
    ];
    if (changes.isEmpty) return;

    final confirmed = await _confirmChanges(changes, salaryChanged);
    if (confirmed != true || !mounted) return;

    // Solo se envían los campos que realmente cambiaron (el backend valida con
    // schema estricto y exige sueldo > 0; mandar todo siempre rompía el guardado).
    setState(() => _saving = true);
    _bloc.add(
      UpdateEmployeeProfileEvent(
        e.employeeId,
        status: statusChanged ? newStatus : null,
        shiftType: shiftChanged ? newShift : null,
        department: deptChanged ? newDept : null,
        baseMonthlySalary: salaryChanged ? newSalary : null,
      ),
    );
  }

  /// Diálogo de confirmación con el detalle de los cambios. Si cambia el sueldo,
  /// avisa que impacta el cálculo de nómina y las solicitudes de egreso a Hacienda.
  Future<bool?> _confirmChanges(List<String> changes, bool salaryChanged) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirmar cambios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vas a actualizar los datos del trabajador:',
              style: TextStyle(fontSize: 13.5, color: StaffUi.textSecondary),
            ),
            const SizedBox(height: 10),
            for (final c in changes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: StaffUi.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: StaffUi.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (salaryChanged) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: TColors.statusOrangeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TColors.statusOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: TColors.statusOrange,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cambiar el sueldo base afecta el cálculo de nómina y '
                        'las solicitudes de egreso a Hacienda.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: TColors.statusOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: StaffUi.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  WorkerStatusWidget _mapStatus(String apiStatus) {
    switch (apiStatus.toUpperCase()) {
      case 'ACTIVO':
        return WorkerStatusWidget.activo;
      case 'DESCANSO':
        return WorkerStatusWidget.descanso;
      default:
        return WorkerStatusWidget.inactivo;
    }
  }

  String _formatSalary(double amount) => StaffUi.money(amount);

  String _formatSeniority(int months) {
    final years = months ~/ 12;
    final rem = months % 12;
    if (years == 0) return '$rem ${rem == 1 ? "Mes" : "Meses"}';
    if (rem == 0) return '$years ${years == 1 ? "Año" : "Años"}';
    return '$years ${years == 1 ? "Año" : "Años"}, $rem ${rem == 1 ? "Mes" : "Meses"}';
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy', 'es').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: StaffUi.background,
        body: BlocConsumer<StaffBloc, StaffState>(
          listenWhen: (_, s) =>
              s is EmployeeProfileUpdateSuccess ||
              s is EmployeeProfileUpdateError ||
              s is EmployeeBalanceLoaded,
          listener: (ctx, state) {
            if (state is EmployeeBalanceLoaded) {
              setState(() => _balance = state.balance);
            } else if (state is EmployeeProfileUpdateSuccess) {
              setState(() {
                _saving = false;
                _formInit = false; // re-inicializa el form con datos frescos
                _balance = null; // forzar recarga del balance tras cambios
              });
              _bloc.add(GetEmployeeBalanceEvent(widget.employeeId));
              CustomAlert.show(
                ctx,
                title: 'Listo',
                message: 'Cambios guardados correctamente',
                type: AlertType.success,
              );
            } else if (state is EmployeeProfileUpdateError) {
              setState(() => _saving = false);
              CustomAlert.show(
                ctx,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          buildWhen: (_, s) =>
              s is EmployeeProfileLoading ||
              s is EmployeeProfileLoaded ||
              s is EmployeeProfileError,
          builder: (context, state) {
            if (state is EmployeeProfileLoading) {
              return _withBackBar(const StaffLoader());
            }
            if (state is EmployeeProfileError) {
              return _withBackBar(
                StaffErrorState(
                  message: state.message,
                  onRetry: () =>
                      _bloc.add(GetEmployeeProfileEvent(widget.employeeId)),
                ),
              );
            }

            if (state is EmployeeProfileLoaded) {
              final e = state.employee;
              if (!_formInit) {
                _selectedStatus = _mapStatus(e.status);
                _shiftType = e.shiftType;
                _department = e.department;
                _baseSalary = e.baseMonthlySalary;
                _formInit = true;
              }
              return _buildContent(e);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(EmployeeEntity e) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAvatarSection(e),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildPayrollCard(e),
                const SizedBox(height: 16),
                _buildSeniorityCard(e),
                const SizedBox(height: 20),
                _buildSaveButton(e),
                const SizedBox(height: 12),
                _buildAttendanceReportButton(e),
                const SizedBox(height: 12),
                _buildRequestPaymentButton(e),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceReportButton(EmployeeEntity e) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AttendanceReportScreen(
              employeeId: e.employeeId,
              employeeName: e.fullName,
            ),
          ),
        ),
        icon: const Icon(Icons.event_note_rounded, size: 18),
        label: const Text(
          'Reporte de asistencia',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: StaffUi.primary,
          side: const BorderSide(color: StaffUi.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestPaymentButton(EmployeeEntity e) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _openPaymentRequestSheet(e),
        icon: const Icon(Icons.account_balance_rounded, size: 18),
        label: const Text(
          'Solicitar pago a Hacienda',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: StaffUi.primary,
          side: const BorderSide(color: StaffUi.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Future<void> _openPaymentRequestSheet(EmployeeEntity e) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PaymentRequestSheet(
        bloc: _bloc,
        employeeId: e.employeeId,
        employeeName: e.fullName,
        balance: _balance,
      ),
    );
    // Un adelanto crea una deducción → recarga balance y perfil.
    if (mounted) {
      _formInit = false;
      _bloc.add(GetEmployeeProfileEvent(widget.employeeId));
      _bloc.add(GetEmployeeBalanceEvent(widget.employeeId));
    }
  }

  bool _hasChanges(EmployeeEntity e) {
    final statusChanged =
        _statusToApi(_selectedStatus) != e.status.toUpperCase();
    final shiftChanged =
        (_shiftType ?? e.shiftType).trim() != e.shiftType.trim();
    final departmentChanged =
        (_department ?? e.department).trim() != e.department.trim();
    final salaryChanged =
        (_baseSalary ?? e.baseMonthlySalary) != e.baseMonthlySalary;
    return statusChanged || shiftChanged || departmentChanged || salaryChanged;
  }

  Widget _buildSaveButton(EmployeeEntity e) {
    final hasChanges = _hasChanges(e);
    final enabled = hasChanges && !_saving;

    return StaffPrimaryButton(
      label: _saving ? 'Guardando...' : 'Guardar cambios',
      icon: _saving ? null : Icons.save_rounded,
      loading: _saving,
      onPressed: enabled ? () => _save(e) : null,
    );
  }

  /// Barra superior con botón atrás para los estados sin hero (carga/error).
  Widget _withBackBar(Widget child) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                BackButton(onPressed: () => Navigator.of(context).maybePop()),
                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: StaffUi.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _buildAvatarSection(EmployeeEntity e) {
    final dotColor = _mapStatus(e.status).dotColor;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [StaffUi.primary, StaffUi.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -28,
            child: _circle(140, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 28,
            right: 48,
            child: _circle(64, Colors.white.withValues(alpha: 0.10)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      StaffGlassButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Perfil',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _initials(e.fullName),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.fullName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _statusLabel(e.status),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (e.position.isNotEmpty ||
                                e.nationalId.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                [
                                  if (e.position.isNotEmpty) e.position,
                                  if (e.nationalId.isNotEmpty)
                                    'CI ${e.nationalId}',
                                ].join('  ·  '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
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
    );
  }

  Widget _buildStatusCard() {
    return StaffCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StaffSectionTitle(
            'Estado del trabajador',
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: WorkerStatusWidget.values.map((status) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStatus = status),
                  child: StatusChip(
                    status: status,
                    isSelected: _selectedStatus == status,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollCard(EmployeeEntity e) {
    return StaffCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StaffSectionTitle(
            'Acciones de nómina',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.credit_card_rounded,
            label: 'Sueldo Base',
            value: _formatSalary(_baseSalary ?? e.baseMonthlySalary),
            onEdit: _editSalary,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.business_rounded,
            label: 'Departamento',
            value: _department ?? e.department,
            onEdit: _editDepartment,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.schedule_rounded,
            label: 'Turno',
            value: _shiftType ?? e.shiftType,
            onEdit: _editShift,
          ),
          if (_balance != null && _balance!.totalPendingAmount > 0) ...[
            const SizedBox(height: 10),
            _buildBalanceRow(_balance!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: StaffUi.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffUi.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: StaffUi.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: StaffUi.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: StaffUi.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: StaffUi.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Fila de saldo pendiente en 2 líneas (la etiqueta arriba y los montos
  /// abajo a todo el ancho, para que no se corte el texto entre paréntesis).
  Widget _buildBalanceRow(EmployeeBalanceEntity b) {
    final meses = b.totalPendingMonths == 1 ? 'mes' : 'meses';
    final pendiente =
        '${StaffUi.money2(b.totalPendingAmount)} · ${b.totalPendingMonths} $meses pendientes';
    final mesesA = b.overdueMonths == 1 ? 'mes' : 'meses';
    final atrasado = b.overdueMonths > 0
        ? 'Atrasado: ${StaffUi.money2(b.overdueAmount)} · ${b.overdueMonths} $mesesA'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: StaffUi.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffUi.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 15,
              color: StaffUi.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo pendiente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: StaffUi.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pendiente,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                if (atrasado != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    atrasado,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: TColors.statusOrange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeniorityCard(EmployeeEntity e) {
    return StaffCard(
      borderColor: TColors.seniorityIconBg,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.seniorityIconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: TColors.seniorityIconColor,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ANTIGÜEDAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: TColors.seniorityLabelColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatSeniority(e.monthsSeniority),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: StaffUi.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (e.hiredDate.isNotEmpty || e.seniorityLevel.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: StaffUi.border),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _seniorityDetail(
                  label: 'Desde',
                  value: _formatDate(e.hiredDate),
                ),
                _seniorityDetail(label: 'Nivel', value: e.seniorityLevel),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _seniorityDetail({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: TColors.seniorityLabelColor,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: StaffUi.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Formulario de solicitud de pago a Hacienda ────────────────────────────────
class PaymentRequestSheet extends StatefulWidget {
  final StaffBloc bloc;
  final String employeeId;
  final String employeeName;
  final EmployeeBalanceEntity? balance;

  const PaymentRequestSheet({
    super.key,
    required this.bloc,
    required this.employeeId,
    required this.employeeName,
    this.balance,
  });

  @override
  State<PaymentRequestSheet> createState() => _PaymentRequestSheetState();
}

class _PaymentRequestSheetState extends State<PaymentRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _justifyCtrl = TextEditingController();
  final _picker = ImagePicker();
  String _type = 'ADELANTO';
  XFile? _image;
  bool _submitting = false;

  bool get _hasOverdue => widget.balance?.hasOverdue ?? false;

  @override
  void initState() {
    super.initState();
    // Si tiene saldos atrasados, no se puede adelantar: arranca en "Pago de saldo".
    _type = _hasOverdue ? 'SALDO' : 'ADELANTO';
    if (_hasOverdue) {
      _amountCtrl.text = widget.balance!.overdueAmount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _justifyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final photo = await _picker.pickImage(source: source, imageQuality: 80);
    if (photo == null) return;
    if (await photo.length() > 10 * 1024 * 1024) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'La imagen supera los 10MB.',
        type: AlertType.error,
      );
      return;
    }
    setState(() => _image = photo);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      CustomAlert.show(
        context,
        title: 'Falta evidencia',
        message: 'Adjunta una imagen de respaldo.',
        type: AlertType.warning,
      );
      return;
    }
    setState(() => _submitting = true);
    widget.bloc.add(
      RequestEmployeePaymentEvent(
        employeeId: widget.employeeId,
        employeeName: widget.employeeName,
        requestType: _type,
        amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
        justification: _justifyCtrl.text.trim(),
        imagePath: _image!.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffBloc, StaffState>(
      bloc: widget.bloc,
      listenWhen: (_, s) =>
          s is EmployeePaymentRequestSuccess ||
          s is EmployeePaymentRequestError,
      listener: (ctx, state) {
        if (state is EmployeePaymentRequestSuccess) {
          Navigator.of(context).pop();
          CustomAlert.show(
            ctx,
            title: 'Listo',
            message: 'Solicitud enviada a Hacienda. Espera la aprobación.',
            type: AlertType.success,
          );
        } else if (state is EmployeePaymentRequestError) {
          setState(() => _submitting = false);
          CustomAlert.show(
            ctx,
            title: 'Error',
            message: state.message,
            type: AlertType.error,
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: TColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Solicitar pago a Hacienda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.employeeName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: StaffUi.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.balance != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: StaffUi.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: StaffUi.border),
                    ),
                    child: Text(
                      'Saldo pendiente: ${StaffUi.money2(widget.balance!.totalPendingAmount)} '
                      '(${widget.balance!.totalPendingMonths} meses) · '
                      'Atrasado: ${StaffUi.money2(widget.balance!.overdueAmount)} '
                      '(${widget.balance!.overdueMonths} meses)',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: StaffUi.textSecondary,
                      ),
                    ),
                  ),
                // Tipo
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Adelanto'),
                        selected: _type == 'ADELANTO',
                        onSelected: _hasOverdue
                            ? null
                            : (_) => setState(() => _type = 'ADELANTO'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Pago de saldo'),
                        selected: _type == 'SALDO',
                        onSelected: _hasOverdue
                            ? (_) => setState(() {
                                _type = 'SALDO';
                                if (_amountCtrl.text.trim().isEmpty) {
                                  _amountCtrl.text = widget
                                      .balance!
                                      .overdueAmount
                                      .toStringAsFixed(2);
                                }
                              })
                            : null,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _hasOverdue
                        ? 'El trabajador tiene saldos atrasados: solo puedes solicitar el pago de saldo, no un adelanto.'
                        : 'El pago de saldo solo está disponible si el trabajador tiene meses atrasados.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: StaffUi.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Monto
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto (Bs)',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  validator: (v) {
                    final value = double.tryParse(
                      (v ?? '').replaceAll(',', '.'),
                    );
                    if (value == null) return 'Ingresa un monto válido';
                    if (value <= 0) return 'El monto debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Justificación
                TextFormField(
                  controller: _justifyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Justificación',
                    alignLabelWithHint: true,
                    hintText: 'Motivo del pago...',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 10) {
                      return 'Mínimo 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Evidencia
                if (_image != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_image!.path),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _image = null),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: TColors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: TColors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(ImageSource.gallery),
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                          ),
                          label: const Text('Galería'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(ImageSource.camera),
                          icon: const Icon(
                            Icons.photo_camera_outlined,
                            size: 18,
                          ),
                          label: const Text('Cámara'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                StaffPrimaryButton(
                  label: _submitting ? 'Enviando...' : 'Enviar a Hacienda',
                  icon: _submitting ? null : Icons.send_rounded,
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
