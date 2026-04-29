import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/utils/assets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class CardMachineryWidget extends StatelessWidget {
  final MachineryEntity machine;
  const CardMachineryWidget({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(DetailMachineryRoute(machineId: machine.machineId));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: TColors.appBackgroundColor,
                child: FadeInImage.assetNetwork(
                  placeholder: AssetImageApp.getIconLoading,
                  image: machine.photoUrl ?? '',
                  fit: BoxFit.cover,
                  imageErrorBuilder: (_, _, _) {
                    return Center(child: const Icon(Icons.image_not_supported, size: 30));
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    machine.description,
                    style: TextStyle(color: TColors.textFieldDisabledColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _viewState(machine.status.toLowerCase()),
          ],
        ),
      ),
    );
  }

  Widget _viewState(String tipo) {
    if (tipo == 'activo') {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: TColors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'ACTIVO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.green.withValues(alpha: 0.9),
            fontSize: 10,
          ),
        ),
      );
    }
    if (tipo == 'en mantenimiento') {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: TColors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'MANTENIMIENTO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.amber.withValues(alpha: 0.9),
            fontSize: 10,
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: TColors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        'INACTIVO',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: TColors.red.withValues(alpha: 0.9),
          fontSize: 10,
        ),
      ),
    );
  }
}
