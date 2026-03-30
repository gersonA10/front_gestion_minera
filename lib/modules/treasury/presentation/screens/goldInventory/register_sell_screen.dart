import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/goldInventory/registerSell/submit_button_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/widgets/upload_file_widget.dart';
import '../../widgets/widgtes.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────

@RoutePage()
class RegisterSellScreen extends StatelessWidget {
  const RegisterSellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectorContainer.getIt<TreasuryBloc>(),
      child: const _RegisterSellBody(),
    );
  }
}

class _RegisterSellBody extends StatefulWidget {
  const _RegisterSellBody();

  @override
  State<_RegisterSellBody> createState() => _RegisterSellBodyState();
}

class _RegisterSellBodyState extends State<_RegisterSellBody> {
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _buyerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  double get _estimatedTotal {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return weight * price;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: TColors.appMainColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
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
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF295AF5),
                ),
                title: const Text('Tomar Foto'),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      CustomAlert.show(
        context,
        title: 'Atención',
        message: 'Debe adjuntar un comprobante de venta',
        type: AlertType.error,
      );
      return;
    }
    final grams = double.parse(_weightController.text);
    context.read<TreasuryBloc>().add(PreviewSaleEvent(gramsToSell: grams));
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _buyerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TreasuryBloc, TreasuryState>(
      listener: (context, state) {
        if (state is SalePreviewLoaded) {
          context.router.push(
            SellPreviewRoute(
              previewData: state.preview,
              salesDate: _isoDate(_selectedDate),
              buyer: _buyerController.text.trim(),
              totalGramsSold: double.parse(_weightController.text),
              priceBsPerGram: double.parse(_priceController.text),
              comprobanteFilePath: _selectedImage!.path,
            ),
          );
        } else if (state is SalePreviewError) {
          CustomAlert.show(
            context,
            title: 'Error',
            message: state.message,
            type: AlertType.error,
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          builder: (context, state) {
            final isLoading = state is SalePreviewLoading;
            return Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  FieldLabel(text: 'Comprador'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _buyerController,
                    style: TextStyle(
                      fontSize: 14,
                      color: TColors.appMainTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(hint: 'Nombre del comprador'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  FieldLabel(text: 'Fecha de Venta'),
                  const SizedBox(height: 8),
                  TapField(
                    text: _formatDate(_selectedDate),
                    icon: Icons.calendar_today_rounded,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 20),
                  FieldLabel(text: 'Peso a Vender (g)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _weightController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.appMainTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: '0.00',
                      suffix: const Padding(
                        padding: EdgeInsets.only(right: 14),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            'g',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: TColors.appSecondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if ((double.tryParse(v) ?? 0) <= 0) {
                        return 'Ingrese un peso válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  FieldLabel(text: 'Precio por Gramo (Bs)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.appMainTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: '0.00',
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            'Bs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: TColors.appSecondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if ((double.tryParse(v) ?? 0) <= 0) {
                        return 'Ingrese un precio válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  TotalCard(total: _estimatedTotal),
                  const SizedBox(height: 20),
                  FieldLabel(text: 'Comprobante de Venta'),
                  const SizedBox(height: 8),
                  UploadFileWidget(
                    onTap: _showPickerOptions,
                    selectedImage: _selectedImage,
                    onRemoveImage: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                  SubmitButton(
                    isLoading: isLoading,
                    onTap: isLoading ? null : _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        color: TColors.appBackgroundColor,
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TColors.appSurfaceColor),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.router.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: TColors.appMainTextColor,
                    ),
                  ),
                ),
                const Text(
                  'Registrar Venta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: TColors.appMainTextColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  String? hint,
  Widget? suffix,
  Widget? prefix,
  bool hasError = false,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontSize: 14,
      color: TColors.disabled,
      fontWeight: FontWeight.w500,
    ),
    suffixIcon: suffix,
    prefixIcon: prefix,
    filled: true,
    fillColor: TColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: TColors.red),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: hasError ? TColors.red : TColors.appSurfaceColor,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: hasError ? TColors.disabledAccount : TColors.appSurfaceColor,
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: TColors.danger, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: TColors.danger, width: 1.5),
    ),
  );
}
