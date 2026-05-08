import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class MinutesMemosMainScreen extends StatefulWidget {
  const MinutesMemosMainScreen({super.key});

  @override
  State<MinutesMemosMainScreen> createState() => _MinutesMemosMainScreenState();
}

class _MinutesMemosMainScreenState extends State<MinutesMemosMainScreen> {
  int selectedTab = 0;
  int selectedFilter = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.textFieldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: TColors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TColors.appMainDarkColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Actas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColors.appMainDarkColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  SummaryCardMinutesMemosWidget(type: 'minute', value: '128'),
                  SizedBox(width: 12),
                  SummaryCardMinutesMemosWidget(type: 'memo', value: '84'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: TColors.appMainDarkColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Registrar Acta',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: TColors.appMainDarkColor,
                          width: 1.5,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: TColors.appMainDarkColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Nuevo Memorando',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: _buildTab('Actas Recientes', 0)),
                  Expanded(child: _buildTab('Memorandos', 1)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFilterChip('Recientes', 0),
                  const SizedBox(width: 10),
                  _buildFilterChip('Semana', 1),
                  const SizedBox(width: 10),
                  _buildFilterChip('Mes', 2),
                  const SizedBox(width: 10),
                  _buildFilterChip('Personalizado', 3, icon: Icons.tune),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  MinutesMemosCardPanelWidget(
                    tipo: 'minute',
                    numero: '452',
                    titulo: 'Reunión de Seguridad Mina Norte',
                    descripcion:
                        'Revisión de protocolos de emergencia y actualización de equipos...',
                    fecha: '15 OCT, 2023',
                    estado: 'Pendiente',
                    actualizado: 'Actualizado hace 2h',
                  ),

                  MinutesMemosCardPanelWidget(
                    tipo: 'memo',
                    numero: '102',
                    titulo: 'Nuevos Turnos de Perforación',
                    destinatario: 'Juan Pérez (Operaciones)',
                    fecha: '12 OCT, 2023',
                    estado: 'Pendiente',
                  ),
                  MinutesMemosCardPanelWidget(
                    tipo: 'minute',
                    numero: '451',
                    titulo: 'Mantenimiento de Maquinaria Pesada',
                    descripcion:
                        'Planificación de paradas técnicas para camiones CAT-797F...',
                    fecha: '10 OCT, 2023',
                    estado: 'Finalizado',
                  ),
                ],
              ),
            ),
          ], ///////////////////////////////
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final bool isActive = selectedTab == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? TColors.appMainDarkColor
                  : TColors.appDisabledColor,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isActive ? 100 : 0,
            color: TColors.appMainDarkColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, int index, {IconData? icon}) {
    final bool isActive = selectedFilter == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? TColors.appMainDarkColor : TColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? TColors.appMainDarkColor
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : TColors.appDisabledColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : TColors.appDisabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
