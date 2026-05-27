import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  WorkerStatus _selectedStatus = WorkerStatus.activo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
      elevation: 0,
      title: const Text(
        'PERFIL DEL TRABAJADOR',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: TColors.profileTitleText,
          letterSpacing: 1.4,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            Icons.verified_rounded,
            color: TColors.profileBlue,
            size: 24,
          ),
        ),
      ],
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildAvatarSection(),
            const SizedBox(height: 28),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildPayrollCard(),
            const SizedBox(height: 16),
            _buildSeniorityCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TColors.border,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: TColors.avatarBackground,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 52,
                    color: TColors.avatarIconColor,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: TColors.statusActiveDot,
                  shape: BoxShape.circle,
                  border: Border.all(color: TColors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Juan Pérez',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: TColors.profileDarkText,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'OPERADOR DE MAQUINARIA PESADA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: TColors.profileBlue,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded,
                  size: 15, color: TColors.profileMutedLabel),
              const SizedBox(width: 6),
              const Text(
                'ESTADO DEL TRABAJADOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: TColors.profileMutedLabel,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: WorkerStatus.values.map((status) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStatus = status),
                  child: _StatusChip(
                    status: status,
                    isSelected: _selectedStatus == status,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'ACCIONES DE NÓMINA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TColors.profileMutedLabel,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Último procesamiento: 01 Oct 2023',
                    style: TextStyle(
                      fontSize: 11,
                      color: TColors.statusInactiveDot,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: TColors.profileIconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: TColors.profileBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: TColors.profileCardInnerBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: TColors.profileIconBg,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    size: 15,
                    color: TColors.profileBlue,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Sueldo Base',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TColors.profileBodyText,
                    ),
                  ),
                ),
                const Text(
                  '\$1.450.000',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TColors.profileDarkText,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeniorityCard() {
    return _Card(
      backgroundColor: TColors.seniorityCardBg,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.seniorityIconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: TColors.seniorityIconColor,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ANTIGÜEDAD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: TColors.seniorityLabelColor,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '4 Años, 2 Meses',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TColors.profileDarkText,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


enum WorkerStatus { activo, descanso, inactivo }

extension WorkerStatusExt on WorkerStatus {
  String get label {
    switch (this) {
      case WorkerStatus.activo:
        return 'Activo';
      case WorkerStatus.descanso:
        return 'Descanso';
      case WorkerStatus.inactivo:
        return 'Inactivo';
    }
  }

  Color get dotColor {
    switch (this) {
      case WorkerStatus.activo:
        return TColors.statusActiveDot;
      case WorkerStatus.descanso:
        return TColors.statusRestDot;
      case WorkerStatus.inactivo:
        return TColors.statusInactiveDot;
    }
  }

  Color get selectedBg {
    switch (this) {
      case WorkerStatus.activo:
        return TColors.statusActiveBg;
      case WorkerStatus.descanso:
        return TColors.statusRestBg;
      case WorkerStatus.inactivo:
        return TColors.statusInactiveBg;
    }
  }
}


class _Card extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const _Card({required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor ?? TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.profileBlue.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final WorkerStatus status;
  final bool isSelected;

  const _StatusChip({required this.status, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? status.selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isSelected ? status.dotColor.withValues(alpha: 0.3) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: status.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? TColors.profileDarkText
                  : TColors.profileMutedLabel,
            ),
          ),
        ],
      ),
    );
  }
}
