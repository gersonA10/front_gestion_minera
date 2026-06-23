import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/data/models/models.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/employee_detail_assistance_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
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
  final String attendanceId;
  const AssistanceDetailScreen({super.key, required this.attendanceId});

  @override
  State<AssistanceDetailScreen> createState() => _AssistanceDetailScreenState();
}

/// Estilo de pill para el estado de una asistencia (contexto turno), derivado
/// del estado REAL del backend (`attendanceStatus`) con respaldo en la
/// validación automática. Reusa los tokens del kit del módulo.
class _AttendanceStatusStyle {
  final String label;
  final Color color;
  final Color bg;
  const _AttendanceStatusStyle(this.label, this.color, this.bg);

  static _AttendanceStatusStyle of(String? raw) {
    final s = (raw ?? '').toUpperCase().trim();
    if (s == 'REJECTED' ||
        s == 'RECHAZADO' ||
        s == 'INCIDENT' ||
        s == 'INCIDENCIA') {
      return const _AttendanceStatusStyle(
          'Con incidencia', Color(0xFFEF4444), Color(0xFFFEF2F2));
    }
    // FINALIZADO y REVISION (jornada corta) son ambos turnos COMPLETADOS:
    // siempre "Finalizado". La jornada corta se indica aparte como dato neutro.
    return const _AttendanceStatusStyle(
        'Finalizado', TColors.statusGreen, TColors.statusGreenBg);
  }
}

class _AssistanceDetailScreenState extends State<AssistanceDetailScreen> {
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

  /// Toma los primeros 5 caracteres ("HH:mm") de forma defensiva: si el
  /// backend manda otro formato no revienta, solo recorta lo que haya.
  String _hhmm(String? raw, {String fallback = '00:00'}) {
    if (raw == null || raw.isEmpty) return fallback;
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  @override
  void initState() {
    super.initState();
    _staffBloc = InjectorContainer.getIt<StaffBloc>()
      ..add(GetDetailAssistanceEmployeeEvent(employeeId: widget.attendanceId));
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
              backgroundColor: StaffUi.background,
              appBar: staffAppBar(context, title: 'Detalle de asistencia'),
              body: const StaffLoader(),
            );
          }
          if (state is DetailAssistanceEmployeeLoaded) {
            _employeeCache = state.employee;
          }
          if (_employeeCache == null) {
            if (isLoading) {
              return Scaffold(
                backgroundColor: StaffUi.background,
                appBar: staffAppBar(context, title: 'Detalle de asistencia'),
                body: const StaffLoader(),
              );
            }
            if (state is DetailAssistanceEmployeeError) {
              return Scaffold(
                backgroundColor: StaffUi.background,
                appBar: staffAppBar(context, title: 'Detalle de asistencia'),
                body: StaffErrorState(
                  message: state.message,
                  onRetry: () => _staffBloc.add(
                    GetDetailAssistanceEmployeeEvent(
                      employeeId: widget.attendanceId,
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: StaffUi.background,
              appBar: staffAppBar(context, title: 'Detalle de asistencia'),
              body: const SizedBox(),
            );
          }
          final employeeDetail = _employeeCache!;
          final employeeDate = employeeDetail.employee;
          final chronology = employeeDetail.chronology;
          final validation = employeeDetail.validation;
          return Scaffold(
            backgroundColor: StaffUi.background,
            appBar: staffAppBar(
              context,
              title: 'Detalle de asistencia',
              actions: [
                IconButton(
                  tooltip: 'Compartir',
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
                  icon: const Icon(
                    Icons.ios_share_rounded,
                    color: StaffUi.textPrimary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _buildHeaderCard(employeeDetail, employeeDate, validation),
                const SizedBox(height: 14),
                _buildChronologyCard(chronology),
                const SizedBox(height: 14),
                _buildValidationCard(chronology, validation),
                const SizedBox(height: 18),
                _buildReportButton(context, employeeDetail),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Card 1: identidad + fecha/turno + estado real ──
  Widget _buildHeaderCard(
    EmployeeDetailAssistanceModel employeeDetail,
    Employee employeeDate,
    Validation validation,
  ) {
    final status = _AttendanceStatusStyle.of(employeeDetail.attendanceStatus);
    final isShortShift =
        employeeDetail.attendanceStatus.toUpperCase() == 'REVISION';
    return StaffCard(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: StaffUi.primarySoft,
                    border: Border.all(color: StaffUi.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FadeInImage.assetNetwork(
                    placeholder: AssetImageApp.getIconLoading,
                    image: employeeDetail.employee.photoUrl ?? '',
                    fit: BoxFit.cover,
                    imageErrorBuilder: (_, _, _) {
                      return const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: StaffUi.primary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  employeeDate.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  employeeDate.position,
                  style: const TextStyle(
                    fontSize: 13,
                    color: StaffUi.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: StaffUi.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NID: ${employeeDate.nationalId}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: StaffUi.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: StaffUi.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CardDateTurnWidget(
                      isDate: true,
                      date: formatDate(
                        DateFormat('yyyy-MM-dd').parse(employeeDetail.date),
                      ),
                    ),
                    Container(width: 1, height: 40, color: StaffUi.border),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StaffPill(
                  label: status.label,
                  color: status.color,
                  bg: status.bg,
                  icon: Icons.check_circle_rounded,
                ),
                if (isShortShift) ...[
                  const SizedBox(height: 6),
                  const StaffPill(
                    label: 'Jornada corta',
                    color: StaffUi.textSecondary,
                    bg: TColors.statusGreyBg,
                    icon: Icons.info_outline_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 2: cronología del turno + horas efectivas ──
  Widget _buildChronologyCard(Chronology chronology) {
    return StaffCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const StaffSectionTitle(
            'Cronología del turno',
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 4),
          TimelineCustomWidget(
            isFirst: true,
            pointColor: StaffUi.primary,
            child: _CardTimeLineInOutWidget(
              isIN: true,
              hour: _hhmm(chronology.checkIn.time),
              place: (chronology.checkOut.location != null)
                  ? chronology.checkOut.location!
                  : 'Lugar no registrado',
              isNotRegistered: chronology.checkIn.time == null,
            ),
          ),
          TimelineCustomWidget(
            pointColor: StaffUi.muted,
            size: 10,
            child: Container(
              padding: const EdgeInsets.only(left: 18, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Refrigerio',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: StaffUi.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: StaffUi.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: StaffUi.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.restaurant_rounded,
                          size: 14,
                          color: StaffUi.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        (chronology.breakMinutes == 0)
                            ? const Text(
                                'Sin refrigerio',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: StaffUi.textSecondary,
                                ),
                              )
                            : Text(
                                '${chronology.breakMinutes} min',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: StaffUi.textPrimary,
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
            pointColor: StaffUi.primary,
            child: _CardTimeLineInOutWidget(
              isIN: false,
              hour: (chronology.checkOut.time == null)
                  ? '00:00'
                  : _hhmm(chronology.checkOut.time),
              place:
                  (chronology.checkOut.location != null &&
                      chronology.checkOut.location!.isNotEmpty)
                  ? chronology.checkOut.location!
                  : 'Lugar no registrado',
              isNotRegistered: chronology.checkOut.time == null,
            ),
          ),
          Divider(color: StaffUi.border, height: 24),
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HORAS EFECTIVAS',
                    style: TextStyle(
                      fontSize: 12,
                      color: StaffUi.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Excluyendo refrigerio',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: StaffUi.muted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  (chronology.netHoursWorked == 0)
                      ? const Text(
                          'No registrado',
                          style: TextStyle(
                            fontSize: 14,
                            color: StaffUi.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          chronology.netHoursWorked.toString(),
                          style: const TextStyle(
                            fontSize: 30,
                            color: StaffUi.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                  const SizedBox(width: 5),
                  Text(
                    (chronology.netHoursWorked == 0) ? '' : 'hrs',
                    style: const TextStyle(
                      fontSize: 15,
                      color: StaffUi.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 3: validación (firma + geo) ──
  Widget _buildValidationCard(
    Chronology chronology,
    Validation validation,
  ) {
    return StaffCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const StaffSectionTitle(
            'Validación',
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 72,
                      decoration: BoxDecoration(
                        color: StaffUi.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: StaffUi.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FadeInImage.assetNetwork(
                        placeholder: AssetImageApp.getIconLoading,
                        image: validation.supervisorSignatureUrl ?? '',
                        fit: BoxFit.cover,
                        imageErrorBuilder: (_, _, _) {
                          return const Center(
                            child: Icon(
                              Icons.draw_outlined,
                              size: 28,
                              color: StaffUi.muted,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Firma supervisor',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: StaffUi.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 64,
                color: StaffUi.border,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: StaffUi.primarySoft,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: StaffUi.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (chronology.checkOut.location == null ||
                              chronology.checkOut.location!.isEmpty)
                          ? 'Lugar no registrado'
                          : chronology.checkOut.location!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: StaffUi.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lat: ${validation.geolocation.checkOut.latitude}, Lon: ${validation.geolocation.checkOut.longitude}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: StaffUi.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Acción: generar reporte PDF (imprimir / previsualizar) ──
  Widget _buildReportButton(
    BuildContext context,
    EmployeeDetailAssistanceModel employeeDetail,
  ) {
    return StaffPrimaryButton(
      label: 'Generar reporte',
      icon: Icons.print_rounded,
      onPressed: () => _generarPdf(context, employeeDetail, false),
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
                                      'yyyy-MM-dd',
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
                                : 'Tiempo de Refrigerio - ${employeeDetail.chronology.breakMinutes}  ${(int.parse(employeeDetail.chronology.checkOut.time!.substring(0, 2)) > 11) ? 'PM' : 'AM'}',
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
                            (employeeDetail.chronology.checkOut.time != null &&
                                    employeeDetail
                                        .chronology
                                        .checkOut
                                        .time!
                                        .isNotEmpty)
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
    required this.isIN,
    required this.hour,
    required this.place,
    required this.isNotRegistered,
  });

  /// AM/PM defensivo: si la hora no trae "HH" parseable, no revienta.
  String get _meridiem {
    if (hour.length < 2) return 'AM';
    final h = int.tryParse(hour.substring(0, 2));
    if (h == null) return 'AM';
    return h > 11 ? 'PM' : 'AM';
  }

  @override
  Widget build(BuildContext context) {
    final bg = isIN ? StaffUi.primarySoft : StaffUi.background;
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StaffUi.border),
      ),
      child: isNotRegistered
          ? const Text(
              'No registrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: StaffUi.textSecondary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIN ? 'Entrada registrada' : 'Salida registrada',
                        style: TextStyle(
                          color: isIN
                              ? StaffUi.primary
                              : StaffUi.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: StaffUi.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      hour,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 25,
                        color: StaffUi.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _meridiem,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: StaffUi.textSecondary,
                      ),
                    ),
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
      beforeLineStyle: const LineStyle(color: StaffUi.border, thickness: 2),
      afterLineStyle: const LineStyle(color: StaffUi.border, thickness: 2),
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
      child: Column(
        children: [
          Text(
            isDate ? 'Fecha' : 'Turno',
            style: const TextStyle(
              color: StaffUi.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isDate ? date : turn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: StaffUi.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
