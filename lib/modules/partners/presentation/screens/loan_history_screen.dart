import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/modules/partners/presentation/widgets/custom_card_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class LoanHistoryScreen extends StatelessWidget {
  const LoanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.white,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        centerTitle: true,
        leading: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.black,
        ),
        title: Text(
          'Historial de Préstamos',
          style: AppTextStyles.mainStyle14Bold(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(topPadding * 0.05),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, size: smallSpacing * 1),
                  hintText: 'Buscar por caja o área...',
                  hintStyle: AppTextStyles.mainStyleGrey12(context),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: smallSpacing * 0.5),
            Row(
              children: [
                FilterButton(text: 'Todos', active: true, onTap: () {}),
                SizedBox(width: smallSpacing * 1),
                FilterButton(text: 'Pagado', active: false, onTap: () {}),
                SizedBox(width: smallSpacing * 1),
                FilterButton(text: 'Pendiente', active: false, onTap: () {}),
              ],
            ),
            SizedBox(height: smallSpacing * 0.5),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return LoanCard(
                    small: smallSpacing,
                    date: "12 Oct 2023",
                    reason: "Compra de bomba",
                    amount: "\$5,000.00",
                    isPaid: index % 2 == 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
