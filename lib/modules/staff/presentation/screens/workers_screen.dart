import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/core/widgets/logout_button_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/worker_card_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

@RoutePage()
class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  String rol = "";
  int selectedTab = 0;
  late final StaffBloc _bloc;
  String _search = '';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _loadUserData() async {
    await UserSession.loadSession();
    final role = await UserSession.getRole();
    setState(() {
      rol = role;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    _bloc.add(GetEmployeesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (selectedTab == index) return;

    setState(() {
      selectedTab = index;
    });

    _bloc.add(
      GetEmployeesEvent(
        page: 1,
        search: _search,
        status: index == 1 ? 'ACTIVO' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: TColors.appMainDarkColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(90),
          ),
          child: const Icon(
            Icons.person_add_alt_1,
            color: Colors.white,
            size: 24,
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              _buildSearchSection(),

              _buildTabs(),

              Expanded(
                child: BlocBuilder<StaffBloc, StaffState>(
                  builder: (context, state) {
                    final currentState = state is EmployeesPageLoading
                        ? state.previousState
                        : state;

                    if (state is EmployeesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is EmployeesError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: TColors.disabled),
                        ),
                      );
                    }

                    if (currentState is EmployeesLoaded) {
                      final employees = currentState.employees;

                      if (state is EmployeesPageLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (employees.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.people_outline,
                                size: 55,
                                color: TColors.disabled,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No se encontraron trabajadores',
                                style: TextStyle(
                                  color: TColors.disabled,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                        itemCount: employees.length,
                        itemBuilder: (_, index) {
                          final employee = employees[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: WorkerCardWidget(
                              image: employee.profilePhotoUrl,
                              name: employee.fullName,
                              position: employee.position,
                              location: employee.department,
                              status: employee.status,
                              actionText: 'Ver Perfil',
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),

              _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
      decoration: const BoxDecoration(
        color: TColors.white,
        border: Border(bottom: BorderSide(color: Color(0xffEAECF0))),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: TColors.appMainDarkColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings, color: TColors.white, size: 18),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserSession.userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.appMainDarkColor,
                    height: 1,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  (rol == 'jefe_personal') ? 'Jefe de Personal' : '',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: TColors.disabled,
                    letterSpacing: 0.8,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          LogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffD0D5DD)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),

            const Icon(Icons.search, color: TColors.disabled, size: 22),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.appMainTextColor,
                ),
                onChanged: (value) {
                  _search = value.trim();

                  _bloc.add(
                    GetEmployeesEvent(
                      page: 1,
                      search: _search,
                      status: selectedTab == 1 ? 'ACTIVO' : null,
                    ),
                  );
                },
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'Buscar trabajadores por nombre, cargo o ID...',
                  hintStyle: TextStyle(fontSize: 13, color: TColors.disabled),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (_, state) {
        final currentState = state is EmployeesPageLoading
            ? state.previousState
            : state;

        final total = currentState is EmployeesLoaded ? currentState.total : 0;

        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTab(
                      title: 'Todos',
                      count: total.toString(),
                      index: 0,
                    ),
                  ),

                  Expanded(child: _buildTab(title: 'Activos', index: 1)),
                ],
              ),

              const SizedBox(height: 2),

              Container(
                width: double.infinity,
                height: 1,
                color: TColors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (_, state) {
        final currentState = state is EmployeesPageLoading
            ? state.previousState
            : state;

        if (currentState is! EmployeesLoaded) {
          return const SizedBox();
        }
        final currentPage = currentState.currentPage;
        final totalPages = currentState.totalPages;
        final isFirstPage = currentPage == 1;
        final isLastPage = currentPage == totalPages;
        

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isFirstPage) ...[
                _paginationButton(
                  icon: Icons.chevron_left,
                  onTap: () {
                    _bloc.add(
                      GetEmployeesEvent(
                        page: currentPage - 1,
                        search: _search,
                        status: selectedTab == 1 ? 'ACTIVO' : null,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 18),
              ],

              Text(
                'Página $currentPage de $totalPages',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TColors.appMainTextColor,
                ),
              ),

              if (!isLastPage) ...[
                const SizedBox(width: 18),

                _paginationButton(
                  icon: Icons.chevron_right,
                  onTap: () {
                    _bloc.add(
                      GetEmployeesEvent(
                        page: currentPage + 1,
                        search: _search,
                        status: selectedTab == 1 ? 'ACTIVO' : null,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _paginationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffD0D5DD)),
        ),
        child: Icon(icon, size: 18, color: TColors.appMainTextColor),
      ),
    );
  }

  Widget _buildTab({required String title, required int index, String? count}) {
    final bool isActive = selectedTab == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTap(index),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? TColors.appMainDarkColor : TColors.disabled,
                ),
              ),

              if (count != null) ...[
                const SizedBox(width: 4),

                Text(
                  '($count)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: TColors.disabled,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            width: isActive ? 92 : 0,
            height: 2.2,
            decoration: BoxDecoration(
              color: TColors.appMainDarkColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }
}
