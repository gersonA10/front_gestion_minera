import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../../../utils/assets.dart';

@RoutePage()
class EmployeeEntryRegisterScreen extends StatefulWidget {
  final String id;
  const EmployeeEntryRegisterScreen({super.key, required this.id});

  @override
  State<EmployeeEntryRegisterScreen> createState() =>
      _EmployeeEntryRegisterScreenState();
}

class _EmployeeEntryRegisterScreenState
    extends State<EmployeeEntryRegisterScreen> {
  TimeOfDay? _selectedTime;
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
            '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _hourController.text = '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        title: Text('Registro de Ingreso'),
        backgroundColor: TColors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: TColors.darkBackgroundAccount),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(50),
                          child: Container(
                            width: 70,
                            height: 70,
                            color: TColors.appBackgroundColor,
                            child: FadeInImage.assetNetwork(
                              placeholder: AssetImageApp.getIconLoading,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Carlos Rodriguez',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text('Operador de mauinaria'),
                              const SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: TColors.appBackgroundColor,
                                  borderRadius: BorderRadius.circular(15),
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
                  const SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: TColors.darkBackgroundAccount),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: TColors.appMainColor,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text('Hora de Entrada'),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          readOnly: true,
                          controller: _hourController,
                          decoration: InputDecoration(
                            suffix: Text(
                              (int.parse(
                                        _hourController.text.split(':').first,
                                      ) <
                                      12)
                                  ? 'AM'
                                  : 'PM',
                            ),
                          ),
                          onTap: () async {
                            await _selectTime(context);
                          },
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Programado 07:00 AM',
                          style: TextStyle(color: TColors.appDisabledColor),
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
                      border: Border.all(color: TColors.darkBackgroundAccount),
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
                              hintStyle: TextStyle(color: TColors.grayText),
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
                if (!_keyForm.currentState!.validate()) {
                  return;
                }
                final resultado = {
                  "employee_id": widget.id,
                  "assigned_shift":
                      (int.parse(_hourController.text.split(':').first) < 12)
                      ? 'MAÑANA'
                      : 'TARDE',
                  "check_in_time": _hourController.text,
                  "epp_data": {
                    "casco": true,
                    "lentes": true,
                    "chaleco": true,
                    "orejeras": true,
                  },
                  "observations": _observationController.text,
                };
                print(resultado);
                _observationController.clear();
                _hourController.text =
                    '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}';
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
    );
  }
}
