import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class NewLoansScreen extends StatefulWidget {
  const NewLoansScreen({super.key});

  @override
  State<NewLoansScreen> createState() => _NewLoansScreenState();
}

class _NewLoansScreenState extends State<NewLoansScreen> {
  final TextEditingController prestamista = TextEditingController();
  final TextEditingController _monto = TextEditingController();
  final TextEditingController _plazo = TextEditingController();
  final TextEditingController tasa = TextEditingController();
  String _moneda = 'BOB';
  String tipoInteres = 'Simple';
  late TreasuryBloc _treasuryBloc;

  late final DateTime _fechaInicio;
  final colors = TColors;
  @override
  void initState() {
    super.initState();
    _fechaInicio = DateTime.now();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>();
  }

  String get _fechaFormateada =>
      '${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.year}';

  // Colors matching the design

  @override
  void dispose() {
    prestamista.dispose();
    _monto.dispose();
    _plazo.dispose();
    tasa.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: TColors.textSecondary1, fontSize: 14),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: TColors.inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.amber, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _treasuryBloc,
      child: Scaffold(
        backgroundColor: TColors.bgColor,
        appBar: AppBar(
          backgroundColor: TColors.bgColor,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Nuevo Préstamo',
            style: TextStyle(
              color: TColors.textPrimaryWhite,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: TColors.amber.withValues(alpha: 0.3),
            ),
          ),
        ),
        body: BlocConsumer<TreasuryBloc, TreasuryState>(
          listener: (context, state) {
            if (state is NewLoansSimulateError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            } else if (state is NewLoansSimulateLoaded) {
              context.router.push(
                LoanSimulationRoute(
                  loan: state.loan,
                  cash: state.cash,
                  name: prestamista.text,
                  date: _fechaFormateada,
                  annualInterestRate: double.parse(tasa.text),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is NewLoansSimulateLoading) {
              return const Center(
                child: CircularProgressIndicator(color: TColors.amber),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    Icons.person_outline,
                    'Detalles del Prestamista',
                  ),
                  const SizedBox(height: 12),
                  _label('Prestamista (Entidad / Persona)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: prestamista,
                    style: const TextStyle(color: TColors.textPrimaryWhite),
                    decoration: _inputDecoration(
                      hint: 'Ej. Banco Nacional, Juan Pérez',
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionHeader(
                    Icons.account_balance,
                    'Condiciones del Préstamo',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Monto Principal'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _monto,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: TColors.textPrimaryWhite,
                              ),
                              decoration: _inputDecoration(
                                prefix: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    '\$ ',
                                    style: TextStyle(
                                      color: TColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Moneda'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.inputBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: TColors.borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _moneda,
                                  isExpanded: true,
                                  dropdownColor: TColors.cardColor,
                                  style: const TextStyle(
                                    color: TColors.textPrimaryWhite,
                                    fontSize: 14,
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: TColors.textSecondary,
                                  ),
                                  items: ['BOB']
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _moneda = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Plazo (Meses)'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _plazo,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: TColors.textPrimaryWhite,
                              ),
                              decoration: _inputDecoration(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Tasa Anual (%)'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: tasa,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: TColors.textPrimaryWhite,
                              ),
                              decoration: _inputDecoration(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _label('Fecha de Inicio'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: TColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _fechaFormateada,
                            style: const TextStyle(
                              color: TColors.textPrimaryWhite,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.lock_outline,
                          color: TColors.textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColors.amberLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: TColors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: TColors.amber.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.percent,
                            color: TColors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TIPO DE INTERÉS',
                                style: TextStyle(
                                  color: TColors.textSecondary1,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tipoInteres,
                                style: const TextStyle(
                                  color: TColors.textPrimaryWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.lock_outline,
                          color: TColors.textSecondary1,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColors.amberLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: TColors.amber.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: TColors.amber,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: TColors.textSecondary1,
                                fontSize: 13,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Este préstamo se calcula bajo ',
                                ),
                                TextSpan(
                                  text: 'interés simple',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TColors.textPrimaryWhite,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '. El interés se calcula únicamente sobre el capital inicial y no se capitaliza.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (prestamista.text.isEmpty ) {
                    CustomAlert.show(
                      context,
                      title: 'Error',
                      message: 'Por favor ingrese el nombre del prestamista.',
                      type: AlertType.error,
                    );
                    return;
                  }
                  if (_monto.text.isEmpty ||
                      int.tryParse(_monto.text.replaceAll(',', '')) == null) {
                    CustomAlert.show(
                      context,
                      title: 'Error',
                      message: 'Por favor ingresa un monto válido.',
                      type: AlertType.error,
                    );
                    return;
                  }
                  if (_plazo.text.isEmpty ||
                      int.tryParse(_plazo.text) == null) {
                    CustomAlert.show(
                      context,
                      title: 'Error',
                      message: 'Por favor ingresa un plazo válido.',
                      type: AlertType.error,
                    );
                    return;
                  }
                  if (tasa.text.isEmpty ) {
                    CustomAlert.show(
                      context,
                      title: 'Error',
                      message: 'Por favor ingresa una tasa de interés válida.',
                      type: AlertType.error,
                    );
                    return;
                  }
                  _treasuryBloc.add(
                    NewLoansSimulateEvent(
                      amount:
                          double.tryParse(_monto.text.replaceAll(',', '')) ??
                          0.0,
                      termMonths: int.tryParse(_plazo.text) ?? 0,
                      annualInterestRate: tasa.text,
                      startDate: _fechaInicio.toIso8601String(),
                    ),
                  );
                },
                icon: const Icon(Icons.grid_view_rounded, size: 20),
                label: const Text(
                  'Simular Préstamo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: TColors.amber, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: TColors.textPrimaryWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(color: TColors.textSecondary1, fontSize: 13),
    );
  }
}
