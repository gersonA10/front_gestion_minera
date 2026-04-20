import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/entity/entity.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.router.back(),
        ),
        title: const Text(
          'Registrar Pago',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Monto Fijo a Pagar',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.item.amountToPay.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Monto Validado',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLabel("Convocatoria de Aporte"),
                  _buildReadOnlyField(
                    "${widget.titleContibuton} - ${formatDate(widget.dateContibution)}",
                    Icons.lock_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Fecha y Hora de Pago"),
                  _buildReadOnlyField(
                    _fechaController.text,
                    Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Evidencia de Pago"),
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
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  setState(() => _imageFile = null),
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
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: TColors.appMainColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Toca para tomar foto o subir recibo",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  _buildLabel("Caja de Destino", isRequired: true),
                  DropdownButtonFormField<String>(
                    value: _selectedCajaId,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    hint: const Text(
                      "Seleccionar caja...",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    items: widget.cash.data.map((caja) {
                      return DropdownMenuItem<String>(
                        value: caja.id,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 18,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              caja.nombre,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCajaId = newValue;
                        _selectedCajaName = widget.cash.data
                            .firstWhere((caja) => caja.id == newValue)
                            .nombre;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Observación", isOptional: true),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      maxLines: 3,
                      controller: _observacionController,
                      decoration: InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        hintText: "Añadir notas adicionales sobre el pago...",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_imageFile == null) {
                    CustomAlert.show(
                      context,
                      title: 'Error',
                      message:
                          'Debes agregar una evidencia antes de continuar.',
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

                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return BlocProvider.value(
                        value: treasuryBloc,
                        child: BlocConsumer<TreasuryBloc, TreasuryState>(
                          listener: (context, state) {
                            if (state is RecordContributionPaymentLoaded) {
                              context.router.push(
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
                            final isLoading =
                                state is RecordContributionPaymentLoading;
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF1F1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.lock_clock_outlined,
                                            color: Color(0xFFEF4444),
                                            size: 40,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Confirmación Final',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Vas a registrar un pago de ${widget.item.amountToPay.toStringAsFixed(2)} Bs. Por favor revisa los detalles cuidadosamente.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.withValues(
                                                alpha: 0.1,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              _buildRowDetail(
                                                "Socio",
                                                widget.item.fullName,
                                                isBold: true,
                                              ),
                                              SizedBox(height: 10),
                                              _buildRowDetail(
                                                "Concepto",
                                                _observacionController
                                                        .text
                                                        .isEmpty
                                                    ? 'Sin observación'
                                                    : _observacionController
                                                          .text,
                                              ),
                                              SizedBox(height: 10),
                                              _buildRowDetail(
                                                "Monto Total",
                                                "${widget.item.amountToPay.toStringAsFixed(2)} Bs",
                                                valueColor: const Color(
                                                  0xFF2563EB,
                                                ),
                                                isBold: true,
                                              ),
                                              SizedBox(height: 10),
                                              _buildRowDetail(
                                                "Caja Destino",
                                                _selectedCajaName ?? '',
                                                valueColor: const Color(
                                                  0xFF2563EB,
                                                ),
                                                isBold: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              treasuryBloc.add(
                                                RecordContributionPaymentEvent(
                                                  recordContributionPaymentRequestModel:
                                                      RecordContributionPaymentRequestEntity(
                                                        detailid: widget
                                                            .item
                                                            .detailId,
                                                        cashRegisterid:
                                                            _selectedCajaId ??
                                                            '',
                                                        observacion:
                                                            _observacionController
                                                                .text,
                                                        evidencia:
                                                            _imageFile!.path,
                                                      ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  TColors.appMainColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              "Confirmar Pago",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            "Cancelar",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isLoading)
                                    const Positioned(
                                      top: -60,
                                      left: 0,
                                      right: 0,
                                      child: ExcavatorLoader(
                                        width: 120,
                                        height: 120,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Azul brillante
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continuar",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            if (isOptional)
              const TextSpan(
                text: ' (Opcional)',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
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
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.blueGrey)),
          Icon(icon, color: Colors.grey, size: 20),
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
      Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
      Text(
        value,
        style: TextStyle(
          color: valueColor ?? const Color(0xFF1E293B),
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
