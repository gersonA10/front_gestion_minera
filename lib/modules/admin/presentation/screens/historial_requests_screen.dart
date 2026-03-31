import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../domain/entity/request_history_entity.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/widgets.dart';

class HistorialRequestsScreen extends StatefulWidget {
  const HistorialRequestsScreen({super.key});

  @override
  State<HistorialRequestsScreen> createState() => _HistorialRequestsScreenState();
}

class _HistorialRequestsScreenState extends State<HistorialRequestsScreen> {
  final ScrollController _scrollController = ScrollController();

  String _activeFilter = 'todos';
  List<RequestHistoryEntity> _cachedItems = [];
  bool _hasMax = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AdminBloc>().state;
      if (state is AdminInitial || state is AdminPendingRequestsLoaded) {
         context.read<AdminBloc>().add(
          GetRequestHistoryEvent(status: _activeFilter),
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
      if (state is AdminRequestHistoryLoaded && !state.hasReachedMax) {
        context.read<AdminBloc>().add(LoadMoreRequestHistoryEvent());
      }
    }
  }

  Future<void> _onRefresh() async {
    context.read<AdminBloc>().add(
      GetRequestHistoryEvent(isRefresh: true, status: _activeFilter),
    );
  }

  void _changeFilter(String filter) {
    if (_activeFilter == filter) return;
    setState(() => _activeFilter = filter);
    context.read<AdminBloc>().add(
      GetRequestHistoryEvent(isRefresh: true, status: filter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      body: SafeArea(
        child: BlocBuilder<AdminBloc, AdminState>(
          buildWhen: (previous, current) =>
              current is AdminRequestHistoryLoading ||
              current is AdminRequestHistoryLoaded ||
              current is AdminRequestHistoryError,
          builder: (context, state) {
            
            bool isLoading = state is AdminRequestHistoryLoading;

            if (state is AdminRequestHistoryLoaded) {
              _cachedItems = state.items;
              _hasMax = state.hasReachedMax;
              _activeFilter = state.currentFilter;
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: TColors.primary,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      const SliverToBoxAdapter(child: _HistorialHeader()),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      SliverToBoxAdapter(
                        child: _HistorialFilterTabs(
                          activeFilter: _activeFilter,
                          onFilterChanged: _changeFilter,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      if (state is AdminRequestHistoryError && _cachedItems.isEmpty)
                        SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: TColors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: TColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (_cachedItems.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList.separated(
                            itemCount: _hasMax ? _cachedItems.length : _cachedItems.length + 1,
                            itemBuilder: (_, index) {
                              if (index >= _cachedItems.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: TColors.primary,
                                    ),
                                  ),
                                );
                              }
                              return HistorialCard(
                                item: _cachedItems[index],
                                onTapDetail: () {},
                              );
                            },
                            separatorBuilder: (_, _) => const SizedBox(height: 18),
                          ),
                        ),

                      if (!isLoading && _cachedItems.isEmpty && state is! AdminRequestHistoryError)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                "No hay solicitudes en este estado.",
                                style: TextStyle(
                                  color: TColors.textSecondary,
                                ),
                              ),
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
                    child: const LinearProgressIndicator(
                      color: Color(0xFF1D54F3),
                    ),
                  ),
                if (isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: TColors.white.withValues(alpha:  0.3),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistorialHeader extends StatelessWidget {
  const _HistorialHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDITORÍA Y CONTROL',
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
            'Historial de Solicitudes',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: TColors.appMainDarkColor,
              height: 1.15,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Revisión detallada de todas las solicitudes\nprocesadas por el sistema.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: TColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorialFilterTabs extends StatelessWidget {
  final String activeFilter;
  final Function(String) onFilterChanged;

  const _HistorialFilterTabs({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: HistorialFilterChip(
              text: 'Todas',
              isSelected: activeFilter == 'todos',
              onTap: () => onFilterChanged('todos'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: HistorialFilterChip(
              text: 'Aprobadas',
              isSelected: activeFilter == 'aprobado',
              onTap: () => onFilterChanged('aprobado'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: HistorialFilterChip(
              text: 'Rechazadas',
              isSelected: activeFilter == 'rechazado',
              onTap: () => onFilterChanged('rechazado'),
            ),
          ),
        ],
      ),
    );
  }
}

class HistorialFilterChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const HistorialFilterChip({
    super.key,
    required this.text,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? TColors.appMainDarkColor : const Color(0xFFF0F1F4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF555964),
            ),
          ),
        ),
      ),
    );
  }
}








