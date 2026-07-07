import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/bloc/surveillance_bloc.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class ApplicationTrayWidget extends StatelessWidget {
  const ApplicationTrayWidget({
    super.key,
    required this.context,
    required this.smallSpacing,
    required this.topPadding,
  });

  final BuildContext context;
  final double topPadding;
  final double smallSpacing;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SurveillanceBloc, SurveillanceState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: topPadding * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: smallSpacing * 0.5),
              Row(
                children: [
                  Text(
                    "PENDIENTES (3)",
                    style: AppTextStyles.mainStyleGrey12Bold(context),
                  ),
                  SizedBox(width: smallSpacing * 0.8),
                  Expanded(
                    child: Container(height: 1, color: Colors.grey.shade300),
                  ),
                ],
              ),
              SizedBox(height: smallSpacing * 0.5),
              /* Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return RequestCard(
                      date: "12 OCT 2023",
                      name: "Ing. Roberto Sánchez",
                      area: "Operaciones Mina",
                      small: smallSpacing,
                      item: ,
                    );
                  },
                ),
              ),*/
            ],
          ),
        );
      },
    );
  }
}
