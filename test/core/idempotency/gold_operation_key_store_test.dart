import 'package:flutter_test/flutter_test.dart';
import 'package:front_gestion_minera/core/idempotency/gold_operation_key_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int generatedKeys;
  late SharedPreferences preferences;
  late GoldOperationKeyStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'ID': 'treasury-user-1'});
    preferences = await SharedPreferences.getInstance();
    generatedKeys = 0;
    store = GoldOperationKeyStore.forTesting(
      preferences,
      generateKey: () =>
          '00000000-0000-4000-8000-${(++generatedKeys).toString().padLeft(12, '0')}',
    );
  });

  test('reutiliza la clave al reintentar la misma venta', () async {
    const fingerprint = '["2026-08-19","Paola","4.3800","1400.00"]';

    final first = await store.getOrCreate(
      type: GoldOperationType.sale,
      fingerprint: fingerprint,
    );
    final retry = await store.getOrCreate(
      type: GoldOperationType.sale,
      fingerprint: fingerprint,
    );

    expect(retry, first);
    expect(generatedKeys, 1);
  });

  test('genera otra clave después de confirmar la operación', () async {
    const fingerprint = '["2026-08-19","Paola","4.3800","1400.00"]';
    final completed = await store.getOrCreate(
      type: GoldOperationType.sale,
      fingerprint: fingerprint,
    );

    await store.complete(completed);
    final nextOperation = await store.getOrCreate(
      type: GoldOperationType.sale,
      fingerprint: fingerprint,
    );

    expect(nextOperation, isNot(completed));
  });

  test('no comparte una operación pendiente entre usuarios', () async {
    const fingerprint = '["2026-08-19","Paola","4.3800","1400.00"]';
    final firstUserKey = await store.getOrCreate(
      type: GoldOperationType.sale,
      fingerprint: fingerprint,
    );

    await preferences.setString('ID', 'treasury-user-2');
    final secondUserKey = await store.getOrCreate(
      type: GoldOperationType.sale,
      fingerprint: fingerprint,
    );

    expect(secondUserKey, isNot(firstUserKey));
  });

  test('normaliza los números del fingerprint', () {
    final first = GoldOperationFingerprint.extraction(
      extractionDate: '2026-08-19',
      grossWeightGrams: 4.38,
      purityPercent: 96,
      observations: 'Turno tarde',
    );
    final retry = GoldOperationFingerprint.extraction(
      extractionDate: '2026-08-19',
      grossWeightGrams: 4.3800,
      purityPercent: 96.00,
      observations: 'Turno tarde',
    );

    expect(retry, first);
  });
}
