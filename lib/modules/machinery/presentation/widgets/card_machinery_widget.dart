import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class CardMachineryWidget extends StatelessWidget {
  final MachineryEntity machine;
  const CardMachineryWidget({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: TColors.appBackgroundColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/img/loadingb.gif',
                image: machine.photoUrl ?? '',
                fit: BoxFit.cover,
                imageErrorBuilder: (_, _, _) {
                  return const Icon(Icons.image_not_supported,size: 30,);
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
