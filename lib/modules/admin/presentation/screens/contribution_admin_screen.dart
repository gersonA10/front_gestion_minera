import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import '../../domain/entity/contribution_history_entity.dart';
import '../bloc/admin_bloc.dart';
import '../../../../core/widgets/custom_date_selector.dart';

class ContributionAdminScreen extends StatefulWidget {
  const ContributionAdminScreen({super.key});

  @override
  State<ContributionAdminScreen> createState() =>
      _ContributionAdminScreenState();
}

class _ContributionAdminScreenState extends State<ContributionAdminScreen> {
  final ScrollController _scrollController = ScrollController();

  String? _activePeriod;
  String? _activeDateString;
  String? _activeDateLabel;

  List<ContributionHistoryEntity> _cachedItems = [];
  bool _hasMax = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AdminBloc>().state;
      if (state is! AdminContributionHistoryLoaded &&
          state is! AdminContributionHistoryLoading) {
        context.read<AdminBloc>().add(
          GetContributionHistoryEvent(exactDate: _activeDateString),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminBloc>().state;
      if (state is AdminContributionHistoryLoaded && !state.hasReachedMax) {
        context.read<AdminBloc>().add(LoadMoreContributionHistoryEvent());
      }
    }
  }

  Future<void> _onRefresh() async {
    context.read<AdminBloc>().add(
      GetContributionHistoryEvent(
        isRefresh: true,
        exactDate: _activeDateString,
      ),
    );
  }

  Future<void> _openDateSelector() async {
    final DateFilterResult? result = await CustomDateSelector.show(context);

    if (result != null && result.exactDate != _activeDateString) {
      setState(() {
        _activePeriod = result.period;
        _activeDateString = result.exactDate;
        _activeDateLabel = result.displayTitle;
      });
      context.read<AdminBloc>().add(
        GetContributionHistoryEvent(
          isRefresh: true,
          period: _activePeriod,
          exactDate: _activeDateString,
        ),
      );
    }
  }

  void _clearDateFilter() {
    setState(() {
      _activePeriod = null;
      _activeDateString = null;
      _activeDateLabel = null;
    });
    context.read<AdminBloc>().add(
      GetContributionHistoryEvent(
        isRefresh: true,
        period: null,
        exactDate: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: BlocBuilder<AdminBloc, AdminState>(
          buildWhen: (previous, current) =>
              current is AdminContributionHistoryLoading ||
              current is AdminContributionHistoryLoaded ||
              current is AdminContributionHistoryError,
          builder: (context, state) {
            bool isLoading = state is AdminContributionHistoryLoading;

            if (state is AdminContributionHistoryLoaded) {
              _cachedItems = state.items;
              _hasMax = state.hasReachedMax;
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF0A2E7A),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      const SliverToBoxAdapter(child: _HeaderAportes()),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _openDateSelector,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFE7EAF0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_outlined,
                                          color: Color(0xFF0A2E7A),
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _activeDateLabel ??
                                              'Seleccionar Periodo',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: _activeDateLabel != null
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: _activeDateLabel != null
                                                ? const Color(0xFF0A2E7A)
                                                : const Color(0xFF7A8191),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF7A8191),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Botón para limpiar el filtro de fecha
                              if (_activeDateString != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: InkWell(
                                    onTap: _clearDateFilter,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE1E1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFFD61F1F),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      if (state is AdminContributionHistoryError &&
                          _cachedItems.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFD61F1F),
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF7A8191),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (_cachedItems.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList.separated(
                            itemCount: _hasMax
                                ? _cachedItems.length
                                : _cachedItems.length + 1,
                            itemBuilder: (_, index) {
                              if (index >= _cachedItems.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0A2E7A),
                                    ),
                                  ),
                                );
                              }
                              // Tarjeta adaptada a tu JSON
                              return ContributionCardWidget(
                                item: _cachedItems[index],
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                          ),
                        ),

                      if (!isLoading &&
                          _cachedItems.isEmpty &&
                          state is! AdminContributionHistoryError)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No hay aportes para este periodo.",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF7A8191),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),

                if (isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(color: TColors.appMainColor),
                  ),
                if (isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: TColors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1A3557),
        onPressed: () async {
          final result = await context.router.push(const CreateContributionRoute());
          if (!context.mounted) return;
          if (result == true) {
            context.read<AdminBloc>().add(GetContributionHistoryEvent(isRefresh: true));
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Aporte',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

/// =========================
/// HEADER DE LA PANTALLA
/// =========================

class _HeaderAportes extends StatelessWidget {
  const _HeaderAportes();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINANZAS DE SOCIOS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7C86A0),
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Historial de Aportes',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A2E7A),
              height: 1.15,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Revisa el progreso de las recaudaciones y contribuciones de la cooperativa.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7A8191),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// =========================
/// TARJETA DE APORTE (Adaptada al JSON)
/// =========================

class ContributionCardWidget extends StatelessWidget {
  final ContributionHistoryEntity item;

  const ContributionCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'es_BO',
      symbol: 'Bs ',
      decimalDigits: 2,
    );
    final metaFormatted = currency.format(item.metaRecaudacion);
    final recaudadoFormatted = currency.format(item.recaudadoReal);
    final dateFormatted = DateFormat(
      "dd MMM, yyyy",
      "es",
    ).format(item.fechaCreacion);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF0A2E7A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.motivo,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF20242C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Color(0xFF7A8191),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatted,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF7A8191),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 14,
                          color: Color(0xFF7A8191),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.sociosTotales} Socios',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF7A8191),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recaudado: $recaudadoFormatted',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A2E7A),
                ),
              ),
              Text(
                'Meta: $metaFormatted',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF7A8191),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.metaRecaudacion > 0
                  ? (item.recaudadoReal / item.metaRecaudacion)
                  : 0,
              backgroundColor: const Color(0xFFF0F1F4),
              color: const Color(0xFF0A2E7A),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${item.progresoPct.toStringAsFixed(1)}% completado',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7C86A0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
