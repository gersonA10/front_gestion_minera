import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_prefs.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_tts.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/payroll_screen.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/screens.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:showcaseview/showcaseview.dart';

/// Metadatos de cada destino del módulo (tab del bottom nav).
class _Destination {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData activeIcon;
  const _Destination({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.activeIcon,
  });
}

const List<_Destination> _kDestinations = [
  _Destination(
    label: 'Trabajadores',
    title: 'Trabajadores',
    subtitle: 'Gestiona y registra a tu personal',
    icon: Icons.groups_outlined,
    activeIcon: Icons.groups_rounded,
  ),
  _Destination(
    label: 'Nómina',
    title: 'Nómina',
    subtitle: 'Pagos y caja del personal',
    icon: Icons.payments_outlined,
    activeIcon: Icons.payments_rounded,
  ),
  _Destination(
    label: 'Egresos',
    title: 'Solicitar egreso',
    subtitle: 'Solicita fondos de nómina a Hacienda',
    icon: Icons.request_quote_outlined,
    activeIcon: Icons.request_quote_rounded,
  ),
  _Destination(
    label: 'Turnos',
    title: 'Control de turnos',
    subtitle: 'Asistencia: ingreso, en planta y finalizados',
    icon: Icons.schedule_outlined,
    activeIcon: Icons.schedule_rounded,
  ),
];

@RoutePage()
class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late final List<Widget> _screens;

  // ─── Tutorial (coach marks) ──────────────────────────────────────────────
  late final ShowcaseView _showcaseView;
  final GlobalKey _heroKey = GlobalKey();
  final List<GlobalKey> _navKeys =
      List.generate(_kDestinations.length, (_) => GlobalKey());

  List<GlobalKey> get _showcaseKeys => [_heroKey, ..._navKeys];

  static const List<String> _speechByStep = [
    'Bienvenido a tu panel de Jefe de Personal. Desde aquí gestionas a todo el '
        'equipo. Puedes repetir este recorrido cuando quieras con el botón de '
        'ayuda.',
    'Trabajadores. Consulta, busca y registra a tu personal, y revisa el perfil '
        'de cada trabajador.',
    'Nómina. Genera y paga la nómina del personal, administra la caja chica y '
        'consulta el historial de pagos.',
    'Solicitar egreso. Pide a Hacienda los fondos para pagar la nómina y haz '
        'seguimiento de tus solicitudes.',
    'Turnos. Controla la asistencia del personal: registra ingresos, mira quién '
        'está en planta y revisa los turnos finalizados.',
  ];

  @override
  void initState() {
    super.initState();

    _screens = const [
      WorkersScreen(),
      PayrollScreen(),
      StaffExpenditureRequestScreen(),
      AttendanceControlScreen(),
    ];

    _showcaseView = ShowcaseView.register(
      scope: StaffUi.tutorialScope,
      enableAutoScroll: false,
      onStart: (index, _) => _speakStep(index),
      onComplete: (index, _) => _maybeReturnHome(index),
      onFinish: _markTutorialSeen,
      onDismiss: (_) => _markTutorialSeen(),
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
      ),
      globalTooltipActions: [
        const TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'Saltar',
          backgroundColor: Colors.transparent,
          textStyle: TextStyle(
            color: StaffUi.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Siguiente',
          backgroundColor: StaffUi.primary,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTutorial());
  }

  void _speakStep(int? index) {
    if (index == null || index < 0 || index >= _speechByStep.length) return;
    TutorialTts.instance.speak(_speechByStep[index]);
  }

  /// El último paso del recorrido deja al usuario de vuelta en Trabajadores.
  void _maybeReturnHome(int? index) {
    if (index == _showcaseKeys.length - 1 && _currentIndex != 0) {
      _goToTab(0);
    }
  }

  Future<void> _maybeStartTutorial() async {
    final alreadySeen = await TutorialPrefs.hasSeen(StaffUi.tutorialRoleKey);
    if (alreadySeen || !mounted) return;
    _startTutorial();
  }

  void _startTutorial() {
    _showcaseView.startShowCase(
      _showcaseKeys,
      delay: const Duration(milliseconds: 400),
    );
  }

  void _markTutorialSeen() {
    TutorialTts.instance.stop();
    TutorialPrefs.markSeen(StaffUi.tutorialRoleKey);
  }

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  @override
  void dispose() {
    TutorialTts.instance.stop();
    _showcaseView.unregister();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dest = _kDestinations[_currentIndex];

    return Scaffold(
      backgroundColor: StaffUi.background,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.router.push(RegisterStaffRoute()),
              backgroundColor: StaffUi.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: const Text(
                'Registrar',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            )
          : null,
      body: Column(
        children: [
          staffCoachMark(
            key: _heroKey,
            title: 'Tu panel de Jefe de Personal',
            description:
                'Desde aquí gestionas a todo el equipo. Usa el botón de ayuda '
                'para repetir este recorrido cuando quieras.',
            child: StaffHeroHeader(
              title: dest.title,
              subtitle: dest.subtitle,
              icon: dest.activeIcon,
              onHelp: _startTutorial,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _StaffBottomNav(
        currentIndex: _currentIndex,
        onTap: _goToTab,
        navKeys: _navKeys,
      ),
    );
  }
}

/// Bottom navigation premium con indicador tipo "pill" e iconos redondeados.
class _StaffBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlobalKey> navKeys;
  const _StaffBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.navKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StaffUi.surface,
        border: Border(top: BorderSide(color: StaffUi.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (int i = 0; i < _kDestinations.length; i++)
                Expanded(
                  child: staffCoachMark(
                    key: navKeys[i],
                    title: _kDestinations[i].title,
                    description: _tutorialHintFor(i),
                    child: _NavItem(
                      destination: _kDestinations[i],
                      active: currentIndex == i,
                      onTap: () => onTap(i),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _tutorialHintFor(int i) {
    switch (i) {
      case 0:
        return 'Consulta, busca y registra a tu personal.';
      case 1:
        return 'Genera y paga la nómina, y administra la caja chica.';
      case 2:
        return 'Pide a Hacienda los fondos para pagar la nómina.';
      default:
        return 'Controla la asistencia: ingreso, en planta y finalizados.';
    }
  }
}

class _NavItem extends StatelessWidget {
  final _Destination destination;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? StaffUi.primary : StaffUi.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: active ? StaffUi.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              active ? destination.activeIcon : destination.icon,
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            destination.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
