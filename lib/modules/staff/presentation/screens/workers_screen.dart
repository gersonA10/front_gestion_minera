import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/worker_card_widget.dart';

@RoutePage()
class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  late final StaffBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _search = '';
  String? _statusValue; // null = Todos
  int _totalGeneral = 0;
  bool _isLoadingMore = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    _bloc.add(GetEmployeesEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 280) return;

    final st = _bloc.state;
    final loaded = st is EmployeesPageLoading ? st.previousState : st;
    if (loaded is EmployeesLoaded && loaded.hasMore) {
      _isLoadingMore = true;
      _bloc.add(LoadMoreEmployeesEvent());
    }
  }

  void _query() {
    _isLoadingMore = false;
    _bloc.add(GetEmployeesEvent(
      page: 1,
      search: _search,
      status: _statusValue,
    ));
  }

  void _onStatusTap(String? value) {
    if (_statusValue == value) return;
    setState(() => _statusValue = value);
    _query();
  }

  void _onSearch(String value) {
    _search = value.trim();
    setState(() {}); // refresca el botón de limpiar del buscador
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _query();
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _search = '';
    _query();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is EmployeesLoaded) {
            _isLoadingMore = false;
            if (state.currentStatus == null) _totalGeneral = state.total;
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: StaffSearchField(
                  controller: _searchController,
                  hint: 'Buscar por nombre, cargo o ID...',
                  onChanged: _onSearch,
                  onClear: _clearSearch,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: _StatusChips(
                  selected: _statusValue,
                  totalLabel: _totalGeneral > 0 ? '$_totalGeneral' : null,
                  onTap: _onStatusTap,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(child: _buildList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(StaffState state) {
    // Carga inicial y recarga por cambio de filtro/búsqueda muestran el loader
    // (el buscador y los chips siguen visibles arriba). El "load more" del scroll
    // infinito usa otro evento y no pasa por aquí (no parpadea la lista).
    if (state is EmployeesLoading || state is EmployeesPageLoading) {
      return const StaffLoader();
    }
    if (state is EmployeesError) {
      return StaffErrorState(message: state.message, onRetry: _query);
    }
    if (state is! EmployeesLoaded) return const SizedBox.shrink();

    final employees = state.employees;
    final hasMore = state.hasMore;

    return RefreshIndicator(
      color: StaffUi.primary,
      onRefresh: () async => _query(),
      child: employees.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                StaffEmptyState(
                  icon: Icons.groups_outlined,
                  title: _search.isEmpty
                      ? 'Aún no hay trabajadores'
                      : 'Sin resultados',
                  message: _search.isEmpty
                      ? 'Registra a tu primer trabajador con el botón “Registrar”.'
                      : 'No encontramos trabajadores que coincidan con tu búsqueda.',
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              // Padding inferior amplio para que el FAB "Registrar" nunca tape
              // la última tarjeta.
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              itemCount: employees.length + (hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                if (index >= employees.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: StaffLoader(),
                  );
                }
                final e = employees[index];
                return WorkerCardWidget(
                  employeeId: e.employeeId,
                  image: e.profilePhotoUrl,
                  name: e.fullName,
                  position: e.position,
                  location: e.department,
                  status: e.status,
                  workedToday: e.workedToday,
                );
              },
            ),
    );
  }
}

/// Un filtro de estado de trabajador (label visible + valor para el backend).
class _StatusFilter {
  final String label;
  final String? value; // null = Todos (sin filtro de estado)
  const _StatusFilter(this.label, this.value);
}

const List<_StatusFilter> _kStatusFilters = [
  _StatusFilter('Todos', null),
  _StatusFilter('Activos', 'ACTIVO'),
  _StatusFilter('En descanso', 'DESCANSO'),
  _StatusFilter('Inactivos', 'INACTIVO'),
];

/// Fila de chips para filtrar la lista por estado del trabajador.
class _StatusChips extends StatelessWidget {
  final String? selected;
  final String? totalLabel;
  final ValueChanged<String?> onTap;
  const _StatusChips({
    required this.selected,
    required this.totalLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _kStatusFilters.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final f = _kStatusFilters[i];
        return _chip(
          label: f.label,
          badge: f.value == null ? totalLabel : null,
          active: selected == f.value,
          onTap: () => onTap(f.value),
        );
      },
    );
  }

  Widget _chip({
    required String label,
    required String? badge,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? StaffUi.primary : StaffUi.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: active ? StaffUi.primary : StaffUi.border),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : StaffUi.textSecondary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.22)
                      : StaffUi.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : StaffUi.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
