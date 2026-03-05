import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class ContributesScreen extends StatelessWidget {
  const ContributesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        backgroundColor: colors.white,
        surfaceTintColor: colors.white,
        title: Text(
          'Historial de ingresos de dividendos',
          style: AppTextStyles.mainStyle17Bold(context),
        ),
      ),
      body: Column(
        children: [
          //Metricas
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  3,
                  (index) => CustomCardMetric(index: index),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomCardMetric extends StatelessWidget {
  const CustomCardMetric({
    required this.index,
    super.key,
  });

  final int index; 

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 140,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: index == 0 ? colors.blue : colors.white,
        border: BoxBorder.all(color: colors.blue, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Center(
        child: Text(
          'Métrica',
          style: AppTextStyles.mainStyleWhite14Bold(context),
        ),
      ),
    );
  }
}
