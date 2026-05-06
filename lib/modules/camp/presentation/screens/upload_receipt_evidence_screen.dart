import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class UploadReceiptEvidenceScreen extends StatefulWidget {
  const UploadReceiptEvidenceScreen({super.key});

  @override
  State<UploadReceiptEvidenceScreen> createState() =>
      _UploadReceiptEvidenceScreenState();
}

class _UploadReceiptEvidenceScreenState
    extends State<UploadReceiptEvidenceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        title: const Text(
          'Subir Recibo',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evidencia de Gasto',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F26),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture una imagen clara del recibo para finalizar la solicitud de fondo fijo.',
              style: TextStyle(fontSize: 14, color: TColors.appDisabledColor),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: TColors.disabled.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  width: 250,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: Color(0xFF9DA4B0),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Sin imagen seleccionada',
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt_outlined, size: 20),
                        label: const Text('TOMAR FOTO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1F26),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              'MONTO FINAL EJECUTADO (BS)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F26),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: TColors.white, 
                border: Border.all(color: const Color(0xFFE9EBF0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: Color(
                      0xFFD1D5DB,
                    ), 
                    fontSize: 16,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Bs',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  border: InputBorder
                      .none, 
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: TColors.appDisabledColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Asegúrese de que el monto coincida exactamente con el total del recibo adjunto.',
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.appDisabledColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'CERRAR SOLICITUD',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
