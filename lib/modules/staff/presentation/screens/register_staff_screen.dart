import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/color.constant.dart';
import '../widgets/widgets.dart';

@RoutePage()
class RegisterStaffScreen extends StatefulWidget {
  const RegisterStaffScreen({super.key});

  @override
  State<RegisterStaffScreen> createState() => _RegisterStaffScreenState();
}

class _RegisterStaffScreenState extends State<RegisterStaffScreen> {
  String? _opcionseleccionada;
  final _roles = ['usuario', 'jefe campamento', 'jefe maquinaria'];
  final _fullNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _dateController = TextEditingController();
  final _paymentController = TextEditingController();
  final _departmentController = TextEditingController();
  final _shiftController = TextEditingController();
  final _keyRegisterUser = GlobalKey<FormState>();

  late final StaffBloc _staffBloc;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        final fecha = DateFormat('MM/dd/yyyy').format(picked);
        _dateController.text = fecha;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _staffBloc = InjectorContainer.getIt<StaffBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _staffBloc,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 45,
          title: Text('Registro de Personal'),
        ),
        body: BlocConsumer<StaffBloc, StaffState>(
          listener: (context, state) {},
          builder: (context, state) {
            return Padding(
              padding: EdgeInsetsGeometry.all(15),
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border(
                        bottom: BorderSide(color: TColors.red, width: 5),
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            color: TColors.appSurfaceColor,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: TColors.appDisabledColor,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Nuevo Trabajador',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: TColors.white,
                                ),
                              ),
                              Text(
                                'Complete la informacion para dar de alta en el sistema operativo',
                                softWrap: true,
                                style: TextStyle(color: TColors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Form(
                      key: _keyRegisterUser,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 15,
                              bottom: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt,
                                  color: TColors.appMainDarkColor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Datos Generales',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TColors.appMainDarkColor,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: TColors.appDisabledColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsGeometry.all(20),
                            child: Column(
                              children: [
                                CustomFormStaffWidget(
                                  icon: Icons.badge_outlined,
                                  titleform: 'Nombre Completo',
                                  hint: 'Ej: Juan Alberto Perez Garcia',
                                  controller: _fullNameController,
                                ),

                                const SizedBox(height: 15),
                                CustomFormStaffWidget(
                                  icon: Icons.contact_emergency_outlined,
                                  titleform: 'DNI / Documento de Identidad',
                                  hint: 'Ingrese su documento',
                                  controller: _dniController,
                                ),
                                const SizedBox(height: 15),
                                CustomFormStaffWidget(
                                  icon: Icons.date_range_outlined,
                                  titleform: 'Fecha Ingreso',
                                  hint: 'mm/dd/yyyy',
                                  controller: _dateController,
                                  isOnlyRead: true,
                                  onTap: () => _selectDate(context),
                                ),
                                const SizedBox(height: 15),
                                CustomFormStaffWidget(
                                  icon: Icons.settings,
                                  titleform: 'Departamento',
                                  hint: 'Ingrese Departamento',
                                  controller: _departmentController,
                                ),
                                const SizedBox(height: 15),
                                CustomFormStaffWidget(
                                  icon: Icons.access_time,
                                  titleform: 'Turno',
                                  hint: 'Ingrese turno - Ej: "7x7 Rotativo"',
                                  controller: _shiftController,
                                ),
                                const SizedBox(height: 15),
                                const Row(
                                  children: [
                                    Icon(Icons.person_4_outlined),
                                    Text(
                                      'Cargo / Puesto',
                                      style: TextStyle(
                                        color: TColors.appMainDarkColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                DropdownButtonFormField<String>(
                                  initialValue: _opcionseleccionada,
                                  hint: const Text('Seleccione un Rol'),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (String? newvalue) {
                                    setState(() {
                                      _opcionseleccionada = newvalue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Seleccione un rol Valido';
                                    }
                                    return null;
                                  },
                                  items: _roles.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 15),
                                CustomFormStaffWidget(
                                  icon: Icons.payments_outlined,
                                  titleform: 'Salario base (Mensual)',
                                  hint: '0.00 Bs',
                                  extraText: 'Bs',
                                  controller: _paymentController,
                                  keyboradtype: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10,
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (!_keyRegisterUser.currentState!
                                        .validate()) {
                                      return;
                                    }
                                    final employeed = RegisterEmployeesEntity(
                                      fullName: _fullNameController.text,
                                      nationalId: _dniController.text,
                                      position: _opcionseleccionada.toString(),
                                      department: _departmentController.text,
                                      baseMonthlySalary:
                                          double.tryParse(
                                            _paymentController.text,
                                          ) ??
                                          0.0,
                                      shiftType: _shiftController.text,
                                      hiredDate: DateFormat('yyyy-MM-dd')
                                          .format(
                                            DateFormat(
                                              'MM/dd/yyyy',
                                            ).parse(_dateController.text),
                                          ),
                                      seniorityLevel: 'Junior',
                                      profilePhotoUrl: null,
                                    );
                                    _staffBloc.add(
                                      RegisterEmployeesEvent(
                                        employeed: employeed,
                                      ),
                                    );
                                    
                                    _fullNameController.clear();
                                    _dniController.clear();
                                    _dateController.clear();
                                    _paymentController.clear();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TColors.appMainDarkColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.save_outlined,
                                          color: TColors.white,
                                        ),
                                        SizedBox(width: 20),
                                        Text(
                                          'Guardar Trabajador',
                                          style: TextStyle(
                                            color: TColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                GestureDetector(
                                  onTap: () {
                                    context.router.popUntil(
                                      (route) => route.isFirst,
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TColors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: TColors.appMainDarkColor,
                                      ),
                                    ),
                                    child: Center(
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          color: TColors.appMainDarkColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
