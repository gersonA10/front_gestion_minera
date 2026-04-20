import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DetailMachineryScreen extends StatefulWidget {
  const DetailMachineryScreen({super.key});

  @override
  State<DetailMachineryScreen> createState() => _DetailMachineryScreenState();
}

class _DetailMachineryScreenState extends State<DetailMachineryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles Maquina'),),
      body: Center(child: Text('Detail Screen'),),
    );
  }
}