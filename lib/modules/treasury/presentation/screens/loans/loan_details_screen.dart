import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';
import 'loan_ui.dart';

@RoutePage()
class LoanDetailsScreen extends StatelessWidget {
  final String idLoan;
  const LoanDetailsScreen({super.key, required this.idLoan});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectorContainer.getIt<TreasuryBloc>()
            ..add(LoanDetailsEvent(idLoan: idLoan)),
      child: Scaffold(
        backgroundColor: LoanUi.bg,
        appBar: loanAppBar(context, title: 'Detalle del Préstamo'),
        body: BlocConsumer<TreasuryBloc, TreasuryState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is LoanDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: LoanUi.primary),
              );
            }
            if (state is LoanDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: LoanUi.mora),
                  ),
                ),
              );
            }
            if (state is LoanDetailsLoaded) {
              final cabecera = state.loanDetails.data.cabecera;
              final cronograma = state.loanDetails.data.cronograma;
              return RefreshIndicator(
                color: LoanUi.primary,
                onRefresh: () async {
                  final bloc = context.read<TreasuryBloc>();
                  bloc.add(LoanDetailsEvent(idLoan: idLoan));
                  // Esperamos a que termine la recarga para cerrar el spinner.
                  await bloc.stream.firstWhere(
                    (s) => s is LoanDetailsLoaded || s is LoanDetailsError,
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    LoanInfoCard(cabecera: cabecera),
                    const SizedBox(height: 24),
                    LoanSectionTitle(
                      'Cronograma de Pagos',
                      icon: Icons.event_note_rounded,
                      trailing: '${cronograma.length} cuotas',
                    ),
                    const SizedBox(height: 6),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cronograma.length,
                      itemBuilder: (context, index) {
                        final cuota = cronograma[index];
                        return InstallmentCard(
                          month: cuota.mesEtiqueta,
                          day: cuota.diaEtiqueta,
                          number: index + 1,
                          label: cuota.textoCuota,
                          amount: cuota.montoTotalCuota.toDouble(),
                          status: cuota.estadoCuota,
                          quotaId: cuota.quotaId,
                          cash: state.cash,
                          idLoan: idLoan,
                          onTap: () async {
                            await context.router.push(
                              RecordPaymentRoute(
                                quotaId: cuota.quotaId,
                                textoCuota: 'Cuota #${index + 1}',
                                montoTotalCuota: cuota.montoTotalCuota,
                                cash: state.cash,
                                idLoan: idLoan,
                              ),
                            );
                            if (context.mounted) {
                              context.read<TreasuryBloc>().add(
                                LoanDetailsEvent(idLoan: idLoan),
                              );
                            }
                          },
                        );
                      },
                    ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
