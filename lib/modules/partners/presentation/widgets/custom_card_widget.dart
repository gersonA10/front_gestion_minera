import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/partners_entity.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class CustomCardWidget extends StatelessWidget {
  const CustomCardWidget({
    super.key,
    required this.screenSize,
    required this.topPadding,
    required this.smallSpacing,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Size screenSize;
  final double topPadding;
  final double smallSpacing;
  final String icon;
  final String title;
  final String subtitle;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenSize.height * 0.17,
        width: screenSize.width * 0.43,
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: colors.lead,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(topPadding * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(topPadding * 0.05),
                margin: EdgeInsets.only(top: topPadding * 0.05),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.bajo,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SvgPicture.asset(icon, width: 28, height: 28),
              ),
              SizedBox(height: smallSpacing * 0.8),
              Text(
                title,
                style: AppTextStyles.mainStyle12Bold(context),
                textAlign: TextAlign.start,
              ),
              Text(
                subtitle,
                style: AppTextStyles.mainStyle10(context),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  child: Icon(Icons.info_outline_rounded, color: colors.red, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Motivo de rechazo',
                  style: AppTextStyles.mainStyle16Bold(context).copyWith(color: colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.red.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.red.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    motivoRechazo ?? 'Sin motivo especificado.',
                    style: AppTextStyles.mainStyle12(context).copyWith(color: colors.black, height: 1.4),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Entendido', style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.white)),
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
                    Text('FECHA DE REGISTRO', style: AppTextStyles.mainStyleGrey12(context)),
                    SizedBox(height: small * 0.5),
                    Text(date, style: AppTextStyles.mainStyle12Bold(context)),
                    SizedBox(height: small * 0.5),
                    Text('Motivo', style: AppTextStyles.mainStyleGrey12(context)),
                    SizedBox(height: small * 0.25),
                    Text(reason, style: AppTextStyles.mainStyle12Bold(context)),
                    SizedBox(height: small * 0.5),
                    Text(
                      loanType.toLowerCase() == 'gramos' ? 'Gramos' : 'Monto total', 
                      style: AppTextStyles.mainStyleGrey12(context)
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: bgStatus, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(color: colorStatus, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  if (isRejected && motivoRechazo != null) ...[
                    SizedBox(height: small * 4.5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_red_eye, color: colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text('Ver motivo', style: AppTextStyles.mainStyle10Bold(context).copyWith(color: colors.red)),
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
  const TextLoanScreen({super.key, required this.hintText, this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(smallSpacing * 1.5),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.mainStyle14Bold(context)),
          SizedBox(height: smallSpacing * 1),
          TextLoanScreen(hintText: "Bs. 0.00", controller: amountController),
          SizedBox(height: smallSpacing * 1),
          Text("Motivo", style: AppTextStyles.mainStyle14Bold(context)),
          SizedBox(height: smallSpacing * 1),
          TextLoanScreen(
            hintText: "Escribe el motivo del préstamo",
            controller: reasonController,
          ),
          SizedBox(height: smallSpacing * 1),
          Text(
            "Nombre del solicitante",
            style: AppTextStyles.mainStyle14Bold(context),
          ),
          SizedBox(height: smallSpacing * 1),
          TextLoanScreen(
            hintText: "Los tigresitos",
            controller: applicantController,
          ),
          SizedBox(height: 18),
          Text(
            "Comprobante",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: smallSpacing * 1),
          Row(
            children: [
              GestureDetector(
                onTap: onOpenCamera,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: image != null
                          ? FileImage(image!)
                          : const NetworkImage("https://picsum.photos/200")
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "recibo_pago_042.jpg",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Ver imagen completa",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: smallSpacing * 1),
        ],
      ),
    );
  }
}
