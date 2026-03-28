  import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key, required this.treasuryBloc});

  final TreasuryBloc treasuryBloc;

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 150,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E63F4), Color(0xFF3F82FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
            boxShadow: [
              BoxShadow(
                color: Color(0x332563EB),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const SizedBox(height: 18),
                  Text(
                    'Hola, ${UserSession.userName}',
                    style: AppTextStyles.mainStyleWhite20Bold(
                      context,
                    ).copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tesoreria / Hacienda',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .88),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  widget.treasuryBloc.add(FetchTreasuryMetricsEvent());
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TColors.disabled.withValues(alpha: 0.25),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: TColors.appBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}