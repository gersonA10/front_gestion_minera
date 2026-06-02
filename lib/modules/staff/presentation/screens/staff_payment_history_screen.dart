import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/previous_cycle_card_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class StaffPaymentHistoryScreen extends StatefulWidget {
  const StaffPaymentHistoryScreen({super.key});

  @override
  State<StaffPaymentHistoryScreen> createState() =>
      _StaffPaymentHistoryScreenState();
}

class _StaffPaymentHistoryScreenState extends State<StaffPaymentHistoryScreen> {
  late int selectedYear;
  final List<int> years = [2024, 2023, 2022, 2021];

  @override
  void initState() {
    super.initState();
    selectedYear = 2024;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.textFieldBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Historial de Pagos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TColors.appMainDarkColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: TColors.appMainDarkColor),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: TColors.white,
            height: 48,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final selected = selectedYear == year;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedYear = year;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected
                              ? TColors.appMainColor
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? TColors.appMainColor
                            : TColors.appDisabledColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'ÚLTIMO PAGO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TColors.appDisabledColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TColors.appMainColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: TColors.appMainColor,
                        blurRadius: 12,
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
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: TColors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: TColors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'COMPLETADO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: TColors.white,
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
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Pagado el 30/11/2023',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.white,
                            foregroundColor: TColors.appMainColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text(
                            'Ver Detalle de Nómina',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'CICLOS ANTERIORES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TColors.appDisabledColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = [
                      {
                        'period': 'Octubre 2023',
                        'payroll_type': 'Mensual',
                        'total_amount': 4250.00,
                        'payment_date': '31/10/2023',
                        'status': 'PAGADO',
                      },
                      {
                        'period': 'Septiembre 2023',
                        'payroll_type': 'Mensual',
                        'total_amount': 4100.00,
                        'payment_date': '30/09/2023',
                        'status': 'PAGADO',
                      },
                      {
                        'period': 'Agosto 2023',
                        'payroll_type': 'Mensual',
                        'total_amount': 4520.15,
                        'payment_date': '31/08/2023',
                        'status': 'PENDIENTE',
                      },
                    ];
                    return PreviousCycleCardWidget(
                      period: data[index]['period'] as String,
                      payrollType: data[index]['payroll_type'] as String,
                      totalAmount: data[index]['total_amount'] as double,
                      paymentDate: data[index]['payment_date'] as String,
                      status: data[index]['status'] as String,
                      onTap: () {},
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
