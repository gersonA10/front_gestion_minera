import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';

@RoutePage()
class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final TextEditingController nombreController =
      TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                hintText: 'attendance_id',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.router.push(
                    EmployeeCheckOutLogRoute(
                      attendanceId:
                          nombreController.text.trim().isEmpty
                              ? 'Miguel Sanchez'
                              : nombreController.text.trim(),
                    ),
                  );
                },
                child: const Text(
                  'Abrir Registro',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}