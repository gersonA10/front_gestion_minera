import 'package:front_gestion_minera/core/voice/spanish_number_normalizer.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';

/// Resultado de interpretar un dictado de transacción urgente.
class TransactionVoiceResult {
  final String transcript;

  /// 'Ingreso' | 'Egreso' | 'Transferencia' (valores del selector del form).
  final String? tipo;
  final double? monto;
  final String? concepto;

  /// Caja para Ingreso (destino) o Egreso (origen).
  final String? cajaId;

  /// Cajas para Transferencia.
  final String? cajaOrigenId;
  final String? cajaDestinoId;

  const TransactionVoiceResult({
    required this.transcript,
    this.tipo,
    this.monto,
    this.concepto,
    this.cajaId,
    this.cajaOrigenId,
    this.cajaDestinoId,
  });

  bool get understoodSomething =>
      tipo != null || monto != null || concepto != null || cajaId != null;
}

/// Interpreta comandos como:
///   "registrar egreso de 500 bolivianos de caja chica por compra de diésel"
///   "ingreso de mil doscientos a caja general por venta de chatarra"
///   "transferencia de 300 de caja chica a caja general"
class TransactionVoiceParser {
  static TransactionVoiceResult parse(
    String transcript, {
    required List<CashRegisterEntity> cajas,
  }) {
    final normalized = SpanishNumberNormalizer.normalize(
      transcript,
    ).replaceAll(',', '.');

    // El tipo se busca solo antes del concepto: "ingreso ... por
    // transferencia bancaria" no debe clasificarse como Transferencia.
    // Sin fallback al texto completo: si no hay tipo claro, el usuario
    // lo elige en el formulario.
    final tipo = _parseTipo(_removeConceptoTail(normalized));
    final monto = _parseMonto(normalized);
    final concepto = _parseConcepto(transcript);
    final matches = matchCajas(normalized, cajas);

    String? cajaId;
    String? origenId;
    String? destinoId;
    if (tipo == 'Transferencia') {
      (origenId, destinoId) = _asignarCajasTransferencia(normalized, matches);
    } else if (matches.isNotEmpty) {
      cajaId = matches.first.$1;
    }

    return TransactionVoiceResult(
      transcript: transcript,
      tipo: tipo,
      monto: monto,
      concepto: concepto,
      cajaId: cajaId,
      cajaOrigenId: origenId,
      cajaDestinoId: destinoId,
    );
  }

  // "por favor" es cortesía, no marcador de concepto.
  static final RegExp _conceptoMarker = RegExp(
    r'\b(?:por\s+concepto\s+de|concepto\s+(?:de\s+)?|por(?!\s+favor\b)|para)\s+(.{4,})',
    caseSensitive: false,
  );

  static String _removeConceptoTail(String text) {
    final match = _conceptoMarker.firstMatch(text);
    return match == null ? text : text.substring(0, match.start);
  }

  static String? _parseTipo(String text) {
    if (RegExp(
      r'\b(transferencia|transferir|transfiere|traspaso)\b',
    ).hasMatch(text)) {
      return 'Transferencia';
    }
    if (RegExp(
      r'\b(ingreso|entrada|deposito|depositar|cobro|cobrar)\b',
    ).hasMatch(text)) {
      return 'Ingreso';
    }
    if (RegExp(
      r'\b(egreso|gasto|gastar|salida|pago|pagar|compra|comprar)\b',
    ).hasMatch(text)) {
      return 'Egreso';
    }
    return null;
  }

  static double? _parseMonto(String text) {
    // Con moneda explícita.
    final withCurrency = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:bolivianos?|bs|pesos)\b',
    ).firstMatch(text);
    if (withCurrency != null) {
      return double.parse(withCurrency.group(1)!);
    }
    // "monto de 500" / "por 500".
    final withKeyword = RegExp(
      r'monto\s+(?:de\s+)?(\d+(?:\.\d+)?)',
    ).firstMatch(text);
    if (withKeyword != null) {
      return double.parse(withKeyword.group(1)!);
    }
    // Primer número del dictado.
    final lone = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    if (lone != null) {
      return double.parse(lone.group(1)!);
    }
    return null;
  }

  /// El concepto es lo que sigue a "por/para/concepto"; se toma del
  /// transcript original para conservar la redacción del usuario.
  static String? _parseConcepto(String original) {
    final match = _conceptoMarker.firstMatch(original);
    if (match == null) return null;

    var concepto = match.group(1)!.trim();
    // Evita arrastrar la cola "...a caja X" de una transferencia.
    concepto = concepto
        .replaceFirst(
          RegExp(
            r'\s+(?:de|a|hacia|desde)\s+(?:la\s+)?caja\s+.+$',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    if (concepto.length < 3) return null;
    return concepto[0].toUpperCase() + concepto.substring(1);
  }

  /// Clasifica las cajas de una transferencia por la preposición que las
  /// precede: "de/desde" = origen, "a/hacia/hasta/para" = destino.
  /// Cae al orden de mención cuando el dictado no trae preposiciones.
  static (String?, String?) _asignarCajasTransferencia(
    String text,
    List<(String, int)> matches,
  ) {
    String? origen;
    String? destino;
    final sinPreposicion = <String>[];

    for (final (id, index) in matches.take(2)) {
      final prep = _preposicionAntes(text, index);
      if ((prep == 'de' || prep == 'desde') && origen == null) {
        origen = id;
      } else if ((prep == 'a' || prep == 'hacia' || prep == 'hasta') &&
          destino == null) {
        destino = id;
      } else {
        sinPreposicion.add(id);
      }
    }
    for (final id in sinPreposicion) {
      if (origen == null) {
        origen = id;
      } else {
        destino ??= id;
      }
    }
    return (origen, destino);
  }

  /// Última palabra significativa antes de [index], saltando artículos
  /// y la palabra "caja".
  static String? _preposicionAntes(String text, int index) {
    final antes = text.substring(0, index).trimRight().split(RegExp(r'\s+'));
    for (var i = antes.length - 1; i >= 0 && i >= antes.length - 4; i--) {
      final w = antes[i];
      if (w == 'la' || w == 'el' || w == 'caja' || w.isEmpty) continue;
      return w;
    }
    return null;
  }

  /// Busca nombres de caja mencionados en el dictado, en orden de aparición.
  /// Devuelve pares (id, posición en el texto).
  static List<(String, int)> matchCajas(
    String normalizedText,
    List<CashRegisterEntity> cajas,
  ) {
    final found = <(String, int)>[];
    for (final caja in cajas) {
      final nombre = SpanishNumberNormalizer.clean(caja.nombre);
      var index = normalizedText.indexOf(nombre);
      if (index < 0) {
        // Intento sin la palabra "caja" (ej: dice "chica" y la caja
        // se llama "Caja Chica").
        final corto = nombre.replaceFirst(RegExp(r'^caja\s+'), '');
        if (corto.length > 3 && corto != nombre) {
          index = normalizedText.indexOf(corto);
        }
      }
      if (index >= 0) {
        found.add((caja.id, index));
      }
    }
    found.sort((a, b) => a.$2.compareTo(b.$2));
    return found;
  }
}
