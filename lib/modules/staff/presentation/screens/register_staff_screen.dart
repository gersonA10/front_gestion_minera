import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/color.constant.dart';

@RoutePage()
class RegisterStaffScreen extends StatefulWidget {
  const RegisterStaffScreen({super.key});

  @override
  State<RegisterStaffScreen> createState() => _RegisterStaffScreenState();
}

class _RegisterStaffScreenState extends State<RegisterStaffScreen> {
  String? _opcionseleccionada;
  final _roles = ['usuario', 'jefe campamento', 'jefe maquinaria'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Personal')),
      body: Padding(
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
                    color: TColors.appDisabledColor.withValues(alpha: 0.2),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.all(20),
                    child: Column(
                      children: [
                        CustomFormStaffWidget(),

                        const SizedBox(height: 15),
                        const Row(
                          children: [
                            Icon(Icons.abc),
                            Text(
                              'CI / Carnet Identidad',
                              style: TextStyle(
                                color: TColors.appMainDarkColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const TextField(
                          decoration: InputDecoration(
                            hintText: 'Ingrese el carnet',
                            hintStyle: TextStyle(
                              color: TColors.textFieldDisabledBorderDarkColor,
                            ),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.abc),
                            Text(
                              'Fecha de ingreso',
                              style: TextStyle(
                                color: TColors.appMainDarkColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'mm/dd/yyyy',
                            hintStyle: TextStyle(
                              color: TColors.textFieldDisabledBorderDarkColor,
                            ),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.abc),
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
                        const Row(
                          children: [
                            Icon(Icons.abc),
                            Text(
                              'Cargo / Puesto',
                              style: TextStyle(
                                color: TColors.appMainDarkColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          decoration: InputDecoration(
                            hintText: '0.00',
                            suffixIcon: const Align(
                              alignment: Alignment.centerRight,
                              widthFactor: 1,
                              child: Padding(
                                padding: EdgeInsetsGeometry.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Bs',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
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
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: TColors.appMainDarkColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_outlined, color: TColors.white),
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
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 20),
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
          ],
        ),
      ),
    );
  }
}

class CustomFormStaffWidget extends StatelessWidget {
  
  const CustomFormStaffWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.abc),
            Text(
              'Nombre Completo',
              style: TextStyle(
                color: TColors.appMainDarkColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'Ej. Juan Alberto Perez garcia',
            hintStyle: TextStyle(
              color:
                  TColors.textFieldDisabledBorderDarkColor,
            ),
          ),
        ),
      ],
    );
  }
}
