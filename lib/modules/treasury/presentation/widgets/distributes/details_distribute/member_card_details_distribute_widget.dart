import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/core/widgets/upload_file_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entity/entity.dart';
import '../../../bloc/treasury_bloc.dart';

class MemberCard extends StatefulWidget {
  final DistributionDetailMemberEntity member;
  final String Function(double) formatCurrency;
  final String distributionId;
  final String distributionPeriod;

  const MemberCard({
    super.key,
    required this.member,
    required this.formatCurrency,
    required this.distributionId,
    required this.distributionPeriod,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  bool _isThisCardPaying = false;

  bool get _isPendiente => widget.member.status.toLowerCase() == 'pendiente';

  Color get _statusColor => _isPendiente ? TColors.warning : TColors.success;

  Color get _avatarBg =>
      _isPendiente ? TColors.warningLight : TColors.successLight;

  String get _initials {
    final parts = widget.member.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.member.fullName.substring(0, 2).toUpperCase();
  }

  void _navigateToSuccess(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();

    context.router.push(
      PaymentSuccessDistributionRoute(
        bloc: context.read<TreasuryBloc>(),
        receiptId: widget.member.detailId,
        isFromDetails: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TreasuryBloc, TreasuryState>(
      // Solo escuchar si esta card fue la que disparó el pago
      listenWhen: (_, state) => _isThisCardPaying,
      listener: (context, state) {
        if (state is PayDividendLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.45),
            builder: (_) => const PopScope(
              canPop: false,
              child: Center(child: ExcavatorLoader()),
            ),
          );
        }

        if (state is PayDividendSuccess) {
          _isThisCardPaying = false;
          _navigateToSuccess(context);
        }

        if (state is PayDividendError) {
          _isThisCardPaying = false;
          Navigator.of(context, rootNavigator: true).pop();
          CustomAlert.show(
            context,
            title: 'Error',
            message: state.message,
            type: AlertType.error,
          );
        }
      },
      buildWhen: (prev, curr) =>
          curr is! PayDividendLoading &&
          curr is! PayDividendSuccess &&
          curr is! PayDividendError,
      builder: (context, state) {
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
                  _Avatar(
                    initials: _initials,
                    bg: _avatarBg,
                    color: _statusColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.member.fullName,
                          style: const TextStyle(
                            color: TColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.member.paymentDate != null)
                          Text(
                            'Pagado: ${widget.member.paymentDate}',
                            style: const TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: widget.member.status,
                    color: _statusColor,
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
                  _AmountColumn(
                    label: 'MONTO ASIGNADO',
                    value: widget.formatCurrency(widget.member.assignedAmount),
                  ),
                  if (_isPendiente)
                    _PayButton(
                      onPressed: () {
                        final bloc = context.read<TreasuryBloc>();
                        showConfirmarPagoDialog(
                          context: context,
                          nombreSocio: widget.member.fullName,
                          monto: widget.formatCurrency(
                            widget.member.assignedAmount,
                          ),
                          periodo: widget.distributionPeriod,
                          cashRegisters: bloc.cashRegisters,
                          onConfirmar: (cashRegisterId, evidenciaPath) {
                            setState(() => _isThisCardPaying = true);
                            bloc.add(
                              PayDividendEvent(
                                distributionId: widget.distributionId,
                                memberId: widget.member.memberId,
                                cashRegisterId: cashRegisterId,
                                period: widget.distributionPeriod,
                                evidenciaPath: evidenciaPath,
                              ),
                            );
                          },
                        );
                      },
                    )
                  else
                    _ViewReceiptButton(
                      onPressed: () {
                        context.router.push(
                          PaymentSuccessDistributionRoute(
                            bloc: context.read<TreasuryBloc>(),
                            receiptId: widget.member.detailId,
                            isFromDetails: false,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color bg;
  final Color color;
  const _Avatar({
    required this.initials,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final String value;
  const _AmountColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: TColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Pagar',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ViewReceiptButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ViewReceiptButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
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
    );
  }
}


void showConfirmarPagoDialog({
  required BuildContext context,
  required String nombreSocio,
  required String monto,
  required String periodo,
  required List<CashRegisterEntity> cashRegisters,
  required void Function(String cashRegisterId, String evidenciaPath)
  onConfirmar,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => ConfirmarPagoDistribucionDialog(
      nombreSocio: nombreSocio,
      monto: monto,
      periodo: periodo,
      cashRegisters: cashRegisters,
      onConfirmar: onConfirmar,
    ),
  );
}

class ConfirmarPagoDistribucionDialog extends StatefulWidget {
  final String nombreSocio;
  final String monto;
  final String periodo;
  final List<CashRegisterEntity> cashRegisters;
  final void Function(String cashRegisterId, String evidenciaPath) onConfirmar;

  const ConfirmarPagoDistribucionDialog({
    super.key,
    required this.nombreSocio,
    required this.monto,
    required this.periodo,
    required this.cashRegisters,
    required this.onConfirmar,
  });

  @override
  State<ConfirmarPagoDistribucionDialog> createState() =>
      _ConfirmarPagoDistribucionDialogState();
}

class _ConfirmarPagoDistribucionDialogState
    extends State<ConfirmarPagoDistribucionDialog> {
  String? _selectedCajaId;
  File? _evidenciaFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _evidenciaFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Seleccionar evidencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF295AF5),
              ),
              title: const Text('Elegir de la Galería'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF295AF5)),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) => NumberFormat.currency(
    locale: 'es_BO',
    symbol: 'Bs',
    decimalDigits: 2,
  ).format(value);

  @override
  Widget build(BuildContext context) {
    final bool canConfirm = _selectedCajaId != null && _evidenciaFile != null;

    return Dialog(
      backgroundColor: TColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono central
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: TColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: TColors.primary,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Confirmar Pago',
                  style: TextStyle(
                    color: TColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '${widget.nombreSocio} · ${widget.monto}',
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Caja origen
              const Text(
                'CAJA ORIGEN',
                style: TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCajaId,
                    isExpanded: true,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Seleccionar caja',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: TColors.textSecondary,
                      ),
                    ),
                    dropdownColor: TColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    items: widget.cashRegisters
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    c.nombre,
                                    style: const TextStyle(
                                      color: TColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(c.saldoDisponible),
                                    style: const TextStyle(
                                      color: TColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCajaId = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Evidencia
              const Text(
                'EVIDENCIA',
                style: TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              UploadFileWidget(
                onTap: _showPickerOptions,
                selectedImage: _evidenciaFile,
                onRemoveImage: () => setState(() => _evidenciaFile = null),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canConfirm
                      ? () {
                          Navigator.pop(context);
                          widget.onConfirmar(
                            _selectedCajaId!,
                            _evidenciaFile!.path,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    disabledBackgroundColor: TColors.primary.withValues(
                      alpha: 0.4,
                    ),
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: TColors.textSecondary,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
