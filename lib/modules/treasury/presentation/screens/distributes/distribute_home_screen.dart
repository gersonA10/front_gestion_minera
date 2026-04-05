import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class DistributeHomeScreen extends StatefulWidget {
  const DistributeHomeScreen({super.key});

  @override
  State<DistributeHomeScreen> createState() => _DistributeHomeScreenState();
}

class _DistributeHomeScreenState extends State<DistributeHomeScreen> {
  String _filtro = 'Todos';

  final List<Map<String, dynamic>> _socios = [
    {
      'nombre': 'Juan Rodriguez',
      'iniciales': 'JR',
      'id': '849302',
      'monto': '\$3,500.00',
      'estado': 'Pendiente',
    },
    {
      'nombre': 'Maria Perez',
      'iniciales': 'MP',
      'id': '993821',
      'monto': '\$2,150.00',
      'estado': 'Pagado',
    },
    {
      'nombre': 'Carlos Lopez',
      'iniciales': 'CL',
      'id': '112093',
      'monto': '\$1,800.00',
      'estado': 'Pagado',
    },
    {
      'nombre': 'Ana Gomez',
      'iniciales': 'AG',
      'id': '772100',
      'monto': '\$4,200.00',
      'estado': 'Pendiente',
    },
  ];

  List<Map<String, dynamic>> get _sociosFiltrados {
    if (_filtro == 'Todos') return _socios;
    return _socios.where((s) => s['estado'] == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: TColors.textPrimary, size: 18),
          onPressed: () => context.router.back(),
        ),
        title: const Text(
          'Detalle de distribución\nde dividendos',
          style: TextStyle(
            color: TColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enero 2024',
              style: TextStyle(
                color: TColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Monto Registrado',
                    value: '\$1,500,000',
                    valueColor: TColors.textPrimary,
                    bgColor: TColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'Saldo Pendiente',
                    value: '\$400,000',
                    valueColor: TColors.warning,
                    bgColor: TColors.warningLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SummaryCard(
              label: 'Total Pagado',
              value: '\$800,000',
              valueColor: TColors.success,
              bgColor: TColors.successLight,
              fullWidth: true,
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: TColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CounterItem(
                      value: '450',
                      label: 'TOTAL',
                      color: TColors.textPrimary),
                  Container(
                      width: 1, height: 36, color: TColors.border),
                  _CounterItem(
                      value: '300',
                      label: 'PAGADOS',
                      color: TColors.success),
                  Container(
                      width: 1, height: 36, color: TColors.border),
                  _CounterItem(
                      value: '150',
                      label: 'PENDIENTES',
                      color: TColors.warning),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: ['Todos', 'Pendientes', 'Pagados'].map((filtro) {
                final selected = _filtro == filtro;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filtro = filtro),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? TColors.textPrimary : TColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected ? TColors.textPrimary : TColors.border,
                        ),
                      ),
                      child: Text(
                        filtro,
                        style: TextStyle(
                          color: selected
                              ? TColors.white
                              : TColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            ..._sociosFiltrados
                .map((socio) => _SocioCard(socio: socio))
                .toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color bgColor;
  final bool fullWidth;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.bgColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
class _CounterItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _CounterItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
class _SocioCard extends StatelessWidget {
  final Map<String, dynamic> socio;

  const _SocioCard({required this.socio});

  bool get _isPendiente => socio['estado'] == 'Pendiente';

  Color get _avatarBg => _isPendiente ? TColors.warningLight : TColors.successLight;
  Color get _avatarText => _isPendiente ? TColors.warning : TColors.success;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila superior
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    socio['iniciales'],
                    style: TextStyle(
                      color: _avatarText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      socio['nombre'],
                      style: const TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'ID: ${socio['id']}',
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isPendiente ? TColors.warning : TColors.success,
                  ),
                ),
                child: Text(
                  socio['estado'],
                  style: TextStyle(
                    color: _isPendiente ? TColors.warning : TColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: TColors.border),
          const SizedBox(height: 10),

          // Fila inferior
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MONTO',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    socio['monto'],
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              _isPendiente
                  ? ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Pagar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        size: 15,
                        color: TColors.textSecondary,
                      ),
                      label: const Text(
                        'Ver recibo',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}