import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_date_selector.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/partners_entity.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class ContributeHistoryScreen extends StatefulWidget {
  const ContributeHistoryScreen({super.key});

  @override
  State<ContributeHistoryScreen> createState() => _ContributeHistoryScreenState();
}

class _ContributeHistoryScreenState extends State<ContributeHistoryScreen> {
  late final PartnersBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = "Todo";
  final List<String> _filters = ["Todo", "Confirmados", "Pendientes", "Este mes"];

    String? _exactDateToFetch;
String? _periodToFetch;
  

  ContributionMetricsEntity? _currentMetrics;
  Map<String, List<ContributeHistoryDataEntity>>? _currentHistory;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<PartnersBloc>()..add(FetchContributeDataEvent());
    
    _searchController.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

void _fetchData() {
  String? status;
  String? period;

  if (_selectedFilter == "Confirmados") status = 'confirmado';
  if (_selectedFilter == "Pendientes") status = 'pendiente';

  if (_selectedFilter == "Este mes") {
    period = 'month';
    _exactDateToFetch = null; 
  } else if (_selectedFilter == "Personalizado") {
    period = _periodToFetch; 
  }

  _bloc.add(FetchContributeDataEvent(
    status: status,
    search: _searchController.text.trim(),
    period: period,
    exactDate: _exactDateToFetch,
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

  Widget _buildTopControls(ColorScheme colors) {
    return Container(
      color: colors.backgroundColor,
      child: Column(
        children: [
          // Búsqueda y Fecha
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
                        hintText: "Buscar por motivo o sistema",
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

          // Chips de Filtro
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
                        border: Border.all(
                          color: isActive ? colors.blue : colors.lead.withOpacity(0.3),
                        ),
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

  // --- CONTENIDO DEL HISTORIAL ---
  Widget _buildHistoryContent(ColorScheme colors, bool isLoading) {
    return RefreshIndicator(
      onRefresh: () async => _fetchData(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.bajo,
          border: Border(top: BorderSide(color: colors.lead.withOpacity(0.2))),
        ),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ContributionSummaryCard(metrics: _currentMetrics!),
                const SizedBox(height: 24),
                
                if (_currentHistory!.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        'No se encontraron aportes.',
                        style: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead),
                      ),
                    ),
                  )
                else
                  ..._currentHistory!.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key, // Ej: "OCTUBRE 2023"
                              style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.lead),
                            ),
                            Text(
                              '${entry.value.length} Registros',
                              style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...entry.value.map((aporte) => ContributionCard(item: aporte)),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
              ],
            ),

            // EFECTO UX: Overlays de carga sin desaparecer los datos anteriores
            if (isLoading) ...[
              Positioned(
                top: 0, left: 0, right: 0,
                child: LinearProgressIndicator(color: colors.blue, backgroundColor: Colors.transparent),
              ),
              Positioned.fill(
                child: Container(color: colors.backgroundColor.withOpacity(0.4)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.backgroundColor,
        surfaceTintColor: colors.backgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.blue),
          onPressed: () => context.router.back(),
        ),
        title: Text(
          "Historial de Aportes",
          style: AppTextStyles.mainStyle16Bold(context).copyWith(color: colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: colors.blue),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Controles Superiores Fijos (Buscador, Filtros, Fecha)
          _buildTopControls(colors),

          // 2. Lista de Aportes y Métricas (Dinámico)
          Expanded(
            child: BlocConsumer<PartnersBloc, PartnersState>(
              bloc: _bloc,
              listener: (context, state) {
                // Cuando los datos cargan exitosamente, guardamos una copia local
                if (state is ContributeDataLoaded) {
                  _currentMetrics = state.metrics;
                  _currentHistory = state.groupedHistory;
                }
              },
              builder: (context, state) {
                final isLoading = state is ContributeDataLoading;
                final hasData = _currentMetrics != null && _currentHistory != null;

                // Primera carga de la pantalla (no hay datos previos, mostramos el circulo normal)
                if (isLoading && !hasData) {
                  return Center(child: CircularProgressIndicator(color: colors.blue));
                }

                // Error en primera carga
                if (state is ContributeDataError && !hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(state.message, style: TextStyle(color: colors.red), textAlign: TextAlign.center),
                    ),
                  );
                }

                // Si ya tenemos datos, construimos la lista (Y el stack se encarga de mostrar la carga)
                if (hasData) {
                  return _buildHistoryContent(colors, isLoading);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES (TARJETAS) ---

class ContributionSummaryCard extends StatelessWidget {
  final ContributionMetricsEntity metrics;

  const ContributionSummaryCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Aportado",
            style: AppTextStyles.mainStyle12(context).copyWith(color: colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 4),
          Text(
            "\$${metrics.totalAportado.toStringAsFixed(2)}",
            style: AppTextStyles.mainStyle25Bold(context).copyWith(color: colors.white, fontSize: 32),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CONFIRMADO",
                        style: TextStyle(fontWeight: FontWeight.bold, color: colors.white.withOpacity(0.7), fontSize: 9),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${metrics.totalConfirmado.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PENDIENTE",
                        style: TextStyle(fontWeight: FontWeight.bold, color: colors.white.withOpacity(0.7), fontSize: 9),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${metrics.totalPendiente.toStringAsFixed(2)}",
                        style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContributionCard extends StatelessWidget {
  final ContributeHistoryDataEntity item;

  const ContributionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isConfirmed = item.estado.toLowerCase() == 'confirmado';
    final statusColor = isConfirmed ? colors.green : colors.amber;

    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final dateStr = '${item.fechaPago.day.toString().padLeft(2, '0')} ${months[item.fechaPago.month - 1]}, ${item.fechaPago.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: colors.green),
                  const SizedBox(width: 6),
                  Text(dateStr, style: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.estado.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("MOTIVO", style: AppTextStyles.mainStyleGrey10(context)),
                    Text(item.motivo, style: AppTextStyles.mainStyle14Bold(context)),
                    const SizedBox(height: 12),
                    Text("CAJA", style: AppTextStyles.mainStyleGrey10(context)),
                    Text("Caja Principal", style: AppTextStyles.mainStyle12Bold(context)), 
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 12),
                    Text("MONTO", style: AppTextStyles.mainStyleGrey10(context)),
                    Text(
                      "\$${item.monto.toStringAsFixed(2)}",
                      style: AppTextStyles.mainStyle20Bold(context).copyWith(color: colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}