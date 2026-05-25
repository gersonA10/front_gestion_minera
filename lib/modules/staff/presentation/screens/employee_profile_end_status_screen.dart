import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5F6FA),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2D2D2D), size: 18),
        onPressed: () {},
      ),
      title: const Text(
        'PERFIL DEL TRABAJADOR',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D2D2D),
          letterSpacing: 1.4,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            Icons.verified_rounded,
            color: const Color(0xFF1A73E8),
            size: 24,
          ),
        ),
      ],
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
                  color: const Color(0xFFE8EDF5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: const Color(0xFFCDD8EC),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 52,
                    color: Color(0xFF7A9CC9),
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
                  color: const Color(0xFF34C759),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
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
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'OPERADOR DE MAQUINARIA PESADA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A73E8),
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
                  size: 15, color: Color(0xFF8A8FA8)),
              const SizedBox(width: 6),
              const Text(
                'ESTADO DEL TRABAJADOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A8FA8),
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
                      color: Color(0xFF8A8FA8),
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Último procesamiento: 01 Oct 2023',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFADB5C7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FB),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    size: 15,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Sueldo Base',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3D4459),
                    ),
                  ),
                ),
                const Text(
                  '\$1.450.000',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
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
      backgroundColor: const Color(0xFFFFFBF0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CC),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: Color(0xFFF5A623),
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
                  color: Color(0xFFBF8C2E),
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '4 Años, 2 Meses',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
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

// ─── Enums ───────────────────────────────────────────────────────────────────

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
        return const Color(0xFF34C759);
      case WorkerStatus.descanso:
        return const Color(0xFFFF9500);
      case WorkerStatus.inactivo:
        return const Color(0xFFADB5C7);
    }
  }

  Color get selectedBg {
    switch (this) {
      case WorkerStatus.activo:
        return const Color(0xFFE8F9EE);
      case WorkerStatus.descanso:
        return const Color(0xFFFFF4E5);
      case WorkerStatus.inactivo:
        return const Color(0xFFF0F1F5);
    }
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

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
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.05),
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
              isSelected ? status.dotColor.withOpacity(0.3) : Colors.transparent,
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
                  ? const Color(0xFF1A1A2E)
                  : const Color(0xFF8A8FA8),
            ),
          ),
        ],
      ),
    );
  }
}