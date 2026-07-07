import 'package:flutter/material.dart';

import '../../../../utils/constants/color.constant.dart';

class CardMaintenanceWidget extends StatelessWidget {
  const CardMaintenanceWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
      margin: EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TColors.appBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.history),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cambio HIstoria',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      'fecha',
                      style: TextStyle(color: TColors.greyText),
                    ),
                    Text(
                      ' - ',
                      style: TextStyle(color: TColors.greyText),
                    ),
                    Text(
                      'Id: ',
                      style: TextStyle(color: TColors.greyText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _viewStatemaintence('completado')
        ],
      ),
    );
  }
  Widget _viewStatemaintence(String tipo) {
    if (tipo == 'completado') {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: TColors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'Completado',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.green.withValues(alpha: 0.9),
            fontSize: 10,
          ),
        ),
      );
    }
    if (tipo == 'en proceso') {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: TColors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'En Proceso',
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
        'Pendiente',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: TColors.red.withValues(alpha: 0.9),
          fontSize: 10,
        ),
      ),
    );
  }
}
