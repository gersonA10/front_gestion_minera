import 'package:flutter_test/flutter_test.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/voice/transaction_voice_parser.dart';

void main() {
  final cajas = [
    CashRegisterEntity(id: 'c1', nombre: 'Caja Chica', saldoDisponible: 500),
    CashRegisterEntity(id: 'c2', nombre: 'Caja General', saldoDisponible: 9000),
  ];

  group('TransactionVoiceParser', () {
    test('egreso con monto, caja y concepto', () {
      final r = TransactionVoiceParser.parse(
        'registrar egreso de 500 bolivianos de caja chica por compra de diésel',
        cajas: cajas,
      );
      expect(r.tipo, 'Egreso');
      expect(r.monto, 500);
      expect(r.cajaId, 'c1');
      expect(r.concepto, 'Compra de diésel');
    });

    test('ingreso con monto en palabras', () {
      final r = TransactionVoiceParser.parse(
        'ingreso de mil doscientos a caja general por venta de chatarra',
        cajas: cajas,
      );
      expect(r.tipo, 'Ingreso');
      expect(r.monto, 1200);
      expect(r.cajaId, 'c2');
      expect(r.concepto, 'Venta de chatarra');
    });

    test('transferencia detecta caja origen y destino en orden', () {
      final r = TransactionVoiceParser.parse(
        'transferencia de 300 de caja chica a caja general',
        cajas: cajas,
      );
      expect(r.tipo, 'Transferencia');
      expect(r.monto, 300);
      expect(r.cajaOrigenId, 'c1');
      expect(r.cajaDestinoId, 'c2');
    });

    test('sinónimos: pago implica egreso, depósito implica ingreso', () {
      expect(
        TransactionVoiceParser.parse('pago de 50 bs', cajas: cajas).tipo,
        'Egreso',
      );
      expect(
        TransactionVoiceParser.parse('depositar 80 bolivianos', cajas: cajas)
            .tipo,
        'Ingreso',
      );
    });

    test('concepto no arrastra la cola de la transferencia', () {
      final r = TransactionVoiceParser.parse(
        'transferencia de 100 por ajuste de saldo de caja chica a caja general',
        cajas: cajas,
      );
      expect(r.concepto, 'Ajuste de saldo');
    });

    test('"por transferencia" en el concepto no cambia el tipo', () {
      final r = TransactionVoiceParser.parse(
        'ingreso de 100 bolivianos a caja general por transferencia del banco',
        cajas: cajas,
      );
      expect(r.tipo, 'Ingreso');
      expect(r.monto, 100);
      expect(r.cajaId, 'c2');
      expect(r.concepto, 'Transferencia del banco');
    });

    // ── Regresiones de la revisión pre-producción ─────────────────────────
    test('miles después de unidades: "cinco mil"', () {
      final r = TransactionVoiceParser.parse(
        'egreso de cinco mil bolivianos de caja chica por compra de diésel',
        cajas: cajas,
      );
      expect(r.monto, 5000);
      final r2 = TransactionVoiceParser.parse(
        'ingreso de dos mil quinientos bs a caja general',
        cajas: cajas,
      );
      expect(r2.monto, 2500);
    });

    test('transferencia con preposiciones invertidas respeta origen/destino',
        () {
      final r = TransactionVoiceParser.parse(
        'transferir 300 a caja general desde caja chica',
        cajas: cajas,
      );
      expect(r.cajaOrigenId, 'c1');
      expect(r.cajaDestinoId, 'c2');
    });

    test('una sola caja con "a" es destino, no origen', () {
      final r = TransactionVoiceParser.parse(
        'transferencia de 300 a caja general',
        cajas: cajas,
      );
      expect(r.cajaDestinoId, 'c2');
      expect(r.cajaOrigenId, isNull);
    });

    test('sin tipo antes del concepto no adivina Transferencia', () {
      final r = TransactionVoiceParser.parse(
        'recibo de 500 por transferencia bancaria',
        cajas: cajas,
      );
      expect(r.tipo, isNull);
      expect(r.monto, 500);
    });

    test('"por favor" no corta el concepto ni el tipo', () {
      final r = TransactionVoiceParser.parse(
        'por favor registrar ingreso de 100 bs a caja general',
        cajas: cajas,
      );
      expect(r.tipo, 'Ingreso');
      expect(r.cajaId, 'c2');
    });

    test('dictado sin nada interpretable', () {
      final r = TransactionVoiceParser.parse('hola qué tal', cajas: cajas);
      expect(r.understoodSomething, false);
    });
  });
}
