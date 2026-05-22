import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/custom_alert_widget.dart';

class StaffExpenditureRequestScreen extends StatefulWidget {
  const StaffExpenditureRequestScreen({super.key});

  @override
  State<StaffExpenditureRequestScreen> createState() =>
      _StaffExpenditureRequestScreenState();
}

class _StaffExpenditureRequestScreenState
    extends State<StaffExpenditureRequestScreen> {
  final double _totalAmount = 20000;
  final int _totalEmployeed = 10;
  final double _amountEmployeed = 2000;

  final List<XFile> _pickedImages = [];
  final int _maxFileSize = 10 * 1024 * 1024;
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 20),
        child: AppBar(title: Text('Hacienda Municipal')),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Solicitud de Egreso',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Módulo de Nómina y tesorería',
              style: TextStyle(fontSize: 15, color: TColors.appDisabledColor),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: TColors.appBackgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: TColors.appDisabledColor.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MONTO TOTAL A SOLICITAR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: TColors.appMainDarkColor,
                    ),
                  ),
                  Text(
                    '$_totalAmount BS',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: TColors.appDisabledColor.withValues(alpha: 0.2),
                  ),
                  Row(
                    children: [
                      const Text('Trabajadores Activos'),
                      const Spacer(),
                      Text(
                        '$_totalEmployeed',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Monto Por Trabajador'),
                      const Spacer(),
                      Text(
                        '$_amountEmployeed Bs',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Justificación de la solicitud',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este Campo es Obligatorio';
                }
                return null;
              },
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Descriva el motivo del egreso de nómina...',
                hintStyle: TextStyle(color: TColors.appSecondaryTextColor),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Planilla de Egreso',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: Radius.circular(15),
                color: TColors.appDisabledColor,
                dashPattern: [6, 3],
                strokeWidth: 1,
                padding: EdgeInsets.all(5),
              ),
              child: _pickedImages.isNotEmpty
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(15),
                          child: Image.file(
                            File(_pickedImages.first.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _pickedImages.clear();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: TColors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_forever,
                                color: TColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        _showPickerOptions();
                      },
                      child: Container(
                        height: 70,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: TColors.appMainDarkColor.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Icon(
                                Icons.image,
                                color: TColors.appMainDarkColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Suba un fota de la Nomina',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Requerido'),
                                ],
                              ),
                            ),
                            const Icon(Icons.remove_red_eye_outlined),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: TColors.amberLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: TColors.amber),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Esta solicitud sera enviada al departamento de Haciendo para su revisión y aprobación presupuestaria inmediata.',
                      style: TextStyle(color: TColors.amber, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: TColors.appMainDarkColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_outlined, color: TColors.white, size: 25),
                    SizedBox(width: 10),
                    Text(
                      'Solicitar a Hacienda',
                      style: TextStyle(
                        color: TColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (photo == null) return;
      int size = await photo.length();

      if (size > _maxFileSize) {
        if (!mounted) return;
        CustomAlert.show(
          context,
          title: 'Error',
          message: 'El archivo ${photo.path.split('/').last} supera los 10MB.',
          type: AlertType.error,
        );
        return;
      }
      setState(() {
        _pickedImages.clear();
        _pickedImages.add(photo);
      });
    } catch (e) {
      debugPrint("Error al procesar la imagen: $e");
    }
  }
}
