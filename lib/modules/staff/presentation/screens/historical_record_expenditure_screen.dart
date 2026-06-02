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

  final int _startYear = 2024;
  List<Map<String, String>> get years {
    final int currentYear = DateTime.now().year;

    return List.generate((currentYear - _startYear) + 1, (index) {
      final String yearStr = (_startYear + index).toString();
      return {'label': yearStr, 'value': yearStr};
    });
  }

  final List<Map<String, String>> states = [
    {'label': 'TODOS', 'value': 'TODOS'},
    {'label': 'APROBADO', 'value': 'APPROVED'},
    {'label': 'RECHAZADO', 'value': 'REJECTED'},
    {'label': 'PENDIENTE', 'value': 'IN_REVIEW'},
    {'label': 'PAGADO', 'value': 'PAID'},
  ];
  List<HistoryExpenditureEntity> _historicalDate = [];
  double _cachedTotalExpenses = 0.0;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _cachedHasReachedMax = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _staffBloc = InjectorContainer.getIt<StaffBloc>()
      ..add(
        GetHistoryRecordExpenditureEvent(
          year: DateTime.now().year.toString(),
          state: 'TODOS',
        ),
      );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_cachedHasReachedMax) return;
    if (_isLoadingMore) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      _staffBloc.add(LoadMoreHistoryRecordExpenditureEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.white,
        centerTitle: true,
        title: const Text(
          'Historial de Solicitudes de\nEgresos',
          textAlign: TextAlign.center,
        ),
      ),
      body: BlocProvider.value(
        value: _staffBloc,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
                          year: selectedYear ?? DateTime.now().year.toString(),
                          state: selectedState ?? 'TODOS',
                        ),
                      );
                    },
                    hint: 'Año',
                  ),
                  CustomDropDownWidget(
                    value: selectedState ?? states.first['value']!,
                    items: states,
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
            Expanded(
              child: BlocBuilder<StaffBloc, StaffState>(
                builder: (context, state) {
                  // Actualización de variables de estado
                  if (state is HistoryRecordExpenditureLoaded) {
                    _historicalDate = state.items;
                    _isLoadingMore = false;
                    _cachedHasReachedMax = !state.hasMore;
                    _cachedTotalExpenses = state.totalExpenses;
                  }

                  final isInitialLoading =
                      state is HistoryRecordExpenditureLoading &&
                      _historicalDate.isEmpty;
                  final isLoading = state is HistoryRecordExpenditureLoading;

                  return Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: isInitialLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _historicalDate.isEmpty
                                ? const Center(
                                    child: Text('No hay registros de egresos.'),
                                  )
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      _staffBloc.add(
                                        LoadMoreHistoryRecordExpenditureEvent(),
                                      );
                                    },
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: _historicalDate.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            return CustomCardHistoricalEcpenditureWidget(
                                              history: _historicalDate[index],
                                            );
                                          },
                                    ),
                                  ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                              bottom: 10,
                              top: 7,
                              left: 15,
                              right: 15,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: TColors.appMainColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Resumen',
                                  style: TextStyle(
                                    color: TColors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                const Text(
                                  'Total Egresos',
                                  style: TextStyle(
                                    color: TColors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$_cachedTotalExpenses BS',
                                  style: const TextStyle(
                                    color: TColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isLoading && !isInitialLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.1),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
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
      margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
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
  final List<Map<String, String>> items;
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
              value: e['value'],
              child: Text(
                '$hint: ${e['label']}',
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
