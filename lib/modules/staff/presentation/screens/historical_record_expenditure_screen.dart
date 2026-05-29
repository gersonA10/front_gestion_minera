import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HistoricalRecordExpenditureScreen extends StatefulWidget {
  const HistoricalRecordExpenditureScreen({super.key});

  @override
  State<HistoricalRecordExpenditureScreen> createState() =>
      _HistoricalRecordExpenditureScreenState();
}

class _HistoricalRecordExpenditureScreenState
    extends State<HistoricalRecordExpenditureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Historial de Solicitudes de\nEgresos',
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 15)),
    );
  }
}
