/// Helpers de parseo tolerantes (número/string/null) para los modelos.
double pNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

double? pNumN(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int pInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

DateTime? pDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

String pStr(dynamic v) => v?.toString() ?? '';

String? pStrN(dynamic v) => v?.toString();
