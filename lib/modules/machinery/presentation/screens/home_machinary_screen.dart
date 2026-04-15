import 'package:auto_route/auto_route.dart';
import 'package:front_gestion_minera/core/widgets/logout_button_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
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
      backgroundColor: TColors.appBackgroundColor,
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
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: TColors.appMainColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.person),
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
                      const Spacer(),
                      LogoutButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF013467),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Maquinaria',
                        style: TextStyle(color: TColors.white),
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
                    CardStateMachinaryWidget(state: 'Activo'),
                    CardStateMachinaryWidget(state: 'Inactivo'),
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
                    return CardMaquinasWidget(index: index);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardStateMachinaryWidget extends StatelessWidget {
  final String state;
  const CardStateMachinaryWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: (state == 'Activo')
            ? EdgeInsets.only(right: 10)
            : EdgeInsets.only(left: 10),
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
                Icon(
                  (state == 'Activo')
                      ? Icons.check_circle_outline_outlined
                      : Icons.warning_amber,
                  color: (state == 'Activo') ? TColors.green : TColors.red,
                ),
                Spacer(),
                Text(
                  (state == 'Activo') ? 'ACTIVO' : 'PARADO',
                  style: TextStyle(
                    color: (state == 'Activo') ? TColors.green : TColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text((state == 'Activo') ? 'OPERATIVAS' : 'INACTIVAS'),
            Text(
              '98',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class CardMaquinasWidget extends StatelessWidget {
  final int index;
  const CardMaquinasWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
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
            child: getEstado('Excavadora'),
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
}
