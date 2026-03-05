import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
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
  final IconData icon;
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
                child: Icon(
                  icon,
                  size: smallSpacing * 1.5,
                  color: Theme.of(context).colorScheme.amber,
                ),
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
  final bool isPaid;
  final double small;

  const LoanCard({
    super.key,
    required this.date,
    required this.reason,
    required this.amount,
    required this.isPaid,
    required this.small,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: small * 0.3,
      color: colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FECHA DE REGISTRO',
                  style: AppTextStyles.mainStyleGrey12(context),
                ),
                SizedBox(height: small * 0.5),
                Text(date, style: AppTextStyles.mainStyle12Bold(context)),
                SizedBox(height: small * 0.5),
                Text('Motivo', style: AppTextStyles.mainStyleGrey12(context)),
                SizedBox(height: small * 0.25),
                Text(reason, style: AppTextStyles.mainStyle12Bold(context)),
                SizedBox(height: small * 0.5),
                Text(
                  'Monto total',
                  style: AppTextStyles.mainStyleGrey12(context),
                ),
              ],
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
                    color: isPaid
                        ? const Color(0xffE7F7EE)
                        : const Color(0xffFFF4E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPaid ? 'PAGADO' : 'PENDIENTE',
                    style: TextStyle(
                      color: isPaid
                          ? const Color(0xff17A05D)
                          : const Color(0xffC47A00),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                SizedBox(height: small * 3.5),

                Text(amount, style: AppTextStyles.mainStyle16Bold(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
