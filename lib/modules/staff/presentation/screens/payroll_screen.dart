import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final TextEditingController nombreController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(
                  hintText: 'attendance_id temporal para abrir el registro',
                  hintStyle: TextStyle(color: TColors.disabled, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'attendance_id obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.router.push(
                        EmployeeCheckOutLogRoute(
                          attendanceId: nombreController.text.trim(),
                        ),
                      );
                    }
                  },
                  child: const Text('Abrir Registro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
