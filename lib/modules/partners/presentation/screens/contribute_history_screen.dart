import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/modules/partners/presentation/widgets/custom_card_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class ContributeHistoryScreen extends StatefulWidget {
  const ContributeHistoryScreen({super.key});

  @override
  State<ContributeHistoryScreen> createState() =>
      _ContributeHistoryScreenState();
}

class _ContributeHistoryScreenState extends State<ContributeHistoryScreen> {
  String selectedFilter = "Todos";
  final filters = ["Todo", "Confirmados", "Pendientes", "Mes"];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) =>
          InjectorContainer.getIt<PartnersBloc>()..add(GetContributeHistory()),
      child: Scaffold(
        backgroundColor: colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Historial de Aportes",
            style: AppTextStyles.mainStyle14Bold(context),
          ),
        ),
        body: BlocBuilder<PartnersBloc, PartnersState>(
          builder: (context, state) {
            if (state is ContributeHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ContributeHistorySuccess) {
              return ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(topPadding * 0.05),
                    child: Column(
                      children: [
                        SearchContributionBar(smallSpacing: smallSpacing),
                        SizedBox(height: smallSpacing * 0.5),
                        SizedBox(
                          height: screenSize.height * 0.03,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final filter = filters[index];

                              return FilterChipButton(
                                text: filter,
                                active: selectedFilter == filter,
                                onTap: () {
                                  setState(() => selectedFilter = filter);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: colors.whitebajo,
                    child: Padding(
                      padding: EdgeInsets.all(topPadding * 0.05),
                      child: Column(
                        children: [
                          SizedBox(height: smallSpacing * 0.5),
                          ContributionSummaryCard(
                            total: 17320.50,
                            confirmed: 12500,
                            pending: 4820.50,
                            month: "Octubre",
                            topadding: topPadding,
                            smallSpacing: smallSpacing,
                          ),
                          SizedBox(height: smallSpacing * 0.5),
                          SizedBox(
                            height: screenSize.height * 0.6,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Octubre 2023",
                                      style: AppTextStyles.mainStyleGrey12Bold(
                                        context,
                                      ),
                                    ),
                                    SizedBox(height: smallSpacing * 0.5),
                                    ContributionCard(
                                      date: "12 Oct, 2023",
                                      motivo: "Aporte Capital",
                                      sistema: "SAP-MIN",
                                      caja: "Caja Principal Operaciones",
                                      monto: 12500,
                                      confirmed: true,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
