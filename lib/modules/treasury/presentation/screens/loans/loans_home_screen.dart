import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';

import '../../../domain/entity/entity.dart';
import '../../widgets/widgtes.dart';
import 'loan_ui.dart';

extension LoanStatusX on LoanStatus {
  Color get color {
    switch (this) {
      case LoanStatus.activo:
        return LoanUi.activo;
      case LoanStatus.enMora:
        return LoanUi.mora;
      case LoanStatus.finalizado:
        return LoanUi.finalizado;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case LoanStatus.activo:
        return LoanUi.activoBg;
      case LoanStatus.enMora:
        return LoanUi.moraBg;
      case LoanStatus.finalizado:
        return LoanUi.finalizadoBg;
    }
  }

  IconData get icon {
    switch (this) {
      case LoanStatus.activo:
        return Icons.autorenew_rounded;
      case LoanStatus.enMora:
        return Icons.error_outline_rounded;
      case LoanStatus.finalizado:
        return Icons.check_circle_outline_rounded;
    }
  }
}

@RoutePage()
class LoansHomeScreen extends StatefulWidget {
  const LoansHomeScreen({super.key});

  @override
  State<LoansHomeScreen> createState() => _LoansHomeScreenState();
}

class _LoansHomeScreenState extends State<LoansHomeScreen> {
  String _searchQuery = '';
  String _activeFilter = 'todos';

  late final TreasuryBloc _treasuryBloc;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  final ScrollController _scrollController = ScrollController();
  List<InternalLoansEntity>? _cachedList;
  bool _cachedHasReachedMax = false;

  @override
  void initState() {
    super.initState();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(InternalLoansRequestsEvent());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _treasuryBloc.add(InternalLoansEvent());
      }
    });
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  void _performSearch(String searchText) {
    if (!mounted) return;
    searchText = searchText.trim();
    final status = _activeFilter == 'todos' ? null : _activeFilter;
    _treasuryBloc.add(
      InternalLoansRequestsEvent(
        status: status,
        search: searchText.isEmpty ? null : searchText,
      ),
    );
  }

  void _applyFilter(String filter) {
    setState(() => _activeFilter = filter);
    _searchController.clear();
    setState(() => _searchQuery = '');
    _treasuryBloc.add(InternalLoansRequestsEvent(
      status: filter == 'todos' ? null : filter,
    ));
  }

  void _reloadWithCurrentFilter() {
    _treasuryBloc.add(InternalLoansRequestsEvent(
      status: _activeFilter == 'todos' ? null : _activeFilter,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _treasuryBloc,
      child: Scaffold(
        backgroundColor: LoanUi.bg,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.router.push(NewLoansRoute());
            if (context.mounted) {
              _treasuryBloc.add(InternalLoansRequestsEvent());
            }
          },
          backgroundColor: LoanUi.primary,
          elevation: 2,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Nuevo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        appBar: loanAppBar(context, title: 'Préstamos Internos'),
        body: SafeArea(
          child: BlocBuilder<TreasuryBloc, TreasuryState>(
            buildWhen: (previous, current) =>
                current is InternalLoansLoading ||
                current is InternalLoansLoaded ||
                current is InternalLoansError,
            builder: (context, state) {
              if (state is InternalLoansLoaded) {
                _cachedList = state.list;
                _cachedHasReachedMax = state.hasReachedMax;
              }

              final bool isLoading = state is InternalLoansLoading;

              if (_cachedList == null) {
                if (isLoading) {
                  return const StaffLoader();
                }
                if (state is InternalLoansError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () =>
                        _treasuryBloc.add(InternalLoansRequestsEvent()),
                  );
                }
                return const StaffLoader();
              }

              final list = _cachedList!;
              final hasReachedMax = _cachedHasReachedMax;

              return Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding:  EdgeInsets.fromLTRB(16, 12, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: (v) {
                                  setState(() => _searchQuery = v);
                                  if (v.isEmpty) _performSearch('');
                                },
                                onSubmitted: _performSearch,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Buscar prestamo...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 13,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = '');
                                            _performSearch('');
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                             SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterChip(
                                    label: 'Todos',
                                    icon: Icons.list_alt_rounded,
                                    isActive: _activeFilter == 'todos',
                                    activeColor: LoanUi.primary,
                                    onTap: () => _applyFilter('todos'),
                                  ),
                                  const SizedBox(width: 8),
                                  FilterChip(
                                    label: 'Activos',
                                    icon: Icons.autorenew_rounded,
                                    isActive: _activeFilter == 'activos',
                                    activeColor: LoanUi.activo,
                                    onTap: () => _applyFilter('activos'),
                                  ),
                                  const SizedBox(width: 8),
                                  FilterChip(
                                    label: 'En Mora',
                                    icon: Icons.error_outline,
                                    isActive: _activeFilter == 'en mora',
                                    activeColor: LoanUi.mora,
                                    onTap: () => _applyFilter('en mora'),
                                  ),
                                  const SizedBox(width: 8),
                                  FilterChip(
                                    label: 'Finalizado',
                                    icon: Icons.check_circle_outline_rounded,
                                    isActive: _activeFilter == 'finalizado',
                                    activeColor: LoanUi.finalizado,
                                    onTap: () => _applyFilter('finalizado'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: list.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.inbox_rounded,
                                      size: 56,
                                      color: Color(0xFFD1D5DB),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _searchQuery.isNotEmpty ||
                                              _activeFilter != 'todos'
                                          ? 'No se encontraron resultados'
                                          : 'No hay préstamos',
                                      style: const TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  80,
                                ),
                                itemCount:
                                    list.length + (hasReachedMax ? 0 : 1),
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (_, i) {
                                  if (i == list.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: StaffLoader(),
                                    );
                                  }
                                  return LoanCard(loan: list[i], treasuryBloc: _treasuryBloc, onReturn: _reloadWithCurrentFilter,);
                                },
                              ),
                      ),
                    ],
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
                          color: const Color(0xFFF8F9FB).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  const FilterChip({super.key, 
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : LoanUi.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : LoanUi.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : LoanUi.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
