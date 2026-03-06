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
