import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/previous_cycle_card_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class StaffPaymentHistoryScreen extends StatelessWidget {
  const StaffPaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final previousPayments = [
      (
        month: 'Octubre 2023',
        amount: '\$4,250.00',
        paymentDate: '31/10/2023',
      ),
      (
        month: 'Septiembre 2023',
        amount: '\$4,100.00',
        paymentDate: '30/09/2023',
      ),
      (
        month: 'Agosto 2023',
        amount: '\$4,520.15',
        paymentDate: '31/08/2023',
      ),
    ];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.white,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Historial de Pagos',
            style: TextStyle(
              color: TColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.filter_list_rounded,
                color: TColors.textPrimary,
              ),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                labelColor: TColors.primary,
                unselectedLabelColor: TColors.textSecondary,
                indicatorColor: TColors.primary,
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(text: '2024'),
                  Tab(text: '2023'),
                  Tab(text: '2022'),
                  Tab(text: '2021'),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ÚLTIMO PAGO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: TColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              const _LatestPaymentCard(),

              const SizedBox(height: 24),

              const Text(
                'CICLOS ANTERIORES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: TColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previousPayments.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = previousPayments[index];

                  return PreviousCycleCardWidget(
                    month: item.month,
                    amount: item.amount,
                    paymentDate: item.paymentDate,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestPaymentCard extends StatelessWidget {
  const _LatestPaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.appMainColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Noviembre 2023',
                  style: TextStyle(
                    color: TColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: TColors.success.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: TColors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'COMPLETADO',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            '\$5,840.50',
            style: TextStyle(
              color: TColors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: TColors.white,
              ),
              SizedBox(width: 6),
              Text(
                'Pagado el 30/11/2023',
                style: TextStyle(
                  color: TColors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Ver Detalle de Nómina'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.white,
                foregroundColor: TColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}