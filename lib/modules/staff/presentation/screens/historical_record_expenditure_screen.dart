import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/egreso_detail_screen.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/date_util.dart';

import '../../domain/entity/entity.dart';

@RoutePage()
class HistoricalRecordExpenditureScreen extends StatefulWidget {
  const HistoricalRecordExpenditureScreen({super.key});

  @override
  State<HistoricalRecordExpenditureScreen> createState() =>
      _HistoricalRecordExpenditureScreenState();
}

class _HistoricalRecordExpenditureScreenState
    extends State<HistoricalRecordExpenditureScreen> {
  late final StaffBloc _staffBloc;
  final ScrollController _scrollController = ScrollController();

  late String _selectedYear;
  String _selectedState = 'TODOS';

  // Caché local para mantener la lista visible durante paginación / refresh.
  List<HistoryExpenditureEntity> _items = [];
  double _totalExpenses = 0;
  bool _hasReachedMax = false;
  bool _isLoadingMore = false;

  static const int _startYear = 2024;

  final List<_Option> _states = const [
    _Option('Todos', 'TODOS'),
    _Option('Aprobado', 'APPROVED'),
    _Option('Pendiente', 'IN_REVIEW'),
    _Option('Pagado', 'PAID'),
    _Option('Rechazado', 'REJECTED'),
  ];

  List<_Option> get _years {
    final currentYear = DateTime.now().year;
    return List.generate((currentYear - _startYear) + 1, (i) {
      final y = (_startYear + i).toString();
      return _Option(y, y);
    }).reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year.toString();
    _scrollController.addListener(_onScroll);
    _staffBloc = InjectorContainer.getIt<StaffBloc>();
    _refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    _isLoadingMore = false;
    _staffBloc.add(
      GetHistoryRecordExpenditureEvent(
        year: _selectedYear,
        state: _selectedState,
        isRefresh: true,
      ),
    );
  }

  void _onYearChanged(String? value) {
    if (value == null || value == _selectedYear) return;
    setState(() => _selectedYear = value);
    _refresh();
  }

  void _onStateChanged(String? value) {
    if (value == null || value == _selectedState) return;
    setState(() => _selectedState = value);
    _refresh();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_hasReachedMax || _isLoadingMore) return;

    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 280) return;

    _isLoadingMore = true;
    _staffBloc.add(LoadMoreHistoryRecordExpenditureEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaffUi.background,
      appBar: staffAppBar(context, title: 'Historial de egresos'),
      body: BlocConsumer<StaffBloc, StaffState>(
        bloc: _staffBloc,
        listener: (context, state) {
          if (state is HistoryRecordExpenditureLoaded) {
            setState(() {
              _items = state.items;
              _totalExpenses = state.totalExpenses;
              _hasReachedMax = !state.hasMore;
              _isLoadingMore = false;
            });
          } else if (state is HistoryRecordExpenditureError) {
            _isLoadingMore = false;
          }
        },
        builder: (context, state) {
          final isInitialLoading =
              state is HistoryRecordExpenditureLoading && _items.isEmpty;
          final isError =
              state is HistoryRecordExpenditureError && _items.isEmpty;

          return Column(
            children: [
              _FiltersBar(
                years: _years,
                states: _states,
                selectedYear: _selectedYear,
                selectedState: _selectedState,
                onYearChanged: _onYearChanged,
                onStateChanged: _onStateChanged,
              ),
              Expanded(
                child: _buildBody(
                  isInitialLoading: isInitialLoading,
                  isError: isError,
                  errorMessage: isError
                      ? (state).message
                      : '',
                ),
              ),
              _TotalCard(amount: _totalExpenses),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody({
    required bool isInitialLoading,
    required bool isError,
    required String errorMessage,
  }) {
    if (isInitialLoading) {
      return const StaffLoader();
    }
    if (isError) {
      return StaffErrorState(message: errorMessage, onRetry: _refresh);
    }

    return RefreshIndicator(
      color: StaffUi.primary,
      onRefresh: () async => _refresh(),
      child: _items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                const StaffEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Sin registros de egresos',
                  message:
                      'No hay solicitudes de egreso para los filtros seleccionados.',
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              itemCount: _items.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: StaffLoader(),
                  );
                }
                return _ExpenditureCard(
                  history: _items[index],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          EgresoDetailScreen(history: _items[index]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Opción genérica (etiqueta visible + valor del backend).
class _Option {
  final String label;
  final String value;
  const _Option(this.label, this.value);
}

/// Parsea una fecha ISO del backend; null si está vacía o no es válida.
DateTime? _tryParseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

/// Barra de filtros Año / Estado con el estilo del kit.
class _FiltersBar extends StatelessWidget {
  final List<_Option> years;
  final List<_Option> states;
  final String selectedYear;
  final String selectedState;
  final ValueChanged<String?> onYearChanged;
  final ValueChanged<String?> onStateChanged;
  const _FiltersBar({
    required this.years,
    required this.states,
    required this.selectedYear,
    required this.selectedState,
    required this.onYearChanged,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _FilterDropdown(
              icon: Icons.event_rounded,
              hint: 'Año',
              value: selectedYear,
              options: years,
              onChanged: onYearChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FilterDropdown(
              icon: Icons.tune_rounded,
              hint: 'Estado',
              value: selectedState,
              options: states,
              onChanged: onStateChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dropdown premium reutilizado para los filtros.
class _FilterDropdown extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String value;
  final List<_Option> options;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({
    required this.icon,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: StaffUi.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StaffUi.border),
        boxShadow: StaffUi.cardShadow,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: StaffUi.primary),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                hint: Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: StaffUi.muted,
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: StaffUi.textSecondary),
                borderRadius: BorderRadius.circular(14),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: StaffUi.textPrimary,
                ),
                items: options
                    .map(
                      (o) => DropdownMenuItem<String>(
                        value: o.value,
                        child: Text(
                          o.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de resumen "Total Egresos" (gradiente premium).
class _TotalCard extends StatelessWidget {
  final double amount;
  const _TotalCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StaffUi.primary, StaffUi.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: StaffUi.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.payments_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total egresos',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  StaffUi.money2(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
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

/// Tarjeta de una solicitud de egreso, con el sistema de diseño del módulo.
class _ExpenditureCard extends StatelessWidget {
  final HistoryExpenditureEntity history;
  final VoidCallback onTap;
  const _ExpenditureCard({required this.history, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = StaffStatusStyle.of(history.status);
    final isApproved = style.label == 'Aprobado' || style.label == 'Pagado';
    final isRejected = style.label == 'Rechazado';

    final requestedDate = _tryParseDate(history.requestedDate);
    final closedDate = _tryParseDate(history.closedDate);

    return StaffCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ciclo de nómina',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: StaffUi.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      history.payrollCycle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: StaffUi.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StaffPill(label: style.label, color: style.color, bg: style.bg),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MoneyColumn(
                  label: 'Total solicitado',
                  value: StaffUi.money2(history.totalRequested),
                  color: StaffUi.textPrimary,
                ),
              ),
              Expanded(
                child: isApproved
                    ? _MoneyColumn(
                        label: 'Monto aprobado',
                        value: StaffUi.money2(history.approvedAmount),
                        color: StaffUi.primary,
                      )
                    : isRejected
                        ? _MoneyColumn(
                            label: 'Motivo',
                            value: history.rejectReason ?? 'No especificado',
                            color: style.color,
                            fontSize: 13.5,
                          )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: StaffUi.border),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              if (requestedDate != null)
                _DateChip(
                  icon: Icons.outbox_outlined,
                  label: 'Solicitado',
                  date: formatDate(requestedDate),
                ),
              if (closedDate != null)
                _DateChip(
                  icon: isRejected
                      ? Icons.cancel_outlined
                      : Icons.event_available_outlined,
                  label: isRejected ? 'Rechazado' : 'Respondido',
                  date: formatDate(closedDate),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Columna etiqueta + monto/valor de la tarjeta.
class _MoneyColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double fontSize;
  const _MoneyColumn({
    required this.label,
    required this.value,
    required this.color,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: StaffUi.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Chip de fecha (icono + etiqueta + fecha real).
class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;
  const _DateChip({
    required this.icon,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: StaffUi.textSecondary),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11.5,
            color: StaffUi.textSecondary,
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: StaffUi.textPrimary,
          ),
        ),
      ],
    );
  }
}
