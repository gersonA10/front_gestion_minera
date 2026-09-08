import 'package:flutter/material.dart';

/// Botón flotante de acceso al Asistente, compartido por los dashboards
/// (hacienda, socios, y los roles que se sumen).
class AssistantFab extends StatelessWidget {
  final VoidCallback onTap;

  const AssistantFab({super.key, required this.onTap});

  static const _primary = Color(0xFF1A56FF);
  static const _primaryDeep = Color(0xFF0B33B8);
  static const _gold = Color(0xFFEFC805);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir asistente',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primary, _primaryDeep],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, color: _gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Asistente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
