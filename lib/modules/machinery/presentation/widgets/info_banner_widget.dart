import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/type_machinery_entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';

/// Aviso informativo en la parte superior del formulario.
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded,
              color: TColors.appMainColor, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Completa los datos tal como figuran en la placa del fabricante. '
              'Los campos con * son obligatorios.',
              style: TextStyle(
                color: TColors.appMainColor,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector de tipo de maquinaria con estados de carga y error.
class TypeDropdown extends StatelessWidget {
  final TypeMachineryEntity? value;
  final List<TypeMachineryEntity> types;
  final bool enabled;
  final bool loading;
  final bool hasError;

  /// Indica que falló la carga de tipos; muestra un reintento inline.
  final bool loadFailed;
  final VoidCallback? onRetry;
  final ValueChanged<TypeMachineryEntity?> onChanged;

  const TypeDropdown({
    super.key,
    required this.value,
    required this.types,
    required this.onChanged,
    this.enabled = true,
    this.loading = false,
    this.hasError = false,
    this.loadFailed = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final showFailed = loadFailed && !loading;
    final borderColor =
        (hasError || showFailed) ? TColors.danger : TColors.border;

    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            showFailed ? Icons.error_outline_rounded : Icons.category_outlined,
            color: showFailed ? TColors.danger : TColors.iconMuted,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: showFailed
                ? Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'No se pudieron cargar los tipos',
                          style: TextStyle(
                            color: TColors.danger,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onRetry,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded,
                                  color: TColors.appMainColor, size: 17),
                              SizedBox(width: 4),
                              Text(
                                'Reintentar',
                                style: TextStyle(
                                  color: TColors.appMainColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : loading
                ? Row(
                    children: const [
                      Text(
                        'Cargando tipos...',
                        style:
                            TextStyle(color: TColors.hintColor, fontSize: 14),
                      ),
                      Spacer(),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TColors.appMainColor,
                        ),
                      ),
                    ],
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<TypeMachineryEntity>(
                      value: value,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(14),
                      hint: const Text(
                        'Seleccionar tipo...',
                        style:
                            TextStyle(color: TColors.hintColor, fontSize: 14),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: TColors.textSecondary),
                      style: const TextStyle(
                          color: TColors.textPrimary, fontSize: 14.5),
                      items: types
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.name,
                                style: const TextStyle(
                                  color: TColors.textPrimary,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: enabled ? onChanged : null,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Caja de carga de fotografía. Muestra vista previa con opción de cambiar /
/// quitar, o un área punteada para subir cuando no hay imagen.
class PhotoUploadBox extends StatelessWidget {
  final XFile? pickedImage;
  final bool enabled;
  final bool hasError;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const PhotoUploadBox({
    super.key,
    required this.pickedImage,
    required this.onTap,
    this.enabled = true,
    this.hasError = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (pickedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(pickedImage!.path),
              width: double.infinity,
              height: 190,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: enabled ? onTap : null,
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Cambiar',
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
          if (onRemove != null)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: enabled ? onRemove : null,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      );
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: DottedBorderBox(
        color: hasError ? TColors.danger : TColors.dottedBorder,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _PhotoUploadHint(),
          ],
        ),
      ),
    );
  }
}

class _PhotoUploadHint extends StatelessWidget {
  const _PhotoUploadHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        DecoratedBox(
          decoration:
              BoxDecoration(color: TColors.primaryLight, shape: BoxShape.circle),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.add_a_photo_rounded,
                color: TColors.appMainColor, size: 28),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Toca para agregar una foto',
          style: TextStyle(
            color: TColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Cámara o galería · JPG o PNG',
          style: TextStyle(color: TColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Contenedor con borde punteado (color configurable para estado de error).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;

  const DottedBorderBox({
    super.key,
    required this.child,
    this.color = TColors.dottedBorder,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(color),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: TColors.photoUploadBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;

  _DottedBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const double dash = 6;
    const double gap = 4;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final Path path = Path()..addRRect(rrect);

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dash).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
