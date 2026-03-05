import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage('assets/avatar.jpg'),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "BUEN DÍA",
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.2,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Cristina",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Los Tigresitos",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F5ED6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Gestión financiera del sistema minero",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: const [
                    _MenuCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Registrar\nPréstamo",
                      subtitle: "Nueva solicitud de crédito",
                    ),
                    _MenuCard(
                      icon: Icons.history,
                      title: "Historial\nPréstamos",
                      subtitle: "Seguimiento de cuotas",
                    ),
                    _MenuCard(
                      icon: Icons.trending_up,
                      title: "Ingresos",
                      subtitle: "Entradas de capital",
                    ),
                    _MenuCard(
                      icon: Icons.person_add_alt_1,
                      title: "Solicitar Dinero",
                      subtitle: "Solicitud de Egreso",
                    ),
                    _MenuCard(
                      icon: Icons.group_add,
                      title: "Historial Aportes",
                      subtitle: "Contribuciones sociales",
                    ),
                    _MenuCard(
                      icon: Icons.access_time,
                      title: "Historial de Solicitudes",
                      subtitle: "Seguimiento de Solicitud",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// CARD INFERIOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: const _MenuCard(
                  icon: Icons.trending_up,
                  title: "Bande de Socios",
                  subtitle: "Verifica tu asistencia y otras actividades.",
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFFC107)),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
