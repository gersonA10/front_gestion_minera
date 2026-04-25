import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/constants/color.constant.dart';
import '../widgets/widgets.dart';

@RoutePage()
class DetailMachineryScreen extends StatefulWidget {
  const DetailMachineryScreen({super.key});

  @override
  State<DetailMachineryScreen> createState() => _DetailMachineryScreenState();
}

class _DetailMachineryScreenState extends State<DetailMachineryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(title: Text('Detalles Maquina')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        color: TColors.white,
                        child: FadeInImage.assetNetwork(
                          placeholder: AssetImageApp.getIconLoading,
                          image: null ?? '',
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
                    const SizedBox(height: 150),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: _viewState('activo')
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Excavadora CAT 336 NOMBRE',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID nombre',
                            style: TextStyle(
                              fontSize: 15,
                              color: TColors.appDisabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: TColors.greyText.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.precision_manufacturing),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.build, color: TColors.white, size: 23),
                    label: Text(
                      'Solicitud de Mantenimiento',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: TColors.appMainDarkColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Historial de Solicitudes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {context.router.push(MaintenanceRequestHistoryRoute(machineId: 'cb155c0d-2ec0-42db-953c-b50ba9bf6081'));},
                      child: Text(
                        'Ver Todos',
                        style: TextStyle(color: TColors.appMainColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return CardMaintenanceWidget();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _viewState(String tipo) {
    if (tipo == 'activo') {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: TColors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'ACTIVO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.white,
            fontSize: 10,
          ),
        ),
      );
    }
    if (tipo == 'en mantenimiento') {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: TColors.amber,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'MANTENIMIENTO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.white,
            fontSize: 10,
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: TColors.red,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        'INACTIVO',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: TColors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}
