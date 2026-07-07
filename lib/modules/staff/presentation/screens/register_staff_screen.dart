import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/custom_alert_widget.dart';
import '../widgets/widgets.dart';

/// Opción de cargo: [value] viaja al backend tal cual; [label] se muestra en UI.
class _RoleOption {
  final String value;
  final String label;
  const _RoleOption(this.value, this.label);
}

@RoutePage()
class RegisterStaffScreen extends StatefulWidget {
  const RegisterStaffScreen({super.key});

  @override
  State<RegisterStaffScreen> createState() => _RegisterStaffScreenState();
}

class _RegisterStaffScreenState extends State<RegisterStaffScreen> {
  // El [value] se envía intacto al backend (contrato), el [label] es legible.
  static const _roles = <_RoleOption>[
    _RoleOption('usuario', 'Usuario'),
    _RoleOption('jefe campamento', 'Jefe de campamento'),
    _RoleOption('jefe maquinaria', 'Jefe de maquinaria'),
  ];

  String? _selectedRole;

  final _fullNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _dateController = TextEditingController();
  final _paymentController = TextEditingController();
  final _departmentController = TextEditingController();
  final _shiftController = TextEditingController();
  final _keyRegisterUser = GlobalKey<FormState>();
  late final StaffBloc _staffBloc;

  @override
  void initState() {
    super.initState();
    _staffBloc = InjectorContainer.getIt<StaffBloc>();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dniController.dispose();
    _dateController.dispose();
    _paymentController.dispose();
    _departmentController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_keyRegisterUser.currentState!.validate()) return;
    if (_selectedRole == null) return;

    final employee = RegisterEmployeesEntity(
      fullName: _fullNameController.text.trim(),
      nationalId: _dniController.text.trim(),
      position: _selectedRole!,
      department: _departmentController.text.trim(),
      baseMonthlySalary: double.tryParse(_paymentController.text) ?? 0.0,
      shiftType: _shiftController.text.trim(),
      hiredDate: DateFormat('yyyy-MM-dd')
          .format(DateFormat('MM/dd/yyyy').parse(_dateController.text)),
      seniorityLevel: 'Junior',
      profilePhotoUrl: null,
    );
    _staffBloc.add(RegisterEmployeesEvent(employeed: employee));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _staffBloc,
      child: Scaffold(
        backgroundColor: StaffUi.background,
        appBar: staffAppBar(context, title: 'Registrar trabajador'),
        body: BlocConsumer<StaffBloc, StaffState>(
          listenWhen: (_, s) =>
              s is RegisterEmployeesSuccess || s is RegisterEmployeesError,
          listener: (context, state) {
            if (state is RegisterEmployeesSuccess) {
              CustomAlert.show(
                context,
                title: 'Listo',
                message: 'El empleado fue registrado exitosamente',
                type: AlertType.success,
              );
              context.router.popUntil((route) => route.isFirst);
            }
            if (state is RegisterEmployeesError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is RegisterEmployeesLoading;
            return Form(
              key: _keyRegisterUser,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  const _RegisterHeaderCard(),
                  const SizedBox(height: 22),
                  const StaffSectionTitle(
                    'Datos generales',
                    icon: Icons.person_add_alt_1_rounded,
                  ),
                  const SizedBox(height: 14),
                  CustomFormStaffWidget(
                    icon: Icons.badge_rounded,
                    titleform: 'Nombre completo',
                    hint: 'Ej: Juan Alberto Pérez García',
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormStaffWidget(
                    icon: Icons.contact_emergency_rounded,
                    titleform: 'DNI / Documento de identidad',
                    hint: 'Ingresa el documento',
                    controller: _dniController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormStaffWidget(
                    icon: Icons.event_rounded,
                    titleform: 'Fecha de ingreso',
                    hint: 'mm/dd/yyyy',
                    controller: _dateController,
                    isOnlyRead: true,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),
                  CustomFormStaffWidget(
                    icon: Icons.settings_rounded,
                    titleform: 'Área',
                    hint: 'Ingresa el área',
                    controller: _departmentController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormStaffWidget(
                    icon: Icons.access_time_rounded,
                    titleform: 'Turno',
                    hint: 'Ej: 7x7 Rotativo',
                    controller: _shiftController,
                  ),
                  const SizedBox(height: 16),
                  _RoleDropdown(
                    selected: _selectedRole,
                    roles: _roles,
                    onChanged: (value) =>
                        setState(() => _selectedRole = value),
                  ),
                  const SizedBox(height: 16),
                  CustomFormStaffWidget(
                    icon: Icons.payments_rounded,
                    titleform: 'Salario base (mensual)',
                    hint: '0.00',
                    extraText: 'Bs',
                    controller: _paymentController,
                    keyboradtype: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 28),
                  StaffPrimaryButton(
                    label: 'Guardar trabajador',
                    icon: Icons.save_rounded,
                    loading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                  _CancelButton(
                    onPressed: isLoading
                        ? null
                        : () => context.router
                            .popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Encabezado limpio del alta: chip de icono + título + subtítulo.
class _RegisterHeaderCard extends StatelessWidget {
  const _RegisterHeaderCard();

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_add_alt_1_rounded,
                color: StaffUi.primary, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nuevo trabajador',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Completa la información para dar de alta al trabajador.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: StaffUi.textSecondary,
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

/// Selector de cargo alineado a los tokens del módulo. Muestra etiquetas
/// legibles, pero entrega el valor crudo del backend en [onChanged].
class _RoleDropdown extends StatelessWidget {
  final String? selected;
  final List<_RoleOption> roles;
  final ValueChanged<String?> onChanged;
  const _RoleDropdown({
    required this.selected,
    required this.roles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.work_rounded, size: 20, color: StaffUi.textSecondary),
            SizedBox(width: 7),
            Text(
              'Cargo / Puesto',
              style: TextStyle(
                color: StaffUi.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: StaffUi.textSecondary),
          style: const TextStyle(
            fontSize: 14,
            color: StaffUi.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          hint: const Text(
            'Selecciona un cargo',
            style: TextStyle(color: StaffUi.muted, fontSize: 14),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: StaffUi.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: border(StaffUi.border),
            focusedBorder: border(StaffUi.primary, 1.4),
            errorBorder: border(const Color(0xFFEF4444)),
            focusedErrorBorder: border(const Color(0xFFEF4444), 1.4),
          ),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Selecciona un cargo' : null,
          onChanged: onChanged,
          items: roles
              .map(
                (role) => DropdownMenuItem<String>(
                  value: role.value,
                  child: Text(role.label),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Botón secundario "Cancelar" consistente con el sistema de diseño.
class _CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _CancelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: StaffUi.textSecondary,
          side: const BorderSide(color: StaffUi.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Cancelar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
