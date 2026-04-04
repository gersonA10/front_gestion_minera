import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/admin/presentation/widgets/bottom_nav_widget.dart';
import 'package:front_gestion_minera/modules/admin/presentation/bloc/admin_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../../../core/widgets/logout_button_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _adminBloc = InjectorContainer.getIt<AdminBloc>();

    _pages = [
      const _SolicitudesPendientesPage(),
      const HistorialRequestsScreen(),
      const ContributionAdminScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _adminBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavWidget(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

class _SolicitudesPendientesPage extends StatefulWidget {
  const _SolicitudesPendientesPage();

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
                  _buildTitleSection(_totalRecords),
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
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
          Spacer(),
          LogoutButton(),
        ],
      ),
    );
  }

  Widget _buildTitleSection(int totalRecords) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GESTIÓN CENTRAL',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A96A8),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Solicitudes\nPendientes',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _PendienteBadge(total: totalRecords),
              const SizedBox(width: 12),
            ],
          ),
        ],
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

class _PendienteBadge extends StatelessWidget {
  final int total;
  const _PendienteBadge({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFE8533F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$total PENDIENTES',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE8533F),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
