import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';

enum AlertType { success, error, warning }

class CustomAlert {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required AlertType type,
  }) {
    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    switch (type) {
      case AlertType.success:
        backgroundColor = Colors.green.shade100;
        iconColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case AlertType.error:
        backgroundColor = Colors.red.shade100;
        iconColor = Colors.red;
        iconData = Icons.error;
        break;
      case AlertType.warning:
        backgroundColor = Colors.orange.shade100;
        iconColor = Colors.orange;
        iconData = Icons.warning;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(iconData, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        color:  Theme.of(context).colorScheme.black.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
