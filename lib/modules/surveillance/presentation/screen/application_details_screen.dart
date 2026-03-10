import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

import '../../domain/entity/entity.dart';

@RoutePage()
class ApplicationDetailsScreen extends StatelessWidget {
  final MonitoringTrayDataEntity item;
  const ApplicationDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;
    const background = Color(0xff0b1d3a);
    const cardColor = Color(0xff1b2b44);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colors.white,
            size: smallSpacing * 1,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Detalle de Solicitud",
          style: AppTextStyles.mainStyleWhite14Bold(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ESTADO ACTUAL",
              style: AppTextStyles.mainStyleGrey12Bold(
                context,
              ).copyWith(fontSize: 10),
            ),
            SizedBox(height: smallSpacing * 0.5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow.withOpacity(.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 4, color: Colors.yellow),
                  SizedBox(width: smallSpacing * 0.5),
                  Text(
                    "Pendiente de Aprobación",
                    style: AppTextStyles.mainStyle10(
                      context,
                    ).copyWith(color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
            SizedBox(height: smallSpacing * 1.5),
            Container(
              padding: EdgeInsets.all(topPadding * 0.08),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: colors.lead),
                      SizedBox(width: 6),
                      Text(
                        "INFORMACIÓN GENERAL",
                        style: AppTextStyles.mainStyleGrey12Bold(
                          context,
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  SizedBox(height: smallSpacing * 0.8),
                  _infoRow(context, "Fecha", formatDate(item.createdAt)),
                  Divider(color: Colors.white12),
                  _infoRow(context, "Área", item.rol),
                  Divider(color: Colors.white12),

                  _infoRow(context, "Solicitante", item.name),
                  Divider(color: Colors.white12),

                  _infoRow(
                    context,
                    "Monto",
                    "${item.amount} Bs.",
                    highlight: true,
                  ),
                  SizedBox(height: smallSpacing * 0.6),
                  Text(
                    "Descripción",
                    style: AppTextStyles.mainStyleGrey12Bold(
                      context,
                    ).copyWith(fontSize: 10),
                  ),
                  SizedBox(height: smallSpacing * 0.5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xff0f213e),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.description,
                      style: AppTextStyles.mainStyleWhite12(
                        context,
                      ).copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: smallSpacing * 0.8),
            Text(
              "DOCUMENTACIÓN ADJUNTA",
              style: AppTextStyles.mainStyleGrey12Bold(
                context,
              ).copyWith(fontSize: 10),
            ),
            SizedBox(height: smallSpacing * 0.8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Image.network(
                              item.evidencia,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.evidencia,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 120,
                            color: Colors.grey[800],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Comprobante_320_CAT.pdf",
                              style: AppTextStyles.mainStyleWhite10Bold(
                                context,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "2.4 MB • PDF DOCUMENT",
                              style: AppTextStyles.mainStyleWhite12(
                                context,
                              ).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.download, color: colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: smallSpacing * 1),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff2df1d),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: smallSpacing * 0.8,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Aprobar Solicitud",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: smallSpacing * 0.8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.red,
                            side: BorderSide(color: colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Rechazar",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.lead,
                            side: BorderSide(color: colors.lead),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.mainStyleGrey12Bold(
                context,
              ).copyWith(fontSize: 10),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: highlight ? Colors.yellow : Colors.white,
              fontSize: highlight ? 14 : 10,
            ),
          ),
        ],
      ),
    );
  }
}
