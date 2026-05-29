import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:front_gestion_minera/modules/staff/presentation/widgets/payroll_employee_card_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/payroll_summary_card_widget.dart';
=======
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
>>>>>>> origin/dev
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});
  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
<<<<<<< HEAD
  final TextEditingController searchController = TextEditingController();
=======
  final TextEditingController nombreController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
>>>>>>> origin/dev
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: TColors.textFieldBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestionar Nómina',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TColors.appMainDarkColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Ciclo: Octubre 2023',
              style: TextStyle(fontSize: 12, color: TColors.appDisabledColor),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            SizedBox(
              height: 130,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: const [
                  PayrollSummaryCardWidget(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Total Nómina Mes',
                    amount: '125,400.00',
                    badge: 'MENSUAL',
                    iconColor: TColors.appMainColor,
                    amountColor: TColors.appMainTextColor,
                  ),
                  SizedBox(width: 5),
                  PayrollSummaryCardWidget(
                    icon: Icons.check_circle_outline,
                    title: 'Total Pagado',
                    amount: '82,150.00',
                    iconColor: TColors.green,
                    amountColor: TColors.green,
                    showBottomIndicator: true,
                  ),
                  SizedBox(width: 5),
                  PayrollSummaryCardWidget(
                    icon: Icons.pending_actions_outlined,
                    title: 'Total Pendiente',
                    amount: '43,250.00',
                    iconColor: TColors.amber,
                    amountColor: TColors.amber,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar empleado o ID...',
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: TColors.appDisabledColor,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.tune,
                        color: TColors.appMainDarkColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'LISTA DE EMPLEADOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TColors.appDisabledColor,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'SELECCIONAR TODO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: TColors.appMainColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  PayrollEmployeeCardWidget(
                    name: 'Juan Pérez',
                    position: 'Operador Excavadora',
                    employeeId: '4421',
                    amount: '2,500.00',
                    paid: true,
                    onTap: () {},
                  ),
                  PayrollEmployeeCardWidget(
                    name: 'Ana Colque',
                    position: 'Ing. de Minas',
                    employeeId: '3021',
                    amount: '4,800.00',
                    paid: false,
                    onTap: () {},
                  ),
                  PayrollEmployeeCardWidget(
                    name: 'Roberto Gómez',
                    position: 'Seguridad Industrial',
                    employeeId: '1192',
                    amount: '3,200.00',
                    paid: true,
                    onTap: () {},
                  ),
                  PayrollEmployeeCardWidget(
                    name: 'Elena Ruiz',
                    position: 'Logística',
                    employeeId: '5512',
                    amount: '2,100.00',
                    paid: false,
                    onTap: () {},
                  ),
                  PayrollEmployeeCardWidget(
                    name: 'Carlos Slim',
                    position: 'Mantenimiento',
                    employeeId: '0082',
                    amount: '2,750.00',
                    paid: false,
                    onTap: () {},
                  ),
                ],
=======
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
>>>>>>> origin/dev
              ),
            ],
          ),
        ),
      ),
    );
  }
}
