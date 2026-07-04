import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/request_history_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/date_util.dart';

import '../bloc/partners_bloc.dart';

class _ReqColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

@RoutePage()
class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;
  late final PartnersBloc _partnersBloc;

  List<RequestHistoryEntity>? _cachedHistory;
  bool _cachedHasReachedMax = false;

  String _selectedStatus = 'Todos';
  final List<String> _filters = const [
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
      ..add(GetHistoryEvent(isRefresh: true));
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _partnersBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _partnersBloc.add(LoadMoreRequestHistoryEvent());
    }
  }

  void _fetchHistory({bool isRefresh = false}) {
    final search = _searchController.text.trim();
    _partnersBloc.add(
      GetHistoryEvent(
        status: _selectedStatus == 'Todos' ? null : _selectedStatus,
        isRefresh: isRefresh,
        search: search.isEmpty ? null : search,
      ),
    );
  }

  void _onSelectFilter(String status) {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() => _selectedStatus = status);
    _fetchHistory(isRefresh: true);
  }

  void _performSearch() {
    _searchFocusNode.unfocus();
    _fetchHistory(isRefresh: true);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _fetchHistory(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ReqColors.background,
      body: Column(
        children: [
          _RequestHeader(onBack: () => Navigator.of(context).maybePop()),
          _SearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onSubmitted: (_) => _performSearch(),
            onSearchTap: _performSearch,
            onClear: _clearSearch,
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = _filters[index];
                return _Chip(
                  label: f,
                  active: _selectedStatus == f,
                  onTap: () => _onSelectFilter(f),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<PartnersBloc, PartnersState>(
              bloc: _partnersBloc,
              builder: (context, state) {
                final bool isLoading = state is RequestHistoryLoading;
                if (state is RequestHistoryLoaded) {
                  _cachedHistory = state.history;
                  _cachedHasReachedMax = state.hasReachedMax;
                }
                final bool hasData = _cachedHistory != null;

                if (!hasData) {
                  if (isLoading) {
                    return const Center(child: StaffLoader(),);
                  }
                  if (state is RequestHistoryError) {
                    return _ErrorState(message: state.message);
                  }
                  return const SizedBox.shrink();
                }

                return _buildHistoryContent(isLoading);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(bool isLoading) {
    final history = _cachedHistory!;
    return RefreshIndicator(
      color: _ReqColors.primary,
      onRefresh: () async => _fetchHistory(isRefresh: true),
      child: Stack(
        children: [
          if (history.isEmpty)
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [_EmptyState(filter: _selectedStatus)],
            )
          else
            ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: history.length + 1,
              itemBuilder: (context, index) {
                if (index == history.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: _cachedHasReachedMax
                          ? Column(
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 20,
                                  color: _ReqColors.textSecondary
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Mostrando los últimos 30 días de actividad',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: _ReqColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: StaffLoader(),
                            ),
                    ),
                  );
                }
                return _RequestCard(item: history[index]);
              },
            ),
          if (isLoading) ...[
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2.5,
                color: _ReqColors.primary,
                backgroundColor: Colors.transparent,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: _ReqColors.background.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Header gradiente ────────────────────────────────────────────────────────

class _RequestHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _RequestHeader({required this.onBack});

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_ReqColors.primary, _ReqColors.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -24,
            child: _circle(120, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 30,
            right: 40,
            child: _circle(60, _ReqColors.gold.withValues(alpha: 0.18)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: onBack,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Historial de Solicitudes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Seguimiento de tus solicitudes de egreso de los últimos 30 días.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─── Búsqueda ────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchTap;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onSearchTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _ReqColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _ReqColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: _ReqColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _ReqColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'Buscar por descripción',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: _ReqColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: _ReqColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
            GestureDetector(
              onTap: onSearchTap,
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_ReqColors.primary, _ReqColors.primaryDeep],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_ReqColors.primary, _ReqColors.primaryDeep],
                )
              : null,
          color: active ? null : _ReqColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? Colors.transparent : _ReqColors.border,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _ReqColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : _ReqColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Tarjeta de solicitud ────────────────────────────────────────────────────

class _RequestStatusStyle {
  final Color fg;
  final Color bg;
  final IconData icon;
  final String label;
  const _RequestStatusStyle({
    required this.fg,
    required this.bg,
    required this.icon,
    required this.label,
  });
}

class _RequestCard extends StatelessWidget {
  final RequestHistoryEntity item;
  const _RequestCard({required this.item});

  _RequestStatusStyle get _style {
    switch (item.status.toLowerCase()) {
      case 'enviado':
        return const _RequestStatusStyle(
          fg: _ReqColors.primary,
          bg: Color(0xFFE8F0FE),
          icon: Icons.send_rounded,
          label: 'Enviado',
        );
      case 'aprobado':
        return const _RequestStatusStyle(
          fg: Color(0xFFC47A00),
          bg: Color(0xFFFFF4E5),
          icon: Icons.gavel_rounded,
          label: 'Aprobado',
        );
      case 'desembolsado':
        return const _RequestStatusStyle(
          fg: Color(0xFF17A05D),
          bg: Color(0xFFE7F7EE),
          icon: Icons.account_balance_wallet_rounded,
          label: 'Desembolsado',
        );
      case 'rechazado':
        return const _RequestStatusStyle(
          fg: Color(0xFFD32F2F),
          bg: Color(0xFFFFEBEE),
          icon: Icons.cancel_rounded,
          label: 'Rechazado',
        );
      default:
        return const _RequestStatusStyle(
          fg: _ReqColors.textSecondary,
          bg: Color(0xFFEDEFF4),
          icon: Icons.list_alt_rounded,
          label: 'Solicitud',
        );
    }
  }

  bool get _hasRejection =>
      item.status.toLowerCase() == 'rechazado' &&
      item.rejectionReason != null &&
      item.rejectionReason!.trim().isNotEmpty;

  void _showRejectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
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
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFD32F2F),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Motivo de rechazo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _ReqColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD32F2F).withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    item.rejectionReason!.trim(),
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: _ReqColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ReqColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
    final st = _style;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _ReqColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ReqColors.border),
        boxShadow: [
          BoxShadow(
            color: _ReqColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _hasRejection ? () => _showRejectionDialog(context) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        color: st.fg.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(st.icon, color: st.fg, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.reason,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: _ReqColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: _ReqColors.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                formatDate(item.date),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: _ReqColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: st.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(st.icon, size: 13, color: st.fg),
                          const SizedBox(width: 4),
                          Text(
                            st.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: st.fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _ReqColors.border),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Monto solicitado',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _ReqColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_hasRejection)
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.remove_red_eye_rounded,
                              color: Color(0xFFD32F2F),
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Ver motivo',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      'Bs ${item.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _ReqColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Estados vacío / error ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  String get _message {
    switch (filter) {
      case 'Enviado':
        return 'No tienes solicitudes enviadas';
      case 'Aprobado':
        return 'No tienes solicitudes aprobadas';
      case 'Rechazado':
        return 'No tienes solicitudes rechazadas';
      case 'Desembolsado':
        return 'No tienes solicitudes desembolsadas';
      default:
        return 'Aún no tienes solicitudes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _ReqColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 44,
                color: _ReqColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _ReqColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aquí aparecerán tus solicitudes de egreso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: _ReqColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pudimos cargar las solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _ReqColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: _ReqColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
