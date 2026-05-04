import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../widgets/widgets.dart';

@RoutePage()
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<String> typeState = [
    'Todos',
    'En Revision',
    'Pendientes de Recibo',
    'Completados',
    'Rechazados',
  ];
  int _selectIndexTypeState = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.appMainDarkColor,
        titleSpacing: 0,
        toolbarHeight: 90,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColors.white),
          onPressed: () => context.router.back(),
        ),
        title: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              'Historial de Transacciones',
              style: TextStyle(color: TColors.white, fontSize: 22),
            ),
            Text(
              'Jefe de Campamento - Sector',
              style: TextStyle(fontSize: 15, color: TColors.textPrimaryWhite),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 60,
                padding: EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(color: TColors.white),
                child: _filterStateRequest(),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return CardRequestDetailWidget(state: index.toString());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView _filterStateRequest() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: typeState.length,
      itemBuilder: (BuildContext context, int index) {
        final isSelected = _selectIndexTypeState == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectIndexTypeState = index;
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 5),
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: isSelected
                  ? TColors.appMainColor
                  : TColors.appBackgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                typeState[index],
                style: TextStyle(
                  color: isSelected
                      ? TColors.white
                      : TColors.textFieldIconColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
