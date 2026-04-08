import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/income_request_entity.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';
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
  
  // Variables para Ingreso/Egreso
  String? _selectedCajaId;
  
  // Variables para Transferencia
  String? _selectedCajaOrigenId;
  String? _selectedCajaDestinoId;

  // Controladores
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();

  // Variables para la imagen
  File? _evidenciaFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Llamamos al servicio para obtener las cajas
    context.read<TreasuryBloc>().add(GetCashRegistersEvent());
  }

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  // Método para seleccionar la imagen
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen')),
      );
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // 1. SI ES TRANSFERENCIA
    if (_selectedType == 'Transferencia') {
      if (_selectedCajaOrigenId == null || _selectedCajaDestinoId == null) {
        CustomAlert.show(context, title: 'Error', message: 'Debes seleccionar caja origen y destino.', type: AlertType.error);
        return;
      }
      if (_selectedCajaOrigenId == _selectedCajaDestinoId) {
        CustomAlert.show(context, title: 'Error', message: 'La caja origen y destino no pueden ser la misma.', type: AlertType.error);
        return;
      }

      // COMPLETAMENTE DESCOMENTADO Y FUNCIONANDO
      final request = TransferRequestEntity(
        monto: double.parse(_montoController.text),
        cajaOrigenId: _selectedCajaOrigenId!,
        cajaDestinoId: _selectedCajaDestinoId!,
        concepto: _conceptoController.text,
      );
      context.read<TreasuryBloc>().add(RegisterUrgentTransferEvent(request: request));
      return;
    }

    // 2. SI ES INGRESO O EGRESO
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
        // AGREGADO EL SUCESO Y ERROR DE TRANSFERENCIA
        if (state is UrgentIncomeSuccess || state is UrgentExpenseSuccess || state is UrgentTransferSuccess) {
          String mensaje = 'Transacción registrada correctamente';
          if (state is UrgentIncomeSuccess) mensaje = 'El ingreso se ha registrado correctamente';
          if (state is UrgentExpenseSuccess) mensaje = 'El egreso se ha registrado correctamente';
          if (state is UrgentTransferSuccess) mensaje = 'La transferencia se ha registrado correctamente';
          
          CustomAlert.show(context, title: 'Éxito', message: mensaje, type: AlertType.success);
          Navigator.pop(context);
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
              TransactionTypeSelectorWidget(
                selectedValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    _evidenciaFile = null;
                    // Limpiamos las selecciones al cambiar de tipo
                    _selectedCajaId = null; 
                    _selectedCajaOrigenId = null;
                    _selectedCajaDestinoId = null;

                    // CORRECCIÓN ERROR 1: Limpiamos los controladores de texto
                    _montoController.clear();
                    _conceptoController.clear();
                  });
                },
              ),
              const SizedBox(height: 24),
                  
              // SECTOR DE CAJAS ALIMENTADO POR EL BLOC
              BlocBuilder<TreasuryBloc, TreasuryState>(
                buildWhen: (previous, current) =>
                    current is CashRegistersLoading ||
                    current is CashRegistersLoaded ||
                    current is CashRegistersError,
                builder: (context, state) {
                  if (state is CashRegistersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final cajas = context.read<TreasuryBloc>().cashRegisters;
                  
                  // Generamos la lista de items para los dropdowns
                  final dropdownItems = cajas.map((caja) {
                    return DropdownMenuItem(
                      value: caja.id,
                      child: Text('${caja.nombre} (Bs. ${caja.saldoDisponible})'),
                    );
                  }).toList();

                  // SI ES TRANSFERENCIA, MOSTRAMOS DOS DROPDOWNS
                  if (_selectedType == 'Transferencia') {
                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedCajaOrigenId,
                          decoration: InputDecoration(
                            labelText: 'Caja Origen',
                            prefixIcon: const Icon(Icons.outbox_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: dropdownItems,
                          onChanged: (value) => setState(() => _selectedCajaOrigenId = value),
                          validator: (value) => value == null ? 'Selecciona la caja origen' : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedCajaDestinoId,
                          decoration: InputDecoration(
                            labelText: 'Caja Destino',
                            prefixIcon: const Icon(Icons.move_to_inbox_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: dropdownItems,
                          onChanged: (value) => setState(() => _selectedCajaDestinoId = value),
                          validator: (value) => value == null ? 'Selecciona la caja destino' : null,
                        ),
                      ],
                    );
                  } 
                  // SI ES INGRESO O EGRESO, MOSTRAMOS UN DROPDOWN
                  else {
                    return DropdownButtonFormField<String>(
                      value: _selectedCajaId,
                      decoration: InputDecoration(
                        labelText: _selectedType == 'Ingreso' ? 'Caja Destino' : 'Caja Origen',
                        prefixIcon: const Icon(Icons.wallet),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                decoration: InputDecoration(
                  labelText: 'Monto (Bs.)',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
                  
              const SizedBox(height: 20),
                  
              TextFormField(
                controller: _conceptoController,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                decoration: InputDecoration(
                  labelText: 'Concepto / Motivo',
                  hintText: 'Describe el motivo de la transacción...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
                  
              const SizedBox(height: 20),
                  
              // Evidencia requerida SOLO para Ingreso o Egreso
              if (_selectedType == 'Ingreso' || _selectedType == 'Egreso') ...[
                Text(
                  'Evidencia (Requerida)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: _evidenciaFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _evidenciaFile!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Toca para añadir foto',
                                style: TextStyle(color: Colors.grey),
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