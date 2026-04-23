import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class MaintenanceRequestHistoryScreen extends StatefulWidget {
  const MaintenanceRequestHistoryScreen({super.key});

  @override
  State<MaintenanceRequestHistoryScreen> createState() =>
      _MaintenanceRequestHistoryScreenState();
}

class _MaintenanceRequestHistoryScreenState
    extends State<MaintenanceRequestHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => context.router.back(),
        ),
        title: Text(
          'Solicitudes de Mantenimiento',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor:  TColors.textPrimary,
          unselectedLabelColor: Color(0xFF9CA3AF),
          indicatorColor: TColors.textPrimary,
          indicatorWeight: 2.5,
          labelStyle:  TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dividerColor: TColors.appSecondaryTextColor,
          unselectedLabelStyle:  TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs:  [
            Tab(text: 'Historial'),
            Tab(text: 'Pendientes'),
            Tab(text: 'Completadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistorialTab(),
          _buildPendientesTab(),
          _buildCompletadasTab(),
        ],
      ),
    );
  }

  Widget _buildHistorialTab() {
    final requests = [
      MaintenanceRequest(
        title: 'Reparación Aire\nAcondicionado',
        date: '15 Oct 2023',
        code: '#MT-8842',
        description:
            'Mantenimiento preventivo y limpieza profunda de filtros en unidad central.',
        costLabel: 'Costo total',
        amount: '120.00',
        status: RequestStatus.aprobado,
        icon: Icons.ac_unit,
        iconColor: const Color(0xFF6366F1),
        iconBg: const Color(0xFFEEF2FF),
      ),
      MaintenanceRequest(
        title: 'Fuga de Agua - Cocina',
        date: '02 Nov 2023',
        code: '#MT-9012',
        description:
            'Goteo constante en la tubería principal debajo del fregadero de la cocina.',
        costLabel: 'Presupuesto est.',
        amount: '45.00',
        status: RequestStatus.pendiente,
        icon: Icons.water_drop_outlined,
        iconColor: const Color(0xFF3B82F6),
        iconBg: const Color(0xFFEFF6FF),
      ),
      MaintenanceRequest(
        title: 'Cambio de Panel\nEléctrico',
        date: '28 Oct 2023',
        code: '#MT-8955',
        description:
            'Actualización a panel de 200 amperios para nueva instalación de cargador EV.',
        costLabel: 'Cotización',
        amount: '850.00',
        status: RequestStatus.rechazado,
        icon: Icons.bolt,
        iconColor: const Color(0xFFEF4444),
        iconBg: const Color(0xFFFEF2F2),
      ),
      MaintenanceRequest(
        title: 'Copia de Llaves\nMaestras',
        date: '12 Oct 2023',
        code: '#MT-8731',
        description:
            'Solicitud de 3 juegos adicionales de llaves para el acceso lateral del edificio.',
        costLabel: 'Costo total',
        amount: '35.00',
        status: RequestStatus.aprobado,
        icon: Icons.vpn_key_outlined,
        iconColor: const Color(0xFF6B7280),
        iconBg: const Color(0xFFF3F4F6),
      ),
    ];

    return ListView.builder(
      padding:  EdgeInsets.symmetric(vertical: 8),
      itemCount: requests.length,
      itemBuilder: (context, index) =>
          _MaintenanceCard(request: requests[index]),
    );
  }

  Widget _buildPendientesTab() {
    return const Center(
      child: Text(
        'Sin solicitudes pendientes',
        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
      ),
    );
  }

  Widget _buildCompletadasTab() {
    return const Center(
      child: Text(
        'Sin solicitudes completadas',
        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
      ),
    );
  }
}


enum RequestStatus { aprobado, pendiente, rechazado }

extension _RequestStatusExtension on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.aprobado:
        return 'APROBADO';
      case RequestStatus.pendiente:
        return 'PENDIENTE';
      case RequestStatus.rechazado:
        return 'RECHAZADO';
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.aprobado:
        return const Color(0xFF16A34A);
      case RequestStatus.pendiente:
        return const Color(0xFFD97706);
      case RequestStatus.rechazado:
        return const Color(0xFFDC2626);
    }
  }

  Color get bgColor {
    switch (this) {
      case RequestStatus.aprobado:
        return const Color(0xFFDCFCE7);
      case RequestStatus.pendiente:
        return const Color(0xFFFEF3C7);
      case RequestStatus.rechazado:
        return const Color(0xFFFEE2E2);
    }
  }
}


class MaintenanceRequest {
  final String title;
  final String date;
  final String code;
  final String description;
  final String costLabel;
  final String amount;
  final RequestStatus status;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  const MaintenanceRequest({
    required this.title,
    required this.date,
    required this.code,
    required this.description,
    required this.costLabel,
    required this.amount,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}


class _MaintenanceCard extends StatelessWidget {
  final MaintenanceRequest request;

  const _MaintenanceCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: request.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(request.icon, color: request.iconColor, size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.date} • ${request.code}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.status.bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    request.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: request.status.color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              request.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.costLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  request.amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}