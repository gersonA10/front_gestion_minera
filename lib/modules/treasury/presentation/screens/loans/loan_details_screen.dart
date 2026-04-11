import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../widgets/widgtes.dart';

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
        backgroundColor: TColors.bgColor,
        appBar: AppBar(
          backgroundColor: TColors.bgColor,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Detalle del Préstamo',
            style: TextStyle(
              color: TColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocConsumer<TreasuryBloc, TreasuryState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is LoanDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: TColors.amber),
              );
            }
            if (state is LoanDetailsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: TColors.danger),
                ),
              );
            }
            if (state is LoanDetailsLoaded) {
              final cabecera = state.loanDetails.data.cabecera;
              final cronograma = state.loanDetails.data.cronograma;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoanInfoCard(cabecera: cabecera),
                    const SizedBox(height: 24),
                    const Text(
                      'Cronograma de Pagos',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
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
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
