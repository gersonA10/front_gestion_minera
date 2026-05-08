import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class RegisterMinutesMemosScreen extends StatefulWidget {
  final int isOption;
  const RegisterMinutesMemosScreen({super.key, required this.isOption});

  @override
  State<RegisterMinutesMemosScreen> createState() =>
      _RegisterMinutesMemosScreenState();
}

class _RegisterMinutesMemosScreenState
    extends State<RegisterMinutesMemosScreen> {
  late bool isSelected;
  late int _isOptionSelected;
  List<String> typeRegister = ['Acta', 'Memorando'];

  @override
  void initState() {
    super.initState();
    _isOptionSelected = widget.isOption;
    isSelected = widget.isOption == 0;
  }

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
        child: ListView(
          children: [
            Column(
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectOptionRegister(),
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
                    hintText: isSelected
                        ? 'Ej. Acta de asamblea'
                        : 'Ej. Memorando Interno',
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
                      ? Column(
                          crossAxisAlignment: .start,
                          children: [
                            const Text(
                              'Destinatario',
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
                                      hintText: 'Persona a quien se dirige',
                                      hintStyle: TextStyle(
                                        color: TColors.textFieldDisabledColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
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
                                    child: Icon(
                                      Icons.add,
                                      color: TColors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    const Text(
                      'Contenido / Descripción',
                      style: TextStyle(
                        color: TColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            minLines: 4, // Altura mínima inicial
                            maxLines: 6, // Permite que crezca un poco más
                            decoration: InputDecoration(
                              hintText:
                                  'Redacte el contenido del documento aquí...',
                              hintStyle: TextStyle(
                                color: TColors.textFieldDisabledColor,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: TColors.textFieldDisabledColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: TColors.appMainDarkColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: TColors.appMainDarkColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Subir Foto / PDF',
                    style: TextStyle(
                      color: TColors.appMainDarkColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      //bottomNavigationBar: Container(),
    );
  }

  ListView _selectOptionRegister() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: typeRegister.length,
      itemBuilder: (BuildContext context, int index) {
        final isSelectedbutton = _isOptionSelected == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _isOptionSelected = index;
              if (!isSelectedbutton) {
                isSelected = !isSelected;
              }
            });
          },
          child: AnimatedContainer(
            width: 140,
            margin: EdgeInsets.only(left: 5),
            padding: EdgeInsets.symmetric(horizontal: 30),
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSelectedbutton
                  ? TColors.appMainDarkColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                typeRegister[index],
                style: TextStyle(
                  color: isSelectedbutton ? TColors.white : TColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
