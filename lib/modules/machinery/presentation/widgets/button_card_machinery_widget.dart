import 'package:flutter/material.dart';

import '../../../../utils/assets.dart';
import '../../../../utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';

class ButtonCardMachineryWidget extends StatelessWidget {
  final MachineryEntity machinery;
  const ButtonCardMachineryWidget({super.key, required this.machinery});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: Container(
                width: 150,
                height: 100,
                color: TColors.appBackgroundColor,
                child: FadeInImage.assetNetwork(
                  placeholder: AssetImageApp.getIconLoading,
                  image: machinery.photoUrl ?? '',
                  fit: BoxFit.cover,
                  imageErrorBuilder: (_, _, _) {
                    return Center(
                      child: const Icon(Icons.image_not_supported, size: 30),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machinery.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Unit ID: ${machinery.uniqueCode}'),
                    ],
                  ),
                ),
                _viewState(machinery.status.toLowerCase())
              ],
            ),
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
