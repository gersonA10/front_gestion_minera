import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backgroundColor, 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    label: 'TOTAL HOY',
                    value: '\$145,200.00',
                    icon: Icons.payments_outlined,
                    color: const Color(0xFFE0E7FF),
                    iconColor: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    label: 'TRANSACCIONES',
                    value: '23',
                    icon: Icons.receipt_long_outlined,
                    color: Colors.white,
                    iconColor: Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Fecha: Últimos 30 días', style: TextStyle(fontSize: 13)),
                  Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader('Hoy', '12 de Oct'),
            _buildPaymentItem(
              title: 'Pago a Proveedores...',
              time: '14:30',
              method: 'Caja Chica #1',
              amount: '-\$4,500.00',
              icon: Icons.people_outline,
              iconBgColor: const Color(0xFFEEF2FF),
              iconColor: Colors.indigo,
            ),
            _buildPaymentItem(
              title: 'Transporte Mineral...',
              time: '11:15',
              method: 'Transferencia',
              amount: '-\$12,200.00',
              icon: Icons.local_shipping_outlined,
              iconBgColor: const Color(0xFFFFF7ED),
              iconColor: Colors.orange,
            ),
            _buildPaymentItem(
              title: 'Servicios de Comedor',
              time: '09:45',
              method: 'Caja Chica #2',
              amount: '-\$850.50',
              icon: Icons.restaurant_outlined,
              iconBgColor: const Color(0xFFF0FDF4),
              iconColor: Colors.green,
            ),

            const SizedBox(height: 24),

            // --- SECCIÓN "AYER" ---
            _buildSectionHeader('Ayer', '11 de Oct'),
            _buildPaymentItem(
              title: 'Mantenimiento Ma...',
              time: '16:20',
              method: 'Transferencia',
              amount: '-\$32,150.00',
              icon: Icons.build_circle_outlined,
              iconBgColor: const Color(0xFFFAF5FF),
              iconColor: Colors.purple,
            ),
             _buildPaymentItem(
              title: 'Papelería y Oficina',
              time: '10:05',
              method: 'Caja Chica #1',
              amount: '-\$240.00',
              icon: Icons.description_outlined,
              iconBgColor: const Color(0xFFF1F5F9),
              iconColor: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget para el encabezado de cada grupo (Hoy, Ayer)
  Widget _buildSectionHeader(String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(date, style: const TextStyle(fontSize: 12, color: Colors.black38)),
        ],
      ),
    );
  }

  // Widget para cada item de la lista de pagos
  Widget _buildPaymentItem({
    required String title,
    required String time,
    required String method,
    required String amount,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text('$time • $method', style: const TextStyle(color: Colors.black38, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Text('Ver detalle', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
