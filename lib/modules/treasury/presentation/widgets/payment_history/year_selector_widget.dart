
import 'package:flutter/material.dart';

class YearSelector extends StatelessWidget {
  final int? selectedYear;
  final void Function(int) onYearSelected;

  const YearSelector({super.key, 
    required this.selectedYear,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - i);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: years.map((y) {
        final isSelected = selectedYear == y;
        return GestureDetector(
          onTap: () => onYearSelected(y),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$y',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
