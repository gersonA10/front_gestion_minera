import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('Bienvenido a hacienda'));
  }
}
