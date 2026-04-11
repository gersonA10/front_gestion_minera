import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/entity.dart';

class HistorialCard extends StatelessWidget {
  final RequestHistoryEntity item;
  final VoidCallback? onTapDetail;

  const HistorialCard({super.key, required this.item, this.onTapDetail});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = item.isApproved
        ? TColors.appMainDarkColor
        : TColors.disabledAccount;

    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardTopSection(item: item),
                    const SizedBox(height: 18),
                    _CardInfoSection(item: item),
                    const SizedBox(height: 18),
                    const Divider(
                      thickness: 1,
                      color: TColors.appSurfaceColor,
                      height: 1,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: HistorialDetailButton(onTap: onTapDetail),
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
}

class _CardTopSection extends StatelessWidget {
  final RequestHistoryEntity item;
  const _CardTopSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _UserIconBox(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.solicitante,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'ID: ${item.shortCode}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: TColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        HistorialStatusBadge(
          isApproved: item.isApproved,
          text: item.isApproved ? 'APROBADA' : 'RECHAZADA',
        ),
      ],
    );
  }
}

class _CardInfoSection extends StatelessWidget {
  final RequestHistoryEntity item;
  const _CardInfoSection({required this.item});

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return DateFormat("dd MMM, yyyy • HH:mm", "es").format(localDate);
  }

  String _money(double value) {
    return NumberFormat.currency(
      locale: 'es_BO',
      symbol: 'Bs ',
      decimalDigits: 2,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool rejected = item.isRejected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HistorialInfoLabel(
          text: 'FECHA DE PROCESO',
          color: Color(0xFF7D8393),
        ),
        const SizedBox(height: 6),
        Text(
          _formatDate(item.fechaDecision),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        HistorialInfoLabel(
          text: rejected ? 'MOTIVO DEL RECHAZO' : 'DESCRIPCIÓN',
          color: rejected ? TColors.red : const Color(0xFF7D8393),
        ),
        const SizedBox(height: 6),
        Text(
          rejected
              ? (item.motivoRechazo?.isNotEmpty == true
                    ? item.motivoRechazo!
                    : 'Sin motivo registrado.')
              : item.descripcion,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TColors.textPrimary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        const HistorialInfoLabel(text: 'MONTO', color: Color(0xFF7D8393)),
        const SizedBox(height: 6),
        Text(
          _money(item.monto),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: TColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _UserIconBox extends StatelessWidget {
  const _UserIconBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: Color(0xFF637092),
        size: 24,
      ),
    );
  }
}

class HistorialInfoLabel extends StatelessWidget {
  final String text;
  final Color color;
  const HistorialInfoLabel({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.1,
      ),
    );
  }
}

class HistorialStatusBadge extends StatelessWidget {
  final bool isApproved;
  final String text;

  const HistorialStatusBadge({
    super.key,
    required this.isApproved,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: isApproved ? TColors.appMainDarkColor : TColors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isApproved ? TColors.white : TColors.white,
        ),
      ),
    );
  }
}

class HistorialDetailButton extends StatelessWidget {
  final VoidCallback? onTap;
  const HistorialDetailButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      // color: TColors.buttonSoft,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver Detalle',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: TColors.appMainDarkColor,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: TColors.appMainDarkColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
