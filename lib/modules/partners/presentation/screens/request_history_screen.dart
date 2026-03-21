import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/request_history_entity.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

import '../bloc/partners_bloc.dart';

@RoutePage()
class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  late final PartnersBloc _partnersBloc;

  final List<String> _tabs = const [
    'Todos',
    'Enviado',
    'Aprobado',
    'Rechazado',
    'Desembolsado',
  ];

  @override
  void initState() {
    super.initState();
    _partnersBloc = InjectorContainer.getIt<PartnersBloc>()
      ..add(GetHistoryEvent());

    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController = TextEditingController();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _partnersBloc.close();
    super.dispose();
  }

  String? _mapTabToStatus(int index) {
    final selectedStatus = _tabs[index];
    return selectedStatus == 'Todos' ? null : selectedStatus;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _partnersBloc.add(LoadMoreRequestHistoryEvent());
    }
  }

  void _fetchHistory({bool isRefresh = false}) {
    _partnersBloc.add(
      GetHistoryEvent(
        status: _mapTabToStatus(_tabController.index),
        isRefresh: isRefresh,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _partnersBloc,
      child: Builder(
        builder: (blocContext) {
          return Scaffold(
            backgroundColor: colors.backgroundColor,
            appBar: AppBar(
              backgroundColor: colors.backgroundColor,
              surfaceTintColor: colors.backgroundColor,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: colors.blue),
                onPressed: () => context.router.back()
              ),
              title: Text(
                'Historial de solicitudes',
                style: AppTextStyles.mainStyle16Bold(
                  context,
                ).copyWith(color: colors.black, fontSize: 18),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colors.blue,
                  unselectedLabelColor: colors.lead,
                  indicatorColor: colors.blue,
                  indicatorWeight: 3,
                  dividerColor: colors.lead.withValues(alpha: 0.3),
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  onTap: (_) {
                    _searchController.clear();
                    _fetchHistory();
                  },
                ),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBox(
                  controller: _searchController,
                  onSearch: () {
                    FocusScope.of(context).unfocus();
                    _fetchHistory();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'RECIENTES',
                    style: AppTextStyles.mainStyle12Bold(
                      context,
                    ).copyWith(color: colors.lead),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocBuilder<PartnersBloc, PartnersState>(
                    builder: (context, state) {
                      if (state is RequestHistoryLoading) {
                        return Center(
                          child: CircularProgressIndicator(color: colors.blue),
                        );
                      }

                      if (state is RequestHistoryError) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            _fetchHistory();
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.mainStyle12(
                                    context,
                                  ).copyWith(color: colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is RequestHistoryLoaded) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            _fetchHistory(isRefresh: true);
                          },
                          child: state.history.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 120),
                                    _EmptyRequestHistory(),
                                  ],
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  itemCount: state.history.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == state.history.length &&
                                        !state.hasReachedMax) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24.0,
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 10),
                                              Text(
                                                'Cargando mas registros...',
                                                style:
                                                    AppTextStyles.mainStyle12(
                                                      context,
                                                    ).copyWith(
                                                      color: colors.lead,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    if (index == state.history.length) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16.0,
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.history,
                                                color: colors.lead.withValues(
                                                  alpha: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Mostrando los últimos 30 días de actividad',
                                                style:
                                                    AppTextStyles.mainStyle10(
                                                      context,
                                                    ).copyWith(
                                                      color: colors.lead,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    final item = state.history[index];
                                    return _RequestCard(item: item);
                                  },
                                ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          _fetchHistory();
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [SizedBox(height: 1)],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchBox extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBox({required this.controller, required this.onSearch});

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _clearSearch() {
    widget.controller.clear();
    FocusScope.of(context).unfocus();
    widget.onSearch(); // vuelve a cargar sin filtro
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.lead.withValues(alpha: 0.3)),
        ),
        child: TextField(
          controller: widget.controller,
          textInputAction: TextInputAction.search,
          onSubmitted: _hasText
              ? (_) {
                  FocusScope.of(context).unfocus();
                  widget.onSearch();
                }
              : null,
          decoration: InputDecoration(
            hintText: 'Buscar por descripción',
            hintStyle: AppTextStyles.mainStyle12(
              context,
            ).copyWith(color: colors.lead),

            prefixIcon: _hasText
                ? IconButton(
                    icon: Icon(Icons.close, color: colors.lead),
                    onPressed: _clearSearch,
                  )
                : Icon(Icons.abc, color: colors.lead),

            suffixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: _hasText ? colors.blue : colors.lead,
              ),
              onPressed: _hasText
                  ? () {
                      FocusScope.of(context).unfocus();
                      widget.onSearch();
                    }
                  : null,
            ),

            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRequestHistory extends StatelessWidget {
  const _EmptyRequestHistory();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'No hay solicitudes.',
          style: AppTextStyles.mainStyle12(
            context,
          ).copyWith(color: colors.lead),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestHistoryEntity item;

  const _RequestCard({required this.item});

  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'enviado':
        return colors.blue;
      case 'aprobado':
        return colors.amber;
      case 'desembolsado':
        return colors.green;
      case 'rechazado':
        return colors.red;
      default:
        return colors.lead;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'enviado':
        return Icons.credit_card_outlined;
      case 'aprobado':
        return Icons.gavel_outlined;
      case 'desembolsado':
        return Icons.account_balance_wallet_outlined;
      case 'rechazado':
        return Icons.cancel_outlined;
      default:
        return Icons.list_alt_outlined;
    }
  }

  void _showRejectionDialog(
    BuildContext context, {
    required ColorScheme colors,
    required String rejectionReason,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Motivo de rechazo',
                  style: AppTextStyles.mainStyle16Bold(
                    context,
                  ).copyWith(color: colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.red.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.red.withOpacity(0.18)),
                  ),
                  child: Text(
                    rejectionReason,
                    style: AppTextStyles.mainStyle12(
                      context,
                    ).copyWith(color: colors.black, height: 1.4),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.blue,
                      foregroundColor: colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Entendido',
                      style: AppTextStyles.mainStyle12Bold(
                        context,
                      ).copyWith(color: colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(item.status, colors);

    final hasRejectionReason =
        item.status.toLowerCase() == 'rechazado' &&
        item.rejectionReason != null &&
        item.rejectionReason!.trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: hasRejectionReason
          ? () => _showRejectionDialog(
              context,
              colors: colors,
              rejectionReason: item.rejectionReason!.trim(),
            )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: statusColor, width: 4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getStatusIcon(item.status),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDate(item.date),
                              style: AppTextStyles.mainStyle10Bold(
                                context,
                              ).copyWith(color: colors.lead),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.status.toUpperCase(),
                                style: AppTextStyles.mainStyle10Bold(
                                  context,
                                ).copyWith(color: statusColor, fontSize: 9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.reason,
                          style: AppTextStyles.mainStyle14Bold(
                            context,
                          ).copyWith(color: colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bs ${item.amount.toStringAsFixed(0)}',
                          style: AppTextStyles.mainStyle12(
                            context,
                          ).copyWith(color: colors.lead),
                        ),
                        if (hasRejectionReason) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                                color: colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ver motivo de rechazo',
                                style: AppTextStyles.mainStyle10Bold(
                                  context,
                                ).copyWith(color: colors.red),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasRejectionReason)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colors.lead.withOpacity(0.6),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
