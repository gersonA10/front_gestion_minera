import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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
  _Tab _selectedTab = _Tab.ingreso;

  final List<IngresoWorker> _pendingWorkers = const [
    IngresoWorker(
      name: 'Carlos Rodriguez',
      role: 'Operador de Maquinaria',
      scheduledTime: '07:00 AM',
      isLate: true,
    ),
    IngresoWorker(
      name: 'Miguel Sanchez',
      role: 'Seguridad Industrial',
      scheduledTime: '07:00 AM',
      isLate: true,
    ),
    IngresoWorker(
      name: 'Ana Torres',
      role: 'Geología',
      scheduledTime: '08:00 AM',
    ),
  ];

  final List<PlantaWorker> _plantaWorkers = const [
    PlantaWorker(
      name: 'Roberto Gomez',
      department: 'Mantenimiento',
      entryTime: '06:45 AM',
    ),
    PlantaWorker(
      name: 'Laura Mendez',
      department: 'Logística',
      entryTime: '07:02 AM',
    ),
    PlantaWorker(
      name: 'Juan Pérez',
      department: 'Transporte',
      entryTime: '07:15 AM',
    ),
  ];

  final List<FinalizadoWorker> _finalizadoWorkers = const [
    FinalizadoWorker(
      name: 'Esteban Soto',
      shift: 'Turno Noche',
      department: 'Operaciones',
      entryTime: '22:00',
      exitTime: '06:30',
      totalTime: '8h 30m',
      totalTimeColor: TColors.primary,
      status: FinalizadoStatus.finalizado,
      avatarColor: Color(0xFF1A56FF),
      initials: 'ES',
    ),
    FinalizadoWorker(
      name: 'Maria Juarez',
      shift: 'Turno Noche',
      department: 'Planta',
      entryTime: '22:15',
      exitTime: '06:15',
      totalTime: '8h 00m',
      totalTimeColor: TColors.primary,
      status: FinalizadoStatus.finalizado,
      avatarColor: Color(0xFF6366F1),
      initials: 'MJ',
    ),
    FinalizadoWorker(
      name: 'Andrés Castro',
      shift: 'Mantenimiento',
      department: 'Incidencia',
      entryTime: '22:00',
      exitTime: '02:00',
      totalTime: '4h 00m',
      totalTimeColor: TColors.warning,
      status: FinalizadoStatus.revision,
      avatarColor: Color(0xFFF59E0B),
      initials: 'AC',
    ),
    FinalizadoWorker(
      name: 'Lucia Ramirez',
      shift: 'Turno Noche',
      department: 'Administración',
      entryTime: '20:00',
      exitTime: '05:00',
      totalTime: '9h 00m',
      totalTimeColor: TColors.primary,
      status: FinalizadoStatus.finalizado,
      avatarColor: Color(0xFF10B981),
      initials: 'LR',
    ),
  ];

  final Set<String> _registeredIngreso = {};

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

  void _onRegisterExit(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Salida registrada: $name',
          style: const TextStyle(fontSize: 13),
        ),
        backgroundColor: TColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onTap: () => setState(() => _selectedTab = tab),
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
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
          workers: _pendingWorkers,
          registered: _registeredIngreso,
          onRegister: _onRegisterEntry,
        );
      case _Tab.enPlanta:
        return AttendanceEnPlantaTab(
          workers: _plantaWorkers,
          onRegisterExit: _onRegisterExit,
        );
      case _Tab.finalizados:
        return AttendanceFinalizadosTab(
          workers: _finalizadoWorkers,
          totalHours: '29',
          totalMinutes: '30',
        );
    }
  }

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
