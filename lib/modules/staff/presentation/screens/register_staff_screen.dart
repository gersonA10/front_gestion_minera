import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RegisterStaffScreen extends StatelessWidget {
  const RegisterStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Personal')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(15),
      ),
    );
  }
}
