import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/payment_history_screen.dart';
import 'package:intl/intl.dart';

import '../widgtes.dart';

class FilterBottomSheet extends StatefulWidget {
  final DateFilterType currentFilter;
  final DateTime? selectedDay;
  final int? selectedMonth;
  final int? selectedYear;
  final void Function(
    DateFilterType filter, {
    DateTime? day,
    int? month,
    int? year,
  }) onApply;

  const FilterBottomSheet({super.key, 
    required this.currentFilter,
    required this.selectedDay,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late DateFilterType _filter;
  DateTime? _day;
  int? _month;
  int? _year;

  final List<String> _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _day = widget.selectedDay;
    _month = widget.selectedMonth;
    _year = widget.selectedYear;
  }

  bool get _canApply {
    switch (_filter) {
      case DateFilterType.ultimos30Dias:
        return true;
      case DateFilterType.dia:
        return _day != null;
      case DateFilterType.mes:
        return _month != null && _year != null;
      case DateFilterType.anio:
        return _year != null;
    }
  }

  void _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3B82F6),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1F2937),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _day = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Título
          const Row(
            children: [
              Icon(Icons.filter_list_rounded,
                  size: 20, color: Color(0xFF3B82F6)),
              SizedBox(width: 8),
              Text(
                'Filtrar por fecha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chips de tipo de filtro
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DateFilterType.values.map((type) {
              final isActive = _filter == type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _filter = type;
                    if (type == DateFilterType.ultimos30Dias) {
                      _day = null;
                      _month = null;
                      _year = null;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildFilterSelector(),
          ),

          const SizedBox(height: 24),

          // Botón aplicar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _canApply
                  ? () => widget.onApply(
                        _filter,
                        day: _day,
                        month: _month,
                        year: _year,
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                disabledBackgroundColor: const Color(0xFFBFDBFE),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white70,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Aplicar filtro',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSelector() {
    switch (_filter) {
      case DateFilterType.ultimos30Dias:
        return const SizedBox.shrink();

      case DateFilterType.dia:
        return GestureDetector(
          onTap: _pickDay,
          child: SelectorRow(
            icon: Icons.calendar_today_rounded,
            label: _day != null
                ? DateFormat('dd/MM/yyyy').format(_day!)
                : 'Seleccionar día',
          ),
        );

      case DateFilterType.mes:
        return Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(12, (i) {
                final isSelected = _month == i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _month = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _monthNames[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            YearSelector(
              selectedYear: _year,
              onYearSelected: (y) => setState(() => _year = y),
            ),
          ],
        );

      case DateFilterType.anio:
        return YearSelector(
          selectedYear: _year,
          onYearSelected: (y) => setState(() => _year = y),
        );
    }
  }
}
