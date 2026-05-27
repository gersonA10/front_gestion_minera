import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeline_tile/timeline_tile.dart';

@RoutePage()
class AssistanceDetailScreen extends StatefulWidget {
  const AssistanceDetailScreen({super.key});

  @override
  State<AssistanceDetailScreen> createState() => _AssistanceDetailScreenState();
}

class _AssistanceDetailScreenState extends State<AssistanceDetailScreen> {
  final _nameEmployee = 'Carlos Rodriguez';
  final _role = 'Operador de Maquinaria';
  final _nid = '12345678';
  final double _hourTotal = 9;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        title: Text('Detalles de Asistencia'),
        actions: [
          IconButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(text: 'Compartir Con', subject: 'Compartir datos'),
              );
            },
            icon: Icon(
              Icons.share_outlined,
              color: TColors.appBackgroundDarkColor,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: TColors.uploadBlue),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _nameEmployee,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _role,
                          style: TextStyle(color: TColors.appDisabledDarkColor),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: TColors.uploadBlue.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'ID: $_nid',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.appNewDarkMainColor,
                            ),
                          ),
                        ),
                        Divider(color: TColors.disabled.withValues(alpha: 0.3)),
                        Row(
                          children: [
                            CardDateTurnWidget(
                              isDate: true,
                              date: '25 May, 2026',
                            ),
                            SizedBox(
                              height: 40,
                              child: VerticalDivider(
                                color: TColors.disabled.withValues(alpha: 0.3),
                              ),
                            ),
                            CardDateTurnWidget(isDate: false, turn: 'Mañana'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: TColors.green.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: TColors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: TColors.green),
                          const SizedBox(width: 5),
                          Text(
                            'Finalizado',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.appNewDarkMainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: TColors.uploadBlue,
                        size: 19,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Cronologia del Turno',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  TimelineCustomWidget(
                    isFirst: true,
                    pointColor: TColors.uploadBlue,
                    child: _CardTimeLineInOutWidget(isIN: true, hour: '06:55'),
                  ),
                  TimelineCustomWidget(
                    pointColor: TColors.grayText,
                    size: 10,
                    child: Container(
                      padding: EdgeInsets.only(left: 18, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Refrigerio'),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: TColors.appBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.restaurant, size: 15),
                                SizedBox(width: 4),
                                Text(
                                  '45 min',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TimelineCustomWidget(
                    isLast: true,
                    pointColor: TColors.bgColor,
                    child: _CardTimeLineInOutWidget(isIN: false, hour: '16:45'),
                  ),
                  Divider(color: TColors.appBackgroundColor),
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HORAS EFECTIVAS',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.disabled,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Excluyendo refrigerio',
                            style: TextStyle(
                              fontSize: 10,
                              color: TColors.disabled,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            _hourTotal.toString(),
                            style: TextStyle(
                              fontSize: 30,
                              color: TColors.uploadBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'hrs',
                            style: TextStyle(
                              fontSize: 15,
                              color: TColors.disabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_outlined, color: TColors.uploadBlue),
                      SizedBox(width: 5),
                      Text(
                        'Validación',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.fiber_manual_record_sharp),
                            Text('Firma Supervisor'),
                          ],
                        ),
                      ),
                      SizedBox(height: 50, child: VerticalDivider()),
                      Expanded(
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: TColors.uploadBlue.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: TColors.uploadBlue,
                                  size: 25,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Sector Norte',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Lat: -22.45, Lon: -68.90',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Ink(
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {},
                      splashColor: TColors.disabled,
                      borderRadius: BorderRadius.circular(15),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.print_outlined,
                              color: TColors.appBackgroundDarkColor,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Reporte',
                              style: TextStyle(
                                color: TColors.appMainTextColor,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Ink(
                    decoration: BoxDecoration(
                      color: TColors.timelineBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(15),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, color: TColors.white),
                            SizedBox(width: 5),
                            Text(
                              'Corrección',
                              style: TextStyle(
                                color: TColors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _CardTimeLineInOutWidget extends StatelessWidget {
  final bool isIN;
  final String hour;
  const _CardTimeLineInOutWidget({
    super.key,
    required this.isIN,
    required this.hour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: isIN
            ? TColors.uploadBlue.withValues(alpha: 0.1)
            : TColors.appBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isIN ? 'Entrada Registrada' : 'Salida Registrada',
                style: TextStyle(
                  color: isIN ? TColors.uploadBlue : TColors.appMainTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Lugar'),
            ],
          ),
          Row(
            children: [
              Text(
                hour,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(width: 4),
              Text('AM'),
            ],
          ),
        ],
      ),
    );
  }
}

class TimelineCustomWidget extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Color pointColor;
  final Widget child;
  final double size;
  const TimelineCustomWidget({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    required this.pointColor,
    required this.child,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      alignment: TimelineAlign.manual,
      lineXY: 0.1,
      indicatorStyle: IndicatorStyle(width: size, color: pointColor),
      beforeLineStyle: const LineStyle(color: TColors.grayText, thickness: 2),
      afterLineStyle: const LineStyle(color: TColors.grayText, thickness: 2),
      endChild: child,
    );
  }
}

class CardDateTurnWidget extends StatelessWidget {
  final bool isDate;
  final String date;
  final String turn;
  const CardDateTurnWidget({
    super.key,
    required this.isDate,
    this.date = '',
    this.turn = '',
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: Column(
          children: [
            Text(
              isDate ? 'Fecha' : 'Turno',
              style: TextStyle(color: TColors.disabled, fontSize: 15),
            ),
            Text(
              isDate ? date : turn,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
