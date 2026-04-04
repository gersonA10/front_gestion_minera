import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../domain/entity/loans/payment_process_entity.dart';

@RoutePage()
class PaymentSuccessScreen extends StatelessWidget {
  final PayTheFeeResponseEntity paymentData;
  const PaymentSuccessScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A150C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A150C),
        automaticallyImplyLeading:false,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'CONFIRMACIÓN', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(
                              alpha: 0.45,
                            ),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Pago registrado\ncon éxito',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'La transacción se ha procesado correctamente. Puedes revisar los detalles de tu pago o compartir el recibo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF86ABAB),
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C2010),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1C4020),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'MONTO PAGADO',
                            style: TextStyle(
                              color: Color(0xFF86ABAB),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            paymentData.montoPagado.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            color: Color(0xFF1C4020),
                            thickness: 1,
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: 'Referencia',
                            value: paymentData.referencia,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Fecha / Hora',
                            value: paymentData.fechaHora,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Caja afectada',
                            value: paymentData.cajaAfectada,
                            valueBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom actions
            Padding(
              padding:  EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {context.router.back();},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Salir',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: 'Compartir',
                        onTap: () {},
                      ),
                      const SizedBox(width: 32),
                      _ActionButton(
                        icon: Icons.download_outlined,
                        label: 'Guardar Recibo',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF86ABAB), fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF86ABAB), size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF86ABAB),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
