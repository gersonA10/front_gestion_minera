import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/financialManagment/cards_primary_and_secondary_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/financialManagment/request_title_widget.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InjectorContainer.getIt<TreasuryBloc>()
            ..add(DashboardDataEvent())
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colors.backgroundColor,
            appBar: AppBar(
              title: Text('Gestion Financiera',style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.black,
                  ),),
            ),
            body: IndexedStack(index: _selectedIndex, children: pages),
            floatingActionButton: _selectedIndex == 0
                ? FloatingActionButton.extended(
                    onPressed: () async {
                      await context.router.push(UrgentTransactionRoute());
                      if (context.mounted) {
                        context.read<TreasuryBloc>().add(DashboardDataEvent());
                      }
                    },
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.colors});

  final ColorScheme colors;
  

  @override
  Widget build(BuildContext context) {
    final userName = UserSession.userName.isEmpty
        ? ''
        : UserSession.userName;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<TreasuryBloc>().add(DashboardDataEvent());
          await Future.delayed(const Duration(seconds: 1)); 
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                'Hola, $userName',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.black,
                ),
              ),
              SizedBox(height: 24),
              BlocConsumer<TreasuryBloc, TreasuryState>(
                listener: (context, state) {
                  if (state is DashboardDataError) {
                    CustomAlert.show(
                      context,
                      title: 'Error',
                      message: state.message,
                      type: AlertType.error,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is DashboardDataLoading) {
                    return const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is DashboardDataLoaded) {
                    final data = state.bondBalance;
        
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryCard(
                                title: 'Caja Mayor',
                                amount: '${data.cajaMayor}',
                                icon: Icons.account_balance,
                                colors: colors,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: SecondaryCard(
                                title: 'Caja Chica',
                                amount: '${data.cajaChica}',
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
                                amount: '${data.aDesembolsar}',
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
                                amount: '${data.saldoDisponibleReal}',
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.router.push(PendingApplicationsRoute());
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF295AF5),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Ver todo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.pendingApplicationsResponseEntity.data.length,
                        itemBuilder: (context, index) {
                          final data = state.pendingApplicationsResponseEntity.data[index];
                          return GestureDetector(
                            onTap: (){
                              InjectorContainer.getIt<AppRouter>().push(ViewRequestDetailsRoute(id: data.requestId));
                            },
                            child: RequestTile(
                              title: data.motivo,
                              subtitle: 'Solocitante:${data.solicitante}',
                              amount: data.monto.toString(),
                              icon: Icons.handyman,
                            ),
                          );
                        },
                      ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
