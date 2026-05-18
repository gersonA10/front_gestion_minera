import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/bloc/minutes_memos_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class RegisterWidget extends StatelessWidget {
  final MinutesMemosBloc bloc;
  const RegisterWidget({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: TColors.appMainDarkColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  await context.router.push(
                    RegisterMinutesMemosRoute(isOption: 0),
                  );
                  bloc.add(GetActasMoemoCountEvent());
                  bloc.add(GetActasEvent());
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Registrar Acta',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TColors.appMainDarkColor, width: 1.5),
              ),
              child: TextButton(
                onPressed: () async {
                  await context.router.push(
                    RegisterMinutesMemosRoute(isOption: 1),
                  );
                  bloc.add(GetActasMoemoCountEvent());
                  bloc.add(GetMemorandosEvent());
                },
                style: TextButton.styleFrom(
                  foregroundColor: TColors.appMainDarkColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Nuevo Memorando',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
