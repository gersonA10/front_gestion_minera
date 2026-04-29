import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';


@RoutePage()
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Transacciones'),)
    );
  }
}