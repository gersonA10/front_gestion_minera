import 'package:front_gestion_minera/core/voice/spanish_number_normalizer.dart';
import 'package:intl/intl.dart';

/// Periodo detectado en una pregunta ("egresos de mayo", "ventas de hoy").
/// Mapea directo a los parámetros `period` / `exact_date` del backend.
class AssistantPeriod {
  final String period; // 'day' | 'month' | 'year'
  final String exactDate; // yyyy-MM-dd

  /// Cómo nombrarlo en la respuesta. SOLO para redactar: la lógica debe
  /// usar [period]/[isCurrent], nunca comparar este texto.
  final String label;

  /// true si el periodo es el vigente (hoy / este mes / este año).
  final bool isCurrent;

  const AssistantPeriod({
    required this.period,
    required this.exactDate,
    required this.label,
    this.isCurrent = false,
  });
}

class AssistantPeriodParser {
  static const List<String> _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  // Regexes compiladas una sola vez.
  static final RegExp _puntuacion = RegExp(r'[^a-z0-9\s]');
  static final RegExp _diaMes = RegExp(
    '\\b(\\d{1,2})\\s+de\\s+(${_meses.join('|')})(?:\\s+de\\s+(\\d{4}))?',
  );
  static final RegExp _mesConAnio = RegExp(
    '\\b(${_meses.join('|')})\\s+de\\s+(\\d{4})\\b',
  );
  static final RegExp _mesSolo = RegExp('\\b(${_meses.join('|')})\\b');

  static String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// Devuelve null si la pregunta no menciona ningún periodo
  /// (el consumidor decide su default, normalmente "hoy").
  static AssistantPeriod? parse(String question, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final t =
        ' ${SpanishNumberNormalizer.clean(question).replaceAll(_puntuacion, ' ')} ';

    // Días puntuales.
    if (t.contains(' anteayer') || t.contains(' antier')) {
      final d = today.subtract(const Duration(days: 2));
      return AssistantPeriod(
        period: 'day',
        exactDate: _fmt(d),
        label: 'anteayer',
      );
    }
    if (t.contains(' ayer')) {
      final d = today.subtract(const Duration(days: 1));
      return AssistantPeriod(period: 'day', exactDate: _fmt(d), label: 'ayer');
    }

    // "el 12 de mayo (de 2025)".
    final diaMes = _diaMes.firstMatch(t);
    if (diaMes != null) {
      final dia = int.parse(diaMes.group(1)!);
      final mes = _meses.indexOf(diaMes.group(2)!) + 1;
      final anio = diaMes.group(3) != null
          ? int.parse(diaMes.group(3)!)
          : _anioParaMes(mes, today);
      return AssistantPeriod(
        period: 'day',
        exactDate: _fmt(DateTime(anio, mes, dia)),
        label:
            'el $dia de ${_meses[mes - 1]}${diaMes.group(3) != null ? ' de $anio' : ''}',
      );
    }

    // Mes por nombre: "mayo de 2025" / "de mayo".
    final mesConAnio = _mesConAnio.firstMatch(t);
    if (mesConAnio != null) {
      final mes = _meses.indexOf(mesConAnio.group(1)!) + 1;
      final anio = int.parse(mesConAnio.group(2)!);
      return AssistantPeriod(
        period: 'month',
        exactDate: _fmt(DateTime(anio, mes, 1)),
        label: '${_meses[mes - 1]} $anio',
      );
    }
    final mesSolo = _mesSolo.firstMatch(t);
    if (mesSolo != null) {
      final mes = _meses.indexOf(mesSolo.group(1)!) + 1;
      final anio = _anioParaMes(mes, today);
      return AssistantPeriod(
        period: 'month',
        exactDate: _fmt(DateTime(anio, mes, 1)),
        label: '${_meses[mes - 1]} $anio',
        isCurrent: mes == today.month && anio == today.year,
      );
    }

    if (t.contains(' mes pasado')) {
      final d = DateTime(today.year, today.month - 1, 1);
      return AssistantPeriod(
        period: 'month',
        exactDate: _fmt(d),
        label: '${_meses[d.month - 1]} ${d.year}',
      );
    }
    if (t.contains(' este mes') || t.contains(' del mes')) {
      return AssistantPeriod(
        period: 'month',
        exactDate: _fmt(today),
        label: 'este mes',
        isCurrent: true,
      );
    }
    if (t.contains(' ano pasado') || t.contains(' gestion pasada')) {
      return AssistantPeriod(
        period: 'year',
        exactDate: _fmt(DateTime(today.year - 1, 1, 1)),
        label: '${today.year - 1}',
      );
    }
    if (t.contains(' este ano') ||
        t.contains(' del ano') ||
        t.contains(' esta gestion') ||
        t.contains(' anual')) {
      return AssistantPeriod(
        period: 'year',
        exactDate: _fmt(today),
        label: 'este año',
        isCurrent: true,
      );
    }
    if (t.contains(' hoy ')) {
      return AssistantPeriod(
        period: 'day',
        exactDate: _fmt(today),
        label: 'hoy',
        isCurrent: true,
      );
    }
    return null;
  }

  /// Si nombran un mes que aún no llegó este año, asumen el año pasado.
  static int _anioParaMes(int mes, DateTime today) =>
      mes > today.month ? today.year - 1 : today.year;
}
