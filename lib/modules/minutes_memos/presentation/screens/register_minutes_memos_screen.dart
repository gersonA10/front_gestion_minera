import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class RegisterMinutesMemosScreen extends StatefulWidget {
  final bool isMemo;
  const RegisterMinutesMemosScreen({super.key, required this.isMemo});

  @override
  State<RegisterMinutesMemosScreen> createState() =>
      _RegisterMinutesMemosScreenState();
}

class _RegisterMinutesMemosScreenState
    extends State<RegisterMinutesMemosScreen> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        title: Text(
          'Registrar Documento',
          style: TextStyle(
            color: TColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              'TIPO DE DOCUMENTO',
              style: TextStyle(
                color: TColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              decoration: BoxDecoration(
                color: TColors.appMainDarkColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  return AnimatedContainer(
                    width: 140,
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: TColors.appMainDarkColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        'Acta',
                        style: TextStyle(color: TColors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Titulo Del Documento',
              style: TextStyle(
                color: TColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Ej. Acta de asamblea',
                hintStyle: TextStyle(color: TColors.textFieldDisabledColor),
                filled: true,
                fillColor: TColors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Fecha de Emisión',
              style: TextStyle(
                color: TColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(),
            const SizedBox(height: 10),
            Container(
              child: isSelected
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: .start,
                      children: [
                        const Text(
                          'Ubicación',
                          style: TextStyle(
                            color: TColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: TColors.white,
                                  hintText: 'Lugar de la reunión',
                                  hintStyle: TextStyle(
                                    color: TColors.textFieldDisabledColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Participantes',
                          style: TextStyle(
                            color: TColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: TColors.white,
                                  hintText: 'Nombre del Participante',
                                  hintStyle: TextStyle(
                                    color: TColors.textFieldDisabledColor,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: TColors.appMainDarkColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.add, color: TColors.white,size: 20),
                              ),
                            ),
                          ],
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
