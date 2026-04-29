import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
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
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(color: TColors.white),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: TColors.appBackgroundColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Text('pendientes en revision')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
