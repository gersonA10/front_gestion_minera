import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class WorkerCardWidget extends StatelessWidget {
  final String image;
  final String name;
  final String position;
  final String location;
  final String status;
  final String actionText;

  const WorkerCardWidget({
    super.key,
    required this.image,
    required this.name,
    required this.position,
    required this.location,
    required this.status,
    required this.actionText,
  });

  static const String _fallbackImage =
      'https://siu.edu.bd/storage/uploaded/authority/male_1723030204.jpeg';

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);

    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffE7EAF0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        image.isNotEmpty ? image : _fallbackImage,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.network(
                            _fallbackImage,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: style.dotColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color:
                                    TColors.appMainDarkColor,
                                height: 1.1,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: style.backgroundColor,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(
                              style.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: style.textColor,
                                letterSpacing: 0.3,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        position,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: TColors.appSecondaryTextColor,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Icon(
                            status.toLowerCase() ==
                                    'inactivo'
                                ? Icons.access_time
                                : Icons.location_on_outlined,
                            size: 13,
                            color: const Color(0xff98A2B3),
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w500,
                                color: Color(0xff98A2B3),
                                height: 1.2,
                              ),
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

          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xffEEF1F4),
          ),

          InkWell(
            onTap: () {},
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 15,
                    color: TColors.appMainDarkColor,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    actionText.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TColors.appMainDarkColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _WorkerStatusStyle _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return const _WorkerStatusStyle(
          label: 'ACTIVO',
          backgroundColor: Color(0xffECFDF3),
          textColor: Color(0xff16A34A),
          dotColor: Color(0xff22C55E),
        );

      case 'descanso':
        return const _WorkerStatusStyle(
          label: 'DESCANSO',
          backgroundColor: Color(0xffFFF1E8),
          textColor: Color(0xffF97316),
          dotColor: Color(0xffF97316),
        );

      case 'inactivo':
        return const _WorkerStatusStyle(
          label: 'INACTIVO',
          backgroundColor: Color(0xffF2F4F7),
          textColor: Color(0xff98A2B3),
          dotColor: Color(0xff98A2B3),
        );

      default:
        return const _WorkerStatusStyle(
          label: 'DESCONOCIDO',
          backgroundColor: Color(0xffF2F4F7),
          textColor: Color(0xff98A2B3),
          dotColor: Color(0xff98A2B3),
        );
    }
  }
}

class _WorkerStatusStyle {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color dotColor;

  const _WorkerStatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.dotColor,
  });
}