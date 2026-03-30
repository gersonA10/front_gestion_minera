import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';

import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';

enum LoteStatus { disponible, parcial, agotado }

@RoutePage()
class GoldDashboardScreen extends StatefulWidget {
  const GoldDashboardScreen({super.key});

  @override
  State<GoldDashboardScreen> createState() => _GoldDashboardScreenState();
}

class _GoldDashboardScreenState extends State<GoldDashboardScreen> {
  //Guardar datos en cache
  GoldInventoryEntity? _cachedInventory;
  List<GoldBatchEntity>? _cachedBatches;
  bool _cachedHasReachedMax = false;

  int _selectedFilter = 0;
  int _selectedNav = 0;
  final List<String> _filters = ['Todos', 'Disponible', 'Parcial', 'Agotado'];
  final ScrollController _scrollController = ScrollController();

  late final TreasuryBloc _treasuryBloc;

  bool _fabVisible = true;
  double _lastScrollOffset = 0;
  static const double _scrollThreshold = 10.0;

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(FetchGoldDashboardDataEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final current = _scrollController.position.pixels;
    final diff = current - _lastScrollOffset;

    if (diff > _scrollThreshold && _fabVisible) {
      setState(() => _fabVisible = false);
    } else if (diff < -_scrollThreshold && !_fabVisible) {
      setState(() => _fabVisible = true);
    }

    _lastScrollOffset = current;

    if (current >= _scrollController.position.maxScrollExtent - 200) {
      _treasuryBloc.add(LoadMoreGoldBatchesEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _treasuryBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: SafeArea(
          child: BlocBuilder<TreasuryBloc, TreasuryState>(
            buildWhen: (previous, current) =>
                current is GoldDashboardLoading ||
                current is GoldDashboardLoaded ||
                current is GoldDashboardError,

            builder: (context, state) {
              if (state is GoldDashboardLoaded) {
                _cachedInventory = state.inventory;
                _cachedBatches = state.batches;
                _cachedHasReachedMax = state.hasReachedMax;
              }

              final bool isLoading = state is GoldDashboardLoading;

              if (_cachedInventory == null) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GoldDashboardError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              }

              final inventory = _cachedInventory!;
              final batches = _cachedBatches!;
              final hasReachedMax = _cachedHasReachedMax;

              return Column(
                children: [
                  AppBarDashboardGoldWidget(context: context),
                  Expanded(
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            context.read<TreasuryBloc>().add(
                              FetchGoldDashboardDataEvent(isRefresh: true),
                            );
                            await context
                                .read<TreasuryBloc>()
                                .stream
                                .firstWhere(
                                  (state) =>
                                      state is GoldDashboardLoaded ||
                                      state is GoldDashboardError,
                                );
                          },
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                ValueEstimateWigdet(
                                  estimateValue: inventory.estimateValue,
                                  totalGramsVault: inventory.totalGramsVault,
                                ),
                                const SizedBox(height: 16),
                                _buildFilterTabs(),
                                const SizedBox(height: 20),
                                const Text(
                                  'Lotes',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Usamos batches de la caché
                                ...batches.map((lote) => _buildLoteCard(lote)),
                                if (batches.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Center(
                                      child: Text(
                                        'No hay lotes con este estado',
                                        style: TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (!hasReachedMax && batches.isNotEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: const LinearProgressIndicator(
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        if (isLoading)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                color: const Color(
                                  0xFFF5F5F7,
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: ScrollAwareFabs(
          visible: _fabVisible,
          onAddTap: () async {
            await context.router.push(NewExtractionRoute());
            if (context.mounted) {
              _treasuryBloc.add(FetchGoldDashboardDataEvent());
            }
          },
          onMoneyTap: () async {
            await context.router.push(RegisterSellRoute());
            if (context.mounted) {
              _treasuryBloc.add(FetchGoldDashboardDataEvent());
            }
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final selected = _selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = index);
                String? statusFilter;
                if (index == 1) statusFilter = 'Disponible';
                if (index == 2) statusFilter = 'Parcial';
                if (index == 3) statusFilter = 'Agotado';
                _treasuryBloc.add(
                  FetchGoldDashboardDataEvent(
                    isRefresh: true,
                    status: statusFilter,
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoteCard(GoldBatchEntity lote) {
    final statusColor = _statusColor(lote.status);

    // Calcular el porcentaje disponible
    double disponibilidadPorcentaje = 0.0;
    if (lote.originalWeight > 0) {
      disponibilidadPorcentaje = lote.avilableWeight / lote.originalWeight;
    }

    // Color específico para el peso disponible según el estado
    final disponibleColor = lote.status == 'Disponible'
        ? const Color(0xFF16A34A)
        : lote.status == 'Parcial'
        ? const Color(0xFFF59E0B)
        : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusBadge(lote.status, statusColor),
                const SizedBox(width: 8),
                Text(
                  lote.batchCode,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(lote.extractionDate),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCol(
                  'PESO ORIG.',
                  '${_formatGrams(lote.originalWeight)} g',
                  const Color(0xFF374151),
                ),
                const SizedBox(width: 24),
                _buildStatCol(
                  'DISPONIBLE',
                  '${_formatGrams(lote.avilableWeight)} g',
                  disponibleColor,
                ),
                const SizedBox(width: 24),
                _buildStatCol(
                  'PUREZA',
                  '${lote.purity}%',
                  const Color(0xFF374151),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: disponibilidadPorcentaje,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        disponibleColor,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  // Mostramos el porcentaje entero (multiplicado por 100)
                  '${(disponibilidadPorcentaje * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: disponibleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'Inicio',
      },
      {
        'icon': Icons.history_outlined,
        'activeIcon': Icons.history,
        'label': 'Historial',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = _selectedNav == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedNav = index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected
                            ? items[index]['activeIcon'] as IconData
                            : items[index]['icon'] as IconData,
                        size: 24,
                        color: selected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[index]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Disponible':
        return const Color(0xFF16A34A);
      case 'Parcial':
        return const Color(0xFFF59E0B);
      case 'Agotado':
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatGrams(double value) {
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }
}

class ValueEstimateWigdet extends StatelessWidget {
  final double estimateValue;
  final double totalGramsVault;

  const ValueEstimateWigdet({
    super.key,
    required this.estimateValue,
    required this.totalGramsVault,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Valor Estimado card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Valor Estimado Total',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$estimateValue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const TextSpan(
                        text: ' Bs',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Bóveda card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'BÓVEDA',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$totalGramsVault',
                        style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' g',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Total acumulado',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
