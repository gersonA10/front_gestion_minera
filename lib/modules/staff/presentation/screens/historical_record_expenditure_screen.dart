import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

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
  final List<String> years = ['2023', '2024', '2025', '2026'];
  final List<String> states = ['Todos', 'Aprobado', 'Rechazado', 'Pendiente'];

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
      body: Padding(
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
                    onChanged: (value) => setState(() => selectedYear = value),
                    hint: 'Año',
                  ),
                  CustomDropDownWidget(
                    value: selectedState ?? states.first,
                    items: states,
                    onChanged: (value) => setState(() => selectedState = value),
                    hint: 'Estado',
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.all(13),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ciclo de nómina'),
                                  Text('Mayo 2026'),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: TColors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Aprobado',
                                  style: TextStyle(color: TColors.white),
                                ),
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
                                      '\$ 45000.00 BS',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Monto Aprobado'),
                                    Text(
                                      '\$ 45000.00 BS',
                                      style: TextStyle(
                                        color: TColors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: TColors.colorBorderInfo),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 16,),
                              SizedBox(width: 5),
                              Text('Solicitado: 15 Oct'),
                              SizedBox(width: 5),
                              Icon(Icons.circle,size: 6,),
                              SizedBox(width: 5),
                              Text('Respondito: 20 Oct'),
                            ],
                          ),
                          
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 20),
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
                  Text(
                    '\$ 542350.00 BS',
                    style: TextStyle(
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
