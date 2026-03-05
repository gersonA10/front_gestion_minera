import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class ContributeHistoryScreen extends StatefulWidget {
  const ContributeHistoryScreen({super.key});

  @override
  State<ContributeHistoryScreen> createState() =>
      _ContributeHistoryScreenState();
}

class _ContributeHistoryScreenState extends State<ContributeHistoryScreen> {
  String selectedDate = '';

  String getCurrentMonth() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
  }

  @override
  void initState() {
    super.initState();
    selectedDate = getCurrentMonth();
  }

  Future<void> pickMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-01";

      setState(() {
        selectedDate = formatted;
      });

      context.read<PartnersBloc>().add(
        GetContributeHistoryMonth(exactDate: formatted),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              InjectorContainer.getIt<PartnersBloc>()
                ..add(GetContributeHistory()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.white,
          elevation: 0,
          title: Text(
            'Historial de Aportes',
            style: AppTextStyles.mainStyle16Bold(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: pickMonth,
            ),
          ],
        ),
        body: BlocConsumer<PartnersBloc, PartnersState>(
          listener: (context, state) {
            if (state is ContributeHistoryError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is ContributeHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContributeHistorySuccess) {
              return Padding(
                padding: EdgeInsets.all(topPadding * 0.05),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _filterButton(
                          context,
                          'Todos',
                          () => context.read<PartnersBloc>().add(
                            GetContributeHistory(),
                          ),
                        ),
                        _filterButton(
                          context,
                          'Semana',
                          () => context.read<PartnersBloc>().add(
                            GetContributeHistoryWeek(),
                          ),
                        ),
                        _filterButton(
                          context,
                          'Mes',
                          () => context.read<PartnersBloc>().add(
                            GetContributeHistoryMonth(exactDate: selectedDate),
                          ),
                        ),
                        _filterButton(
                          context,
                          'Año',
                          () => context.read<PartnersBloc>().add(
                            GetContributeHistoryYear(exactDate: selectedDate),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: smallSpacing * 0.5),
                    Container(
                      height: screenSize.height * 0.25,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(topPadding * 0.05),
                        child: Column(
                          children: [
                            Text(
                              'Total Aportado (Octubre)',
                              style: AppTextStyles.mainStyleWhite14(context),
                            ),
                            Text(
                              'Bs. 5000',
                              style: AppTextStyles.mainStyleWhite20Bold(
                                context,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: screenSize.width * 0.4,
                                  height: screenSize.height * 0.1,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.alpa,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'CONFIRMADO',
                                        style: AppTextStyles.mainStyleWhite14(
                                          context,
                                        ),
                                      ),
                                      Text(
                                        'BS. 3000',
                                        style:
                                            AppTextStyles.mainStyleWhite20Bold(
                                              context,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: screenSize.width * 0.4,
                                  height: screenSize.height * 0.1,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.alpa,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'PENDIENTE',
                                        style: AppTextStyles.mainStyleWhite14(
                                          context,
                                        ),
                                      ),
                                      Text(
                                        'BS. 3000',
                                        style:
                                            AppTextStyles.mainStyleWhite20Bold(
                                              context,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListView.builder(
                      itemCount: 5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        //final item = contributions[index];

                        return ContributionCard(
                          date: "2024-01-01",
                          motivo: "Contribución mensual",
                          monto: 5000.0,
                          status: "confirmado",
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _filterButton(BuildContext context, String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.blue,
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }
}

class ContributionCard extends StatelessWidget {
  final String date;
  final String motivo;
  final double monto;
  final String status;

  const ContributionCard({
    super.key,
    required this.date,
    required this.motivo,
    required this.monto,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool confirmed = status == "confirmado";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// FECHA Y ESTADO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: confirmed ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  confirmed ? "CONFIRMADO" : "PENDIENTE",
                  style: TextStyle(
                    color: confirmed ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text("Motivo: $motivo"),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "Bs. $monto",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class ContributeHistoryScreen extends StatefulWidget {
  const ContributeHistoryScreen({super.key});

  @override
  State<ContributeHistoryScreen> createState() =>
      _ContributeHistoryScreenState();
}

class _ContributeHistoryScreenState extends State<ContributeHistoryScreen> {
  String selectedDate = '';

  String getCurrentMonth() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
  }

  @override
  void initState() {
    super.initState();
    selectedDate = getCurrentMonth();
  }

  Future<void> pickMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-01";

      setState(() {
        selectedDate = formatted;
      });

      context.read<PartnersBloc>().add(
        GetContributeHistoryMonth(exactDate: formatted),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double spacing = screenSize.height * 0.02;

    return BlocProvider(
      create: (context) =>
          InjectorContainer.getIt<PartnersBloc>()
            ..add(GetContributeHistoryMonth(exactDate: selectedDate)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.white,
          elevation: 0,
          title: Text(
            'Historial de Aportes',
            style: AppTextStyles.mainStyle16Bold(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: pickMonth,
            ),
          ],
        ),
        body: BlocConsumer<PartnersBloc, PartnersState>(
          listener: (context, state) {
            if (state is ContributeHistoryError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is ContributeHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ContributeHistorySuccess) {
              final contributions = state.data;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// FILTROS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _filterButton(
                            context,
                            'Todos',
                            () => context.read<PartnersBloc>().add(
                              GetContributeHistory(),
                            ),
                          ),
                          _filterButton(
                            context,
                            'Semana',
                            () => context.read<PartnersBloc>().add(
                              GetContributeHistoryWeek(),
                            ),
                          ),
                          _filterButton(
                            context,
                            'Mes',
                            () => context.read<PartnersBloc>().add(
                              GetContributeHistoryMonth(
                                exactDate: selectedDate,
                              ),
                            ),
                          ),
                          _filterButton(
                            context,
                            'Año',
                            () => context.read<PartnersBloc>().add(
                              GetContributeHistoryYear(exactDate: selectedDate),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: spacing),

                      /*
                      /// CARD TOTAL
                      Container(
                        padding: EdgeInsets.all(spacing),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total Aportado',
                              style: AppTextStyles.mainStyleWhite14(context),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bs. ${state.total}',
                              style: AppTextStyles.mainStyleWhite20Bold(
                                context,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _summaryCard(
                                    context,
                                    'CONFIRMADO',
                                    state.confirmed,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _summaryCard(
                                    context,
                                    'PENDIENTE',
                                    state.pending,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),*/
                      SizedBox(height: spacing),

                      /// LISTA DE APORTES
                      ListView.builder(
                        itemCount: contributions.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = contributions[index];

                          return ContributionCard(
                            date: item.fechaPago.toString(),
                            motivo: item.motivo,
                            monto: item.monto as double,
                            status: item.estado,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _filterButton(BuildContext context, String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.blue,
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }

  Widget _summaryCard(BuildContext context, String title, dynamic amount) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.alpa,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyles.mainStyleWhite14(context)),
          Text(
            "Bs. $amount",
            style: AppTextStyles.mainStyleWhite20Bold(context),
          ),
        ],
      ),
    );
  }
}
*/
