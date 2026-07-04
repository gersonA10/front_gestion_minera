import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_prefs.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_tts.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/admin/home/presentation/widgets/bottom_nav_widget.dart';
import 'package:front_gestion_minera/modules/admin/home/presentation/bloc/admin_bloc.dart';
import 'package:front_gestion_minera/modules/admin/users/presentation/bloc/admin_users_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/widgets/logout_button_widget.dart';
import '../../domain/entity/entity.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

@RoutePage()
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final AdminBloc _adminBloc;

  // ─── Tutorial (coach marks) ───────────────────────────────────────────────
  /// Clave de rol para persistir si el admin ya vio el recorrido guiado.
  static const String _kTutorialRoleKey = 'admin';

  /// Scope propio del recorrido de esta pantalla (evita choques con otros).
  static const String _kShowcaseScope = 'admin_panel';

  /// Cantidad de pestañas del bottom nav (debe coincidir con [BottomNavWidget]).
  static const int _kNavCount = 4;

  late final ShowcaseView _showcaseView;

  /// Una key por pestaña del bottom nav. En showcaseview 5.x estas keys son
  /// identificadores de registro (no se adjuntan al widget), por eso viven aquí.
  final List<GlobalKey> _showcaseKeys =
      List.generate(_kNavCount, (_) => GlobalKey());

  /// Locución de cada pestaña (mismo orden que el BottomNavWidget); la lee
  /// flutter_tts al aparecer cada coach mark.
  static const List<String> _speechByStep = [
    'Bandeja de Solicitudes. Aquí llegan las solicitudes de préstamos y retiros '
        'de los socios. Revísalas para aprobarlas o rechazarlas.',
    'Historial. Consulta todas las solicitudes ya procesadas y el resultado de '
        'cada una.',
    'Aportes. Registra y administra los aportes que hacen los socios al fondo.',
    'Usuarios. Gestiona los usuarios del sistema: crea, edita y administra sus '
        'accesos.',
  ];

  void _speakStep(int? index) {
    if (index == null || index < 0 || index >= _speechByStep.length) return;
    TutorialTts.instance.speak(_speechByStep[index]);
  }

  @override
  void initState() {
    super.initState();
    _adminBloc = InjectorContainer.getIt<AdminBloc>();

    _pages = [
      _SolicitudesPendientesPage(onHelp: _startTutorial),
      const HistorialRequestsScreen(),
      const ContributionAdminScreen(),
      const UsersManagementScreen(),
    ];

    _showcaseView = ShowcaseView.register(
      scope: _kShowcaseScope,
      enableAutoScroll: true,
      onStart: (index, _) => _speakStep(index),
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
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Siguiente',
          backgroundColor: Color(0xFF1A3557),
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    // Lanza el recorrido la primera vez, tras pintar la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTutorial());
  }

  Future<void> _maybeStartTutorial() async {
    final alreadySeen = await TutorialPrefs.hasSeen(_kTutorialRoleKey);
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
    TutorialPrefs.markSeen(_kTutorialRoleKey);
  }

  @override
  void dispose() {
    TutorialTts.instance.stop();
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _adminBloc),
        BlocProvider.value(value: InjectorContainer.getIt<AdminUsersBloc>()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavWidget(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          showcaseKeys: _showcaseKeys,
          showcaseScope: _kShowcaseScope,
        ),
      ),
    );
  }
}

class _SolicitudesPendientesPage extends StatefulWidget {
  const _SolicitudesPendientesPage({required this.onHelp});

  /// Reabre el tutorial (coach marks) cuando el admin toca el botón de ayuda.
  final VoidCallback onHelp;

  @override
  State<_SolicitudesPendientesPage> createState() =>
      _SolicitudesPendientesPageState();
}

class _SolicitudesPendientesPageState
    extends State<_SolicitudesPendientesPage> {
  final ScrollController _scrollController = ScrollController();
  late AdminBloc _adminBloc;

  List<PendingRequestEntity> _cachedItems = [];
  bool _hasMax = false;
  int _totalRecords = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adminBloc = context.read<AdminBloc>();
      final state = _adminBloc.state;
      if (state is! AdminPendingRequestsLoaded &&
          state is! AdminPendingRequestsLoading) {
        _adminBloc.add(GetPendingRequestsEvent(isRefresh: true));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _adminBloc.state;
      if (state is AdminPendingRequestsLoaded && !state.hasReachedMax) {
        _adminBloc.add(LoadMorePendingRequestsEvent());
      }
    }
  }

  Future<void> _onRefresh() async {
    _adminBloc.add(GetPendingRequestsEvent(isRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AdminBloc, AdminState>(
        buildWhen: (previous, current) =>
            current is AdminPendingRequestsLoading ||
            current is AdminPendingRequestsLoaded ||
            current is AdminPendingRequestsError,
        builder: (context, state) {
          bool isLoading =
              state is AdminPendingRequestsLoading || state is AdminInitial;

          if (state is AdminPendingRequestsLoaded) {
            _cachedItems = state.items;
            _hasMax = state.hasReachedMax;
            _totalRecords = state.totalRecords;
          }

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildHero(_totalRecords),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: const Color(0xFF1A3557),
                      child: _buildBody(isLoading, state),
                    ),
                  ),
                ],
              ),

              if (isLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(color: TColors.appMainColor),
                ),
              if (isLoading)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: TColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(bool isLoading, AdminState state) {
    if (state is AdminPendingRequestsError && _cachedItems.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildError(state.message),
      );
    }

    if (_cachedItems.isNotEmpty) {
      return ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _hasMax ? _cachedItems.length : _cachedItems.length + 1,
        itemBuilder: (context, index) {
          if (index >= _cachedItems.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: StaffLoader(),
            );
          }
          return SolicitudCard(solicitud: _cachedItems[index], index: index);
        },
      );
    }

    if (!isLoading && _cachedItems.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: _buildEmpty(),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A3557),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'Administrador',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A3557),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onHelp,
            child: Tooltip(
              message: 'Ver tutorial',
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF1A3557),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          LogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHero(int totalRecords) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF152D49), Color(0xFF20416B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF152D49).withValues(alpha: 0.32),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BANDEJA DE APROBACIÓN',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalRecords',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          totalRecords == 1 ? 'solicitud' : 'solicitudes',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pendientes de tu revisión',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1A3557),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 36,
              color: Color(0xFF93C5FD),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin solicitudes pendientes',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Todas las solicitudes han sido\nrevisadas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

