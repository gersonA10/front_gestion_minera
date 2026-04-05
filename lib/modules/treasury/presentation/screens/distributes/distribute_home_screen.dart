import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../widgets/widgtes.dart';


@RoutePage()
class DistributeHomeScreen extends StatefulWidget {
  const DistributeHomeScreen({super.key});

  @override
  State<DistributeHomeScreen> createState() => _DistributeHomeScreenState();
}

class _DistributeHomeScreenState extends State<DistributeHomeScreen> {
  String _filtroAnio = 'Todos';
  late final TreasuryBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(GetDistributionHistoryEvent(isRefresh: true));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(LoadMoreDistributionHistoryEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _extractYear(DistributionHistoryItemEntity item) {
    final parts = item.period.trim().split(' ');
    return parts.isNotEmpty ? parts.last : '';
  }

  List<DistributionHistoryItemEntity> _applyFilter(
      List<DistributionHistoryItemEntity> items) {
    if (_filtroAnio == 'Todos') return items;
    return items.where((i) => _extractYear(i) == _filtroAnio).toList();
  }

  List<String> _availableYears(List<DistributionHistoryItemEntity> items) {
    final years = items.map(_extractYear).where((y) => y.isNotEmpty).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  String _formatCurrency(double value) => NumberFormat.currency(
        locale: 'es_BO',
        symbol: 'Bs',
        decimalDigits: 2,
      ).format(value);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: TColors.primary,
          foregroundColor: TColors.white,
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Nueva Distribución',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        appBar: AppBar(
          backgroundColor: TColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: TColors.textPrimary, size: 18),
            onPressed: () => context.router.back(),
          ),
          centerTitle: true,
          title: const Text(
            'Distribuciones',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: TColors.textPrimary, size: 22),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          buildWhen: (_, curr) =>
              curr is DistributionHistoryLoading ||
              curr is DistributionHistoryLoaded ||
              curr is DistributionHistoryError,
          builder: (context, state) {
            if (state is DistributionHistoryLoading) {
              return const Center(child: ExcavatorLoader());
            }

            if (state is DistributionHistoryError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: TColors.danger, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: const TextStyle(
                            color: TColors.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          _bloc.add(GetDistributionHistoryEvent(isRefresh: true)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is DistributionHistoryLoaded) {
              final allItems = state.items;
              final years = _availableYears(allItems);
              final filtered = _applyFilter(allItems);

              return Column(
                children: [
                  Container(
                    color: TColors.surface,
                    padding:  EdgeInsets.symmetric(
                        horizontal: 60, vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Todos', ...years].map((anio) {
                          final selected = _filtroAnio == anio;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _filtroAnio = anio),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? TColors.textPrimary
                                      : TColors.surface,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: selected
                                        ? TColors.textPrimary
                                        : TColors.border,
                                  ),
                                ),
                                child: Text(
                                  anio,
                                  style: TextStyle(
                                    color: selected
                                        ? TColors.white
                                        : TColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: TColors.primary,
                      onRefresh: () async {
                        _bloc.add(GetDistributionHistoryEvent(isRefresh: true));
                        await _bloc.stream.firstWhere((s) =>
                            s is DistributionHistoryLoaded ||
                            s is DistributionHistoryError);
                      },
                      child: filtered.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: Center(
                                    child: Text(
                                      'Sin registros',
                                      style: TextStyle(
                                          color: TColors.textSecondary,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                              itemCount: filtered.length +
                                  (state.hasReachedMax ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index == filtered.length) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          color: TColors.primary),
                                    ),
                                  );
                                }
                                return _DistribucionCard(
                                  item: filtered[index],
                                  formatCurrency: _formatCurrency,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DistribucionCard extends StatelessWidget {
  final DistributionHistoryItemEntity item;
  final String Function(double) formatCurrency;

  const _DistribucionCard({
    required this.item,
    required this.formatCurrency,
  });

  bool get _isAbierto => item.status.toLowerCase() == 'abierto';
  bool get _isCerrado => item.status.toLowerCase() == 'cerrado';
  bool get _tieneEstado => item.status.isNotEmpty;

  Color get _estadoColor =>
      _isAbierto ? const Color(0xFF0EA5E9) : TColors.success;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isCerrado
                          ? [
                              const Color(0xFF1A2A1A),
                              const Color(0xFF2D4A2D),
                            ]
                          : _isAbierto
                              ? [
                                  const Color(0xFF0C2340),
                                  const Color(0xFF1A4060),
                                ]
                              : [
                                  const Color(0xFF0D2137),
                                  const Color(0xFF1A3A55),
                                ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: _GeometricPainter(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro: ${item.registeredDate}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.period,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_tieneEstado)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _estadoColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _estadoColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _estadoColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.status,
                            style: TextStyle(
                              color: _estadoColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DataColumn(
                      label: 'Monto Registrado',
                      value: formatCurrency(item.registeredAmount),
                      labelColor: TColors.primary,
                      valueColor: TColors.textPrimary,
                    ),
                    _DataColumn(
                      label: 'Pendiente',
                      value: formatCurrency(item.amountDue),
                      labelColor: TColors.primary,
                      valueColor: item.amountDue > 0
                          ? TColors.primary
                          : TColors.textPrimary,
                      alignRight: true,
                    ),
                  ],
                ),

                if (item.progressPct > 0 && item.progressPct < 100) ...[
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.progressPct / 100,
                      minHeight: 5,
                      backgroundColor: TColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF0EA5E9)),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _DataColumn(
                      label: 'Pagado',
                      value: formatCurrency(item.amountPaid),
                      labelColor: TColors.textSecondary,
                      valueColor: TColors.textPrimary,
                      alignRight: true,
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: TColors.border),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      context.router.push(DividendDistributionDetailsRoute(
                        distributionId: item.distributionId,
                      ));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _isAbierto
                          ? TColors.primary
                          : TColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ver detalle',
                          style: TextStyle(
                            color: _isAbierto
                                ? TColors.primary
                                : TColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward,
                          size: 15,
                          color: _isAbierto
                              ? TColors.primary
                              : TColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final bool alignRight;

  const _DataColumn({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GeometricPainter extends CustomPainter {
  final Color color;
  const _GeometricPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.4, size.height)
      ..close();
    canvas.drawPath(path1, paint);

    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_GeometricPainter old) => false;
}
