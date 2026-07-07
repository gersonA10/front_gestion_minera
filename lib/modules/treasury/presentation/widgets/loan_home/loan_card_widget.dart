import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loans_home_screen.dart';
import '../../../domain/entity/entity.dart';
import '../../screens/loans/loan_ui.dart';

class LoanCard extends StatelessWidget {
  final InternalLoansEntity loan;
  final TreasuryBloc treasuryBloc;
  final VoidCallback? onReturn;
  const LoanCard({
    super.key,
    required this.loan,
    required this.treasuryBloc,
    this.onReturn,
  });

  bool get _finalizado => loan.status == LoanStatus.finalizado;
  bool get _enMora => loan.status == LoanStatus.enMora;

  @override
  Widget build(BuildContext context) {
    final statusColor = loan.status.color;

    return LoanCardBox(
      padding: const EdgeInsets.all(14),
      onTap: () async {
        await context.router.push(LoanDetailsRoute(idLoan: loan.loanId));
        onReturn?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: prestamista + código + estado.
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: loan.status.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(loan.status.icon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.lenderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: LoanUi.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cód. ${loan.loanCode}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: LoanUi.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              LoanPill(
                label: loan.estadoEtiqueta,
                color: statusColor,
                bg: loan.status.backgroundColor,
                icon: loan.status.icon,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Montos: del préstamo / total a pagar.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: LoanUi.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: LoanStatTile(
                    label: 'Monto del préstamo',
                    value: LoanUi.money(loan.montoPrestado),
                  ),
                ),
                Container(width: 1, height: 30, color: LoanUi.border),
                const SizedBox(width: 14),
                Expanded(
                  child: LoanStatTile(
                    label: 'Total a pagar',
                    value: LoanUi.money(loan.totalAPagar),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Progreso + pendiente/pagado.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de pago',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              Text(
                '${loan.progresoInt}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: LoanUi.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LoanProgress(
            value: loan.progreso / 100,
            color: statusColor,
            showPercent: false,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _finalizado ? 'Total pagado' : 'Por pagar',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: LoanUi.textSecondary,
                ),
              ),
              Text(
                _finalizado
                    ? LoanUi.money(loan.totalPagado)
                    : LoanUi.money(loan.pendiente),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _finalizado ? LoanUi.finalizado : LoanUi.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _footer(),
        ],
      ),
    );
  }

  Widget _footer() {
    final texto = loan.alertaVencimiento.textoFecha;

    if (_enMora) {
      // Alerta de mora destacada: banner rojo de ancho completo.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: LoanUi.moraBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LoanUi.mora.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 16, color: LoanUi.mora),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto.isNotEmpty ? texto : 'Pago en mora',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: LoanUi.mora,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_finalizado) {
      return Row(
        children: const [
          Icon(Icons.check_circle_outline_rounded,
              size: 15, color: LoanUi.finalizado),
          SizedBox(width: 6),
          Text(
            'Pagado totalmente',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: LoanUi.finalizado,
            ),
          ),
        ],
      );
    }

    // Activo: próximo vencimiento.
    return Row(
      children: [
        const Icon(Icons.calendar_today_rounded,
            size: 14, color: LoanUi.muted),
        const SizedBox(width: 6),
        const Text(
          'Próximo vencimiento:',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: LoanUi.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            texto.isNotEmpty ? texto : '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: LoanUi.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
