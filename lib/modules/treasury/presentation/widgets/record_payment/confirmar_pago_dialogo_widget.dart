import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/record_payment_screen.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entity/entity.dart';

class ConfirmarPagoDialog extends StatefulWidget {
  final String textoCuota;
  final String montoFormateado;
  final String idLoan;
  final String idQuota;
  final String cajaOrigenId;
  final String metodoPago;
  final String referencia;
  final TreasuryBloc treasuryBloc;
  const ConfirmarPagoDialog({
    super.key,
    required this.textoCuota,
    required this.montoFormateado,
    required this.idLoan,
    required this.idQuota,
    required this.cajaOrigenId,
    required this.metodoPago,
    required this.referencia,
    required this.treasuryBloc,
  });

  @override
  State<ConfirmarPagoDialog> createState() => _ConfirmarPagoDialogState();
}

class _ConfirmarPagoDialogState extends State<ConfirmarPagoDialog> {
  XFile? _imagenComprobante;

  bool get _comprobanteSubido => _imagenComprobante != null;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _imagenComprobante = picked);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TColors.cardBgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: TColors.cardBorderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Adjuntar comprobante',
                style: TextStyle(
                  color: TColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              SourceOption(
                icon: Icons.photo_library_outlined,
                label: 'Seleccionar de galería',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              SourceOption(
                icon: Icons.camera_alt_outlined,
                label: 'Tomar una foto',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.treasuryBloc,
      child: BlocConsumer<TreasuryBloc, TreasuryState>(
        listenWhen: (_, state) =>
            state is PayTheFeeLoaded || state is PayTheFeeError,
        listener: (context, state) {
          if (state is PayTheFeeLoaded) {
            context.router.back();
            context.router.push(
              PaymentSuccessRoute(paymentData: state.payTheFee),
            );
          } else if (state is PayTheFeeError) {
            CustomAlert.show(
              context,
              title: 'Error',
              message: state.message,
              type: AlertType.error,
            );
          }
        },
        buildWhen: (_, state) =>
            state is PayTheFeeLoading ||
            state is PayTheFeeLoaded ||
            state is PayTheFeeError,
        builder: (context, state) {
          final isLoading = state is PayTheFeeLoading;
          return Dialog(
            backgroundColor: TColors.cardBgDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: Color(0xFF2563EB),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Confirmar Pago',
                        style: TextStyle(
                          color: TColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: TColors.textSecondary1,
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Está registrando un pago de ',
                            ),
                            TextSpan(
                              text: '${widget.montoFormateado} CLP',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: ' correspondiente a la '),
                            TextSpan(
                              text: widget.textoCuota,
                              style: const TextStyle(
                                color: TColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '. Esta acción actualizará el saldo del préstamo.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_comprobanteSubido)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B1515),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF7B2020)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFEF4444),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Para confirmar el pago tienes que subir el comprobante electronico o recibo',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _comprobanteSubido
                                ? const Color(0xFF0F1E3A)
                                : const Color(0xFF1A2236),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _comprobanteSubido
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF2A3A55),
                              width: _comprobanteSubido ? 1.5 : 1,
                            ),
                          ),
                          child: _comprobanteSubido
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        File(_imagenComprobante!.path),
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.edit_outlined,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Cambiar',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withValues(
                                                  alpha: 0.65,
                                                ),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF34D399),
                                                size: 14,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Comprobante adjunto',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 160,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E3A5F),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo_outlined,
                                          color: Color(0xFF2563EB),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Subir foto del comprobante',
                                        style: TextStyle(
                                          color: TColors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'JPG, PNG hasta 5MB',
                                        style: TextStyle(
                                          color: TColors.textSecondary1,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: TColors.white,
                                side: BorderSide(color: TColors.cardBorderDark),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      final payRequest = PayTheFeeRequetsEntity(
                                        cajaOrigenId: widget.cajaOrigenId,
                                        metodoPago: widget.metodoPago,
                                        referencia: widget.referencia,
                                        fechaPago: DateTime.now()
                                            .toIso8601String(),
                                        comprobante: _imagenComprobante!.path
                                            .toString(),
                                      );
                                      widget.treasuryBloc.add(
                                        PayTheFeeEvent(
                                          payTheFeeRequest: payRequest,
                                          idLoan: widget.idLoan,
                                          idQuota: widget.idQuota,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                disabledBackgroundColor: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Confirmar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
