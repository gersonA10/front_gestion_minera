import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class DateFilterResult {
  final String period; // 'day', 'month', 'year'
  final String exactDate; // Formato YYYY-MM-DD
  final String displayTitle; // Para mostrar en el botón (ej. "Feb 2026")

  DateFilterResult({
    required this.period,
    required this.exactDate,
    required this.displayTitle,
  });
}

class CustomDateSelector extends StatefulWidget {
  const CustomDateSelector({super.key});

  /// Método estático para invocar el selector fácilmente desde cualquier pantalla
  static Future<DateFilterResult?> show(BuildContext context) {
    return showModalBottomSheet<DateFilterResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CustomDateSelector(),
    );
  }

  @override
  State<CustomDateSelector> createState() => _CustomDateSelectorState();
}

class _CustomDateSelectorState extends State<CustomDateSelector> {
  String _selectedTab = 'Mes'; // 'Día', 'Mes', 'Año'
  final int _currentYear = DateTime.now().year;

  final List<String> _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pequeña barra superior (Handle)
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: colors.lead.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Seleccionar Periodo',
              style: AppTextStyles.mainStyle16Bold(context).copyWith(color: colors.black),
            ),
            const SizedBox(height: 20),

            // Selector de Pestañas (Día / Mes / Año)
            Row(
              children: [
                _buildTab(context, 'Día', colors),
                const SizedBox(width: 10),
                _buildTab(context, 'Mes', colors),
                const SizedBox(width: 10),
                _buildTab(context, 'Año', colors),
              ],
            ),
            const SizedBox(height: 24),

            // Contenido dinámico según la pestaña
            if (_selectedTab == 'Mes') _buildMonthSelector(colors),
            if (_selectedTab == 'Año') _buildYearSelector(colors),
            if (_selectedTab == 'Día') _buildDaySelector(colors),
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, ColorScheme colors) {
    final isActive = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? colors.blue : colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? colors.blue : colors.lead.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? colors.white : colors.lead,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. SELECTOR DE MESES ---
  Widget _buildMonthSelector(ColorScheme colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(_months.length, (index) {
        return GestureDetector(
          onTap: () {
            final monthNumber = (index + 1).toString().padLeft(2, '0');
            Navigator.pop(
              context,
              DateFilterResult(
                period: 'month',
                exactDate: '$_currentYear-$monthNumber-01',
                displayTitle: '${_months[index]} $_currentYear',
              ),
            );
          },
          child: Container(
            width: (MediaQuery.of(context).size.width - 80) / 3, // 3 columnas
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.lead.withOpacity(0.2)),
            ),
            alignment: Alignment.center,
            child: Text(
              _months[index],
              style: TextStyle(color: colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }),
    );
  }

  // --- 2. SELECTOR DE AÑOS (Últimos 2) ---
  Widget _buildYearSelector(ColorScheme colors) {
    final years = [_currentYear, _currentYear - 1]; // Año actual y el anterior

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: years.map((year) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(
                context,
                DateFilterResult(
                  period: 'year',
                  exactDate: '$year-01-01',
                  displayTitle: 'Año $year',
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.lead.withOpacity(0.2)),
              ),
              child: Text(
                year.toString(),
                style: TextStyle(color: colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- 3. SELECTOR DE DÍA (Abre el calendario nativo) ---
  Widget _buildDaySelector(ColorScheme colors) {
    return Column(
      children: [
        Icon(Icons.calendar_month, size: 50, color: colors.lead.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text(
          'Elige una fecha específica en el calendario',
          style: TextStyle(color: colors.lead),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null && mounted) {
                final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                Navigator.pop(
                  context,
                  DateFilterResult(
                    period: 'day',
                    exactDate: formattedDate,
                    displayTitle: '${picked.day} ${_months[picked.month - 1]}',
                  ),
                );
              }
            },
            child: const Text('Abrir Calendario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }
}