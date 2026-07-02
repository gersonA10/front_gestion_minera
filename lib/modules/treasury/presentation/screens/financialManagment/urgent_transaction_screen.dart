import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';

import '../../../../../core/widgets/app_loading_overlay.dart';
import '../../../../../injector_container.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/financialManagment/urgent_transaction_form_widget.dart';

@RoutePage()
class UrgentTransactionScreen extends StatelessWidget {
  const UrgentTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TreasuryBloc>(
      create: (context) => InjectorContainer.getIt<TreasuryBloc>(),
      child: BlocBuilder<TreasuryBloc, TreasuryState>(
        builder: (context, state) {
          final isLoading = (state is UrgentIncomeLoading || state is UrgentExpenseLoading);


          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FB),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF5F7FB),
              surfaceTintColor: const Color(0xFFF5F7FB),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Registro urgente',
                style: TextStyle(
                  color: Color(0xFF0D1B3E),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            body: AppLoadingOverlay(
              isLoading: isLoading,
              message: 'Cargando...',
              loader: const StaffLoader(),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nueva Transacción',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa los datos para registrar el movimiento en caja.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),
                      const UrgentTransactionFormWidget(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}