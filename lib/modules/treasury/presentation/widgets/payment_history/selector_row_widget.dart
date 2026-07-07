
import 'package:flutter/material.dart';

class SelectorRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const SelectorRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
