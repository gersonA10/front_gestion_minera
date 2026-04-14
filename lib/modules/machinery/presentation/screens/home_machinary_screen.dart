import 'package:auto_route/auto_route.dart';
import 'package:front_gestion_minera/core/widgets/logout_button_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

@RoutePage()
class HomeMachinaryScreen extends StatefulWidget {
  const HomeMachinaryScreen({super.key});

  @override
  State<HomeMachinaryScreen> createState() => _HomeMachinaryScreenState();
}

class _HomeMachinaryScreenState extends State<HomeMachinaryScreen> {
  String rol = 'cargando...';

  Future<void> _loadUserData() async {
    final role = await UserSession.getRole();
    setState(() {
      rol = role;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: TColors.appMainColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(UserSession.userName),
                          const SizedBox(height: 10),
                          Text(rol),
                        ],
                      ),
                      Spacer(),
                      LogoutButton()
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFF013467),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Maquinaria',
                        style: TextStyle(
                          color: TColors.white,
                        ),
                      ),
                      Text(
                        '124',
                        style: TextStyle(
                          color: TColors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_outlined,
                                  color: TColors.green,
                                ),
                                Spacer(),
                                Text(
                                  'ACTIVO',
                                  style: TextStyle(
                                    color: TColors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text('OPERATIVAS'),
                            Text(
                              '98',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber, color: TColors.red),
                                Spacer(),
                                Text(
                                  'PARADO',
                                  style: TextStyle(
                                    color: TColors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text('INACTIVAS'),
                            Text(
                              '24',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Listado de Maquinas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Ver Todos',
                        style: TextStyle(color: TColors.appMainColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return _cardMaquinas(index);
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: TColors.white,
                      size: 23,
                    ),
                    label: Text(
                      'Registrar Nueva Maquina',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFF013467),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // SizedBox(
                //   width: double.infinity,
                //   height: 52,
                //   child: OutlinedButton.icon(
                //     onPressed: () {
                //       SessionActions.logout();
                //     },
                //     icon: const Icon(
                //       Icons.logout,
                //       color: TColors.white,
                //       size: 18,
                //     ),
                //     label: const Text(
                //       'Cerrar Sesión',
                //       style: TextStyle(
                //         color: TColors.white,
                //         fontWeight: FontWeight.w700,
                //         fontSize: 16,
                //       ),
                //     ),
                //     style: OutlinedButton.styleFrom(
                //       backgroundColor: Colors.red,
                //       side: const BorderSide(
                //         color: Color(0xFFFFC9C9),
                //         width: 1.2,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(14),
                //       ),
                //       elevation: 0,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getEstado(String tipo) {
    if (tipo == 'Excavadora') {
      return Icon(
        Icons.handyman,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    if (tipo == 'Camión') {
      return Icon(
        Icons.local_shipping_outlined,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    if (tipo == 'Perforadora') {
      return Icon(
        Icons.precision_manufacturing,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    return Icon(
      Icons.handyman,
      color: TColors.appMainColor.withValues(alpha: 0.9),
    );
  }

  Container _cardMaquinas(int index) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TColors.appMainColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: getEstado('Camión')
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Excavadora-camion',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'detalles',
                style: TextStyle(color: TColors.textFieldDisabledColor),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: ((index % 2) == 0)
                  ? TColors.green.withValues(alpha: 0.2)
                  : TColors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              ((index % 2) == 0) ? 'ACTIVO' : 'INACTIVO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ((index % 2) == 0)
                    ? TColors.green.withValues(alpha: 0.9)
                    : TColors.red.withValues(alpha: 0.9),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
