import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/worker_card_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  int selectedTab = 0;
  int currentPage = 1;
  int totalPages = 12;

  void _onTabTap(int index) {
    if (selectedTab == index) return;

    setState(() {
      selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(RegisterStaffRoute());
        },
        backgroundColor: TColors.appMainDarkColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: const [
                  WorkerCardWidget(
                    image: '',
                    name: 'Ricardo Alarcón',
                    position: 'Ingeniero de Minas Senior',
                    location: 'Planta Atacama',
                    status: 'Activo',
                    actionText: 'Ver Perfil',
                  ),

                  SizedBox(height: 14),

                  WorkerCardWidget(
                    image: '',
                    name: 'Elena Valencia',
                    position: 'Supervisora de Seguridad',
                    location: 'Sede Corporativa',
                    status: 'Activo',
                    actionText: 'Ver Perfil',
                  ),

                  SizedBox(height: 14),

                  WorkerCardWidget(
                    image: '',
                    name: 'Javier Montes',
                    position: 'Operador de Maquinaria',
                    location: 'Mina San José',
                    status: 'Descanso',
                    actionText: 'Ver Perfil',
                  ),

                  SizedBox(height: 14),

                  WorkerCardWidget(
                    image: '',
                    name: 'Sofía Méndez',
                    position: 'Analista de Laboratorio',
                    location: 'Última actividad',
                    status: 'Inactivo',
                    actionText: 'Revisar',
                  ),
                ],
              ),
            ),

            _buildPagination(),
          ],
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
              children: const [
                Text(
                  '14 de septiembre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.appMainDarkColor,
                    height: 1,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'RECURSOS HUMANOS',
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

          IconButton(
            onPressed: () {},
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.description_outlined,
              color: TColors.disabled,
              size: 22,
            ),
          ),
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
          children: const [
            SizedBox(width: 12),

            Icon(Icons.search, color: TColors.disabled, size: 22),

            SizedBox(width: 10),

            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 12, color: TColors.appMainTextColor),
                decoration: InputDecoration(
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
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTab(title: 'Todos', count: '124', index: 0),
              ),

              Expanded(child: _buildTab(title: 'Activos', index: 1)),
            ],
          ),

          const SizedBox(height: 2),

          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xffEAECF0),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final bool isFirstPage = currentPage == 1;
    final bool isLastPage = currentPage == totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(color: TColors.appBackgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isFirstPage) ...[
            _paginationButton(
              icon: Icons.chevron_left,
              onTap: () {
                setState(() {
                  currentPage--;
                });
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
                setState(() {
                  currentPage++;
                });
              },
            ),
          ],
        ],
      ),
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
