part of 'partners_bloc.dart';

sealed class PartnersEvent {}

class PartnersSubmitMoneyRequestEvent extends PartnersEvent {
  final String area;
  final String solicitante;
  final double monto;
  final String descripcion;
  final String? comprobantePath;

  PartnersSubmitMoneyRequestEvent({
    required this.area,
    required this.solicitante,
    required this.monto,
    required this.descripcion,
    this.comprobantePath,
  });
}