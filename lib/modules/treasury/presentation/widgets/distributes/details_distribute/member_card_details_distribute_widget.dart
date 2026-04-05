import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/date_util.dart';

import '../../../../domain/entity/entity.dart';

class MemberCard extends StatelessWidget {
  final DistributionDetailMemberEntity member;
  final String Function(double) formatCurrency;

  const MemberCard({
    super.key,
    required this.member,
    required this.formatCurrency,
  });

  bool get _isPendiente => member.status.toLowerCase() == 'pendiente';
  Color get _statusColor => _isPendiente ? TColors.warning : TColors.success;
  Color get _avatarBg =>
      _isPendiente ? TColors.warningLight : TColors.successLight;

  String get _initials {
    final parts = member.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return member.fullName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (member.paymentDate != null)
                      Text(
                        'Pagado: ${member.paymentDate}',
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: TColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _statusColor),
                ),
                child: Text(
                  member.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: TColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MONTO ASIGNADO',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(member.assignedAmount),
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (_isPendiente)
                ElevatedButton(
                  onPressed: () {
                    showConfirmarPagoDialog(
                      context: context,
                      nombreSocio: member.fullName,
                      monto: member.assignedAmount.toString(),
                      periodo: member.paymentDate != null ? formatDate(DateTime.parse(member.paymentDate!)) : '',
                      onConfirmar: () {
                        
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Pagar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () {
                    context.router.push(PaymentSuccessDistributionRoute(
                      beneficiario: member.fullName,
                      montoPagado: member.assignedAmount.toString(),
                      periodo: member.paymentDate != null ? formatDate(DateTime.parse(member.paymentDate!)) : '',
                      fechaHora: DateTime.now().toString(),
                      cajaOrigen: member.detailId   ,//ojo
                      saldoRestante: member.assignedAmount.toString(),//ojo
                    ));
                  },
                  icon: const Icon(
                    Icons.receipt_long_outlined,
                    color: TColors.textSecondary,
                    size: 15,
                  ),
                  label: const Text(
                    'Ver recibo',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

void showConfirmarPagoDialog({
  required BuildContext context,
  required String nombreSocio,
  required String monto,
  required String periodo,
  required VoidCallback onConfirmar,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => ConfirmarPagoDistribucionDialog(
      nombreSocio: nombreSocio,
      monto: monto,
      periodo: periodo,
      onConfirmar: onConfirmar,
    ),
  );
}

class ConfirmarPagoDistribucionDialog extends StatelessWidget {
  final String nombreSocio;
  final String monto;
  final String periodo;
  final VoidCallback onConfirmar;

  const ConfirmarPagoDistribucionDialog({
    super.key,
    required this.nombreSocio,
    required this.monto,
    required this.periodo,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: TColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Ícono ───
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payments_outlined,
                color: TColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),

            // ─── Título ───
            const Text(
              'Confirmar Pago',
              style: TextStyle(
                color: TColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),

            // ─── Descripción ───
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15, height: 1.55),
                children: [
                  const TextSpan(
                    text: 'Está a punto de pagar ',
                    style: TextStyle(color: TColors.primary),
                  ),
                  TextSpan(
                    text: monto,
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text: ' a ',
                    style: TextStyle(color: TColors.primary),
                  ),
                  TextSpan(
                    text: nombreSocio,
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text: ' correspondiente a la distribución ',
                    style: TextStyle(color: TColors.primary),
                  ),
                  TextSpan(
                    text: '$periodo.',
                    style: const TextStyle(
                      color: TColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text: ' ¿Desea continuar?',
                    style: TextStyle(color: TColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirmar();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirmar Pago',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: TColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
