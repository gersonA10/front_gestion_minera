import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/payroll_monthly_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../../../injector_container.dart';
import '../bloc/staff_bloc.dart';

@RoutePage()
class ProcessPaymentScreen extends StatefulWidget {
  final PayrollMonthlyEntity payroll;
  final String payrollPeriod;
  const ProcessPaymentScreen({
    super.key,
    required this.payroll,
    required this.payrollPeriod,
  });

  @override
  State<ProcessPaymentScreen> createState() => _ProcessPaymentScreenState();
}

class _ProcessPaymentScreenState extends State<ProcessPaymentScreen> {
  late final StaffBloc _bloc;
  final Uuid _uuid = const Uuid();
  final TextEditingController _amountCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final int _maxFileSize = 10 * 1024 * 1024;
  XFile? _comprobante;

  PayrollMonthlyEntity get payroll => widget.payroll;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    // Por defecto se cancela todo lo que falta.
    _amountCtrl.text = payroll.remaining.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _bloc.close();
    super.dispose();
  }

  void _listener(BuildContext context, StaffState state) {
    if (state is ProcessPayrollPaymentSuccess) {
      CustomAlert.show(
        context,
        title: 'Éxito',
        message: 'Pago procesado',
        type: AlertType.success,
      );

      final router = context.router;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        router.pop(true);
      });
    }

    if (state is ProcessPayrollPaymentError) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: state.message,
        type: AlertType.error,
      );
    }
  }

  /// Rellena el campo con un monto sugerido (todo lo que falta / la mitad).
  void _setAmount(double value) {
    HapticFeedback.selectionClick();
    _amountCtrl.text = value.toStringAsFixed(2);
    _amountCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountCtrl.text.length),
    );
    setState(() {});
  }

  Future<void> _showConfirmDialog() async {
    final amount =
        double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      CustomAlert.show(
        context,
        title: 'Monto inválido',
        message: 'Ingresa un monto mayor a 0.',
        type: AlertType.warning,
      );
      return;
    }
    if (amount > payroll.remaining + 0.009) {
      CustomAlert.show(
        context,
        title: 'Monto excede',
        message:
            'El monto supera lo que falta por pagar (${StaffUi.money2(payroll.remaining)}).',
        type: AlertType.warning,
      );
      return;
    }
    if (_comprobante == null) {
      CustomAlert.show(
        context,
        title: 'Comprobante requerido',
        message: 'Adjunta el comprobante de pago para continuar.',
        type: AlertType.warning,
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: StaffUi.surface,
          surfaceTintColor: StaffUi.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirmar pago',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: StaffUi.textPrimary,
            ),
          ),
          content: Text(
            '¿Confirmar pago de ${StaffUi.money2(amount)} a ${payroll.fullName}?',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: StaffUi.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: StaffUi.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: StaffUi.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    if (result != true) return;
    _bloc.add(
      ProcessPayrollPaymentEvent(
        payrollId: payroll.payrollId,
        idempotencyKey: _uuid.v4(),
        comprobantePath: _comprobante!.path,
        amount: amount,
      ),
    );
  }

  /// Abre el selector para adjuntar el comprobante (galería o cámara).
  void _showAttachSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: StaffUi.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Adjuntar comprobante',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: StaffUi.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: StaffUi.primary),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickComprobante(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded,
                    color: StaffUi.primary),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickComprobante(ImageSource.camera);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickComprobante(ImageSource source) async {
    try {
      final XFile? photo =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (photo == null) return;
      final int size = await photo.length();
      if (size > _maxFileSize) {
        if (!mounted) return;
        CustomAlert.show(
          context,
          title: 'Archivo muy grande',
          message: 'El archivo ${photo.path.split('/').last} supera los 10MB.',
          type: AlertType.error,
        );
        return;
      }
      setState(() => _comprobante = photo);
    } catch (e) {
      debugPrint('Error al procesar el comprobante: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaffUi.background,
      appBar: staffAppBar(context, title: 'Procesar pago'),
      body: BlocConsumer<StaffBloc, StaffState>(
        bloc: _bloc,
        listener: _listener,
        builder: (context, state) {
          final isLoading = state is ProcessPayrollPaymentLoading;
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _EmployeeHeaderCard(payroll: payroll),
                            const SizedBox(height: 16),
                            _PeriodCard(period: widget.payrollPeriod),
                            const SizedBox(height: 22),
                            const StaffSectionTitle(
                              'Detalle de la nómina',
                              icon: Icons.receipt_long_rounded,
                            ),
                            const SizedBox(height: 12),
                            _BreakdownCard(payroll: payroll),
                            const SizedBox(height: 20),
                            _NetCard(payroll: payroll),
                            const SizedBox(height: 22),
                            const StaffSectionTitle(
                              '¿Cuánto cancelar ahora?',
                              icon: Icons.payments_rounded,
                            ),
                            const SizedBox(height: 12),
                            _AmountField(
                              controller: _amountCtrl,
                              enabled: !isLoading,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 10),
                            _QuickAmounts(
                              enabled: !isLoading,
                              onFull: () => _setAmount(payroll.remaining),
                              onHalf: () => _setAmount(payroll.remaining / 2),
                            ),
                            const SizedBox(height: 22),
                            const StaffSectionTitle(
                              'Comprobante de pago',
                              icon: Icons.attach_file_rounded,
                            ),
                            const SizedBox(height: 12),
                            _ComprobantePicker(
                              file: _comprobante,
                              enabled: !isLoading,
                              onTap: _showAttachSheet,
                              onRemove: () =>
                                  setState(() => _comprobante = null),
                            ),
                            const Spacer(),
                            const SizedBox(height: 24),
                            StaffPrimaryButton(
                              label: isLoading
                                  ? 'Procesando pago...'
                                  : 'Confirmar y pagar',
                              icon: Icons.check_circle_rounded,
                              loading: isLoading,
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                await _showConfirmDialog();
                              },
                            ),
                            const SizedBox(height: 12),
                            const _LegalNote(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Avatar con iniciales del nombre (sin foto de red), estilo módulo staff.
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: StaffUi.primarySoft,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: StaffUi.primary,
        ),
      ),
    );
  }
}

/// Tarjeta de cabecera del empleado: avatar con iniciales + nombre / cargo / ID.
class _EmployeeHeaderCard extends StatelessWidget {
  final PayrollMonthlyEntity payroll;
  const _EmployeeHeaderCard({required this.payroll});

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      child: Row(
        children: [
          _Avatar(name: payroll.fullName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payroll.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  payroll.position,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: StaffUi.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.badge_rounded,
                        size: 13, color: StaffUi.muted),
                    const SizedBox(width: 4),
                    Text(
                      'ID #${payroll.employeeId}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: StaffUi.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta del periodo de nómina con pill "Mensual".
class _PeriodCard extends StatelessWidget {
  final String period;
  const _PeriodCard({required this.period});

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.event_rounded,
                size: 19, color: StaffUi.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Periodo de pago',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: StaffUi.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const StaffPill(
            label: 'Mensual',
            color: StaffUi.primary,
            bg: StaffUi.primarySoft,
            icon: Icons.calendar_month_rounded,
          ),
        ],
      ),
    );
  }
}

/// Desglose de percepciones y deducciones dentro de una sola tarjeta.
class _BreakdownCard extends StatelessWidget {
  final PayrollMonthlyEntity payroll;
  const _BreakdownCard({required this.payroll});

  @override
  Widget build(BuildContext context) {
    final hasDeductions = payroll.totalDeductions > 0;
    return StaffCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          _BreakdownRow(
            icon: Icons.add_circle_rounded,
            iconColor: StaffUi.primary,
            label: 'Salario base',
            value: StaffUi.money2(payroll.baseSalary),
            valueColor: StaffUi.textPrimary,
          ),
          if (hasDeductions) ...[
            const Divider(height: 1, color: StaffUi.border),
            _BreakdownRow(
              icon: Icons.remove_circle_rounded,
              iconColor: TColors.statusOrange,
              label: 'Adelantos / deducciones',
              value: '- ${StaffUi.money2(payroll.totalDeductions)}',
              valueColor: TColors.statusOrange,
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;
  const _BreakdownRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: StaffUi.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta destacada del NETO con gradiente premium (estilo _CajaCard).
class _NetCard extends StatelessWidget {
  final PayrollMonthlyEntity payroll;
  const _NetCard({required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StaffUi.primary, StaffUi.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: StaffUi.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Neto a recibir',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            StaffUi.money2(payroll.netToReceive),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NetStat(
                    label: 'Ya pagado',
                    value: StaffUi.money2(payroll.paidAmount),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: _NetStat(
                    label: 'Falta por pagar',
                    value: StaffUi.money2(payroll.remaining),
                    alignEnd: true,
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

class _NetStat extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;
  const _NetStat({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

/// Campo de monto a cancelar (prefijo Bs).
class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  const _AmountField({
    required this.controller,
    required this.enabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: StaffUi.textPrimary,
        letterSpacing: -0.3,
      ),
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 8),
          child: Text(
            'Bs',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: StaffUi.textSecondary,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: StaffUi.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StaffUi.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StaffUi.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StaffUi.primary, width: 1.6),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StaffUi.border),
        ),
      ),
    );
  }
}

/// Sugerencias rápidas de monto (todo / mitad).
class _QuickAmounts extends StatelessWidget {
  final bool enabled;
  final VoidCallback onFull;
  final VoidCallback onHalf;
  const _QuickAmounts({
    required this.enabled,
    required this.onFull,
    required this.onHalf,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickChip(
            label: 'Pago total',
            icon: Icons.done_all_rounded,
            onTap: enabled ? onFull : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickChip(
            label: 'Pago parcial (50%)',
            icon: Icons.pie_chart_rounded,
            onTap: enabled ? onHalf : null,
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _QuickChip({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: StaffUi.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StaffUi.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: StaffUi.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: StaffUi.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector/preview del comprobante de pago (obligatorio).
class _ComprobantePicker extends StatelessWidget {
  final XFile? file;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _ComprobantePicker({
    required this.file,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Container(
        decoration: BoxDecoration(
          color: StaffUi.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: StaffUi.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(13),
              ),
              child: Image.file(
                File(file!.path),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file!.path.split('/').last,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: StaffUi.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: enabled ? onRemove : null,
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: StaffUi.muted),
              tooltip: 'Quitar',
            ),
            const SizedBox(width: 4),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: StaffUi.primarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: StaffUi.primary.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_rounded,
                size: 28, color: StaffUi.primary),
            const SizedBox(height: 8),
            const Text(
              'Adjuntar comprobante',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: StaffUi.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Foto o imagen del comprobante (máx. 10MB)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: StaffUi.textSecondary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nota legal bajo el CTA.
class _LegalNote extends StatelessWidget {
  const _LegalNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_rounded, size: 13, color: StaffUi.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Al confirmar, el pago se procesa y se envía automáticamente un '
              'comprobante digital al correo del trabajador.',
              style: const TextStyle(
                fontSize: 11,
                height: 1.45,
                color: StaffUi.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
