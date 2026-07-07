import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

import '../../../../../core/widgets/app_loading_overlay.dart';
import '../../../../../core/widgets/custom_alert_widget.dart';
import '../../domain/entity/entity.dart';
import '../bloc/admin_bloc.dart';

@RoutePage()
class CreateContributionScreen extends StatefulWidget {
  const CreateContributionScreen({super.key});

  @override
  State<CreateContributionScreen> createState() =>
      _CreateContributionScreenState();
}

class _CreateContributionScreenState extends State<CreateContributionScreen> {

  
  late final AdminBloc _adminBloc;
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _montoController = TextEditingController();

  String _selectedCalculationType = 'TOTAL_TARGET';
  String _selectedMonth = 'enero';
  String _selectedYear = DateTime.now().year.toString();

  final List<String> _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  Timer? _debounce;
  bool _isSimulating = false;
  ContributionSimulationEntity? _simulationResult;

  @override
  void initState() {
    super.initState();
    _adminBloc = InjectorContainer.getIt<AdminBloc>();
    _selectedMonth = _months[DateTime.now().month - 1];
    _montoController.addListener(_onMontoChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _montoController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  void _onMontoChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _triggerSimulation();
    });
  }

  void _triggerSimulation() {
    final montoText = _montoController.text.trim();
    if (montoText.isNotEmpty && double.tryParse(montoText) != null) {
      _adminBloc.add(
        SimulateAdminContributionEvent(
          monto: double.parse(montoText),
          tipoCalculo: _selectedCalculationType,
        ),
      );
    } else {
      setState(() {
        _simulationResult = null;
      });
    }
  }

  void _changeCalculationType(String type) {
    setState(() => _selectedCalculationType = type);
    _triggerSimulation();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_simulationResult == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Espera a que termine la simulación antes de crear.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      FocusScope.of(context).unfocus();
      _adminBloc.add(
        CreateAdminContributionEvent(
          motivo: _motivoController.text.trim(),
          periodMonth: _selectedMonth,
          periodYear: _selectedYear,
          monto: double.parse(_montoController.text.trim()),
          tipoCalculo: _selectedCalculationType,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _adminBloc,
      child: BlocConsumer<AdminBloc, AdminState>(
        listenWhen: (previous, current) =>
            current is CreateContributionSuccess ||
            current is CreateContributionError ||
            current is AdminSimulationLoading ||
            current is AdminSimulationSuccess ||
            current is AdminSimulationError,
        listener: (context, state) {
          // --- Manejo de la Creaión ---
          if (state is CreateContributionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          } else if (state is CreateContributionSuccess) {
            CustomAlert.show(
              context,
              title: 'Campaña Creada',
              message: state.response.message,
              type: AlertType.success,
            );
            context.router.maybePop(true);
          }
          else if (state is AdminSimulationLoading) {
            setState(() => _isSimulating = true);
          } else if (state is AdminSimulationSuccess) {
            setState(() {
              _isSimulating = false;
              _simulationResult = state.simulation;
            });
          } else if (state is AdminSimulationError) {
            setState(() => _isSimulating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateContributionLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF4F6FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFF1A3557)),
              title: const Text(
                'Crear Nuevo Aporte',
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
                  child: StaffLoader(label: 'Creando aporte'),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Detalles del Aporte'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _motivoController,
                        label: 'Motivo del Aporte',
                        hint: 'Ej. Cuota Aniversario...',
                        icon: Icons.edit_document,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              'Mes',
                              _selectedMonth,
                              _months,
                              (v) => setState(() => _selectedMonth = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              'Año',
                              _selectedYear,
                              [
                                DateTime.now().year.toString(),
                                (DateTime.now().year + 1).toString(),
                              ],
                              (v) => setState(() => _selectedYear = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Método de Cálculo'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: TColors.appMainDarkColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildToggleButton(
                                'Total Objetivo',
                                'TOTAL_TARGET',
                              ),
                            ),
                            Expanded(
                              child: _buildToggleButton(
                                'Monto Individual',
                                'INDIVIDUAL',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedCalculationType == 'TOTAL_TARGET'
                            ? 'Ingresa el monto global que se desea recaudar. El sistema lo dividirá automáticamente entre los socios activos.'
                            : 'Ingresa el monto exacto que deberá pagar CADA socio. El sistema calculará el total esperado.',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Monto a Registrar'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _montoController,
                        label: _selectedCalculationType == 'TOTAL_TARGET'
                            ? 'Monto Total Global (Bs)'
                            : 'Monto por Socio (Bs)',
                        hint: '0.00',
                        icon: Icons.attach_money,
                        isNumeric: true,
                      ),
                      const SizedBox(height: 24),

                      _buildPreviewBox(),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _submitForm,
                        child: const Text(
                          'Crear Aporte',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewBox() {
    if (_isSimulating) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: StaffLoader(),
      );
    }

    if (_simulationResult == null) return const SizedBox.shrink();

    final sim = _simulationResult!;
    final formatCurrency = NumberFormat('#,##0.00', 'es');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previsualización del Cálculo',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1B2A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A3557),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A3557).withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPreviewRow(
                Icons.groups_outlined,
                'Socios Activos',
                '${sim.cantidadSocios}',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Colors.white24),
              ),
              _buildPreviewRow(
                Icons.person_outline,
                'Monto por Socio',
                'Bs ${formatCurrency.format(sim.montoPorSocio)}',
                isHighlight: _selectedCalculationType == 'TOTAL_TARGET',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Colors.white24),
              ),
              _buildPreviewRow(
                Icons.account_balance_wallet_outlined,
                'Total a Recaudar',
                'Bs ${formatCurrency.format(sim.totalRecaudacion)}',
                isHighlight: _selectedCalculationType == 'INDIVIDUAL',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isHighlight
                ? const Color(0xFF10B981)
                : Colors.white, // Verde agua si es el valor calculado
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0D1B2A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A3557)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Campo requerido';
        if (isNumeric && double.tryParse(value) == null)
          return 'Ingresa un número válido';
        return null;
      },
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e.toUpperCase(),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, String type) {
    final isSelected = _selectedCalculationType == type;
    return GestureDetector(
      onTap: () => _changeCalculationType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TColors.white : TColors.appMainDarkColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? TColors.appMainDarkColor
                : TColors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
