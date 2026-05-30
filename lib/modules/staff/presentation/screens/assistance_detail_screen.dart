import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/data/models/models.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../utils/assets.dart';
import '../bloc/staff_bloc.dart';

@RoutePage()
class AssistanceDetailScreen extends StatefulWidget {
  final String idEmployee;
  const AssistanceDetailScreen({super.key, required this.idEmployee});

  @override
  State<AssistanceDetailScreen> createState() => _AssistanceDetailScreenState();
}

class _AssistanceDetailScreenState extends State<AssistanceDetailScreen> {
  final isimage = false;
  late final StaffBloc _staffBloc;
  EmployeeDetailAssistanceModel? _employeeCache;

  String formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Agos',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _staffBloc = InjectorContainer.getIt<StaffBloc>()
      ..add(GetDetailAssistanceEmployeeEvent(employeeId: widget.idEmployee));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _staffBloc,
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          final isLoading = state is DetailAssistanceEmployeeLoading;
          if (isLoading && _employeeCache == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: TColors.white,
                title: Text('Detalles de Asistencia'),
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is DetailAssistanceEmployeeLoaded) {
            _employeeCache = state.employee;
          }
          if (_employeeCache == null) {
            if (isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is DetailAssistanceEmployeeError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          }
          final employeeDetail = _employeeCache!;
          final employeeDate = employeeDetail.employee;
          final chronology = employeeDetail.chronology;
          final validation = employeeDetail.validation;
          return Scaffold(
            backgroundColor: TColors.appBackgroundColor,
            appBar: AppBar(
              backgroundColor: TColors.white,
              title: Text('Detalles de Asistencia'),
              actions: [
                IconButton(
                  onPressed: () async {
                    try {
                      final pw.Document myPdf = await _generarPdf(
                        context,
                        employeeDetail,
                        true,
                      );
                      final Uint8List pdfBytes = await myPdf.save();
                      final String fileName =
                          'Reporte_Asistencia_${employeeDate.fullName.replaceAll(' ', '_')}.pdf';
                      final XFile pdfFile = XFile.fromData(
                        pdfBytes,
                        name: fileName,
                        mimeType: 'application/pdf',
                      );
                      SharePlus.instance.share(
                        ShareParams(
                          text:
                              'Reporte de Asistencia de ${employeeDate.fullName}',
                          subject: 'Compartir datos',
                          files: [pdfFile],
                        ),
                      );
                    } catch (_) {}
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
                              ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(40),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  color: TColors.appBackgroundColor,
                                  child: FadeInImage.assetNetwork(
                                    placeholder: AssetImageApp.getIconLoading,
                                    image:
                                        employeeDetail.employee.photoUrl ?? '',
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (_, _, _) {
                                      return Center(
                                        child: const Icon(
                                          Icons.person,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                employeeDate.fullName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                employeeDate.position,
                                style: TextStyle(
                                  color: TColors.appDisabledDarkColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: TColors.uploadBlue.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'NID: ${employeeDate.nationalId}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: TColors.appNewDarkMainColor,
                                  ),
                                ),
                              ),
                              Divider(
                                color: TColors.disabled.withValues(alpha: 0.3),
                              ),
                              Row(
                                children: [
                                  CardDateTurnWidget(
                                    isDate: true,
                                    date: formatDate(
                                      DateFormat(
                                        'yyyy-MM-dd',
                                      ).parse(employeeDetail.date),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: VerticalDivider(
                                      color: TColors.disabled.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  CardDateTurnWidget(
                                    isDate: false,
                                    turn: employeeDetail.assignedShift,
                                  ),
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
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: TColors.green,
                                ),
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
                          child: _CardTimeLineInOutWidget(
                            isIN: true,
                            hour: chronology.checkIn.time!.substring(0, 5),
                            place: (chronology.checkOut.location!.isEmpty)
                                ? 'Lugar no registrado'
                                : chronology.checkOut.location!,
                            isNotRegistered: chronology.checkIn.time == '',
                          ),
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
                                      (chronology.breakMinutes == 0)
                                          ? Text('Sin Refrigerio')
                                          : Text(
                                              '${chronology.breakMinutes} min',
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
                          child: _CardTimeLineInOutWidget(
                            isIN: false,
                            hour: (chronology.checkOut.time == '')
                                ? '00:00'
                                : chronology.checkOut.time!.substring(0, 5),
                            place: (chronology.checkOut.location!.isEmpty)
                                ? 'Lugar no registrado'
                                : chronology.checkOut.location!,
                            isNotRegistered: chronology.checkOut.time == '',
                          ),
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
                                (chronology.netHoursWorked == 0)
                                    ? Text('No registrado')
                                    : Text(
                                        chronology.netHoursWorked.toString(),
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: TColors.uploadBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                const SizedBox(width: 5),
                                Text(
                                  (chronology.netHoursWorked == 0) ? '' : 'hrs',
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
                            Icon(
                              Icons.verified_outlined,
                              color: TColors.uploadBlue,
                            ),
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
                                  Container(
                                    width: 100,
                                    height: 70,
                                    color: TColors.appBackgroundColor,
                                    child: FadeInImage.assetNetwork(
                                      placeholder: AssetImageApp.getIconLoading,
                                      image:
                                          validation
                                              .supervisorSignatureUrl
                                              .isNotEmpty
                                          ? validation.supervisorSignatureUrl
                                          : '',
                                      fit: BoxFit.cover,
                                      imageErrorBuilder: (_, _, _) {
                                        return Center(
                                          child: const Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 30,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Firma Supervisor',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                      (chronology.checkOut.location!.isEmpty)
                                          ? 'Lugar no registrado'
                                          : chronology.checkOut.location!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Lat: ${validation.geolocation.checkOut.latitude}, Lon: ${validation.geolocation.checkOut.longitude}',
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
                            onTap: () {
                              _generarPdf(context, employeeDetail, false);
                            },
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
                        // const SizedBox(width: 20),
                        // Ink(
                        //   decoration: BoxDecoration(
                        //     color: TColors.timelineBlue,
                        //     borderRadius: BorderRadius.circular(15),
                        //   ),
                        //   child: InkWell(
                        //     onTap: () {

                        //     },
                        //     borderRadius: BorderRadius.circular(15),
                        //     child: const Padding(
                        //       padding: EdgeInsets.symmetric(
                        //         horizontal: 20,
                        //         vertical: 10,
                        //       ),
                        //       child: Row(
                        //         children: [
                        //           Icon(
                        //             Icons.edit_outlined,
                        //             color: TColors.white,
                        //           ),
                        //           SizedBox(width: 5),
                        //           Text(
                        //             'Corrección',
                        //             style: TextStyle(
                        //               color: TColors.white,
                        //               fontSize: 18,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<pw.Document> _generarPdf(
    BuildContext context,
    EmployeeDetailAssistanceModel employeeDetail,
    bool isShared,
  ) async {
    final pdf = pw.Document();
    pw.ImageProvider? fotoEmpleado;
    final photoUrl = employeeDetail.employee.photoUrl;
    if (photoUrl != null &&
        photoUrl.trim().isNotEmpty &&
        photoUrl.startsWith('http')) {
      try {
        fotoEmpleado = await networkImage(photoUrl);
      } catch (_) {
        fotoEmpleado = null;
      }
    }
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 100, vertical: 50),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 30),
            pw.Row(
              children: [
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#000000')),
                  ),
                  child: (fotoEmpleado != null)
                      ? pw.Image(
                          fotoEmpleado,
                          width: 120,
                          height: 120,
                          fit: pw.BoxFit.cover,
                        )
                      : pw.Container(
                          width: 120,
                          height: 120,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '[Sin Foto]',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                ),
                pw.SizedBox(width: 60),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 15),
                    pw.Text(
                      employeeDetail.employee.fullName,
                      style: pw.TextStyle(
                        fontSize: 25,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      employeeDetail.employee.position,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 10),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(15),
                      ),
                      child: pw.Text(
                        'ID: ${employeeDetail.employee.nationalId}',
                        style: pw.TextStyle(fontSize: 15),
                      ),
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 20),
                          child: pw.Center(
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Fecha',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                pw.Text(
                                  formatDate(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).parse(employeeDetail.date),
                                  ),
                                  style: pw.TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.Container(
                          width: 1,
                          height: 40,
                          color: PdfColors.grey,
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 20),
                          child: pw.Center(
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Turno',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                pw.Text(
                                  employeeDetail.assignedShift,
                                  style: pw.TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 50),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Cronologia del Turno',
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(30),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 12,
                            height: 12,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Text(
                            'Entrada Registrada - ${employeeDetail.chronology.checkIn.time!.substring(0, 5)} AM',
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 30),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 10,
                            height: 10,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Text(
                            employeeDetail.chronology.breakMinutes == 0
                                ? 'Sin Refrigerio'
                                : 'Tiempo de Refrigerio - ${employeeDetail.chronology.breakMinutes} ${(int.parse(employeeDetail.chronology.checkOut.time!.substring(0, 2)) > 11) ? 'PM' : 'AM'}',
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 30),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 12,
                            height: 12,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.black,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Text(
                            (!(employeeDetail.chronology.checkOut.time != null))
                                ? 'Salida Registrada - ${employeeDetail.chronology.checkOut.time!.substring(0, 5)} ${(int.parse(employeeDetail.chronology.checkOut.time!.substring(0, 2)) > 11) ? 'PM' : 'AM'}'
                                : 'Salida no registrada',
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Horas Efectivas: ',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Excluyendo refrigerio',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Text(
                  employeeDetail.chronology.netHoursWorked.toString(),
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  ' hrs',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 80),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('___________________'),
                  pw.SizedBox(height: 10),
                  pw.Text('Firma Supervisor'),
                  pw.SizedBox(height: 5),
                  pw.Text(employeeDetail.audit.registeredBy.fullName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (!isShared) {
      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name:
            'Reporte_Asistencia_${employeeDetail.employee.fullName.replaceAll(' ', '_')}.pdf',
      );
    }
    return pdf;
  }
}

class _CardTimeLineInOutWidget extends StatelessWidget {
  final bool isIN;
  final String hour;
  final String place;
  final bool isNotRegistered;
  const _CardTimeLineInOutWidget({
    super.key,
    required this.isIN,
    required this.hour,
    required this.place,
    required this.isNotRegistered,
  });

  @override
  Widget build(BuildContext context) {
    return isNotRegistered
        ? Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              color: isIN
                  ? TColors.uploadBlue.withValues(alpha: 0.1)
                  : TColors.appBackgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text('No Registrado', textAlign: TextAlign.center),
          )
        : Container(
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
                        color: isIN
                            ? TColors.uploadBlue
                            : TColors.appMainTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      place,
                      style: TextStyle(fontSize: 12, color: TColors.disabled),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      hour,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text((int.parse(hour.substring(0, 2)) > 11) ? 'PM' : 'AM'),
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
