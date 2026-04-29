import 'package:flutter/widgets.dart';
import '../../../../utils/constants/color.constant.dart';

class CardRequestsWidget extends StatelessWidget {
  final int state;
  const CardRequestsWidget({super.key, required this.state});

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
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text('Descripcion solicitud', style: TextStyle(fontSize: 15)),
                const SizedBox(height: 5),
                Text(
                  'id: datoaref - fecha',
                  style: TextStyle(
                    fontSize: 13,
                    color: TColors.appDisabledColor,
                  ),
                ),
              ],
            ),
          ),
          _tipodato(state.toString()),
        ],
      ),
    );
  }

  Widget _tipodato(String state) {
    if (state == '1') {
      return Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            decoration: BoxDecoration(
              color: TColors.appMainColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('En Revision', style: TextStyle(fontSize: 10,color: TColors.appMainColor,fontWeight: FontWeight.bold)),
          );
    }
    if (state == '2') {
      return Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            decoration: BoxDecoration(
              color: TColors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Completada', style: TextStyle(fontSize: 10,color: TColors.green,fontWeight: FontWeight.bold)),
          );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: TColors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('Rechazada', style: TextStyle(fontSize: 10,color: TColors.red,fontWeight: FontWeight.bold)),
    );
  }
}
