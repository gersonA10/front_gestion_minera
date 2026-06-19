import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

/// Imagen de red con placeholder *shimmer* animado, fundido de entrada y
/// un fallback limpio cuando no hay URL o falla la descarga.
///
/// Reemplaza el uso del GIF de carga (`loadingb.gif`) por algo coherente
/// con los skeletons del resto de la app.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData errorIcon;
  final double errorIconSize;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorIcon = Icons.image_not_supported_rounded,
    this.errorIconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    if (!hasUrl) {
      return _ImageFallback(
        width: width,
        height: height,
        icon: errorIcon,
        iconSize: errorIconSize,
      );
    }

    // El shimmer vive DETRÁS de la imagen; la imagen se funde encima.
    // Así nunca hay un salto brusco entre placeholder e imagen final.
    return Stack(
      fit: StackFit.passthrough,
      children: [
        const Positioned.fill(child: _ShimmerBox()),
        Image.network(
          url!,
          width: width,
          height: height,
          fit: fit,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) => _ImageFallback(
            width: width,
            height: height,
            icon: errorIcon,
            iconSize: errorIconSize,
          ),
        ),
      ],
    );
  }
}

/// Caja con efecto de pulso usada como placeholder de imagen.
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();
  late final Animation<double> _a =
      CurvedAnimation(parent: _ac, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, _) {
        final c = Color.lerp(
          const Color(0xFFEAEDF2),
          const Color(0xFFF6F8FB),
          _a.value,
        )!;
        return ColoredBox(color: c);
      },
    );
  }
}

/// Fallback limpio cuando no hay imagen disponible.
class _ImageFallback extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;
  final double iconSize;

  const _ImageFallback({
    this.width,
    this.height,
    required this.icon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: TColors.background,
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: TColors.iconMuted),
    );
  }
}
