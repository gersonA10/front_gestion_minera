import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/zoomable_evidence_image.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/partners_entity.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:path/path.dart' as path;


class FilterButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback? onTap;

  const FilterButton({
    super.key,
    required this.text,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colors.blue : const Color(0xffECECEC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class LoanCard extends StatelessWidget {
  final String date;
  final String reason;
  final String amount;
  final String status;
  final String? motivoRechazo;
  final String loanType;
  final double small;

  const LoanCard({
    super.key,
    required this.date,
    required this.reason,
    required this.amount,
    required this.status,
    this.motivoRechazo,
    required this.loanType,
    required this.small,
  });

  Color _getStatusColor(String statusText) {
    switch (statusText.toLowerCase()) {
      case 'pagado':
        return const Color(0xff17A05D);
      case 'aprobado':
        return const Color(0xff2457C5);
      case 'rechazado':
        return const Color(0xffD32F2F);
      case 'en revisión':
      case 'pendiente':
      default:
        return const Color(0xffC47A00);
    }
  }

  Color _getStatusBgColor(String statusText) {
    switch (statusText.toLowerCase()) {
      case 'pagado':
        return const Color(0xffE7F7EE);
      case 'aprobado':
        return const Color(0xffE8F0FE);
      case 'rechazado':
        return const Color(0xffFFEBEE);
      case 'en revisión':
      case 'pendiente':
      default:
        return const Color(0xffFFF4E5);
    }
  }

  void _showRejectionDialog(BuildContext context, ColorScheme colors) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Motivo de rechazo',
                  style: AppTextStyles.mainStyle16Bold(
                    context,
                  ).copyWith(color: colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.red.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.red.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    motivoRechazo ?? 'Sin motivo especificado.',
                    style: AppTextStyles.mainStyle12(
                      context,
                    ).copyWith(color: colors.black, height: 1.4),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Entendido',
                      style: AppTextStyles.mainStyle12Bold(
                        context,
                      ).copyWith(color: colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final colorStatus = _getStatusColor(status);
    final bgStatus = _getStatusBgColor(status);
    final isRejected = status.toLowerCase() == 'rechazado';

    return Card(
      elevation: small * 0.3,
      color: colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isRejected && motivoRechazo != null
            ? () => _showRejectionDialog(context, colors)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FECHA DE REGISTRO',
                      style: AppTextStyles.mainStyleGrey12(context),
                    ),
                    SizedBox(height: small * 0.5),
                    Text(date, style: AppTextStyles.mainStyle12Bold(context)),
                    SizedBox(height: small * 0.5),
                    Text(
                      'Motivo',
                      style: AppTextStyles.mainStyleGrey12(context),
                    ),
                    SizedBox(height: small * 0.25),
                    Text(reason, style: AppTextStyles.mainStyle12Bold(context)),
                    SizedBox(height: small * 0.5),
                    Text(
                      loanType.toLowerCase() == 'gramos'
                          ? 'Gramos'
                          : 'Monto total',
                      style: AppTextStyles.mainStyleGrey12(context),
                    ),
                    SizedBox(height: small * 0.25),
                    Text(amount, style: AppTextStyles.mainStyle16Bold(context)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bgStatus,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: colorStatus,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (isRejected && motivoRechazo != null) ...[
                    SizedBox(height: small * 4.5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_red_eye, color: colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Ver motivo',
                          style: AppTextStyles.mainStyle10Bold(
                            context,
                          ).copyWith(color: colors.red),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchContributionBar extends StatelessWidget {
  final double smallSpacing;
  const SearchContributionBar({super.key, required this.smallSpacing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.whitebajo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              style: AppTextStyles.mainStyle12(context),
              decoration: InputDecoration(
                icon: Icon(Icons.search, size: 20),
                hintText: "Buscar por motivo",
                hintStyle: AppTextStyles.mainStyleGrey12(context),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 10),
              ),
            ),
          ),
        ),
        SizedBox(width: smallSpacing * 0.5),
        Container(
          height: smallSpacing * 2,
          width: smallSpacing * 2.5,
          decoration: BoxDecoration(
            color: colors.blue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.tune, color: colors.white),
        ),
      ],
    );
  }
}

class FilterChipButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const FilterChipButton({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        // alignment: Alignment.ce,
        decoration: BoxDecoration(
          color: active ? const Color(0xff2457C5) : const Color(0xffEDEFF4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class ContributionSummaryCard extends StatelessWidget {
  final double total;
  final double confirmed;
  final double pending;
  final String month;
  final double topadding;
  final double smallSpacing;

  const ContributionSummaryCard({
    super.key,
    required this.total,
    required this.confirmed,
    required this.pending,
    required this.month,
    required this.topadding,
    required this.smallSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(topadding * 0.08),
      decoration: BoxDecoration(
        color: colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Aportado ($month)",
            style: AppTextStyles.mainStyleGrey10(
              context,
            ).copyWith(color: colors.bluebajo1),
          ),

          SizedBox(height: smallSpacing * 0.5),

          Text(
            "\$${total.toStringAsFixed(2)}",
            style: AppTextStyles.mainStyleWhite25Bold(context),
          ),

          SizedBox(height: smallSpacing * 0.5),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "CONFIRMADO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.bluebajo1,
                          fontSize: 7,
                        ),
                      ),
                      Text(
                        "\$${confirmed.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "PENDIENTE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.bluebajo1,
                          fontSize: 7,
                        ),
                      ),
                      Text(
                        "\$${pending.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MonthHeader extends StatelessWidget {
  final String month;
  final int count;

  const MonthHeader({super.key, required this.month, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          month.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          "$count Registros",
          style: const TextStyle(
            color: Color(0xff2457C5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ContributionCard extends StatelessWidget {
  final String date;
  final String motivo;
  final String sistema;
  final String caja;
  final double monto;
  final bool confirmed;

  const ContributionCard({
    super.key,
    required this.date,
    required this.motivo,
    required this.sistema,
    required this.caja,
    required this.monto,
    required this.confirmed,
    required ContributeHistoryDataEntity item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: AppTextStyles.mainStyle10(context)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: confirmed ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  confirmed ? "CONFIRMADO" : "PENDIENTE",
                  style: TextStyle(
                    color: confirmed ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MOTIVO",
                      style: AppTextStyles.mainStyleGrey10(context),
                    ),
                    Text(motivo, style: AppTextStyles.mainStyle12Bold(context)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CAJA", style: AppTextStyles.mainStyleGrey10(context)),
                  SizedBox(
                    width: 150,
                    child: Text(
                      caja,
                      style: AppTextStyles.mainStyle12Bold(context),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("MONTO", style: AppTextStyles.mainStyleGrey10(context)),
                  Text(
                    "\$${monto.toStringAsFixed(2)}",
                    style: AppTextStyles.mainStyleBlue16Bold(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TextLoanScreen extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool enabled;
  final TextInputType? keyboardType;
  const TextLoanScreen({
    super.key,
    required this.hintText,
    this.controller,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          enabled: enabled,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}


class CustomForm extends StatelessWidget {
  const CustomForm({
    super.key,
    required this.smallSpacing,
    required this.colors,
    required this.image,
    required this.onOpenCamera,
    required this.title,
    required this.amountController,
    required this.reasonController,
    required this.applicantController,
  });

  final double smallSpacing;
  final ColorScheme colors;
  final File? image;
  final VoidCallback onOpenCamera;
  final String title;
  final TextEditingController amountController;
  final TextEditingController reasonController;
  final TextEditingController applicantController;

  String get fileName =>
      image != null ? path.basename(image!.path) : 'Ningún archivo seleccionado';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Formulario de solicitud",
            style: AppTextStyles.mainStyle14Bold(context).copyWith(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Completa la información requerida y adjunta un comprobante válido.",
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          Text(title, style: AppTextStyles.mainStyle14Bold(context)),
          const SizedBox(height: 8),
          TextLoanScreen(
            hintText: title == 'Monto' ? "Bs. 0.00" : "Gr. 0.00",
            controller: amountController,
            enabled: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          const SizedBox(height: 16),

          Text("Motivo", style: AppTextStyles.mainStyle14Bold(context)),
          const SizedBox(height: 8),
          TextLoanScreen(
            hintText: "Describe brevemente el motivo",
            controller: reasonController,
            enabled: true,
          ),

          const SizedBox(height: 16),

          Text(
            "Nombre del solicitante",
            style: AppTextStyles.mainStyle14Bold(context),
          ),
          const SizedBox(height: 8),
          TextLoanScreen(
            hintText: UserSession.userName,
            controller: applicantController,
            enabled: false,
          ),

          const SizedBox(height: 20),

          Text("Comprobante", style: AppTextStyles.mainStyle14Bold(context)),
          const SizedBox(height: 10),

          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onOpenCamera,
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: image != null
                      ? colors.primary.withValues(alpha: 0.25)
                      : colors.outline.withValues(alpha: 0.18),
                ),
                color: colors.surfaceContainerHighest.withValues(alpha: 0.28),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 84,
                      height: 84,
                      color: colors.surfaceContainerHighest,
                      child: image != null
                          ? Image.file(image!, fit: BoxFit.cover)
                          : Icon(
                              Icons.camera_alt_rounded,
                              size: 30,
                              color: colors.primary,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          image != null
                              ? "Archivo adjunto"
                              : "Subir comprobante",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                image != null ? "Cambiar imagen" : "Agregar imagen",
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (image != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (_, _, _) =>
                                          FullScreenFileImageViewer(file: image!),
                                      transitionsBuilder:
                                          (_, animation, _, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Ver completa",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class NumericTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;

  const NumericTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
