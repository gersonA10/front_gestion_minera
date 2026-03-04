import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class CustomCardWidget extends StatelessWidget {
  const CustomCardWidget({
    super.key,
    required this.screenSize,
    required this.topPadding,
    required this.smallSpacing,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Size screenSize;
  final double topPadding;
  final double smallSpacing;
  final IconData icon;
  final String title;
  final String subtitle;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenSize.height * 0.17,
        width: screenSize.width * 0.43,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.lead,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(topPadding * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(topPadding * 0.05),
                margin: EdgeInsets.only(top: topPadding * 0.05),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.bajo,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: smallSpacing * 1.5,
                  color: Theme.of(context).colorScheme.amber,
                ),
              ),
              SizedBox(height: smallSpacing * 0.8),
              Text(
                title,
                style: AppTextStyles.mainStyle12Bold(context),
                textAlign: TextAlign.start,
              ),
              Text(
                subtitle,
                style: AppTextStyles.mainStyle10(context),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
