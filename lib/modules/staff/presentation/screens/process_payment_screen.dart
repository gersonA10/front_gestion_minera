import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class ProcessPaymentScreen extends StatefulWidget {
  const ProcessPaymentScreen({super.key});

  @override
  State<ProcessPaymentScreen> createState() =>
      _ProcessPaymentScreenState();
}

class _ProcessPaymentScreenState
    extends State<ProcessPaymentScreen> {
  bool isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Procesar Pago',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6FC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFDCE5F4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 62,
                                    height: 62,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius:
                                          BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 34,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Juan Perez',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Operador de Maquinaria Pesada',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.badge_outlined,
                                          size: 14,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'ID : #29481',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9CA3AF),
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFE0F2FE,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            'Activo',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color:
                                                  Color(0xFF0284C7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'PERIODO DE PAGO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Octubre 2026',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(30),
                                border: Border.all(
                                  color:
                                      const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: const Text(
                                'Nómina Mensual',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        Row(
                          children: const [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Percepciones',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Salario Base',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.w500,
                                        color:
                                            Color(0xFF374151),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Bs 2,500.00',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                      color:
                                          Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFF9FAFB),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        const Color(0xFFE5E7EB),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 18,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Espacio preparado para bonos y pagos extras',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: const [
                            Icon(
                              Icons.remove_circle_outline,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Deducciones',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Color(0xFF9CA3AF),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Estructura lista para descuentos, AFP, impuestos u otras retenciones.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6FC),
                            borderRadius:
                                BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFD7E2F3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Neto a Pagar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w500,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Bs 2,720.00',
                                      style: TextStyle(
                                        fontSize: 34,
                                        height: 1,
                                        fontWeight:
                                            FontWeight.w800,
                                        color:
                                            Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFE0E7FF,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(
                                        20,
                                      ),
                                    ),
                                    child: const Text(
                                      'Bs',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w700,
                                        color:
                                            Color(0xFF4338CA),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: isProcessingPayment
                                ? null
                                : () async {
                                    HapticFeedback.lightImpact();

                                    setState(() {
                                      isProcessingPayment = true;
                                    });

                                    await Future.delayed(
                                      const Duration(
                                        seconds: 2,
                                      ),
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      isProcessingPayment = false;
                                    });
                                  },
                            icon: isProcessingPayment
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline,
                                    size: 20,
                                  ),
                            label: Text(
                              isProcessingPayment
                                  ? 'Procesando pago...'
                                  : 'Confirmar y Pagar',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              disabledBackgroundColor:
                                  const Color(0xFFE5E7EB),
                              disabledForegroundColor:
                                  const Color(0xFF9CA3AF),
                              backgroundColor:
                                  const Color(0xFFD4A514),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Text(
                            'Al confirmar, el pago será procesado y se enviará el comprobante digital al correo del trabajador.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}