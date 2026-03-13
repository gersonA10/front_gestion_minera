import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

import '../../domain/entity/entity.dart';

class RequestCard extends StatelessWidget {
  final String date;
  final String name;
  final String area;
  final bool urgent;
  final double small;
  final MonitoringTrayDataEntity item;

  const RequestCard({
    super.key,
    required this.date,
    required this.name,
    required this.area,
    this.urgent = false,
    required this.small,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: urgent ? Colors.orange : Colors.grey,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: small * 0.5),
              Text(date, style: AppTextStyles.mainStyleGrey10(context)),
            ],
          ),
          SizedBox(height: small * 0.8),
          Text("SOLICITANTE", style: AppTextStyles.mainStyleGrey10(context)),
          SizedBox(height: small * 0.3),
          Text(name, style: AppTextStyles.mainStyle14Bold(context)),
          SizedBox(height: small * 0.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ÁREA", style: AppTextStyles.mainStyleGrey10(context)),
                    SizedBox(height: small * 0.3),
                    Text(area, style: AppTextStyles.mainStyle12(context)),
                  ],
                ),
              ),
              SizedBox(
                height: small * 2,
                child: ElevatedButton(
                  onPressed: () {
                    InjectorContainer.getIt<AppRouter>().push(
                      ApplicationDetailsRoute(item: item),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Ver Detalle",
                        style: AppTextStyles.mainStyleWhite10Bold(context),
                      ),
                      SizedBox(width: small * 0.3),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
