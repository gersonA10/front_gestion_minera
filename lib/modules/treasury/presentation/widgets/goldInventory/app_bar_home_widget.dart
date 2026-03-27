
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class AppBarDashboardGoldWidget extends StatelessWidget {
  const AppBarDashboardGoldWidget({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(onPressed: ()=> context.router.back(), icon: Icon(Icons.arrow_back_ios)),
          const SizedBox(width: 10),
          const Text(
            'Inventario de Oro',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}