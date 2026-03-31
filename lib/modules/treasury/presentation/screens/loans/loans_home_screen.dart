import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/loans/loans_list_entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:intl/intl.dart';

extension LoanStatusX on LoanStatus {
  Color get color {
    switch (this) {
      case LoanStatus.activo:
        return const Color(0xFF3B82F6);
      case LoanStatus.enMora:
        return const Color(0xFFEF4444);
      case LoanStatus.finalizado:
        return const Color(0xFF16A34A);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case LoanStatus.activo:
        return const Color(0xFFEFF6FF);
      case LoanStatus.enMora:
        return const Color(0xFFFEF2F2);
      case LoanStatus.finalizado:
        return const Color(0xFFF0FDF4);
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
  static const double _scrollThreshold = 10.0;

  late final TreasuryBloc _treasuryBloc;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  final ScrollController _scrollController = ScrollController();
  bool _fabVisible = true;
  double _lastScrollOffset = 0;

  // Cache para mantener datos durante recargas (como GoldDashboardScreen)
  List<InternalLoansEntity>? _cachedList;
  bool _cachedHasReachedMax = false;

  @override
  void initState() {
    super.initState();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(InternalLoansRequestsEvent());
    _scrollController.addListener(_onScroll);
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
    _treasuryBloc.add(InternalLoansRequestsEvent(status: filter));
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
      _treasuryBloc.add(InternalLoansEvent());
    }
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
    final colors = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _treasuryBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: _fabVisible ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _fabVisible ? 1 : 0,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF3B82F6),
              elevation: 2,
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: colors.white,
          surfaceTintColor: colors.white,
          centerTitle: true,
          title: const Text(
            'Préstamos Internos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE5E7EB), height: 1),
          ),
        ),
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is InternalLoansError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () =>
                        _treasuryBloc.add(InternalLoansRequestsEvent()),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }

              final list = _cachedList!;
              final hasReachedMax = _cachedHasReachedMax;

              return Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
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
                                  hintText: 'Buscar por socio o código...',
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
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: 'Todos',
                                    icon: Icons.list_alt_rounded,
                                    isActive: _activeFilter == 'todos',
                                    activeColor: const Color(0xFF1F2937),
                                    onTap: () => _applyFilter('todos'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: 'Activos',
                                    icon: Icons.check_circle_outline,
                                    isActive: _activeFilter == 'activos',
                                    activeColor: const Color(0xFF3B82F6),
                                    onTap: () => _applyFilter('activos'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: 'En Mora',
                                    icon: Icons.error_outline,
                                    isActive: _activeFilter == 'en mora',
                                    activeColor: const Color(0xFFEF4444),
                                    onTap: () => _applyFilter('en mora'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: 'Finalizado',
                                    icon: Icons.history,
                                    isActive: _activeFilter == 'finalizado',
                                    activeColor: const Color(0xFF16A34A),
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
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }
                                  return _LoanCard(loan: list[i]);
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterChip({
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
            color: isActive ? activeColor : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF374151),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final InternalLoansEntity loan;

  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'es_PE');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: loan.status.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: loan.status.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  loan.estadoEtiqueta,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: loan.status.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            loan.lenderName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${loan.loanCode}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Prestado',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      fmt.format(loan.totalPrestado),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    loan.status == LoanStatus.finalizado
                        ? 'Total Pagado'
                        : 'Pendiente',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    loan.status == LoanStatus.finalizado
                        ? fmt.format(loan.totalPagado)
                        : fmt.format(loan.pendiente),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: loan.status == LoanStatus.finalizado
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de pago',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: loan.status.color,
                ),
              ),
              Text(
                '${loan.progresoInt}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: loan.progreso / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(loan.status.color),
            ),
          ),
          const SizedBox(height: 10),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final textoFecha = loan.alertaVencimiento.textoFecha;

    switch (loan.status) {
      case LoanStatus.activo:
        return Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Próximo vencimiento: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: textoFecha.isNotEmpty ? textoFecha : '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case LoanStatus.enMora:
        return Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 15,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                textoFecha.isNotEmpty ? textoFecha : 'En mora',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        );

      case LoanStatus.finalizado:
        return Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 15,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(width: 6),
            const Text(
              'Pagado totalmente',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF16A34A),
                fontSize: 10,
              ),
            ),
          ],
        );
    }
  }
}
