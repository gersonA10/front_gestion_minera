// import 'package:flutter/material.dart';
// import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
// import 'package:front_gestion_minera/utils/constants/color.constant.dart';

// class SubmittingOverlay extends StatelessWidget {
//   final String title;
//   final String subtitle;

//   const SubmittingOverlay({
//     super.key,
//     this.title = 'Cargando',
//     this.subtitle = 'Espera un momento',
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ColoredBox(
//       color: Colors.black.withValues(alpha: 0.35),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           decoration: BoxDecoration(
//             color: TColors.white,
//             borderRadius: BorderRadius.circular(22),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 width: 168,
//                 height: 172,
//                 child: StaffLoader(label: title.replaceAll('...', '').trim()),
//               ),
//               if (subtitle.isNotEmpty) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: TColors.textSecondary,
//                     fontSize: 12.5,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
