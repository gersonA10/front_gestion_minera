import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class DistributesScreen extends StatelessWidget {
  const DistributesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: colors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.blue),
          onPressed: () => context.router.back(),
        ),
        title: Text(
          'Historial de Ingresos de dividendo',
          style: AppTextStyles.mainStyle16Bold(context).copyWith(color: colors.black),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.file_download_outlined, color: colors.blue),
        //     onPressed: () {
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          //Bara de busqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: colors.bajo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar por detalle o lote',
                        hintStyle: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead),
                        prefixIcon: Icon(Icons.search, color: colors.lead),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: colors.bajo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: colors.lead),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          //Métricas
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: [
                CustomCardMetric(
                  title: 'TOTAL MES',
                  amount: '\$42.5k',
                  bgColor: colors.blue,
                  titleColor: colors.white.withOpacity(0.8),
                  amountColor: colors.white,
                ),
                CustomCardMetric(
                  title: 'PENDIENTE',
                  amount: '\$12.1k',
                  bgColor: colors.white,
                  titleColor: colors.lead,
                  amountColor: colors.amber,
                ),
                CustomCardMetric(
                  title: 'COMPLETADO',
                  amount: '\$30.4k',
                  bgColor: colors.white,
                  titleColor: colors.lead,
                  amountColor: colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          //Historial 
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'OCTUBRE 2023',
                    style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.lead),
                  ),
                ),
                
                DividendCard(
                  title: 'Liquidación Lote #442',
                  dateInfo: '12 Oct 2023 • Ref: 98231',
                  amount: '\$14,250.00',
                  isPaid: true,
                ),
                DividendCard(
                  title: 'Venta de Concentrado',
                  dateInfo: '10 Oct 2023 • Ref: 98229',
                  amount: '\$8,120.00',
                  isPaid: false,
                ),
                DividendCard(
                  title: 'Servicios de Refinería',
                  dateInfo: '05 Oct 2023 • Ref: 98220',
                  amount: '\$5,400.00',
                  isPaid: true,
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
                  child: Text(
                    'SEPTIEMBRE 2023',
                    style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.lead),
                  ),
                ),

                DividendCard(
                  title: 'Liquidación Lote #441',
                  dateInfo: '28 Sep 2023 • Ref: 98115',
                  amount: '\$12,800.00',
                  isPaid: true,
                ),
                DividendCard(
                  title: 'Ajuste de Cuenta Anual',
                  dateInfo: '24 Sep 2023 • Ref: 98102',
                  amount: '\$3,950.00',
                  isPaid: false,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCardMetric extends StatelessWidget {
  const CustomCardMetric({
    required this.title,
    required this.amount,
    required this.bgColor,
    required this.titleColor,
    required this.amountColor,
    super.key,
  });

  final String title;
  final String amount;
  final Color bgColor;
  final Color titleColor;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isWhite = bgColor == colors.white;

    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isWhite ? Border.all(color: colors.bajo, width: 1.5) : null,
        boxShadow: isWhite
            ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]
            : [BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.mainStyle10Bold(context).copyWith(color: titleColor),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTextStyles.mainStyle20Bold(context).copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}

class DividendCard extends StatelessWidget {
  const DividendCard({
    required this.title,
    required this.dateInfo,
    required this.amount,
    required this.isPaid,
    super.key,
  });

  final String title;
  final String dateInfo;
  final String amount;
  final bool isPaid; 

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = isPaid ? colors.green : colors.amber;
    final iconData = isPaid ? Icons.payments_outlined : Icons.pending_actions_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.mainStyle14Bold(context).copyWith(color: colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateInfo,
                  style: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead),
                ),
              ],
            ),
          ),
          
          // Monto y Estado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTextStyles.mainStyle14Bold(context).copyWith(color: colors.black),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? 'PAGADO' : 'PENDIENTE',
                  style: AppTextStyles.mainStyle10Bold(context).copyWith(color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}