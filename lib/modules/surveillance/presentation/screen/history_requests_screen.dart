import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_date_selector.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/surveillance/domain/entity/surveillance_history_entity.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/bloc/surveillance_bloc.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

import '../widget/widgets.dart';

@RoutePage()
class HistoryRequestsScreen extends StatefulWidget {
  const HistoryRequestsScreen({super.key});

  @override
  State<HistoryRequestsScreen> createState() => _HistoryRequestsScreenState();
}

class _HistoryRequestsScreenState extends State<HistoryRequestsScreen> {
  late final SurveillanceBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'Todos';
  final List<String> _statusFilters = [
    'Todos',
    'Aprobado',
    'Pendiente',
    'Rechazado',
  ];

  String? _exactDateToFetch;
  String? _periodToFetch;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<SurveillanceBloc>()
      ..add(GetSurveillanceHistoryEvent());

    _searchController.addListener(() {
      setState(() {});
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(LoadMoreSurveillanceHistoryEvent());
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

  void _fetchData({bool isRefresh = true}) {
    String? status;
    if (_selectedFilter != 'Todos' && _selectedFilter != 'Personalizado') {
      status = _selectedFilter.toLowerCase();
    }

    // Mapeo de seguridad para que el backend lo entienda en inglés
    String? mappedPeriod = _periodToFetch;
    if (mappedPeriod != null) {
      switch (mappedPeriod.toLowerCase()) {
        case 'día':
        case 'dia':
          mappedPeriod = 'day';
          break;
        case 'semana':
          mappedPeriod = 'week';
          break;
        case 'mes':
          mappedPeriod = 'month';
          break;
        case 'año':
        case 'ano':
          mappedPeriod = 'year';
          break;
      }
    }

    _bloc.add(
      GetSurveillanceHistoryEvent(
        status: status,
        search: _searchController.text.trim(),
        period: mappedPeriod,
        exactDate: _exactDateToFetch,
        isRefresh: isRefresh,
      ),
    );
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
          'Historial de Solicitudes',
          style: AppTextStyles.mainStyle16Bold(
            context,
          ).copyWith(color: colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Controles Superiores: Buscador y Filtros
          _buildTopControls(colors),

          // lista y Estados
          Expanded(
            child: BlocBuilder<SurveillanceBloc, SurveillanceState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is SurveillanceHistoryLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: colors.blue),
                  );
                }

                if (state is SurveillanceHistoryError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colors.red.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.mainStyle12(
                              context,
                            ).copyWith(color: colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _fetchData(),
                            child: const Text("Reintentar"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is SurveillanceHistoryLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async => _fetchData(isRefresh: true),
                    child: state.history.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'No se encontraron solicitudes.',
                                  style: AppTextStyles.mainStyle12(
                                    context,
                                  ).copyWith(color: colors.lead),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            itemCount:
                                state.history.length +
                                (state.hasReachedMax ? 0 : 1),
                            itemBuilder: (context, index) {
                              if (index >= state.history.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final item = state.history[index];
                              return SurveillanceHistoryCard(item: item);
                            },
                          ),
                  );
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
          // Buscador y Botón de Fechas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.lead.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                        _fetchData();
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: colors.lead.withOpacity(0.8),
                        ),
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
                        hintText: 'Buscar por solicitante...',
                        hintStyle: AppTextStyles.mainStyle12(
                          context,
                        ).copyWith(color: colors.lead),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _selectCustomDate,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: _selectedFilter == "Personalizado"
                          ? colors.amber
                          : colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune, color: colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Chips de Estado
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                return _buildFilterChip(
                  filter,
                  _getIconForStatus(filter),
                  _getColorForStatus(filter, colors),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  IconData? _getIconForStatus(String status) {
    switch (status) {
      case 'Aprobado':
        return Icons.check_circle_outline;
      case 'Pendiente':
        return Icons.hourglass_bottom;
      case 'Rechazado':
        return Icons.cancel_outlined;
      default:
        return null;
    }
  }

  Color _getColorForStatus(String status, ColorScheme colors) {
    switch (status) {
      case 'Aprobado':
        return colors.green;
      case 'Pendiente':
        return colors.amber;
      case 'Rechazado':
        return colors.red;
      default:
        return colors.blue;
    }
  }

  Widget _buildFilterChip(String label, IconData? icon, Color statusColor) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          if (label != 'Personalizado') {
            _periodToFetch = null;
            _exactDateToFetch = null;
          }
        });
        _fetchData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.blue : colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.blue : colors.lead.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? colors.white : statusColor,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.white : colors.lead,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

