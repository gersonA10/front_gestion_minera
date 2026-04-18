import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class ListMachineryScreen extends StatefulWidget {
  const ListMachineryScreen({super.key});

  @override
  State<ListMachineryScreen> createState() => _ListMachineryScreenState();
}

class _ListMachineryScreenState extends State<ListMachineryScreen> {
  List<String> tipos = ['Todos', 'Excavador', 'Camion', 'Perforadora'];
  List<Map<String, dynamic>> estados = [
    {"estado": "Todo", "color": TColors.darkBackgroundSplash},
    {"estado": "Activo", "color": TColors.green},
    {"estado": "Inactivo", "color": TColors.red},
    {"estado": "Mantenimiento", "color": TColors.homeTopColor},
  ];
  int _selectIndexTipo = 0;
  int _selectIndexEstado = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(title: Text('Listado de Maquinas')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hint: Text(
                      'Buscar por ID, nombre o modelo',
                      style: TextStyle(color: TColors.greyText),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // filtro de tipo
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      final isSelected = _selectIndexTipo == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectIndexTipo = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TColors.appMainDarkColor
                                : TColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              tipos[index],
                              style: TextStyle(
                                color: isSelected
                                    ? TColors.white
                                    : TColors.bgColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      Text(
                        'Estado: ',
                        style: TextStyle(color: TColors.appDisabledColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        // filtro de estados
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index) {
                            final isSelected = _selectIndexEstado == index;
                            final colorestado = estados[index]['color'] as Color;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectIndexEstado = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorestado.withValues(alpha: 0.5)
                                      : TColors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    if (isSelected)
                                      Icon(
                                        Icons.circle,
                                        color: Color.lerp(
                                                  colorestado,
                                                  Colors.black,
                                                  0.3
                                                )!,
                                        size: 10,
                                      ),
                                    const SizedBox(width: 5),
                                    Center(
                                      child: Text(
                                        estados[index]['estado'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected
                                              ? Color.lerp(
                                                  colorestado,
                                                  Colors.black,
                                                  0.5
                                                )!
                                              : TColors.appBackgroundDarkColor,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: TColors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: TColors.appBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.agriculture),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nombre',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text('Unit ID:'),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TColors.enabledAccount.withValues(
                                      alpha: 0.7,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Activo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: TColors
                                          .textFieldFocusedBorderDarkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
