/// Convierte números dichos en palabras dentro de un texto en español a
/// dígitos, para que los parsers de dictado trabajen siempre sobre cifras.
///
/// Ejemplos:
///   "quince gramos"              -> "15 gramos"
///   "noventa y seis por ciento"  -> "96 por ciento"
///   "quince punto cinco gramos"  -> "15.5 gramos"
///   "mil doscientos gramos"      -> "1200 gramos"
class SpanishNumberNormalizer {
  static const Map<String, int> _units = {
    'cero': 0,
    'un': 1,
    'uno': 1,
    'una': 1,
    'dos': 2,
    'tres': 3,
    'cuatro': 4,
    'cinco': 5,
    'seis': 6,
    'siete': 7,
    'ocho': 8,
    'nueve': 9,
    'diez': 10,
    'once': 11,
    'doce': 12,
    'trece': 13,
    'catorce': 14,
    'quince': 15,
    'dieciseis': 16,
    'diecisiete': 17,
    'dieciocho': 18,
    'diecinueve': 19,
    'veintiun': 21,
    'veintiuno': 21,
    'veintidos': 22,
    'veintitres': 23,
    'veinticuatro': 24,
    'veinticinco': 25,
    'veintiseis': 26,
    'veintisiete': 27,
    'veintiocho': 28,
    'veintinueve': 29,
  };

  static const Map<String, int> _tens = {
    'veinte': 20,
    'treinta': 30,
    'cuarenta': 40,
    'cincuenta': 50,
    'sesenta': 60,
    'setenta': 70,
    'ochenta': 80,
    'noventa': 90,
  };

  static const Map<String, int> _hundreds = {
    'cien': 100,
    'ciento': 100,
    'doscientos': 200,
    'trescientos': 300,
    'cuatrocientos': 400,
    'quinientos': 500,
    'seiscientos': 600,
    'setecientos': 700,
    'ochocientos': 800,
    'novecientos': 900,
  };

  /// Quita acentos y pasa a minúsculas.
  static String clean(String input) {
    const accents = 'áéíóúüñÁÉÍÓÚÜÑ';
    const plain = 'aeiouunAEIOUUN';
    var out = input.toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      out = out.replaceAll(accents[i], plain[i]);
    }
    return out;
  }

  /// Reemplaza en [input] (ya limpio o no) las secuencias de palabras
  /// numéricas por su valor en dígitos. El resto del texto queda igual.
  static String normalize(String input) {
    final tokens = clean(input).split(RegExp(r'\s+'));
    final out = <String>[];

    var i = 0;
    while (i < tokens.length) {
      final parsed = _parseNumber(tokens, i);
      if (parsed != null) {
        out.add(parsed.$1);
        i = parsed.$2;
      } else {
        out.add(tokens[i]);
        i++;
      }
    }
    return out.join(' ');
  }

  /// Intenta leer un número (con posible parte decimal "punto"/"coma")
  /// empezando en [start]. Devuelve (texto en dígitos, índice siguiente)
  /// o null si en [start] no empieza un número.
  static (String, int)? _parseNumber(List<String> tokens, int start) {
    final intPart = _parseInt(tokens, start);
    if (intPart == null) return null;

    var (value, i) = intPart;

    // Parte decimal: "punto"/"coma" seguido de palabras numéricas.
    if (i + 1 < tokens.length &&
        (tokens[i] == 'punto' || tokens[i] == 'coma')) {
      final decimals = <int>[];
      var j = i + 1;
      while (j < tokens.length) {
        final d = _parseInt(tokens, j);
        if (d == null) break;
        decimals.add(d.$1);
        j = d.$2;
      }
      if (decimals.isNotEmpty) {
        return ('$value.${decimals.map((d) => d.toString()).join()}', j);
      }
    }
    return (value.toString(), i);
  }

  /// Lee un entero en palabras (hasta miles). Devuelve (valor, índice
  /// siguiente) o null.
  static (int, int)? _parseInt(List<String> tokens, int start) {
    var i = start;
    var total = 0;
    var current = 0;
    var consumed = false;

    while (i < tokens.length) {
      final t = tokens[i];
      if (_hundreds.containsKey(t)) {
        // "ciento" solo cuenta como número si le sigue otra palabra numérica
        // ("ciento veinte"); solo, es parte de "por ciento".
        if (t == 'ciento' &&
            (i + 1 >= tokens.length ||
                (!_units.containsKey(tokens[i + 1]) &&
                    !_tens.containsKey(tokens[i + 1])))) {
          break;
        }
        current += _hundreds[t]!;
        consumed = true;
        i++;
      } else if (_tens.containsKey(t)) {
        current += _tens[t]!;
        consumed = true;
        i++;
        // "treinta y cinco"
        if (i + 1 < tokens.length &&
            tokens[i] == 'y' &&
            _units.containsKey(tokens[i + 1]) &&
            _units[tokens[i + 1]]! < 10) {
          current += _units[tokens[i + 1]]!;
          i += 2;
        }
        // "treinta mil": sigue solo si viene un multiplicador.
        if (i < tokens.length && tokens[i] == 'mil') continue;
        break;
      } else if (_units.containsKey(t)) {
        current += _units[t]!;
        consumed = true;
        i++;
        // "cinco mil": sigue solo si viene un multiplicador.
        if (i < tokens.length && tokens[i] == 'mil') continue;
        break;
      } else if (t == 'mil') {
        total += (current == 0 ? 1 : current) * 1000;
        current = 0;
        consumed = true;
        i++;
      } else {
        break;
      }
    }

    if (!consumed) return null;
    return (total + current, i);
  }
}
