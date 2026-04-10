import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class SellSummaryScreen extends StatelessWidget {
  final RegisterSaleResponseEntity saleData;
  final bool isFromHistory;
  
  const SellSummaryScreen({super.key, required this.saleData, this.isFromHistory = false});
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: _buildAppBar(context),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SuccessBanner(numOperacion: saleData.numOperacion),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Detalle de la Venta'),
          const SizedBox(height: 12),
          _DetailCard(saleData: saleData),

          const SizedBox(height: 24),
          _SectionTitle(text: 'Desglose de Lotes'),
          const SizedBox(height: 12),
          ...saleData.desgloseLotes.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LotCard(lot: lot),
            ),
          ),
          const SizedBox(height: 32),
          _BackButton(
            onTap: () {
              if (isFromHistory) {
                context.router.maybePop();
              } else {
                context.router.popUntil((route) => route.isFirst);
              }
            },
            isFromHistory: isFromHistory,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        color: TColors.surface,
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: TColors.border)),
            ),
            child: const Center(
              child: Text(
                'Venta Registrada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: TColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String numOperacion;
  const _SuccessBanner({required this.numOperacion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: TColors.successLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: TColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: TColors.success,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '¡Venta Exitosa!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: TColors.success,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'N° Operación: $numOperacion',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TColors.success.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: TColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final RegisterSaleResponseEntity saleData;
  const _DetailCard({required this.saleData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Comprador', value: saleData.comprador),
          const Divider(color: TColors.border, height: 20),
          _DetailRow(
            label: 'Peso vendido',
            value: '${saleData.pesoVendidoG.toStringAsFixed(2)} g',
          ),
          const Divider(color: TColors.border, height: 20),
          _DetailRow(
            label: 'Precio por gramo',
            value: 'Bs ${saleData.precioPorGramoBS.toStringAsFixed(2)}',
          ),
          const Divider(color: TColors.border, height: 20),
          _DetailRow(
            label: 'Fecha',
            value: _formatDate(saleData.fechaHora),
          ),
          const Divider(color: TColors.border, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: TColors.textPrimary,
                ),
              ),
              Text(
                'Bs ${_formatNum(saleData.totalBs)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  static String _formatNum(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$intPart.${parts[1]}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: TColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: TColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LotCard extends StatelessWidget {
  final SaleBatchDesgloceEntity lot;
  const _LotCard({required this.lot});

  Color get _statusColor {
    switch (lot.estado.toLowerCase()) {
      case 'agotado':
        return TColors.danger;
      case 'parcial':
        return TColors.warning;
      default:
        return TColors.success;
    }
  }

  Color get _statusBg {
    switch (lot.estado.toLowerCase()) {
      case 'agotado':
        return TColors.dangerLight;
      case 'parcial':
        return TColors.warningLight;
      default:
        return TColors.successLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lot.batchCode,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pureza ${lot.pureza.toStringAsFixed(0)}% · '
                  '${lot.gramosDescontados.toStringAsFixed(2)} g descontados',
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              lot.estado,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isFromHistory;
  const _BackButton({required this.onTap, required this.isFromHistory});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: TColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              isFromHistory ? 'Volver A Historial': 'Volver al Inicio',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
