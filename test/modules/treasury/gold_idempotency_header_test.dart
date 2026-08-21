import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/treasury/data/datasource/treasury_datasource.dart';
import 'package:front_gestion_minera/modules/treasury/data/models/gold_inventory.dart/gold_sale_model.dart';
import 'package:front_gestion_minera/modules/treasury/data/models/gold_inventory.dart/new_extraction_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temporaryDirectory;
  late File evidence;
  late ApiClient client;
  late TreasuryDatasource datasource;
  late List<RequestOptions> requests;

  setUp(() async {
    await dotenv.load(fileName: '.env');
    temporaryDirectory = await Directory.systemTemp.createTemp('gold-test-');
    evidence = File('${temporaryDirectory.path}/evidence.jpg');
    await evidence.writeAsBytes([1, 2, 3]);

    requests = [];
    client = ApiClient();
    client.api.interceptors.clear();
    client.api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          final isExtraction = options.path.endsWith('/batches');
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 201,
              data: isExtraction
                  ? {
                      'success': true,
                      'message': 'Extracción Registrada',
                      'batch_code': 'LOT-2026-TEST',
                      'idempotent_replay': false,
                    }
                  : {
                      'success': true,
                      'data': {
                        'sale_id': 'sale-id',
                        'peso_vendido_g': 4.38,
                        'precio_por_gramo_bs': 1400,
                        'total_bs': 6132,
                        'comprador': 'Paola',
                        'fecha_hora': '2026-08-19',
                        'num_operacion': 'OP-2026-TEST',
                        'is_idempotent': false,
                        'desglose_lotes': <dynamic>[],
                      },
                    },
            ),
          );
        },
      ),
    );
    datasource = TreasuryDatasource(apiClient: client);
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('envía X-Idempotency-Key al registrar una extracción', () async {
    const key = '10000000-0000-4000-8000-000000000001';

    await datasource.newExtraction(
      NewExtractionRequestModel(
        extractionDate: '2026-08-19',
        grossWeightGrams: '4.38',
        purityPercent: '96',
        observations: 'Turno tarde',
        evidencia: evidence.path,
        idempotencyKey: key,
      ),
    );

    expect(requests.single.headers['X-Idempotency-Key'], key);
  });

  test('envía X-Idempotency-Key al registrar una venta', () async {
    const key = '20000000-0000-4000-8000-000000000002';

    await datasource.registerSale(
      RegisterSaleRequestModel(
        salesDate: '2026-08-19',
        buyer: 'Paola',
        totalGramsSold: 4.38,
        priceBsPerGram: 1400,
        comprobante: evidence.path,
        idempotencyKey: key,
      ),
    );

    expect(requests.single.headers['X-Idempotency-Key'], key);
  });
}
