import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entity/entity.dart';

/// Genera los PDF de actas y memorandos con toda la información del documento
/// (encabezado, datos, descripción, participantes/destinatario e imágenes
/// adjuntas) en lugar de descargar únicamente el archivo adjunto.
class MinutesMemosPdf {
  static const PdfColor _primary = PdfColor.fromInt(0xFF1A56FF);
  static const PdfColor _primaryDeep = PdfColor.fromInt(0xFF0B33B8);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _border = PdfColor.fromInt(0xFFE5E7EB);

  static final _extensiones = <String>['jpg', 'jpeg', 'png'];

  /// Construye el PDF de un acta.
  static Future<Uint8List> buildActaPdf(ActaDetailEntity acta) async {
    final images = await _fetchImages(
      acta.attachments
          .map((a) => _AttachmentRef(a.tipoArchivo, a.nombreArchivo, a.url))
          .toList(),
    );

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        header: (context) => _header('ACTA', acta.numero),
        build: (context) => [
          _titulo(acta.titulo),
          pw.SizedBox(height: 16),
          _infoRow('Número de acta', acta.numero),
          _infoRow('Fecha', _formatDate(acta.fechaEmision)),
          _infoRow('Ubicación', _valueOr(acta.ubicacion)),
          _infoRow('Estado', acta.estado),
          pw.SizedBox(height: 18),
          _seccion('Descripción'),
          _parrafo(_valueOr(acta.descripcion)),
          pw.SizedBox(height: 18),
          _seccion('Participantes (${acta.participants.length})'),
          _participantes(acta.participants),
          if (images.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _seccion('Imágenes adjuntas'),
            ..._imagenes(images),
          ],
        ],
      ),
    );
    return doc.save();
  }

  /// Construye el PDF de un memorando.
  static Future<Uint8List> buildMemorandumPdf(
    MemorandumDetailEntity memo,
  ) async {
    final images = await _fetchImages(
      memo.attachments
          .map((a) => _AttachmentRef(a.tipoArchivo, a.nombreArchivo, a.url))
          .toList(),
    );

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        header: (context) => _header('MEMORANDO', memo.numero),
        build: (context) => [
          _titulo(memo.titulo),
          pw.SizedBox(height: 16),
          _infoRow('Número de memorando', memo.numero),
          _infoRow('Fecha', _formatDate(memo.fechaEmision)),
          _infoRow('Dirigido a', _valueOr(memo.destinatarioNombre)),
          pw.SizedBox(height: 18),
          _seccion('Descripción'),
          _parrafo(memo.contenido),
          if (images.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _seccion('Imágenes adjuntas'),
            ..._imagenes(images),
          ],
        ],
      ),
    );
    return doc.save();
  }

  // ------------------------------------------------------------------ helpers

  static pw.PageTheme _pageTheme() => pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      );

  static pw.Widget _header(String tipo, String numero) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primary, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            tipo,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: _primaryDeep,
              letterSpacing: 2,
            ),
          ),
          pw.Text(
            'N° $numero',
            style: pw.TextStyle(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  static pw.Widget _titulo(String titulo) => pw.Text(
        titulo,
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      );

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                color: _muted,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _seccion(String titulo) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: _primaryDeep,
          ),
        ),
      );

  static pw.Widget _parrafo(String texto) => pw.Text(
        texto,
        textAlign: pw.TextAlign.justify,
        style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
      );

  static pw.Widget _participantes(List<ActaParticipantEntity> participants) {
    if (participants.isEmpty) {
      return _parrafo('Sin participantes registrados.');
    }
    return pw.Table(
      border: pw.TableBorder.all(color: _border),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF3F4F6)),
          children: [
            _celda('Nombre', header: true),
            _celda('Cargo', header: true),
            _celda('Asistencia', header: true),
          ],
        ),
        ...participants.map(
          (p) => pw.TableRow(
            children: [
              _celda(p.fullName),
              _celda(_valueOr(p.position)),
              _celda(p.attendanceStatus),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _celda(String texto, {bool header = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(
          texto,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );

  static List<pw.Widget> _imagenes(List<pw.MemoryImage> images) {
    return images
        .map(
          (img) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.ClipRRect(
              horizontalRadius: 6,
              verticalRadius: 6,
              child: pw.Image(
                img,
                fit: pw.BoxFit.contain,
                height: 260,
              ),
            ),
          ),
        )
        .toList();
  }

  static Future<List<pw.MemoryImage>> _fetchImages(
    List<_AttachmentRef> attachments,
  ) async {
    final imageRefs = attachments.where(
      (a) => _extensiones.contains(a.tipo.toLowerCase()),
    );
    final dio = Dio();
    final result = <pw.MemoryImage>[];
    for (final ref in imageRefs) {
      try {
        final response = await dio.get<List<int>>(
          ref.url,
          options: Options(responseType: ResponseType.bytes),
        );
        final data = response.data;
        if (data != null && data.isNotEmpty) {
          result.add(pw.MemoryImage(Uint8List.fromList(data)));
        }
      } catch (_) {
        // Si falla la descarga de una imagen, se omite y se continúa.
      }
    }
    return result;
  }

  static String _formatDate(DateTime date) =>
      DateFormat("d 'de' MMMM 'de' y", 'es').format(date);

  static String _valueOr(String? value) =>
      (value == null || value.trim().isEmpty) ? 'No especificado' : value;
}

class _AttachmentRef {
  final String tipo;
  final String nombre;
  final String url;
  const _AttachmentRef(this.tipo, this.nombre, this.url);
}
