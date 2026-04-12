
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loans_home_screen.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';

class LoanCard extends StatelessWidget {
  final InternalLoansEntity loan;
   final TreasuryBloc treasuryBloc;
  const LoanCard({super.key, required this.loan, required this.treasuryBloc});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'es_PE');

    return GestureDetector(
      onTap: () async{
        await context.router.push(LoanDetailsRoute(idLoan: loan.loanId));
         treasuryBloc.add(
      InternalLoansRequestsEvent(
        
      ),
    );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: loan.status.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: loan.status.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    loan.estadoEtiqueta,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: loan.status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.lenderName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${loan.loanCode}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Prestado',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      fmt.format(loan.montoPrestado),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total a Pagar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        fmt.format(loan.totalAPagar),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      loan.status == LoanStatus.finalizado
                          ? 'Total Pagado'
                          : 'Pendiente',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      loan.status == LoanStatus.finalizado
                          ? fmt.format(loan.totalPagado)
                          : fmt.format(loan.pendiente),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: loan.status == LoanStatus.finalizado
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso de pago',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: loan.status.color,
                  ),
                ),
                Text(
                  '${loan.progresoInt}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: loan.progreso / 100,
                minHeight: 6,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(loan.status.color),
              ),
            ),
            const SizedBox(height: 10),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final textoFecha = loan.alertaVencimiento.textoFecha;

    switch (loan.status) {
      case LoanStatus.activo:
        return Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Próximo vencimiento: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: textoFecha.isNotEmpty ? textoFecha : '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case LoanStatus.enMora:
        return Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 15,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                textoFecha.isNotEmpty ? textoFecha : 'En mora',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        );

      case LoanStatus.finalizado:
        return Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 15,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(width: 6),
            const Text(
              'Pagado totalmente',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF16A34A),
                fontSize: 10,
              ),
            ),
          ],
        );
    }
  }
}
