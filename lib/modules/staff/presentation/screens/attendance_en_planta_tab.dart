import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/planta_worker_card_wisget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../widgets/widgets.dart';

class PlantaWorker {
  final String name;
  final String department;
  final String entryTime;
  final String? avatarUrl;
  final String attendanceId;

  const PlantaWorker({
    required this.name,
    required this.department,
    required this.entryTime,
    required this.attendanceId,
    this.avatarUrl,
  });
}

class AttendanceEnPlantaTab extends StatefulWidget {
  final List<PlantaWorker> workers;
  final void Function(PlantaWorker) onRegisterExit;
  final bool isLoading;
  final String? errorMessage;

  const AttendanceEnPlantaTab({
    super.key,
    required this.workers,
    required this.onRegisterExit,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<AttendanceEnPlantaTab> createState() => _AttendanceEnPlantaTabState();
}

class _AttendanceEnPlantaTabState extends State<AttendanceEnPlantaTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.workers
        .where(
          (w) =>
              _searchQuery.isEmpty ||
              w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              w.department.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildHeader(filtered.length),
          const SizedBox(height: 14),
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: StaffLoader(),
            )
          else if (widget.errorMessage != null)
            _buildErrorState(widget.errorMessage!)
          else if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PlantaWorkerCard(
                  worker: w,
                  onRegisterExit: () => widget.onRegisterExit(w),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return AttendanceStatCardWidget(
      label: 'Personal en Planta',
      value: '${widget.workers.length}',
      valueLabel: 'Activos',
      valueLabelColor: TColors.primary,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.border),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 14, color: TColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Buscar empleado, rol o área...',
          hintStyle: TextStyle(fontSize: 13, color: TColors.profileMutedLabel),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: TColors.profileMutedLabel,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Row(
      children: [
        Text(
          'Personal Activo ($count)',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: TColors.textSecondary,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded,
                color: TColors.profileMutedLabel, size: 40),
            SizedBox(height: 10),
            Text(
              'No hay personal en planta',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: TColors.warning,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

