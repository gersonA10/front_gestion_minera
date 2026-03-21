// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i20;
import 'package:flutter/material.dart' as _i21;
import 'package:front_gestion_minera/modules/auth/presentation/screen/auth_screens.dart'
    as _i2;
import 'package:front_gestion_minera/modules/partners/presentation/screens/contribute_history_screen.dart'
    as _i3;
import 'package:front_gestion_minera/modules/partners/presentation/screens/distributes_screen.dart'
    as _i6;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_history_screen.dart'
    as _i11;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_screen.dart'
    as _i12;
import 'package:front_gestion_minera/modules/partners/presentation/screens/money_request_screen.dart'
    as _i14;
import 'package:front_gestion_minera/modules/partners/presentation/screens/partners_screen.dart'
    as _i15;
import 'package:front_gestion_minera/modules/partners/presentation/screens/request_history_screen.dart'
    as _i17;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/application_details_screen.dart'
    as _i1;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/history_requests_screen.dart'
    as _i8;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/home_surveillance_screen.dart'
    as _i10;
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart'
    as _i22;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/contributes_home_screen.dart'
    as _i4;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/distribute_home_screen.dart'
    as _i5;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/home_dashboard_screen.dart'
    as _i9;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/gold_dashboard_screen.dart'
    as _i7;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loans_home_screen.dart'
    as _i13;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/pending_applications/pending_applications_screen.dart'
    as _i16;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/treasury_screen.dart'
    as _i18;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/view_request_details/view_request_detail_screen.dart'
    as _i19;

/// generated route for
/// [_i1.ApplicationDetailsScreen]
class ApplicationDetailsRoute
    extends _i20.PageRouteInfo<ApplicationDetailsRouteArgs> {
  ApplicationDetailsRoute({
    _i21.Key? key,
    required String requestId,
    required DateTime createdAt,
    required String name,
    required String rol,
    required String description,
    required String amount,
    required String evidencia,
    required String status,
    String? motivoRechazo,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         ApplicationDetailsRoute.name,
         args: ApplicationDetailsRouteArgs(
           key: key,
           requestId: requestId,
           createdAt: createdAt,
           name: name,
           rol: rol,
           description: description,
           amount: amount,
           evidencia: evidencia,
           status: status,
           motivoRechazo: motivoRechazo,
         ),
         initialChildren: children,
       );

  static const String name = 'ApplicationDetailsRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ApplicationDetailsRouteArgs>();
      return _i1.ApplicationDetailsScreen(
        key: args.key,
        requestId: args.requestId,
        createdAt: args.createdAt,
        name: args.name,
        rol: args.rol,
        description: args.description,
        amount: args.amount,
        evidencia: args.evidencia,
        status: args.status,
        motivoRechazo: args.motivoRechazo,
      );
    },
  );
}

class ApplicationDetailsRouteArgs {
  const ApplicationDetailsRouteArgs({
    this.key,
    required this.requestId,
    required this.createdAt,
    required this.name,
    required this.rol,
    required this.description,
    required this.amount,
    required this.evidencia,
    required this.status,
    this.motivoRechazo,
  });

  final _i21.Key? key;

  final String requestId;

  final DateTime createdAt;

  final String name;

  final String rol;

  final String description;

  final String amount;

  final String evidencia;

  final String status;

  final String? motivoRechazo;

  @override
  String toString() {
    return 'ApplicationDetailsRouteArgs{key: $key, requestId: $requestId, createdAt: $createdAt, name: $name, rol: $rol, description: $description, amount: $amount, evidencia: $evidencia, status: $status, motivoRechazo: $motivoRechazo}';
  }
}

/// generated route for
/// [_i2.AuthScreen]
class AuthRoute extends _i20.PageRouteInfo<void> {
  const AuthRoute({List<_i20.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthScreen();
    },
  );
}

/// generated route for
/// [_i3.ContributeHistoryScreen]
class ContributeHistoryRoute extends _i20.PageRouteInfo<void> {
  const ContributeHistoryRoute({List<_i20.PageRouteInfo>? children})
    : super(ContributeHistoryRoute.name, initialChildren: children);

  static const String name = 'ContributeHistoryRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i3.ContributeHistoryScreen();
    },
  );
}

/// generated route for
/// [_i4.ContributesHomeScreen]
class ContributesHomeRoute extends _i20.PageRouteInfo<void> {
  const ContributesHomeRoute({List<_i20.PageRouteInfo>? children})
    : super(ContributesHomeRoute.name, initialChildren: children);

  static const String name = 'ContributesHomeRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i4.ContributesHomeScreen();
    },
  );
}

/// generated route for
/// [_i5.DistributeHomeScreen]
class DistributeHomeRoute extends _i20.PageRouteInfo<void> {
  const DistributeHomeRoute({List<_i20.PageRouteInfo>? children})
    : super(DistributeHomeRoute.name, initialChildren: children);

  static const String name = 'DistributeHomeRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i5.DistributeHomeScreen();
    },
  );
}

/// generated route for
/// [_i6.DistributesScreen]
class DistributesRoute extends _i20.PageRouteInfo<void> {
  const DistributesRoute({List<_i20.PageRouteInfo>? children})
    : super(DistributesRoute.name, initialChildren: children);

  static const String name = 'DistributesRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i6.DistributesScreen();
    },
  );
}

/// generated route for
/// [_i7.GoldDashboardScreen]
class GoldDashboardRoute extends _i20.PageRouteInfo<void> {
  const GoldDashboardRoute({List<_i20.PageRouteInfo>? children})
    : super(GoldDashboardRoute.name, initialChildren: children);

  static const String name = 'GoldDashboardRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i7.GoldDashboardScreen();
    },
  );
}

/// generated route for
/// [_i8.HistoryRequestsScreen]
class HistoryRequestsRoute extends _i20.PageRouteInfo<void> {
  const HistoryRequestsRoute({List<_i20.PageRouteInfo>? children})
    : super(HistoryRequestsRoute.name, initialChildren: children);

  static const String name = 'HistoryRequestsRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i8.HistoryRequestsScreen();
    },
  );
}

/// generated route for
/// [_i9.HomeDashboardScreen]
class HomeDashboardRoute extends _i20.PageRouteInfo<void> {
  const HomeDashboardRoute({List<_i20.PageRouteInfo>? children})
    : super(HomeDashboardRoute.name, initialChildren: children);

  static const String name = 'HomeDashboardRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i9.HomeDashboardScreen();
    },
  );
}

/// generated route for
/// [_i10.HomeSurveillanceScreen]
class HomeSurveillanceRoute extends _i20.PageRouteInfo<void> {
  const HomeSurveillanceRoute({List<_i20.PageRouteInfo>? children})
    : super(HomeSurveillanceRoute.name, initialChildren: children);

  static const String name = 'HomeSurveillanceRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i10.HomeSurveillanceScreen();
    },
  );
}

/// generated route for
/// [_i11.LoanHistoryScreen]
class LoanHistoryRoute extends _i20.PageRouteInfo<void> {
  const LoanHistoryRoute({List<_i20.PageRouteInfo>? children})
    : super(LoanHistoryRoute.name, initialChildren: children);

  static const String name = 'LoanHistoryRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i11.LoanHistoryScreen();
    },
  );
}

/// generated route for
/// [_i12.LoanScreen]
class LoanRoute extends _i20.PageRouteInfo<void> {
  const LoanRoute({List<_i20.PageRouteInfo>? children})
    : super(LoanRoute.name, initialChildren: children);

  static const String name = 'LoanRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i12.LoanScreen();
    },
  );
}

/// generated route for
/// [_i13.LoansHomeScreen]
class LoansHomeRoute extends _i20.PageRouteInfo<void> {
  const LoansHomeRoute({List<_i20.PageRouteInfo>? children})
    : super(LoansHomeRoute.name, initialChildren: children);

  static const String name = 'LoansHomeRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i13.LoansHomeScreen();
    },
  );
}

/// generated route for
/// [_i14.MoneyRequestScreen]
class MoneyRequestRoute extends _i20.PageRouteInfo<void> {
  const MoneyRequestRoute({List<_i20.PageRouteInfo>? children})
    : super(MoneyRequestRoute.name, initialChildren: children);

  static const String name = 'MoneyRequestRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i14.MoneyRequestScreen();
    },
  );
}

/// generated route for
/// [_i15.PartnersScreen]
class PartnersRoute extends _i20.PageRouteInfo<PartnersRouteArgs> {
  PartnersRoute({
    _i21.Key? key,
    required String nombre,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         PartnersRoute.name,
         args: PartnersRouteArgs(key: key, nombre: nombre),
         initialChildren: children,
       );

  static const String name = 'PartnersRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PartnersRouteArgs>();
      return _i15.PartnersScreen(key: args.key, nombre: args.nombre);
    },
  );
}

class PartnersRouteArgs {
  const PartnersRouteArgs({this.key, required this.nombre});

  final _i21.Key? key;

  final String nombre;

  @override
  String toString() {
    return 'PartnersRouteArgs{key: $key, nombre: $nombre}';
  }
}

/// generated route for
/// [_i16.PendingApplicationsScreen]
class PendingApplicationsRoute extends _i20.PageRouteInfo<void> {
  const PendingApplicationsRoute({List<_i20.PageRouteInfo>? children})
    : super(PendingApplicationsRoute.name, initialChildren: children);

  static const String name = 'PendingApplicationsRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i16.PendingApplicationsScreen();
    },
  );
}

/// generated route for
/// [_i17.RequestHistoryScreen]
class RequestHistoryRoute extends _i20.PageRouteInfo<void> {
  const RequestHistoryRoute({List<_i20.PageRouteInfo>? children})
    : super(RequestHistoryRoute.name, initialChildren: children);

  static const String name = 'RequestHistoryRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i17.RequestHistoryScreen();
    },
  );
}

/// generated route for
/// [_i18.TreasuryScreen]
class TreasuryRoute extends _i20.PageRouteInfo<void> {
  const TreasuryRoute({List<_i20.PageRouteInfo>? children})
    : super(TreasuryRoute.name, initialChildren: children);

  static const String name = 'TreasuryRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i18.TreasuryScreen();
    },
  );
}

/// generated route for
/// [_i19.ViewRequestDetailsScreen]
class ViewRequestDetailsRoute
    extends _i20.PageRouteInfo<ViewRequestDetailsRouteArgs> {
  ViewRequestDetailsRoute({
    _i21.Key? key,
    required String id,
    required _i22.BondBalanceResponseEntity data,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         ViewRequestDetailsRoute.name,
         args: ViewRequestDetailsRouteArgs(key: key, id: id, data: data),
         initialChildren: children,
       );

  static const String name = 'ViewRequestDetailsRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewRequestDetailsRouteArgs>();
      return _i19.ViewRequestDetailsScreen(
        key: args.key,
        id: args.id,
        data: args.data,
      );
    },
  );
}

class ViewRequestDetailsRouteArgs {
  const ViewRequestDetailsRouteArgs({
    this.key,
    required this.id,
    required this.data,
  });

  final _i21.Key? key;

  final String id;

  final _i22.BondBalanceResponseEntity data;

  @override
  String toString() {
    return 'ViewRequestDetailsRouteArgs{key: $key, id: $id, data: $data}';
  }
}
