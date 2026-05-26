import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class AssistanceDetailScreen extends StatefulWidget {
  const AssistanceDetailScreen({super.key});

  @override
  State<AssistanceDetailScreen> createState() => _AssistanceDetailScreenState();
}

class _AssistanceDetailScreenState extends State<AssistanceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Asistencia'),
        actions: [
          IconButton(
            onPressed: () {
              
            },
            icon: Icon(
              Icons.share_outlined,
              color: TColors.appBackgroundDarkColor,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
