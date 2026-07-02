import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import 'contributes_ui.dart';

@RoutePage()
class RecordContributionPaymentScreen extends StatefulWidget {
  final DateTime dateContibution;
  final String titleContibuton;
  final ContributionDetailMemberEntity item;
  final CashResponseEntity cash;
  const RecordContributionPaymentScreen({
    super.key,
    required this.dateContibution,
    required this.titleContibuton,
    required this.item,
    required this.cash,
  });

  @override
  State<RecordContributionPaymentScreen> createState() =>
      _RecordContributionPaymentScreenState();
}

class _RecordContributionPaymentScreenState
    extends State<RecordContributionPaymentScreen> {
  final TextEditingController _observacionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final _fmt = NumberFormat('#,##0.00', 'es_PE');

  late TreasuryBloc treasuryBloc;
  String? _selectedCajaId;
  String? _selectedCajaName;
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CUi.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: CUi.primary),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library_outlined, color: CUi.primary),
              title: const Text('Elegir de Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    treasuryBloc = InjectorContainer.getIt<TreasuryBloc>();

    if (widget.cash.data.isNotEmpty) {
      _selectedCajaId = widget.cash.data.first.id;
      _selectedCajaName = widget.cash.data.first.nombre;
    }

    final now = DateTime.now();
    _fechaController.text =
        '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    _observacionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CUi.bg,
      appBar: contribAppBar(context, title: 'Registrar Pago'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero del monto a pagar.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: CUi.gradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: CUi.primary.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'MONTO FIJO A PAGAR',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_fmt.format(widget.item.amountToPay)} Bs',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.white.withValues(alpha: 0.95),
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.item.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildLabel('Convocatoria de Aporte'),
                  _buildReadOnlyField(
                    '${widget.titleContibuton} · ${formatDate(widget.dateContibution)}',
                    Icons.lock_outline,
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Fecha y Hora de Pago'),
                  _buildReadOnlyField(
                    _fechaController.text,
                    Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Evidencia de Pago', isRequired: true),
                  if (_imageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageFile = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: _showImageSourceOptions,
                      child: Container(
                        width: double.infinity,
                        height: 124,
                        decoration: BoxDecoration(
                          color: CUi.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CUi.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: CUi.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_a_photo_outlined,
                                color: CUi.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Toca para tomar foto o subir recibo',
                              style: TextStyle(
                                color: CUi.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  _buildLabel('Caja de Destino', isRequired: true),
                  _buildCajaSelector(),
                  const SizedBox(height: 18),
                  _buildLabel('Observación', isOptional: true),
                  TextField(
                    maxLines: 3,
                    controller: _observacionController,
                    style: const TextStyle(color: CUi.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CUi.surface,
                      hintText: 'Añadir notas adicionales sobre el pago...',
                      hintStyle: const TextStyle(color: CUi.muted, fontSize: 14),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: CUi.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: CUi.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: CUi.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: CPrimaryButton(
                label: 'Continuar',
                icon: Icons.arrow_forward_rounded,
                onPressed: _onContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    if (_imageFile == null) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Debes agregar una evidencia antes de continuar.',
        type: AlertType.error,
      );
      return;
    }
    if (_selectedCajaId == null) {
      CustomAlert.show(
        context,
        title: 'Atención',
        message: 'Por favor, selecciona una caja destino.',
        type: AlertType.warning,
      );
      return;
    }
    _showConfirmDialog();
  }

  // Selector de caja tipo campo (no se estira como el dropdown de Material).
  Widget _buildCajaSelector() {
    final hasSelection = _selectedCajaName != null;
    return GestureDetector(
      onTap: _showCajaSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CUi.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CUi.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 18,
              color: CUi.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasSelection ? _selectedCajaName! : 'Seleccionar caja...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w400,
                  color: hasSelection ? CUi.textPrimary : CUi.muted,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: CUi.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCajaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CUi.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CUi.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Caja de destino',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: CUi.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.cash.data.map((caja) {
                final selected = caja.id == _selectedCajaId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCajaId = caja.id;
                        _selectedCajaName = caja.nombre;
                      });
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? CUi.primarySoft : CUi.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? CUi.primary : CUi.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: selected ? CUi.primary : CUi.muted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              caja.nombre,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? CUi.textPrimary
                                    : CUi.textSecondary,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: CUi.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: treasuryBloc,
          child: BlocConsumer<TreasuryBloc, TreasuryState>(
            listener: (context, state) {
              if (state is RecordContributionPaymentLoaded) {
                final router = context.router;
                // Cierra el diálogo de confirmación.
                Navigator.of(context).pop();
                // Reemplaza "registrar pago" por el comprobante: al volver del
                // comprobante se cae directo al detalle del aporte, sin dejar
                // la pantalla de "registrar pago" colgada en el stack.
                router.replace(
                  PaymentConfirmationRoute(
                    transactionId: widget.item.detailId,
                    screen: true,
                  ),
                );
              }
              if (state is RecordContributionPaymentError) {
                context.router.back();
                CustomAlert.show(
                  context,
                  title: 'Error',
                  message: state.message,
                  type: AlertType.error,
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is RecordContributionPaymentLoading;
              return Dialog(
                backgroundColor: CUi.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: CUi.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.payments_rounded,
                          color: CUi.primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Confirmación Final',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: CUi.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Vas a registrar un pago de ${_fmt.format(widget.item.amountToPay)} Bs. Revisa los detalles antes de confirmar.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CUi.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CUi.bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CUi.border),
                        ),
                        child: Column(
                          children: [
                            _buildRowDetail(
                              'Socio',
                              widget.item.fullName,
                              isBold: true,
                            ),
                            const SizedBox(height: 10),
                            _buildRowDetail(
                              'Concepto',
                              _observacionController.text.isEmpty
                                  ? 'Sin observación'
                                  : _observacionController.text,
                            ),
                            const SizedBox(height: 10),
                            _buildRowDetail(
                              'Monto Total',
                              '${_fmt.format(widget.item.amountToPay)} Bs',
                              valueColor: CUi.primary,
                              isBold: true,
                            ),
                            const SizedBox(height: 10),
                            _buildRowDetail(
                              'Caja Destino',
                              _selectedCajaName ?? '',
                              valueColor: CUi.primary,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: StaffLoader(),
                        )
                      else ...[
                        CPrimaryButton(
                          label: 'Confirmar Pago',
                          onPressed: () {
                            treasuryBloc.add(
                              RecordContributionPaymentEvent(
                                recordContributionPaymentRequestModel:
                                    RecordContributionPaymentRequestEntity(
                                  detailid: widget.item.detailId,
                                  cashRegisterid: _selectedCajaId ?? '',
                                  observacion: _observacionController.text,
                                  evidencia: _imageFile!.path,
                                ),
                              ),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: CUi.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLabel(
    String text, {
    bool isRequired = false,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: CUi.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: CUi.danger),
              ),
            if (isOptional)
              const TextSpan(
                text: '  (Opcional)',
                style: TextStyle(
                  color: CUi.muted,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CUi.fieldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CUi.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: CUi.muted, size: 18),
        ],
      ),
    );
  }
}

Widget _buildRowDetail(
  String label,
  String value, {
  Color? valueColor,
  bool isBold = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: CUi.textSecondary, fontSize: 14)),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: valueColor ?? CUi.textPrimary,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
