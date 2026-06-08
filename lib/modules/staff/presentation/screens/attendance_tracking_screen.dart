import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/attendance_en_planta_entity.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/attendance_finalizado_entity.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/attendance_ingreso_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_en_planta_tab.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_finalizados_tab.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_ingreso_tab.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

enum _Tab { ingreso, enPlanta, finalizados }

@RoutePage()
class AttendanceControlScreen extends StatefulWidget {
  const AttendanceControlScreen({super.key});

  @override
  State<AttendanceControlScreen> createState() =>
      _AttendanceControlScreenState();
}

class _AttendanceControlScreenState extends State<AttendanceControlScreen> {
  late final StaffBloc _bloc;
  _Tab _selectedTab = _Tab.ingreso;

  List<AttendanceIngresoEntity> _ingresoData = [];
  List<AttendanceEnPlantaEntity> _plantaData = [];
  List<AttendanceFinalizadoEntity> _finalizadoData = [];

  bool _ingresoLoading = false;
  bool _plantaLoading = false;
  bool _finalizadoLoading = false;

  String? _ingresoError;
  String? _plantaError;
  String? _finalizadoError;

  DateTime _finalizadoDate = DateTime.now();
  final Set<String> _registeredIngreso = {};

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    _bloc.add(GetAttendanceIngresoEvent());
  }

  void _fetchFinalizado(DateTime date) =>
      _bloc.add(GetAttendanceFinalizadoEvent(date: _isoDate(date)));

  void _onTabChanged(_Tab tab) {
    setState(() => _selectedTab = tab);
    switch (tab) {
      case _Tab.ingreso:
        if (_ingresoData.isEmpty && !_ingresoLoading) {
          _bloc.add(GetAttendanceIngresoEvent());
        }
      case _Tab.enPlanta:
        if (_plantaData.isEmpty && !_plantaLoading) {
          _bloc.add(GetAttendanceEnPlantaEvent());
        }
      case _Tab.finalizados:
        if (_finalizadoData.isEmpty && !_finalizadoLoading) {
          _bloc.add(
            GetAttendanceFinalizadoEvent(date: _isoDate(_finalizadoDate)),
          );
        }
    }
  }

  void _onFinalizadoDateChanged(DateTime date) {
    setState(() {
      _finalizadoDate = date;
      _finalizadoData = [];
      _finalizadoError = null;
    });
    _fetchFinalizado(date);
  }

  void _onRegisterEntry(String name) {
    setState(() => _registeredIngreso.add(name));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Entrada registrada: $name',
          style: const TextStyle(fontSize: 13),
        ),
        backgroundColor: TColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onRegisterExit(PlantaWorker worker) async {
  final result = await context.router.push<bool>(
    EmployeeCheckOutLogRoute(
      worker: worker,
    ),
  );

  if (result == true) {
    _bloc.add(GetAttendanceEnPlantaEvent());
  }
}

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is AttendanceIngresoLoading) {
            setState(() {
              _ingresoLoading = true;
              _ingresoError = null;
            });
          } else if (state is AttendanceIngresoLoaded) {
            setState(() {
              _ingresoLoading = false;
              _ingresoData = state.employees;
            });
          } else if (state is AttendanceIngresoError) {
            setState(() {
              _ingresoLoading = false;
              _ingresoError = state.message;
            });
          } else if (state is AttendanceEnPlantaLoading) {
            setState(() {
              _plantaLoading = true;
              _plantaError = null;
            });
          } else if (state is AttendanceEnPlantaLoaded) {
            setState(() {
              _plantaLoading = false;
              _plantaData = state.employees;
            });
          } else if (state is AttendanceEnPlantaError) {
            setState(() {
              _plantaLoading = false;
              _plantaError = state.message;
            });
          } else if (state is AttendanceFinalizadoLoading) {
            setState(() {
              _finalizadoLoading = true;
              _finalizadoError = null;
            });
          } else if (state is AttendanceFinalizadoLoaded) {
            setState(() {
              _finalizadoLoading = false;
              _finalizadoData = state.employees;
            });
          } else if (state is AttendanceFinalizadoError) {
            setState(() {
              _finalizadoLoading = false;
              _finalizadoError = state.message;
            });
          }
        },
        child: Scaffold(
          backgroundColor: TColors.background,
          appBar: AppBar(
            title: const Text(
              'Control de Asistencia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            backgroundColor: TColors.surface,
            foregroundColor: TColors.profileDarkText,
            elevation: 1,
          ),
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: TColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: TColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: _Tab.values.map((tab) {
            final isSelected = _selectedTab == tab;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onTabChanged(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected ? TColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.07),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tabLabel(tab),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? TColors.primary
                          : TColors.profileMutedLabel,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case _Tab.ingreso:
        return AttendanceIngresoTab(
          workers: _ingresoData.map(_toIngresoWorker).toList(),
          registered: _registeredIngreso,
          onRegister: _onRegisterEntry,
          isLoading: _ingresoLoading,
          errorMessage: _ingresoError,
        );
      case _Tab.enPlanta:
        return AttendanceEnPlantaTab(
          workers: _plantaData.map(_toPlantaWorker).toList(),
          onRegisterExit: _onRegisterExit,
          isLoading: _plantaLoading,
          errorMessage: _plantaError,
        );
      case _Tab.finalizados:
        final totalMinutes = _finalizadoData.fold(
          0,
          (sum, e) => sum + e.totalWorkedMinutes,
        );
        return AttendanceFinalizadosTab(
          workers: _finalizadoData.map(_toFinalizadoWorker).toList(),
          totalHours: (totalMinutes ~/ 60).toString(),
          totalMinutes: (totalMinutes % 60).toString().padLeft(2, '0'),
          selectedDate: _finalizadoDate,
          onDateChanged: _onFinalizadoDateChanged,
          isLoading: _finalizadoLoading,
          errorMessage: _finalizadoError,
        );
    }
  }

  // ─── Entity → UI model mappers ──────────────────────────────────────────────

  IngresoWorker _toIngresoWorker(AttendanceIngresoEntity e) {
    return IngresoWorker(
      employeeId: e.employeeId,
      name: e.fullName,
      role: e.position,
      scheduledTime: e.scheduledTime,
      isLate: _isLate(e.scheduledTime),
    );
  }

  PlantaWorker _toPlantaWorker(AttendanceEnPlantaEntity e) {
    return PlantaWorker(
      name: e.fullName,
      department: e.department,
      entryTime: e.checkInTime,
      attendanceId: e.attendanceId,
    );
  }

  FinalizadoWorker _toFinalizadoWorker(AttendanceFinalizadoEntity e) {
    return FinalizadoWorker(
      idEmployee: e.employeeId,
      name: e.fullName,
      shift: e.shiftType,
      department: e.department,
      entryTime: e.checkInTime,
      exitTime: e.checkOutTime,
      totalTime: _formatMinutes(e.totalWorkedMinutes),
      totalTimeColor: e.hasIncident ? TColors.warning : TColors.primary,
      status: e.hasIncident
          ? FinalizadoStatus.revision
          : FinalizadoStatus.finalizado,
      avatarColor: _avatarColor(e.fullName),
      initials: _initials(e.fullName),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  bool _isLate(String scheduledTime) {
    final parts = scheduledTime.split(':');
    if (parts.length != 2) return false;
    final scheduledMinutes =
        int.tryParse(parts[0])! * 60 + int.tryParse(parts[1])!;
    final now = TimeOfDay.now();
    return now.hour * 60 + now.minute > scheduledMinutes;
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF1A56FF),
      Color(0xFF6366F1),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  String _isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _tabLabel(_Tab tab) {
    switch (tab) {
      case _Tab.ingreso:
        return 'Ingreso';
      case _Tab.enPlanta:
        return 'En Planta';
      case _Tab.finalizados:
        return 'Finalizados';
    }
  }
}
