import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';

@RoutePage()
class HistoricalRecordExpenditureScreen extends StatefulWidget {
  const HistoricalRecordExpenditureScreen({super.key});

  @override
  State<HistoricalRecordExpenditureScreen> createState() =>
      _HistoricalRecordExpenditureScreenState();
}

class _HistoricalRecordExpenditureScreenState
    extends State<HistoricalRecordExpenditureScreen> {
  String? selectedYear;
  String? selectedState;
  late final StaffBloc _staffBloc;
  final List<String> years = ['2023', '2024', '2025', '2026'];
  final List<Map<String, String>> states = [
    {'value': 'TODOS', 'label': 'TODOS'},
    {'value': 'APROBADO', 'label': 'APPROVED'},
    {'value': 'RECHAZADO', 'label': 'REJECTED'},
    {'value': 'PENDIENTE', 'label': 'IN_REVIEW'},
    {'value': 'PAGADO', 'label': 'PAID'},
  ];
  List<HistoryExpenditureEntity> _historicalDate = [];

  @override
  void initState() {
    super.initState();
    _staffBloc = InjectorContainer.getIt<StaffBloc>()
      ..add(
        GetHistoryRecordExpenditureEvent(
          year: DateTime.now().year.toString(),
          state: 'TODOS',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.white,
        centerTitle: true,
        title: Text(
          'Historial de Solicitudes de\nEgresos',
          textAlign: TextAlign.center,
        ),
      ),
      body: BlocProvider.value(
        value: _staffBloc,
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsetsGeometry.symmetric(vertical: 15),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomDropDownWidget(
                      value: selectedYear ?? DateTime.now().year.toString(),
                      items: years,
                      onChanged: (value) {
                        setState(() => selectedYear = value);
                        _staffBloc.add(
                          GetHistoryRecordExpenditureEvent(
                            year:
                                selectedYear ?? DateTime.now().year.toString(),
                            state: selectedState ?? 'TODOS',
                          ),
                        );
                      },
                      hint: 'Año',
                    ),
                    CustomDropDownWidget(
                      value: selectedState ?? states.first['value']!,
                      items: states.map((e) => e['value']!).toList(),
                      onChanged: (value) {
                        setState(() => selectedState = value);
                        _staffBloc.add(
                          GetHistoryRecordExpenditureEvent(
                            year: selectedYear ?? DateTime.now().year.toString(),
                            state: selectedState ?? 'TODOS',
                          ),
                        );
                      },
                      hint: 'Estado',
                    ),
                  ],
                ),
              ),
              BlocBuilder<StaffBloc, StaffState>(
                builder: (context, state) {
                  if (state is HistoryRecordExpenditureLoading) {
                    return Expanded(child: const Center(child: CircularProgressIndicator()));
                  }
                  if (state is HistoryRecordExpenditureLoaded) {
                    _historicalDate = state.items;
                    if (state.items.isEmpty) {
                      return Expanded(
                        child: const Center(
                          child: Text('No hay registros de egresos.'),
                        ),
                      );
                    }
                  }
                  final isLoading = state is HistoryRecordExpenditureLoading;
                  if (_historicalDate.isEmpty) {
                    if (isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Expanded(
                      child: const Center(
                        child: Text('No hay registros de egresos ahora.'),
                      ),
                    );
                  }
                  final historical = _historicalDate;
                  return Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: historical.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CustomCardHistoricalEcpenditureWidget(
                            history: historical[index],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10, top: 7),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TColors.appMainColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen',
                      style: TextStyle(color: TColors.white, fontSize: 15),
                    ),
                    Text(
                      'Total Egresos',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    BlocBuilder<StaffBloc, StaffState>(
                      builder: (context, state) {
                        double totalExpenses = 0;
                        if (state is HistoryRecordExpenditureLoaded) {
                          totalExpenses = state.totalExpenses;
                        }
                        final isLoading =
                            state is HistoryRecordExpenditureLoading;
                        return isLoading
                            ? const SizedBox(
                                height: 34,
                                width: 34,
                                child: CircularProgressIndicator(
                                  color: TColors.white,
                                ),
                              )
                            : Text(
                                '$totalExpenses BS',
                                style: TextStyle(
                                  color: TColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCardHistoricalEcpenditureWidget extends StatelessWidget {
  final HistoryExpenditureEntity history;
  const CustomCardHistoricalEcpenditureWidget({
    super.key,
    required this.history,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(13),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ciclo de nómina'),
                    Text(
                      history.payrollCycle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              if (history.status == 'APROBADO')
                BadgeCardCustomWidget(
                  icon: Icons.check_circle_outline,
                  text: 'Aprobado',
                  color: TColors.success,
                ),
              if (history.status == 'PAGADO')
                BadgeCardCustomWidget(
                  icon: Icons.check_circle_outline,
                  text: 'Pagado',
                  color: TColors.success,
                ),
              if (history.status == 'PENDIENTE')
                BadgeCardCustomWidget(
                  icon: Icons.access_time,
                  text: 'Pendiente',
                  color: TColors.amber,
                ),
              if (history.status == 'RECHAZADO')
                BadgeCardCustomWidget(
                  icon: Icons.cancel_outlined,
                  text: 'Rechazado',
                  color: TColors.red,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Solicitado'),
                    Text(
                      '\$ ${history.totalRequested}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    history.status == 'APROBADO' || history.status == 'PAGADO'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monto Aprobado'),
                          Text(
                            '\$ ${history.approvedAmount}',
                            style: TextStyle(
                              color: TColors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : history.status == 'RECHAZADO'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Motivo'),
                          Text(
                            history.rejectReason ?? 'No especificado',
                            style: TextStyle(
                              color: TColors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
              ),
            ],
          ),
          const Divider(color: TColors.colorBorderInfo),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 11),
              const SizedBox(width: 5),
              Text('Solicitado: 15 Oct', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              if (history.status == 'APROBADO')
                Row(
                  children: [
                    Icon(Icons.circle, size: 6),
                    const SizedBox(width: 5),
                    Text('Respondido: 20 Oct', style: TextStyle(fontSize: 12)),
                  ],
                ),
              if (history.status == 'RECHAZADO')
                Row(
                  children: [
                    Icon(Icons.circle, size: 6),
                    const SizedBox(width: 5),
                    Text('Rechazado: 20 Oct', style: TextStyle(fontSize: 12)),
                  ],
                ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: history.status != 'Pendiente'
                    ? TColors.appBackgroundColor
                    : TColors.uploadBlue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver Detalles',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: history.status != 'Pendiente'
                          ? TColors.appMainColor
                          : TColors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_outlined,
                    size: 16,
                    color: history.status != 'Pendiente'
                        ? TColors.appMainColor
                        : TColors.white,
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

class BadgeCardCustomWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const BadgeCardCustomWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CustomDropDownWidget extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  const CustomDropDownWidget({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.border, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                '$hint: $e',
                style: TextStyle(
                  fontSize: 13,
                  color: TColors.darkBackgroundAccount,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
