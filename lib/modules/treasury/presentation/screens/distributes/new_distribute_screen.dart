import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class NewDistributionScreen extends StatefulWidget {
  const NewDistributionScreen({super.key});

  @override
  State<NewDistributionScreen> createState() => _NewDistributionScreenState();
}

class _NewDistributionScreenState extends State<NewDistributionScreen> {
  late final String _selectedMes;
  late final String _selectedAnio;
  late final String _fechaActual;

  final TextEditingController _montoController = TextEditingController();

  late final TreasuryBloc _treasuryBloc;
  Timer? _debounceTimer;

  String _formatNumber(double value) {
    if (value == 0) return '0.00';
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
      count++;
    }
    return '${buffer.toString().split('').reversed.join()}.$decPart';
  }

  void _onMontoChanged() {
    _debounceTimer?.cancel();
    final raw = _montoController.text.replaceAll(',', '').replaceAll(' ', '');
    if (raw.isEmpty) return;
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) return;
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _treasuryBloc.add(SimulateDistributionEvent(baseAmount: amount));
    });
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>();
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    _selectedMes = meses[now.month - 1];
    _selectedAnio = now.year.toString();
    _fechaActual =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    _montoController.addListener(_onMontoChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _treasuryBloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: TColors.textPrimary,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Nueva Distribución',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
        ),
        body: BlocListener<TreasuryBloc, TreasuryState>(
          listener: (context, state) {
           if (state is NewLayoutLoaded) {
              context.router.back();
              CustomAlert.show(
                context,
                title: 'Éxito',
                message: 'La distribución se ha creado exitosamente.',
                type: AlertType.success,
              );
            } else if (state is NewLayoutError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
             
           }
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Periodo'),
                                const SizedBox(height: 8),
                                _ReadOnlyField(
                                  value: _selectedMes,
                                  icon: Icons.calendar_month_outlined,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Año'),
                                const SizedBox(height: 8),
                                _ReadOnlyField(
                                  value: _selectedAnio,
                                  icon: Icons.event_outlined,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _label('Fecha de Registro'),
                      const SizedBox(height: 8),
                      _ReadOnlyField(
                        value: _fechaActual,
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 20),
                      _label('Monto Base Registrado'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: TColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: TColors.border),
                        ),
                        child: TextField(
                          controller: _montoController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9,.]'),
                            ),
                          ],
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: TColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<TreasuryBloc, TreasuryState>(
                        buildWhen: (_, curr) =>
                            curr is SimulateDistributionLoading ||
                            curr is SimulateDistributionLoaded ||
                            curr is SimulateDistributionError,
                        builder: (context, state) {
                          final isLoading =
                              state is SimulateDistributionLoading;
                          int totalSocios = 0;
                          double porPersona = 0.0;

                          if (state is SimulateDistributionLoaded) {
                            totalSocios = state
                                .simulateDistribution
                                .data
                                .numberOfActiveMembers;
                            porPersona =
                                state.simulateDistribution.data.amountPerMember;
                          }

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: TColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: TColors.border),
                            ),
                            child: isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: TColors.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'TOTAL SOCIOS',
                                              style: TextStyle(
                                                color: TColors.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  '$totalSocios',
                                                  style: const TextStyle(
                                                    color: TColors.primary,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.lock_outline,
                                                  color: TColors.primary,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 48,
                                        color: TColors.border,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'POR PERSONA',
                                                style: TextStyle(
                                                  color: TColors.primary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.6,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _formatNumber(porPersona),
                                                      style: const TextStyle(
                                                        color: TColors.primary,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.grid_view_outlined,
                                                    color: TColors.primary,
                                                    size: 16,
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
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_montoController.text.isEmpty) {
                        CustomAlert.show(
                          context,
                          title: 'error',
                          message: 'El monto es requerido',
                          type: AlertType.error,
                        );
                        return;
                      }
                      _treasuryBloc.add(
                        NewLayoutEvent(
                          monthPeriod: _selectedMes,
                          yearPeriod: _selectedAnio,
                          baseAmount: _montoController.text.isEmpty
                              ? 0
                              : double.parse(
                                  _montoController.text.replaceAll(',', ''),
                                ),
                        ),
                      );
                     
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text(
                      'Confirmar y Abrir',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: TColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;

  const _ReadOnlyField({required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: TColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon, color: TColors.textSecondary, size: 18),
        ],
      ),
    );
  }
}
