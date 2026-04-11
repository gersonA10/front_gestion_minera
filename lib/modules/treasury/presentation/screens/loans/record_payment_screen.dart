import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/record_payment/confirmar_pago_dialogo_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../../domain/entity/entity.dart';

@RoutePage()
class RecordPaymentScreen extends StatefulWidget {
  final String quotaId;
  final String textoCuota;
  final int montoTotalCuota;
  final CashResponseEntity cash;
  final String idLoan;
  const RecordPaymentScreen({
    super.key,
    required this.quotaId,
    required this.textoCuota,
    required this.montoTotalCuota,
    required this.cash,
    required this.idLoan,
  });

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  String? _selectedCaja;
  String _metodoPago = 'Efectivo';
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  // Cajas estáticas — reemplaza con tu servicio cuando esté disponible
late TreasuryBloc treasuryBloc;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    treasuryBloc = InjectorContainer.getIt<TreasuryBloc>();
    _fechaController.text =
        '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
    _selectedCaja = widget.cash.data.isNotEmpty
        ? widget.cash.data.first.id
        : null;
  }

  @override
  void dispose() {
    _referenciaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void _showConfirmarPagoDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value:treasuryBloc,
        child: ConfirmarPagoDialog(
          textoCuota: widget.textoCuota,
          montoFormateado: widget.montoTotalCuota.toStringAsFixed(2),
          idLoan: widget.idLoan,
          idQuota: widget.quotaId,
          cajaOrigenId: _selectedCaja!,
          metodoPago: _metodoPago,
          referencia: _referenciaController.text,
          treasuryBloc: treasuryBloc,
        ),
      ),
    );
  }

  void _showCajaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempSelected = _selectedCaja;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: TColors.cardBgDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: TColors.cardBorderDark),
              ),
              title: const Text(
                'Seleccionar Caja',
                style: TextStyle(
                  color: TColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.cash.data.map((caja) {
                    final isSelected = tempSelected == caja.id;
                    return GestureDetector(
                      onTap: () => setStateDialog(() => tempSelected = caja.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TColors.amber.withValues(alpha: 0.1)
                              : TColors.cardInnerBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? TColors.amber
                                : TColors.cardBorderDark.withValues(alpha: 0.5),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_outlined,
                              color: isSelected
                                  ? TColors.amber
                                  : TColors.textSecondary1,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                caja.nombre,
                                style: TextStyle(
                                  color: isSelected
                                      ? TColors.white
                                      : TColors.textSecondary1,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: TColors.amber,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TColors.textSecondary1,
                          side: BorderSide(color: TColors.cardBorderDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _selectedCaja = tempSelected);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.amber,
                          foregroundColor: TColors.bgColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: treasuryBloc,
      child: Scaffold(
        backgroundColor: TColors.bgColor,
        appBar: AppBar(
          backgroundColor: TColors.bgColor,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Registrar Pago',
            style: TextStyle(
              color: TColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalle de la Cuota',
                style: TextStyle(
                  color: TColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TColors.cardBgDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: TColors.cardBorderDark.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Nº Cuota', widget.textoCuota),
                    _buildDivider(),
                    _buildDetailRow(
                      'Capital',
                      (widget.montoTotalCuota * 0.89).toStringAsFixed(2),
                    ),
                    _buildDivider(),
                    _buildDetailRow(
                      'Interés',
                      (widget.montoTotalCuota * 0.11).toStringAsFixed(2),
                    ),
                    _buildDivider(),
                    _buildDetailRow(
                      'Total a Pagar',
                      widget.montoTotalCuota.toStringAsFixed(2),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Datos del Pago',
                style: TextStyle(
                  color: TColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Fecha de Pago'),
              const SizedBox(height: 8),
              TextField(
                controller: _fechaController,
                readOnly: true,
                style: const TextStyle(color: TColors.white, fontSize: 14),
                decoration: _inputDecoration(
                  hint: 'mm/dd/yyyy',
                  suffix: const Icon(
                    Icons.calendar_today_outlined,
                    color: TColors.textSecondary1,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Caja de Destino'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showCajaDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.cardInnerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: TColors.cardBorderDark.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_outlined,
                        color: TColors.textSecondary1,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedCaja != null
                              ? widget.cash.data
                                    .firstWhere(
                                      (caja) => caja.id == _selectedCaja,
                                    )
                                    .nombre
                              : 'Seleccionar caja',
                          style: TextStyle(
                            color: _selectedCaja != null
                                ? TColors.white
                                : TColors.textSecondary1,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: TColors.textSecondary1,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Método de Pago'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MetodoPagoCard(
                      icon: Icons.wallet_outlined,
                      label: 'Efectivo',
                      selected: _metodoPago == 'Efectivo',
                      onTap: () => setState(() => _metodoPago = 'Efectivo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetodoPagoCard(
                      icon: Icons.account_balance_outlined,
                      label: 'Transferencia',
                      selected: _metodoPago == 'Transferencia',
                      onTap: () =>
                          setState(() => _metodoPago = 'Transferencia'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Referencia / Observaciones'),
              const SizedBox(height: 8),
              TextField(
                controller: _referenciaController,
                style: const TextStyle(color: TColors.white, fontSize: 14),
                maxLines: 3,
                decoration: _inputDecoration(hint: 'Ej. Depósito Nº 123456...'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_referenciaController.text.isEmpty) {
                      CustomAlert.show(
                        context,
                        title: 'Error',
                        message:
                            'Por favor, ingresa una referencia u observación para el pago.',
                        type: AlertType.error,
                      );
                      return;
                    }
                    if (_metodoPago.isEmpty) {
                      CustomAlert.show(
                        context,
                        title: 'Error',
                        message: 'Por favor, selecciona un método de pago.',
                        type: AlertType.error,
                      );
                      return;
                    }
                    if (_selectedCaja == null) {
                      CustomAlert.show(
                        context,
                        title: 'Error',
                        message: 'Por favor, selecciona una caja.',
                        type: AlertType.error,
                      );
                      return;
                    }
                    _showConfirmarPagoDialog();
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? TColors.white : TColors.textSecondary1,
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? const Color(0xFF2563EB) : TColors.white,
              fontSize: isTotal ? 18 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(color: TColors.cardBorderDark.withValues(alpha: 0.4), height: 1);

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: TColors.white,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );

  InputDecoration _inputDecoration({required String hint, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: TColors.textSecondary1, fontSize: 14),
        suffixIcon: suffix,
        filled: true,
        fillColor: TColors.cardInnerBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: TColors.cardBorderDark.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: TColors.cardBorderDark.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TColors.amber),
        ),
      );
}

class _MetodoPagoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MetodoPagoCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? TColors.amber.withValues(alpha: 0.08)
              : TColors.cardInnerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? TColors.amber
                : TColors.cardBorderDark.withValues(alpha: 0.5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            if (selected)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: TColors.amber,
                    size: 16,
                  ),
                ),
              ),
            Icon(
              icon,
              color: selected ? TColors.amber : TColors.textSecondary1,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? TColors.white : TColors.textSecondary1,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SourceOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TColors.cardInnerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TColors.cardBorderDark.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: TColors.textSecondary1, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: TColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
