import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/employee_entity.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/employee_balance_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/employee_profile_end_status_widgets.dart';
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
          decoration: const InputDecoration(
            hintText: 'Ej: 7x7 Rotativo',
          ),
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

  void _save(EmployeeEntity e) {
    setState(() => _saving = true);
    _bloc.add(
      UpdateEmployeeProfileEvent(
        e.employeeId,
        status: _statusToApi(_selectedStatus),
        shiftType: _shiftType ?? e.shiftType,
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

  String _formatSalary(double amount) {
    return NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    ).format(amount);
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'PERFIL DEL TRABAJADOR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: TColors.profileTitleText,
              letterSpacing: 1.4,
            ),
          ),
          centerTitle: true,
        ),
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
              return const Center(child: CircularProgressIndicator());
            }
            if (state is EmployeeProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: TColors.disabled),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: const TextStyle(color: TColors.disabled),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => _bloc
                          .add(GetEmployeeProfileEvent(widget.employeeId)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is EmployeeProfileLoaded) {
              final e = state.employee;
              if (!_formInit) {
                _selectedStatus = _mapStatus(e.status);
                _shiftType = e.shiftType;
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildAvatarSection(e),
          const SizedBox(height: 28),
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildPayrollCard(e),
          const SizedBox(height: 16),
          _buildSeniorityCard(e),
          const SizedBox(height: 20),
          _buildSaveButton(e),
          const SizedBox(height: 12),
          _buildRequestPaymentButton(e),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRequestPaymentButton(EmployeeEntity e) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _openPaymentRequestSheet(e),
        icon: const Icon(Icons.account_balance_rounded, size: 18),
        label: const Text('Solicitar pago a Hacienda'),
        style: OutlinedButton.styleFrom(
          foregroundColor: TColors.profileBlue,
          side: const BorderSide(color: TColors.profileBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
    final statusChanged = _statusToApi(_selectedStatus) != e.status.toUpperCase();
    final shiftChanged =
        (_shiftType ?? e.shiftType).trim() != e.shiftType.trim();
    return statusChanged || shiftChanged;
  }

  Widget _buildSaveButton(EmployeeEntity e) {
    final hasChanges = _hasChanges(e);
    final enabled = hasChanges && !_saving;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: enabled ? () => _save(e) : null,
        icon: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: TColors.white,
                ),
              )
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.profileBlue,
          foregroundColor: TColors.white,
          // Mientras guarda mantiene el azul (con spinner); si no hay cambios, gris.
          disabledBackgroundColor: _saving ? TColors.profileBlue : TColors.disabled,
          disabledForegroundColor: TColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(EmployeeEntity e) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TColors.border, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: e.profilePhotoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: e.profilePhotoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: TColors.avatarBackground,
                          child: const Icon(Icons.person_rounded,
                              size: 52, color: TColors.avatarIconColor),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: TColors.avatarBackground,
                          child: const Icon(Icons.person_rounded,
                              size: 52, color: TColors.avatarIconColor),
                        ),
                      )
                    : Container(
                        color: TColors.avatarBackground,
                        child: const Icon(Icons.person_rounded,
                            size: 52, color: TColors.avatarIconColor),
                      ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _mapStatus(e.status).dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: TColors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          e.fullName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: TColors.profileDarkText,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          e.position.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: TColors.profileBlue,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          e.nationalId,
          style: const TextStyle(
            fontSize: 11,
            color: TColors.profileMutedLabel,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 15, color: TColors.profileMutedLabel),
              SizedBox(width: 6),
              Text(
                'ESTADO DEL TRABAJADOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: TColors.profileMutedLabel,
                  letterSpacing: 1.1,
                ),
              ),
            ],
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
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCIONES DE NÓMINA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TColors.profileMutedLabel,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: TColors.profileIconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: TColors.profileBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.credit_card_rounded,
            label: 'Sueldo Base',
            value: _formatSalary(e.baseMonthlySalary),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.business_rounded,
            label: 'Departamento',
            value: e.department,
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
            _buildInfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Saldo pendiente',
              value:
                  '${_balance!.totalPendingAmount.toStringAsFixed(2)} Bs '
                  '(${_balance!.totalPendingMonths}m'
                  '${_balance!.overdueMonths > 0 ? ", ${_balance!.overdueMonths} atras." : ""})',
            ),
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
        color: TColors.profileCardInnerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: TColors.profileIconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 15, color: TColors.profileBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: TColors.profileBodyText,
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
                fontWeight: FontWeight.w700,
                color: TColors.profileDarkText,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.edit_rounded,
                    size: 16, color: TColors.profileBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeniorityCard(EmployeeEntity e) {
    return CardWidget(
      backgroundColor: TColors.seniorityCardBg,
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
                      fontWeight: FontWeight.w700,
                      color: TColors.profileDarkText,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (e.hiredDate.isNotEmpty || e.seniorityLevel.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: TColors.seniorityIconBg),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _seniorityDetail(
                  label: 'Desde',
                  value: _formatDate(e.hiredDate),
                ),
                _seniorityDetail(
                  label: 'Nivel',
                  value: e.seniorityLevel,
                ),
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
            fontWeight: FontWeight.w600,
            color: TColors.profileDarkText,
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
      CustomAlert.show(context,
          title: 'Error',
          message: 'La imagen supera los 10MB.',
          type: AlertType.error);
      return;
    }
    setState(() => _image = photo);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      CustomAlert.show(context,
          title: 'Falta evidencia',
          message: 'Adjunta una imagen de respaldo.',
          type: AlertType.warning);
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
          CustomAlert.show(ctx,
              title: 'Listo',
              message: 'Solicitud enviada a Hacienda. Espera la aprobación.',
              type: AlertType.success);
        } else if (state is EmployeePaymentRequestError) {
          setState(() => _submitting = false);
          CustomAlert.show(ctx,
              title: 'Error', message: state.message, type: AlertType.error);
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.employeeName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: TColors.profileMutedLabel,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.balance != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: TColors.appBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Saldo pendiente: ${widget.balance!.totalPendingAmount.toStringAsFixed(2)} Bs '
                      '(${widget.balance!.totalPendingMonths} meses) · '
                      'Atrasado: ${widget.balance!.overdueAmount.toStringAsFixed(2)} Bs '
                      '(${widget.balance!.overdueMonths} meses)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.profileBodyText,
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
                                    _amountCtrl.text = widget.balance!.overdueAmount
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
                      color: TColors.profileMutedLabel,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Monto
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto (Bs)',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  validator: (v) {
                    final value = double.tryParse((v ?? '').replaceAll(',', '.'));
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
                            child: const Icon(Icons.close,
                                color: TColors.white, size: 18),
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
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Galería'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined, size: 18),
                          label: const Text('Cámara'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: TColors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_submitting ? 'Enviando...' : 'Enviar a Hacienda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.profileBlue,
                      foregroundColor: TColors.white,
                      disabledBackgroundColor: TColors.profileBlue,
                      disabledForegroundColor: TColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

