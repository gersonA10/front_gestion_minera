import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_ingreso_tab.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../../../core/widgets/custom_alert_widget.dart';
import '../../../../core/widgets/excavator_loader.dart';
import '../../../../utils/assets.dart';

@RoutePage()
class EmployeeEntryRegisterScreen extends StatefulWidget {
  final IngresoWorker usuario;
  const EmployeeEntryRegisterScreen({super.key, required this.usuario});

  @override
  State<EmployeeEntryRegisterScreen> createState() =>
      _EmployeeEntryRegisterScreenState();
}

class _EmployeeEntryRegisterScreenState
    extends State<EmployeeEntryRegisterScreen> {
  TimeOfDay? _selectedTime;
  late final StaffBloc _checkinBloc;
  final _hourController = TextEditingController();
  final _observationController = TextEditingController();
  final _keyForm = GlobalKey<FormState>();
  static const String _fallbackImage =
      'https://siu.edu.bd/storage/uploaded/authority/male_1723030204.jpeg';

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 7, minute: _selectedTime?.minute ?? 00),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _hourController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _hourController.text = '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
    _checkinBloc = InjectorContainer.getIt<StaffBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        title: Text('Registro de Ingreso'),
        backgroundColor: TColors.white,
      ),
      body: BlocProvider.value(
        value: _checkinBloc,
        child: BlocConsumer<StaffBloc, StaffState>(
          listener: (context, state) {
            if (state is CheckInEmployeeSuccess) {
              CustomAlert.show(
                context,
                title: 'Registrado',
                message: 'Ingreso correctamente registrado',
                type: AlertType.success,
              );
              context.router.pop(true);
            }
            if (state is CheckInEmployeeError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CheckInEmployeeLoading;
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: ListView(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              margin: EdgeInsets.only(top: 18, bottom: 15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: TColors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: TColors.darkBackgroundAccount,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      50,
                                    ),
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      color: TColors.appBackgroundColor,
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            AssetImageApp.getIconLoading,
                                        image: _fallbackImage,
                                        fit: BoxFit.cover,
                                        imageErrorBuilder: (_, _, _) {
                                          return Center(
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 30,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.usuario.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(widget.usuario.role),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: TColors.appBackgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Text(
                                            'ID: 65478921',
                                            style: TextStyle(
                                              color: TColors.appMainColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: TColors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: TColors.darkBackgroundAccount,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomFormStaffWidget(
                                    icon: Icons.access_time_outlined,
                                    titleform: 'Hora de Entrada',
                                    hint: '',
                                    controller: _hourController,
                                    isOnlyRead: true,
                                    onTap: () async {
                                      await _selectTime(context);
                                    },
                                    extraText:
                                        (int.parse(
                                              _hourController.text
                                                  .split(':')
                                                  .first,
                                            ) <
                                            12)
                                        ? 'AM'
                                        : 'PM',
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Programado 07:00 AM',
                                    style: TextStyle(
                                      color: TColors.appDisabledColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: TColors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: TColors.darkBackgroundAccount,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.density_small_sharp,
                                        color: TColors.appMainColor,
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text('Observaciones / Condición'),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Form(
                                    key: _keyForm,
                                    child: TextFormField(
                                      maxLines: 3,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Rellene el campo';
                                        }
                                        return null;
                                      },
                                      maxLength: 500,
                                      controller: _observationController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Ej: Ingreso con equipamiento propio....',
                                        hintStyle: TextStyle(
                                          color: TColors.grayText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 80,
                      padding: EdgeInsets.all(15),
                      color: TColors.white,
                      child: InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          if (!_keyForm.currentState!.validate()) {
                            return;
                          }
                          final isEppData = {
                            "casco": true,
                            "lentes": true,
                            "chaleco": true,
                            "orejeras": true,
                          };
                          final int hour = int.parse(_hourController.text.split(':')[0]);
                          final checkIn = EmployeeCheckInEntity(
                            employeeId: widget.usuario.employeeId,
                            assignedShift: _getTurn(hour),
                            checkInTime: _hourController.text,
                            eppData: isEppData,
                            observation: _observationController.text,
                          );
                          _checkinBloc.add(
                            RegisterCheckInEmployeeEvent(checkIn: checkIn),
                          );
                          _observationController.clear();
                          _hourController.text =
                              '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
                        },
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: TColors.timelineBlue,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Confirmar Ingreso',
                                style: TextStyle(
                                  color: TColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 15),
                              Icon(Icons.check_circle, color: TColors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(child: ExcavatorLoader()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getTurn(int hour) {
    if (hour >= 6 && hour < 12) {
      return 'MAÑANA';
    } else if (hour >= 12 && hour < 18) {
      return 'TARDE';
    } else {
      return 'NOCHE';
    }
  }
}
