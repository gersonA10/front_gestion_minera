import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_date_selector.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/modules/partners/presentation/widgets/distributes/custom_card_metric_widget.dart';
import 'package:front_gestion_minera/modules/partners/presentation/widgets/distributes/dividend_card_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

import '../../domain/entity/entity.dart';

@RoutePage()
class DistributesScreen extends StatefulWidget {
  const DistributesScreen({super.key});

  @override
  State<DistributesScreen> createState() => _DistributesScreenState();
}

class _DistributesScreenState extends State<DistributesScreen> {
  late final PartnersBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = "Todo";
  final List<String> _filters = ["Todo", "Pagados", "Pendientes", "Este mes"];

  String? _exactDateToFetch;
String? _periodToFetch;

  DistributesMetricsEntity? _currentMetrics;
  Map<String, List<DistributesHistoryEntity>>? _currentHistory;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<PartnersBloc>()..add(FetchDistributesDataEvent());
    
    _searchController.addListener(() => setState(() {})); 
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(LoadMoreDistributesEvent());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

void _fetchData() {
  String? status;
  String? period;

  if (_selectedFilter == "Pagados") status = 'pagado';
  if (_selectedFilter == "Pendientes") status = 'pendiente';

  if (_selectedFilter == "Este mes") {
    period = 'month';
    _exactDateToFetch = null; // Borramos fecha exacta para que traiga el mes actual natural
  } else if (_selectedFilter == "Personalizado") {
    period = _periodToFetch; // Usamos el periodo devuelto por el modal ('day', 'month' o 'year')
  }

  _bloc.add(FetchDistributesDataEvent(
    status: status,
    search: _searchController.text.trim(),
    period: period,
    exactDate: _exactDateToFetch,
    isRefresh: true,
  ));
}

Future<void> _selectCustomDate() async {
  final result = await CustomDateSelector.show(context);

  if (result != null) {
    setState(() {
      _selectedFilter = "Personalizado"; 
      _periodToFetch = result.period;
      _exactDateToFetch = result.exactDate;
    });
    _fetchData();
  }
}

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        surfaceTintColor: colors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.blue),
          onPressed: () => context.router.back(),
        ),
        title: Text(
          'Historial de Ingresos',
          style: AppTextStyles.mainStyle16Bold(context).copyWith(color: colors.black),
        ),
      ),
      body: Column(
        children: [
          _buildTopControls(colors),
          Expanded(
            child: BlocConsumer<PartnersBloc, PartnersState>(
              bloc: _bloc,
              listener: (context, state) {
                if (state is DistributesDataLoaded) {
                  _currentMetrics = state.metrics;
                  _currentHistory = state.groupedHistory;
                }
              },
              builder: (context, state) {
                final isLoading = state is DistributesDataLoading;
                final hasData = _currentMetrics != null && _currentHistory != null;

                if (isLoading && !hasData) {
                  return Center(child: CircularProgressIndicator(color: colors.blue));
                }

                if (state is DistributesDataError && !hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(state.message, style: TextStyle(color: colors.red), textAlign: TextAlign.center),
                    ),
                  );
                }

                if (hasData) {
                  final isFetchingMore = state is DistributesDataLoaded && !state.hasReachedMax;
                  return _buildHistoryContent(colors, isLoading, isFetchingMore);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls(ColorScheme colors) {
    return Container(
      color: colors.backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.lead.withValues(alpha: 0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                        _fetchData();
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: colors.lead),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, color: colors.lead),
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                  _fetchData();
                                },
                              )
                            : null,
                        hintText: "Buscar por detalle",
                        hintStyle: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _selectCustomDate,
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: _selectedFilter == "Personalizado" ? colors.amber : colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune, color: colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isActive = _selectedFilter == filter;
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      _fetchData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? colors.blue : colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isActive ? colors.blue : colors.lead.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isActive ? colors.white : Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(ColorScheme colors, bool isLoading, bool isFetchingMore) {
    return RefreshIndicator(
      onRefresh: () async => _fetchData(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.bajo,
          border: Border(top: BorderSide(color: colors.lead.withValues(alpha: 0.2))),
        ),
        child: Stack(
          children: [
            ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildMetricsHeader(colors),
                const SizedBox(height: 14),
                
                if (_currentHistory!.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        'No se encontraron ingresos.',
                        style: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead),
                      ),
                    ),
                  )
                else
                  ..._currentHistory!.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
                          child: Text(
                            entry.key,
                            style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.lead),
                          ),
                        ),
                        ...entry.value.map((item) => DividendCard(item: item)),
                      ],
                    );
                  }),

                if (isFetchingMore && !isLoading)
                   const Padding(
                     padding: EdgeInsets.symmetric(vertical: 20),
                     child: Center(child: CircularProgressIndicator()),
                   ),
              ],
            ),
            if (isLoading) ...[
              Positioned(
                top: 0, left: 0, right: 0,
                child: LinearProgressIndicator(color: colors.blue, backgroundColor: Colors.transparent),
              ),
              Positioned.fill(
                child: Container(color: colors.backgroundColor.withValues(alpha: 0.4)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsHeader(ColorScheme colors) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CustomCardMetric(
            title: 'TOTAL DISTRIBUIDO',
            amount: 'Bs ${_currentMetrics!.totalDistribuido.toStringAsFixed(0)}',
            bgColor: colors.blue,
            titleColor: colors.white.withValues(alpha: 0.8),
            amountColor: colors.white,
          ),
          CustomCardMetric(
            title: 'PENDIENTE',
            amount: 'Bs ${_currentMetrics!.totalPendiente.toStringAsFixed(0)}',
            bgColor: colors.white,
            titleColor: colors.lead,
            amountColor: colors.amber,
          ),
          CustomCardMetric(
            title: 'COMPLETADO',
            amount: 'Bs ${_currentMetrics!.totalPagado.toStringAsFixed(0)}',
            bgColor: colors.white,
            titleColor: colors.lead,
            amountColor: colors.green,
          ),
        ],
      ),
    );
  }
}
