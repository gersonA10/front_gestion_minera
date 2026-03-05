import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/widgets/custom_card_widget.dart';
import 'package:front_gestion_minera/utils/greeting_util.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class PartnersScreen extends StatelessWidget {
  final String nombre;
  const PartnersScreen({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(topPadding * 1),
        child: Container(
          height: screenSize.height * 0.5,
          color: Theme.of(context).colorScheme.white,
          child: Padding(
            padding: EdgeInsets.all(topPadding * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: smallSpacing * 3),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: smallSpacing * 0.5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          GreetingUtil.getGreeting(),
                          style: AppTextStyles.mainStyleGrey14(context),
                        ),
                        Text(
                          UserSession.userName,
                          style: AppTextStyles.mainStyle16Bold(context),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: smallSpacing * 0.8),
                Text(
                  'Los Tigresito',
                  style: AppTextStyles.mainStyleBlue16Bold(context),
                ),
                Text(
                  'Gestion de socios financiero',
                  style: AppTextStyles.mainStyleGrey14(context),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.bajo,
        child: Padding(
          padding: EdgeInsets.all(topPadding * 0.05),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomCardWidget(
                    onTap: () {},
                    screenSize: screenSize,
                    topPadding: topPadding,
                    smallSpacing: smallSpacing,
                    icon: Icons.account_balance,
                    title: 'Socios Financieros',
                    subtitle: 'Nueva Gestion de Socios Financieros',
                  ),
                  CustomCardWidget(
                    onTap: () {
                      InjectorContainer.getIt<AppRouter>().push(
                        LoanHistoryRoute(),
                      );
                    },
                    screenSize: screenSize,
                    topPadding: topPadding,
                    smallSpacing: smallSpacing,
                    icon: Icons.account_balance,
                    title: 'Historial de Prestamos',
                    subtitle: 'Seguimiento de Cuotas',
                  ),
                ],
              ),
              SizedBox(height: smallSpacing * 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomCardWidget(
                    onTap: () {
                      context.router.push(DistributesRoute());
                    },
                    screenSize: screenSize,
                    topPadding: topPadding,
                    smallSpacing: smallSpacing,
                    icon: Icons.account_balance,
                    title: 'Ingresos',
                    subtitle: 'Entradas de Capital',
                  ),
                  CustomCardWidget(
                    onTap: () {},
                    screenSize: screenSize,
                    topPadding: topPadding,
                    smallSpacing: smallSpacing,
                    icon: Icons.account_balance,
                    title: 'Solicitar dinero',
                    subtitle: 'Solicitud de Egreso',
                  ),
                ],
              ),
              SizedBox(height: smallSpacing * 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomCardWidget(
                    onTap: () {
                      InjectorContainer.getIt<AppRouter>().push(
                        const ContributeHistoryRoute(),
                      );
                    },
                    screenSize: screenSize,
                    topPadding: topPadding,
                    smallSpacing: smallSpacing,
                    icon: Icons.account_balance,
                    title: 'Historial de Aportes',
                    subtitle: 'Contribuciones Totales',
                  ),
                  CustomCardWidget(
                    onTap: () {},
                    screenSize: screenSize,
                    topPadding: topPadding,
                    smallSpacing: smallSpacing,
                    icon: Icons.account_balance,
                    title: 'Historial de Solicitudes',
                    subtitle: 'Seguimiento de solicitud',
                  ),
                ],
              ),
              SizedBox(height: smallSpacing * 0.5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomCardWidget(
                    onTap: () {},
                    screenSize: screenSize,
                    topPadding: topPadding,
                    smallSpacing: smallSpacing,
                    icon: Icons.account_balance,
                    title: 'Bandeja de Socios',
                    subtitle: 'Verifica tu asistencia y otras actividades',
                  ),
                ],
              ),
              SizedBox(height: smallSpacing * 1.5),
            ],
          ),
        ),
      ),
    );
  }
}
