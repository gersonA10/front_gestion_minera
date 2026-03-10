import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/register_contribution.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/request_card_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class HomeSurveillanceScreen extends StatefulWidget {
  const HomeSurveillanceScreen({super.key});

  @override
  State<HomeSurveillanceScreen> createState() => _HomeSurveillanceScreenState();
}

class _HomeSurveillanceScreenState extends State<HomeSurveillanceScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Bandeja de Solicitudes",
          style: AppTextStyles.mainStyle16Bold(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: TextButton(
                onPressed: () => context.router.push(const HistoryRequestsRoute()),
                child: Text(
                  "Historial",
                  style: AppTextStyles.mainStyleBlue12Bold(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(smallSpacing, topPadding),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Aportes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody(double smallSpacing, double topPadding) {
    if (_selectedIndex == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: topPadding * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: smallSpacing * 0.5),
            Row(
              children: [
                Text(
                  "PENDIENTES (3)",
                  style: AppTextStyles.mainStyleGrey12Bold(context),
                ),
                SizedBox(width: smallSpacing * 0.8),
                Expanded(
                  child: Container(height: 1, color: Colors.grey.shade300),
                ),
              ],
            ),
            SizedBox(height: smallSpacing * 0.5),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return RequestCard(
                    date: "12 OCT 2023",
                    name: "Ing. Roberto Sánchez",
                    area: "Operaciones Mina",

                    small: smallSpacing,
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return RegisyerContributionsView();
    }
  }
}
