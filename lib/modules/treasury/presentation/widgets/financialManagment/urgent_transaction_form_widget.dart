import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/voice/voice_dictation_sheet.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/income_request_entity.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';
import '../../voice/transaction_voice_parser.dart';
import 'transaction_type_selector_widget.dart';
import 'transaction_action_buttons_widget.dart';

class UrgentTransactionFormWidget extends StatefulWidget {
  const UrgentTransactionFormWidget({super.key});

  @override
  State<UrgentTransactionFormWidget> createState() =>
      _UrgentTransactionFormWidgetState();
}

class _UrgentTransactionFormWidgetState
    extends State<UrgentTransactionFormWidget> {
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'Ingreso';
  
  String? _selectedCajaId;
  
  String? _selectedCajaOrigenId;
  String? _selectedCajaDestinoId;

  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();

  File? _evidenciaFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<TreasuryBloc>().add(GetCashRegistersEvent());
  }

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required String label,
    String? hint,
    IconData? icon,
    bool alignHint = false,
  }) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignHint,
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: const Color(0xFF6B7A99), size: 20),
      filled: true,
      fillColor: Colors.white,
      border: b(const Color(0xFFE8EDF5)),
      enabledBorder: b(const Color(0xFFE8EDF5)),
      focusedBorder: b(const Color(0xFF1A56FF), 1.6),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _evidenciaFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      CustomAlert.show(context, title: 'Error', message: 'No se pudo seleccionar la imagen. Intenta de nuevo.', type: AlertType.error);
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _dictarPorVoz() async {
    final transcript = await showVoiceDictationSheet(
      context: context,
      title: 'Dictar transacción',
      hintExample:
          'Di por ejemplo: "Egreso de 500 bolivianos de caja chica por compra de diésel"',
    );
    if (transcript == null || !mounted) return;

    final result = TransactionVoiceParser.parse(
      transcript,
      cajas: context.read<TreasuryBloc>().cashRegisters,
    );

    if (!result.understoodSomething) {
      CustomAlert.show(
        context,
        title: 'Atención',
        message:
            'No se pudo interpretar el dictado: "$transcript". Intenta de nuevo.',
        type: AlertType.warning,
      );
      return;
    }

    setState(() {
      if (result.tipo != null && result.tipo != _selectedType) {
        // Mismo reseteo que hace el selector manual al cambiar de tipo.
        _selectedType = result.tipo!;
        _evidenciaFile = null;
        _selectedCajaId = null;
        _selectedCajaOrigenId = null;
        _selectedCajaDestinoId = null;
      }
      if (_selectedType == 'Transferencia') {
        if (result.cajaOrigenId != null) {
          _selectedCajaOrigenId = result.cajaOrigenId;
        }
        if (result.cajaDestinoId != null) {
          _selectedCajaDestinoId = result.cajaDestinoId;
        }
      } else if (result.cajaId != null) {
        _selectedCajaId = result.cajaId;
      }
      if (result.monto != null) {
        _montoController.text = result.monto!.toStringAsFixed(2);
      }
      if (result.concepto != null) {
        _conceptoController.text = result.concepto!;
      }
    });

    if (!mounted) return;
    CustomAlert.show(
      context,
      title: 'Formulario rellenado',
      message: 'Revisa los datos dictados y completa lo que falte antes de registrar.',
      type: AlertType.success,
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == 'Transferencia') {
      if (_selectedCajaOrigenId == null || _selectedCajaDestinoId == null) {
        CustomAlert.show(context, title: 'Error', message: 'Debes seleccionar caja origen y destino.', type: AlertType.error);
        return;
      }
      if (_selectedCajaOrigenId == _selectedCajaDestinoId) {
        CustomAlert.show(context, title: 'Error', message: 'La caja origen y destino no pueden ser la misma.', type: AlertType.error);
        return;
      }
      final request = TransferRequestEntity(
        monto: double.parse(_montoController.text),
        cajaOrigenId: _selectedCajaOrigenId!,
        cajaDestinoId: _selectedCajaDestinoId!,
        concepto: _conceptoController.text,
      );
      context.read<TreasuryBloc>().add(RegisterUrgentTransferEvent(request: request));
      return;
    }

    if (_selectedCajaId == null) {
      CustomAlert.show(
        context, title: 'Error', message: 'Debes seleccionar una caja ${_selectedType == 'Ingreso' ? 'destino' : 'origen'}.', type: AlertType.error);
      return;
    }

    if (_evidenciaFile == null) {
      CustomAlert.show(
        context, title: 'Error', message: 'La foto de evidencia es obligatoria.', type: AlertType.error);
      return;
    }

    if (_selectedType == 'Ingreso') {
      final request = IncomeRequestEntity(
        monto: double.parse(_montoController.text),
        cajaDestinoId: _selectedCajaId!,
        concepto: _conceptoController.text,
        evidenceUrlPath: _evidenciaFile!.path,
      );
      context.read<TreasuryBloc>().add(RegisterUrgentIncomeEvent(request: request));
    } else if (_selectedType == 'Egreso') {
      final request = ExpenseRequestEntity(
        monto: double.parse(_montoController.text),
        cajaOrigenId: _selectedCajaId!,
        concepto: _conceptoController.text,
        evidenceUrlPath: _evidenciaFile!.path,
      );
      context.read<TreasuryBloc>().add(RegisterUrgentExpenseEvent(request: request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TreasuryBloc, TreasuryState>(
      listener: (context, state) {
        if (state is UrgentIncomeSuccess || state is UrgentExpenseSuccess || state is UrgentTransferSuccess) {
          String mensaje = 'Transacción registrada correctamente';
          if (state is UrgentIncomeSuccess) mensaje = 'El ingreso se ha registrado correctamente';
          if (state is UrgentExpenseSuccess) mensaje = 'El egreso se ha registrado correctamente';
          if (state is UrgentTransferSuccess) mensaje = 'La transferencia se ha registrado correctamente';
          
          CustomAlert.show(context, title: 'Éxito', message: mensaje, type: AlertType.success);
          // Devuelve true para que el dashboard recargue también el historial.
          Navigator.pop(context, true);
        } else if (state is UrgentIncomeError) {
          CustomAlert.show(context, title: 'Error', message: state.message, type: AlertType.error);
        } else if (state is UrgentExpenseError) {
          CustomAlert.show(context, title: 'Error', message: state.message, type: AlertType.error);
        } else if (state is UrgentTransferError) {
          CustomAlert.show(context, title: 'Error', message: state.message, type: AlertType.error);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: _dictarPorVoz,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD97706),
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(
                    color: const Color(0xFFD97706).withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.mic_rounded, size: 20),
                label: const Text(
                  'Dictar por voz',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              TransactionTypeSelectorWidget(
                selectedValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    _evidenciaFile = null;
                    _selectedCajaId = null; 
                    _selectedCajaOrigenId = null;
                    _selectedCajaDestinoId = null;

                    _montoController.clear();
                    _conceptoController.clear();
                  });
                },
              ),
              const SizedBox(height: 24),
              BlocBuilder<TreasuryBloc, TreasuryState>(
                buildWhen: (previous, current) =>
                    current is CashRegistersLoading ||
                    current is CashRegistersLoaded ||
                    current is CashRegistersError,
                builder: (context, state) {
                  if (state is CashRegistersLoading) {
                    return const StaffLoader();
                  }
                  
                  final cajas = context.read<TreasuryBloc>().cashRegisters;
                  
                  final dropdownItems = cajas.map((caja) {
                    return DropdownMenuItem(
                      value: caja.id,
                      child: Text('${caja.nombre} (Bs. ${caja.saldoDisponible})'),
                    );
                  }).toList();

                  if (_selectedType == 'Transferencia') {
                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedCajaOrigenId,
                          decoration: _dec(
                            label: 'Caja origen',
                            icon: Icons.outbox_rounded,
                          ),
                          items: dropdownItems,
                          onChanged: (value) => setState(() => _selectedCajaOrigenId = value),
                          validator: (value) => value == null ? 'Selecciona la caja origen' : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedCajaDestinoId,
                          decoration: _dec(
                            label: 'Caja destino',
                            icon: Icons.move_to_inbox_rounded,
                          ),
                          items: dropdownItems,
                          onChanged: (value) => setState(() => _selectedCajaDestinoId = value),
                          validator: (value) => value == null ? 'Selecciona la caja destino' : null,
                        ),
                      ],
                    );
                  } 
                  else {
                    return DropdownButtonFormField<String>(
                      value: _selectedCajaId,
                      decoration: _dec(
                        label: _selectedType == 'Ingreso'
                            ? 'Caja destino'
                            : 'Caja origen',
                        icon: Icons.wallet_rounded,
                      ),
                      items: dropdownItems,
                      onChanged: (value) => setState(() => _selectedCajaId = value),
                      validator: (value) => value == null ? 'Por favor, selecciona una caja' : null,
                    );
                  }
                },
              ),
                  
              const SizedBox(height: 20),
                  
              TextFormField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El monto es requerido';
                  final monto = double.tryParse(value);
                  if (monto == null) return 'Ingresa un valor numérico válido';
                  if (monto <= 0) return 'El monto debe ser mayor a 0';
                  return null;
                },
                decoration: _dec(
                  label: 'Monto (Bs.)',
                  hint: '0.00',
                  icon: Icons.attach_money_rounded,
                ),
              ),
                  
              const SizedBox(height: 20),
                  
              TextFormField(
                controller: _conceptoController,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                decoration: _dec(
                  label: 'Concepto / Motivo',
                  hint: 'Describe el motivo de la transacción...',
                  alignHint: true,
                ),
              ),
                  
              const SizedBox(height: 20),
                  
              // Evidencia requerida SOLO para Ingreso o Egreso
              if (_selectedType == 'Ingreso' || _selectedType == 'Egreso') ...[
                const Text(
                  'Evidencia (requerida)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7A99),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _evidenciaFile == null
                            ? const Color(0xFF1A56FF).withValues(alpha: 0.3)
                            : const Color(0xFFE8EDF5),
                        width: 1.4,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      color: _evidenciaFile == null
                          ? const Color(0xFF1A56FF).withValues(alpha: 0.04)
                          : Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _evidenciaFile != null
                        ? Image.file(
                            _evidenciaFile!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 34,
                                color: Color(0xFF1A56FF),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Toca para añadir foto',
                                style: TextStyle(
                                  color: Color(0xFF0D1B3E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Cámara o galería',
                                style: TextStyle(
                                  color: Color(0xFF6B7A99),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_evidenciaFile != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _evidenciaFile = null),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    label: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                  ),
              ],
                  
              const SizedBox(height: 32),
                  
              TransactionActionButtonsWidget(
                onCancel: () => Navigator.pop(context),
                onSubmit: (state is UrgentIncomeLoading || state is UrgentExpenseLoading || state is UrgentTransferLoading)
                    ? null
                    : _submitForm, 
              ),
            ],
          ),
        );
      },
    );
  }
}