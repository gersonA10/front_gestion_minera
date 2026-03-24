import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';

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
            appBar: AppBar(
              title: const Text('Registro Urgente'),
              centerTitle: true,
              elevation: 0,
            ),
            body: AppLoadingOverlay(
              isLoading: isLoading,
              message: 'Cargando...',
              loader: const ExcavatorLoader(),
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