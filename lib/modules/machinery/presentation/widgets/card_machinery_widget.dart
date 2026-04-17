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
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TColors.appMainColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: getEstado(machine.type.toLowerCase()),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
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
          _viewState(machine.status.toLowerCase())
        ],
      ),
    );
  }
    Widget getEstado(String tipo) {
    if (tipo == 'excavadora') {
      return Icon(
        Icons.handyman,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    if (tipo == 'camion_acarreo') {
      return Icon(
        Icons.local_shipping_outlined,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    if (tipo == 'perforadora') {
      return Icon(
        Icons.precision_manufacturing,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    if (tipo == 'tractor') {
      return Icon(
        Icons.agriculture,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    return Icon(
      Icons.construction,
      color: TColors.appMainColor.withValues(alpha: 0.9),
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
