
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/type_machinery_entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: TColors.infoBannerBg,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: TColors.textPrimary, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: TColors.textPrimary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Asegúrese de que todos los campos técnicos coincidan '
              'con la placa del fabricante.',
              style: TextStyle(
                color: TColors.textPrimary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool enabled;

  const CustomTextField({super.key, 
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      style: const TextStyle(fontSize: 14, color: TColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: TColors.hintColor, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TColors.textPrimary, width: 1.5),
        ),
        filled: true,
        fillColor: TColors.surface,
      ),
    );
  }
}

class TypeDropdown extends StatelessWidget {
  final TypeMachineryEntity? value;
  final List<TypeMachineryEntity> types;
  final bool enabled;
  final ValueChanged<TypeMachineryEntity?> onChanged;

  const TypeDropdown({super.key, 
    required this.value,
    required this.types,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TypeMachineryEntity>(
          value: value,
          isExpanded: true,
          hint: const Text(
            'Seleccionar tipo...',
            style: TextStyle(color: TColors.hintColor, fontSize: 14),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: TColors.textPrimary,
          ),
          items: types
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(
                    t.name,
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

class PhotoUploadBox extends StatelessWidget {
  final XFile? pickedImage;
  final bool enabled;
  final VoidCallback onTap;

  const PhotoUploadBox({super.key, 
    required this.pickedImage,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: pickedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(pickedImage!.path),
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            )
          : DottedBorderBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: TColors.iconMuted,
                    size: 36,
                  ),
                  SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Haz clic para subir',
                          style: TextStyle(
                            color: TColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: ' o arrastra y suelta',
                          style: TextStyle(
                            color: TColors.iconMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PNG, JPG o PDF (MÁX. 10MB)',
                    style: TextStyle(color: TColors.hintColor, fontSize: 11),
                  ),
                ],
              ),
            ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: TColors.photoUploadBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dash = 6;
    const double gap = 4;
    final Paint paint = Paint()
      ..color = TColors.dottedBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    final Path path = Path()..addRRect(rrect);

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dash).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
