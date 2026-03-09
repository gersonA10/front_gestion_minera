import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class HistoryRequestsScreen extends StatefulWidget {
  const HistoryRequestsScreen({super.key});

  @override
  State<HistoryRequestsScreen> createState() => _HistoryRequestsScreenState();
}

class _HistoryRequestsScreenState extends State<HistoryRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Todos';

  final List<Map<String, dynamic>> _mockRequests = [
    {
      'date': '12 OCT 2023',
      'name': 'Juan Perez',
      'desc': 'Compra viveres',
      'status': 'APROBADO',
    },
    {
      'date': '11 OCT 2023',
      'name': 'Maria Garcia',
      'desc': 'Compra combustible',
      'status': 'PENDIENTE',
    },
    {
      'date': '11 OCT 2023',
      'name': 'Maria Garcia',
      'desc': 'Repuestos de maquina',
      'status': 'PENDIENTE',
      // 'borderColorOverride': true, // Para replicar el borde azul de la imagen
    },
    {
      'date': '09 OCT 2023',
      'name': 'Ricardo Soto',
      'desc': 'Logística & Transporte',
      'status': 'RECHAZADO',
      'reason': 'Motivo: Falta firma de supervisor',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        surfaceTintColor: colors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.blue),
          onPressed: () => context.router.back(),
        ),
        title: Text(
          'Historial de Solicitudes',
          style: AppTextStyles.mainStyle16Bold(context).copyWith(color: colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: colors.blue),
            onPressed: () {
              // TODO: Abrir filtros avanzados
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.lead.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: colors.lead.withOpacity(0.8)),
                  hintText: 'Buscar por nombre del solicitante...',
                  hintStyle: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 2. Filtros (Chips horizontales)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildFilterChip('Todos', null, colors.blue, true),
                const SizedBox(width: 10),
                _buildFilterChip('Aprobado', Icons.check_circle_outline, colors.green, false),
                const SizedBox(width: 10),
                _buildFilterChip('Pendiente', Icons.hourglass_bottom, colors.amber, false),
                const SizedBox(width: 10),
                _buildFilterChip('Rechazado', Icons.receipt_long_outlined, colors.red, false),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _mockRequests.length,
              itemBuilder: (context, index) {
                final item = _mockRequests[index];
                return _SurveillanceHistoryCard(
                  date: item['date'],
                  name: item['name'],
                  description: item['desc'],
                  status: item['status'],
                  rejectionReason: item['reason'],
                  forceBlueBorder: item['borderColorOverride'] ?? false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData? icon, Color statusColor, bool isDefault) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDefault && isSelected ? colors.blue : colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDefault && isSelected ? colors.blue : colors.lead.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: statusColor, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isDefault && isSelected ? colors.white : colors.lead,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurveillanceHistoryCard extends StatelessWidget {
  final String date;
  final String name;
  final String description;
  final String status;
  final String? rejectionReason;
  final bool forceBlueBorder;

  const _SurveillanceHistoryCard({
    required this.date,
    required this.name,
    required this.description,
    required this.status,
    this.rejectionReason,
    this.forceBlueBorder = false,
  });

  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status.toUpperCase()) {
      case 'APROBADO':
        return colors.green;
      case 'PENDIENTE':
        return colors.amber;
      case 'RECHAZADO':
        return colors.red;
      default:
        return colors.lead;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(status, colors);
    
    // Para replicar la anomalía visual del diseño original donde un pendiente tiene borde azul
    final borderColor = forceBlueBorder ? colors.blue : statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: borderColor, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: Fecha y Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: AppTextStyles.mainStyle10Bold(context).copyWith(
                        color: colors.lead,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: AppTextStyles.mainStyle10Bold(context).copyWith(
                          color: statusColor,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Cuerpo: Nombre y descripción
                Text(
                  name,
                  style: AppTextStyles.mainStyle16Bold(context).copyWith(color: colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead.withOpacity(0.9)),
                ),

                const SizedBox(height: 16),
                
                // Pie: Botón Ver Detalle (y Motivo si aplica)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (rejectionReason != null)
                      Expanded(
                        child: Text(
                          rejectionReason!,
                          style: AppTextStyles.mainStyle10(context).copyWith(color: colors.red),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    
                    GestureDetector(
                      onTap: () {
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VER DETALLE',
                            style: AppTextStyles.mainStyleBlue12Bold(context),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}