import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        title: Text('Registro de Ingreso'),
        backgroundColor: TColors.white,
      ),
      body: Padding(
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
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: TColors.appBackgroundColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.person, size: 30),
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
                  TextFormField(decoration: InputDecoration(hintText: '07:00')),
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
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ej: Ingreso con equipamiento propio....',
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Programado 07:00 AM',
                    style: TextStyle(color: TColors.appDisabledColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
