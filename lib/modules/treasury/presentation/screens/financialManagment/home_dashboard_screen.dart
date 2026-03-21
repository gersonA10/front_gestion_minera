import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/financialManagment/cards_primary_and_secondary_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/financialManagment/request_title_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final List<Widget> pages = [
      HomeBody(colors: colors),
      const _HistoryBody(),
      const _ModulesBody(),
    ];
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: const Color(0xFF295AF5),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              icon: Icon(Icons.receipt_long, color: colors.white),
              label: Text(
                'Transacción Urgente',
                style: AppTextStyles.mainStyleWhite14Bold(context),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: const Color(0xFFE5EDFF),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? colors.blue : Colors.grey,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bar_chart,
              color: _selectedIndex == 1 ? colors.blue : Colors.grey,
            ),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: _selectedIndex == 2 ? colors.blue : Colors.grey,
            ),
            label: 'Modulos',
          ),
        ],
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pantalla de Historial',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ModulesBody extends StatelessWidget {
  const _ModulesBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pantalla de Módulos',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'Hola, Carlos',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colors.black,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryCard(
                    title: 'Caja Mayor',
                    amount: '\$45,800.00',
                    icon: Icons.account_balance,
                    colors: colors,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SecondaryCard(
                    title: 'Caja Chica',
                    amount: '\$1,250.00',
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.orange,
                    iconBgColor: Color(0xFFFFF3E0),
                    colors: colors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryCard(
                    title: 'Saldo a Desembolsar',
                    amount: '\$12,450.00',
                    icon: Icons.lock_outline,
                    iconColor: Colors.blue,
                    iconBgColor: Color(0xFFE3F2FD),
                    colors: colors,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SecondaryCard(
                    title: 'Saldo Disponible Real',
                    amount: '\$33,350.00',
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                    iconBgColor: Color(0xFFE8F5E9),
                    colors: colors,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solicitudes Pendientes',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF295AF5),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return RequestTile(
                  title: 'Mant. Maquinaria Pesada',
                  subtitle: 'Prov: Caterpillar Inc. • Hace 2h',
                  amount: '-\$4,500.00',
                  icon: Icons.handyman,
                );
              },
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
