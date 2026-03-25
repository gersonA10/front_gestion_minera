import 'package:flutter/material.dart';

class TransactionTypeSelectorWidget extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const TransactionTypeSelectorWidget({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildOption(context, 'Ingreso', Icons.arrow_downward_rounded, Colors.green),
        ),
        const SizedBox(width: 8),
        
        Expanded(
          child: _buildOption(context, 'Egreso', Icons.arrow_upward_rounded, Colors.red),
        ),
        const SizedBox(width: 8),
        
        Expanded(
          child: _buildOption(context, 'Transferencia', Icons.swap_horiz_rounded, Colors.blue),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon, Color color) {
    final isSelected = selectedValue == title;
    
    final displayName = title == 'Transferencia' ? 'Transf.' : title;

    return InkWell(
      onTap: () => onChanged(title),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected ? color : Colors.grey.shade500, 
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              displayName,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}