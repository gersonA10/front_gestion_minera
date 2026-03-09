// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i11;
import 'package:flutter/material.dart' as _i12;
import 'package:front_gestion_minera/modules/auth/presentation/screen/auth_screens.dart'
    as _i1;
import 'package:front_gestion_minera/modules/partners/presentation/screens/contribute_history_screen.dart'
    as _i2;
import 'package:front_gestion_minera/modules/partners/presentation/screens/distributes_screen.dart'
    as _i3;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_history_screen.dart'
    as _i5;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_screen.dart'
    as _i6;
import 'package:front_gestion_minera/modules/partners/presentation/screens/money_request_screen.dart'
    as _i7;
import 'package:front_gestion_minera/modules/partners/presentation/screens/partners_screen.dart'
    as _i8;
import 'package:front_gestion_minera/modules/partners/presentation/screens/request_history_screen.dart'
    as _i9;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/home_surveillance_screen.dart'
    as _i4;
import 'package:front_gestion_minera/modules/treasury/presentation/screen/treasury_screen.dart'
    as _i10;

/// generated route for
/// [_i1.AuthScreen]
class AuthRoute extends _i11.PageRouteInfo<void> {
  const AuthRoute({List<_i11.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i1.AuthScreen();
    },
  );
}

/// generated route for
/// [_i2.ContributeHistoryScreen]
class ContributeHistoryRoute extends _i11.PageRouteInfo<void> {
  const ContributeHistoryRoute({List<_i11.PageRouteInfo>? children})
    : super(ContributeHistoryRoute.name, initialChildren: children);

  static const String name = 'ContributeHistoryRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i2.ContributeHistoryScreen();
    },
  );
}

/// generated route for
/// [_i3.DistributesScreen]
class DistributesRoute extends _i11.PageRouteInfo<void> {
  const DistributesRoute({List<_i11.PageRouteInfo>? children})
    : super(DistributesRoute.name, initialChildren: children);

  static const String name = 'DistributesRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i3.DistributesScreen();
    },
  );
}

/// generated route for
/// [_i4.HomeSurveillanceScreen]
class HomeSurveillanceRoute extends _i11.PageRouteInfo<void> {
  const HomeSurveillanceRoute({List<_i11.PageRouteInfo>? children})
    : super(HomeSurveillanceRoute.name, initialChildren: children);

  static const String name = 'HomeSurveillanceRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i4.HomeSurveillanceScreen();
    },
  );
}

/// generated route for
/// [_i5.LoanHistoryScreen]
class LoanHistoryRoute extends _i11.PageRouteInfo<void> {
  const LoanHistoryRoute({List<_i11.PageRouteInfo>? children})
    : super(LoanHistoryRoute.name, initialChildren: children);

  static const String name = 'LoanHistoryRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i5.LoanHistoryScreen();
    },
  );
}

/// generated route for
/// [_i6.LoanScreen]
class LoanRoute extends _i11.PageRouteInfo<void> {
  const LoanRoute({List<_i11.PageRouteInfo>? children})
    : super(LoanRoute.name, initialChildren: children);

  static const String name = 'LoanRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i6.LoanScreen();
    },
  );
}

/// generated route for
/// [_i7.MoneyRequestScreen]
class MoneyRequestRoute extends _i11.PageRouteInfo<void> {
  const MoneyRequestRoute({List<_i11.PageRouteInfo>? children})
    : super(MoneyRequestRoute.name, initialChildren: children);

  static const String name = 'MoneyRequestRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i7.MoneyRequestScreen();
    },
  );
}

/// generated route for
/// [_i8.PartnersScreen]
class PartnersRoute extends _i11.PageRouteInfo<PartnersRouteArgs> {
  PartnersRoute({
    _i12.Key? key,
    required String nombre,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         PartnersRoute.name,
         args: PartnersRouteArgs(key: key, nombre: nombre),
         initialChildren: children,
       );

  static const String name = 'PartnersRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PartnersRouteArgs>();
      return _i8.PartnersScreen(key: args.key, nombre: args.nombre);
    },
  );
}

class PartnersRouteArgs {
  const PartnersRouteArgs({this.key, required this.nombre});

  final _i12.Key? key;

  final String nombre;

  @override
  String toString() {
    return 'PartnersRouteArgs{key: $key, nombre: $nombre}';
  }
}

/// generated route for
/// [_i9.RequestHistoryScreen]
class RequestHistoryRoute extends _i11.PageRouteInfo<void> {
  const RequestHistoryRoute({List<_i11.PageRouteInfo>? children})
    : super(RequestHistoryRoute.name, initialChildren: children);

  static const String name = 'RequestHistoryRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i9.RequestHistoryScreen();
    },
  );
}

/// generated route for
/// [_i10.TreasuryScreen]
class TreasuryRoute extends _i11.PageRouteInfo<void> {
  const TreasuryRoute({List<_i11.PageRouteInfo>? children})
    : super(TreasuryRoute.name, initialChildren: children);

  static const String name = 'TreasuryRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i10.TreasuryScreen();
    },
  );
}
