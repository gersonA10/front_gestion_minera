import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/camp/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class HomeDashboardCampScreen extends StatefulWidget {
  const HomeDashboardCampScreen({super.key});

  @override
  State<HomeDashboardCampScreen> createState() =>
      _HomeDashboardCampScreenState();
}

class _HomeDashboardCampScreenState extends State<HomeDashboardCampScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(backgroundColor: TColors.white, title: Text('Campamento')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CardDashboardCampWidget(type: 'activo'),
                    CardDashboardCampWidget(type: 'completado'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Solicitudes Recientes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
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
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    return CardRequestsWidget(state: index);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: TColors.appMainColor,
          icon: Icon(Icons.add),
          label: Text('Nueva Solicitud',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)),
        ),
      ),
    );
  }
}