import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum GoldOperationType { extraction, sale }

/// Conserva la identidad de una operacion de oro hasta recibir una respuesta
/// exitosa del servidor. Si la app se cierra o la red falla, el siguiente
/// intento con los mismos datos reutiliza la misma clave y el backend devuelve
/// el registro original en vez de crear un duplicado.
class GoldOperationKeyStore {
  static const _storageKey = 'pending_gold_operation_keys_v1';
  static const _userIdKey = 'ID';

  final SharedPreferences _preferences;
  final String Function() _generateKey;

  GoldOperationKeyStore._(this._preferences, {String Function()? generateKey})
    : _generateKey = generateKey ?? const Uuid().v4;

  static Future<GoldOperationKeyStore> create() async {
    return GoldOperationKeyStore._(await SharedPreferences.getInstance());
  }

  /// Constructor visible para pruebas. La app debe usar [create].
  factory GoldOperationKeyStore.forTesting(
    SharedPreferences preferences, {
    required String Function() generateKey,
  }) {
    return GoldOperationKeyStore._(preferences, generateKey: generateKey);
  }

  Future<String> getOrCreate({
    required GoldOperationType type,
    required String fingerprint,
  }) async {
    final records = _readRecords();
    final ownerId = _preferences.getString(_userIdKey) ?? '';
    final typeName = type.name;

    for (final record in records) {
      if (record['owner_id'] == ownerId &&
          record['type'] == typeName &&
          record['fingerprint'] == fingerprint) {
        final existingKey = record['key'];
        if (existingKey is String && existingKey.isNotEmpty) {
          return existingKey;
        }
      }
    }

    final key = _generateKey();
    records.add({
      'owner_id': ownerId,
      'type': typeName,
      'fingerprint': fingerprint,
      'key': key,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    await _writeRecords(records);
    return key;
  }

  Future<void> complete(String key) async {
    final records = _readRecords();
    records.removeWhere((record) => record['key'] == key);
    await _writeRecords(records);
  }

  List<Map<String, dynamic>> _readRecords() {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((record) => Map<String, dynamic>.from(record))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeRecords(List<Map<String, dynamic>> records) async {
    if (records.isEmpty) {
      await _preferences.remove(_storageKey);
      return;
    }
    await _preferences.setString(_storageKey, jsonEncode(records));
  }
}

class GoldOperationFingerprint {
  static String extraction({
    required String extractionDate,
    required double grossWeightGrams,
    required double purityPercent,
    required String observations,
  }) {
    return jsonEncode([
      extractionDate,
      grossWeightGrams.toStringAsFixed(4),
      purityPercent.toStringAsFixed(2),
      observations,
    ]);
  }

  static String sale({
    required String salesDate,
    required String buyer,
    required double totalGramsSold,
    required double priceBsPerGram,
  }) {
    return jsonEncode([
      salesDate,
      buyer.trim(),
      totalGramsSold.toStringAsFixed(4),
      priceBsPerGram.toStringAsFixed(2),
    ]);
  }
}
