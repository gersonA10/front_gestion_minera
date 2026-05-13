import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class InternalMemorandumDetailsScreen extends StatelessWidget {
  const InternalMemorandumDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: TColors.appMainDarkColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const Spacer(),

                  const Text(
                    'Memorando Interno',
                    style: TextStyle(
                      color: TColors.appMainDarkColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Violacion de ley',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: TColors.appMainTextColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FECHA DE EMISIÓN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TColors.appDisabledColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: const [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: TColors.appMainDarkColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '24 de Octubre, 2023',
                          style: TextStyle(
                            fontSize: 13,
                            color: TColors.appMainTextColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Text(
                      'RESPONSABLE / DESTINATARIO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TColors.appDisabledColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: const [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: TColors.appMainDarkColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Ing. Roberto Gómez',
                          style: TextStyle(
                            fontSize: 13,
                            color: TColors.appMainTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
