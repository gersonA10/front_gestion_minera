import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorialRequestsScreen extends StatelessWidget {
  const HistorialRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AuditHistoryItem> items = [
      AuditHistoryItem(
        requestId: '3db3b516-3df5-4729-b528-9575127087d1',
        fechaDecision: DateTime.parse('2026-03-30T22:12:55.223Z').toLocal(),
        solicitante: 'Juan Perez',
        rol: 'socios',
        descripcion: 'Compra soda',
        monto: 12000,
        evidenciaUrl: '/uploads/requets/solicitud-1772985400994.png',
        decisionTomada: 'Aprobado',
        estadoGlobalActual: 'APPROVED',
        motivoRechazo: 'la cantidad es muy alta',
      ),
      AuditHistoryItem(
        requestId: '6ab3b516-3df5-4729-b528-9575127087d2',
        fechaDecision: DateTime.parse('2026-03-28T14:40:00.000Z').toLocal(),
        solicitante: 'María Vaca',
        rol: 'socios',
        descripcion: 'Compra de materiales',
        monto: 8500,
        evidenciaUrl: null,
        decisionTomada: 'Aprobado',
        estadoGlobalActual: 'APPROVED',
        motivoRechazo: null,
      ),
      AuditHistoryItem(
        requestId: '8cc3b516-3df5-4729-b528-9575127087d3',
        fechaDecision: DateTime.parse('2026-03-27T10:30:00.000Z').toLocal(),
        solicitante: 'Roberto Soliz',
        rol: 'socios',
        descripcion: 'Pago de mantenimiento',
        monto: 5400,
        evidenciaUrl: null,
        decisionTomada: 'Rechazado',
        estadoGlobalActual: 'REJECTED',
        motivoRechazo: 'Fondos insuficientes reportados por el banco emisor.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(child: _HistorialHeader()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverToBoxAdapter(child: _HistorialFilterTabs()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        return HistorialCard(
                          item: items[index],
                          onTapDetail: () {
                            // Aquí luego navegas al detalle.
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  const SliverToBoxAdapter(child: _HistorialPagination()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =========================
/// MODELO
/// =========================
class AuditHistoryItem {
  final String requestId;
  final DateTime fechaDecision;
  final String solicitante;
  final String rol;
  final String descripcion;
  final double monto;
  final String? evidenciaUrl;
  final String decisionTomada;
  final String estadoGlobalActual;
  final String? motivoRechazo;

  const AuditHistoryItem({
    required this.requestId,
    required this.fechaDecision,
    required this.solicitante,
    required this.rol,
    required this.descripcion,
    required this.monto,
    required this.evidenciaUrl,
    required this.decisionTomada,
    required this.estadoGlobalActual,
    required this.motivoRechazo,
  });

  bool get isApproved => estadoGlobalActual.toUpperCase() == 'APPROVED';

  bool get isRejected => estadoGlobalActual.toUpperCase() == 'REJECTED';

  String get shortCode {
    final clean = requestId.replaceAll('-', '');
    return '#SOL-${clean.substring(0, 4).toUpperCase()}';
  }
}

/// =========================
/// COLORES
/// =========================
class AppColors {
  static const Color background = Color(0xFFF4F6FA);
  static const Color primary = Color(0xFF0A2E7A);
  static const Color primarySoft = Color(0xFFDCE7FF);
  static const Color textPrimary = Color(0xFF20242C);
  static const Color textSecondary = Color(0xFF7A8191);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE7EAF0);
  static const Color divider = Color(0xFFEDF0F5);

  static const Color approved = Color(0xFF7E97FF);
  static const Color approvedSoft = Color(0xFFE8EEFF);

  static const Color rejected = Color(0xFFD61F1F);
  static const Color rejectedSoft = Color(0xFFFFE1E1);

  static const Color buttonSoft = Color(0xFFE7EBF0);
}

/// =========================
/// HEADER
/// =========================
class _HistorialHeader extends StatelessWidget {
  const _HistorialHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDITORÍA Y CONTROL',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7C86A0),
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Historial de Solicitudes',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.15,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Revisión detallada de todas las solicitudes\nprocesadas por el sistema.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// =========================
/// FILTROS
/// =========================
class _HistorialFilterTabs extends StatelessWidget {
  const _HistorialFilterTabs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: HistorialFilterChip(
              text: 'Todas',
              isSelected: true,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: HistorialFilterChip(
              text: 'Aprobadas',
              isSelected: false,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: HistorialFilterChip(
              text: 'Rechazadas',
              isSelected: false,
            ),
          ),
        ],
      ),
    );
  }
}

class HistorialFilterChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const HistorialFilterChip({
    super.key,
    required this.text,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : const Color(0xFFF0F1F4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF555964),
            ),
          ),
        ),
      ),
    );
  }
}

/// =========================
/// CARD
/// =========================
class HistorialCard extends StatelessWidget {
  final AuditHistoryItem item;
  final VoidCallback? onTapDetail;

  const HistorialCard({
    super.key,
    required this.item,
    this.onTapDetail,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        item.isApproved ? AppColors.approved : AppColors.rejected;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardTopSection(item: item),
                    const SizedBox(height: 18),
                    _CardInfoSection(item: item),
                    const SizedBox(height: 18),
                    const Divider(
                      thickness: 1,
                      color: AppColors.divider,
                      height: 1,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: HistorialDetailButton(
                        onTap: onTapDetail,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTopSection extends StatelessWidget {
  final AuditHistoryItem item;

  const _CardTopSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _UserIconBox(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.solicitante,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'ID: ${item.shortCode}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        HistorialStatusBadge(
          isApproved: item.isApproved,
          text: item.isApproved ? 'APROBADA' : 'RECHAZADA',
        ),
      ],
    );
  }
}

class _CardInfoSection extends StatelessWidget {
  final AuditHistoryItem item;

  const _CardInfoSection({required this.item});

  String _formatDate(DateTime date) {
    final formatter = DateFormat("dd MMM, yyyy • HH:mm", "es");
    final text = formatter.format(date);
    return text
        .replaceAll('ene', 'Ene')
        .replaceAll('feb', 'Feb')
        .replaceAll('mar', 'Mar')
        .replaceAll('abr', 'Abr')
        .replaceAll('may', 'May')
        .replaceAll('jun', 'Jun')
        .replaceAll('jul', 'Jul')
        .replaceAll('ago', 'Ago')
        .replaceAll('sept', 'Sep')
        .replaceAll('oct', 'Oct')
        .replaceAll('nov', 'Nov')
        .replaceAll('dic', 'Dic');
  }

  String _money(double value) {
    final formatter = NumberFormat.currency(
      locale: 'es_BO',
      symbol: 'Bs ',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool rejected = item.isRejected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HistorialInfoLabel(
          text: 'FECHA DE PROCESO',
          color: const Color(0xFF7D8393),
        ),
        const SizedBox(height: 6),
        Text(
          _formatDate(item.fechaDecision),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        HistorialInfoLabel(
          text: rejected ? 'MOTIVO DEL RECHAZO' : 'DESCRIPCIÓN',
          color: rejected ? AppColors.rejected : const Color(0xFF7D8393),
        ),
        const SizedBox(height: 6),
        Text(
          rejected
              ? (item.motivoRechazo?.trim().isNotEmpty == true
                  ? item.motivoRechazo!
                  : 'Sin motivo registrado.')
              : item.descripcion,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        HistorialInfoLabel(
          text: 'MONTO',
          color: const Color(0xFF7D8393),
        ),
        const SizedBox(height: 6),
        Text(
          _money(item.monto),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _UserIconBox extends StatelessWidget {
  const _UserIconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: Color(0xFF637092),
        size: 24,
      ),
    );
  }
}

class HistorialStatusBadge extends StatelessWidget {
  final bool isApproved;
  final String text;

  const HistorialStatusBadge({
    super.key,
    required this.isApproved,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: isApproved ? AppColors.approvedSoft : AppColors.rejectedSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isApproved ? AppColors.primary : AppColors.rejected,
        ),
      ),
    );
  }
}

class HistorialInfoLabel extends StatelessWidget {
  final String text;
  final Color color;

  const HistorialInfoLabel({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.1,
      ),
    );
  }
}

class HistorialDetailButton extends StatelessWidget {
  final VoidCallback? onTap;

  const HistorialDetailButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.buttonSoft,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver Detalle',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =========================
/// PAGINACIÓN
/// =========================
class _HistorialPagination extends StatelessWidget {
  const _HistorialPagination();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _PaginationArrowButton(
            icon: Icons.chevron_left_rounded,
            enabled: false,
          ),
          SizedBox(width: 12),
          PaginationNumberButton(
            text: '1',
            isSelected: true,
          ),
          SizedBox(width: 8),
          PaginationNumberButton(
            text: '2',
            isSelected: false,
          ),
          SizedBox(width: 8),
          PaginationNumberButton(
            text: '3',
            isSelected: false,
          ),
          SizedBox(width: 12),
          _PaginationArrowButton(
            icon: Icons.chevron_right_rounded,
            enabled: true,
          ),
        ],
      ),
    );
  }
}

class PaginationNumberButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const PaginationNumberButton({
    super.key,
    required this.text,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF4F5562),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _PaginationArrowButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFFE8ECF2) : const Color(0xFFF1F3F6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: enabled ? AppColors.primary : const Color(0xFFBDC4D1),
          ),
        ),
      ),
    );
  }
}