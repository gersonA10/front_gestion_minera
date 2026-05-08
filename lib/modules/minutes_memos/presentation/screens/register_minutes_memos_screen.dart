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
              padding: EdgeInsets.symmetric(horizontal: 30,vertical: 5),
              decoration: BoxDecoration(
                color: TColors.textPrimary.withValues(alpha: 0.2),
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
                      color: TColors.textFieldIconColor,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Center(child: Text('Acta',style: TextStyle(color: TColors.white),)),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text ('Titulo Del Documento', style: TextStyle(color: TColors.textPrimary,fontWeight: FontWeight.bold),),
            const SizedBox(height: 10),
            TextFormField(decoration: InputDecoration(hintText: 'Ej. Acta de asamblea',hoverColor: TColors.white),),
            const SizedBox(height: 10),
            Container(),
            const SizedBox(height: 10),
            Container(child: isSelected ? const SizedBox() : Column(crossAxisAlignment: .start,children: [Text('Ubicación'),Row()],),)
          ],
        ),
      ),
    );
  }
}
