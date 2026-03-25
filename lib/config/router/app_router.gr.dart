// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i23;
import 'package:flutter/material.dart' as _i24;
import 'package:front_gestion_minera/modules/auth/presentation/screen/auth_screens.dart'
    as _i2;
import 'package:front_gestion_minera/modules/partners/presentation/screens/contribute_history_screen.dart'
    as _i3;
import 'package:front_gestion_minera/modules/partners/presentation/screens/distributes_screen.dart'
    as _i6;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_history_screen.dart'
    as _i12;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_screen.dart'
    as _i13;
import 'package:front_gestion_minera/modules/partners/presentation/screens/money_request_screen.dart'
    as _i15;
import 'package:front_gestion_minera/modules/partners/presentation/screens/partners_screen.dart'
    as _i16;
import 'package:front_gestion_minera/modules/partners/presentation/screens/request_history_screen.dart'
    as _i19;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/application_details_screen.dart'
    as _i1;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/history_requests_screen.dart'
    as _i9;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/home_surveillance_screen.dart'
    as _i11;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/contributes_home_screen.dart'
    as _i4;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/distribute_home_screen.dart'
    as _i5;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/home_dashboard_screen.dart'
    as _i10;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/urgent_transaction_screen.dart'
    as _i21;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/gold_dashboard_screen.dart'
    as _i8;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loans_home_screen.dart'
    as _i14;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/payment%20history/payment_history_screen.dart'
    as _i17;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/pending_applications/pending_applications_screen.dart'
    as _i18;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/reports/financial_reports_screen.dart'
    as _i7;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/treasury_screen.dart'
    as _i20;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/view_request_details/view_request_detail_screen.dart'
    as _i22;

/// generated route for
/// [_i1.ApplicationDetailsScreen]
class ApplicationDetailsRoute
    extends _i23.PageRouteInfo<ApplicationDetailsRouteArgs> {
  ApplicationDetailsRoute({
    _i24.Key? key,
    required String requestId,
    required DateTime createdAt,
    required String name,
    required String rol,
    required String description,
    required String amount,
    required String evidencia,
    required String status,
    String? motivoRechazo,
    List<_i23.PageRouteInfo>? children,
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

  static _i23.PageInfo page = _i23.PageInfo(
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

  final _i24.Key? key;

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
class AuthRoute extends _i23.PageRouteInfo<void> {
  const AuthRoute({List<_i23.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthScreen();
    },
  );
}

/// generated route for
/// [_i3.ContributeHistoryScreen]
class ContributeHistoryRoute extends _i23.PageRouteInfo<void> {
  const ContributeHistoryRoute({List<_i23.PageRouteInfo>? children})
    : super(ContributeHistoryRoute.name, initialChildren: children);

  static const String name = 'ContributeHistoryRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i3.ContributeHistoryScreen();
    },
  );
}

/// generated route for
/// [_i4.ContributesHomeScreen]
class ContributesHomeRoute extends _i23.PageRouteInfo<void> {
  const ContributesHomeRoute({List<_i23.PageRouteInfo>? children})
    : super(ContributesHomeRoute.name, initialChildren: children);

  static const String name = 'ContributesHomeRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i4.ContributesHomeScreen();
    },
  );
}

/// generated route for
/// [_i5.DistributeHomeScreen]
class DistributeHomeRoute extends _i23.PageRouteInfo<void> {
  const DistributeHomeRoute({List<_i23.PageRouteInfo>? children})
    : super(DistributeHomeRoute.name, initialChildren: children);

  static const String name = 'DistributeHomeRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i5.DistributeHomeScreen();
    },
  );
}

/// generated route for
/// [_i6.DistributesScreen]
class DistributesRoute extends _i23.PageRouteInfo<void> {
  const DistributesRoute({List<_i23.PageRouteInfo>? children})
    : super(DistributesRoute.name, initialChildren: children);

  static const String name = 'DistributesRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i6.DistributesScreen();
    },
  );
}

/// generated route for
/// [_i7.FinancialReportsScreen]
class FinancialReportsRoute extends _i23.PageRouteInfo<void> {
  const FinancialReportsRoute({List<_i23.PageRouteInfo>? children})
    : super(FinancialReportsRoute.name, initialChildren: children);

  static const String name = 'FinancialReportsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i7.FinancialReportsScreen();
    },
  );
}

/// generated route for
/// [_i8.GoldDashboardScreen]
class GoldDashboardRoute extends _i23.PageRouteInfo<void> {
  const GoldDashboardRoute({List<_i23.PageRouteInfo>? children})
    : super(GoldDashboardRoute.name, initialChildren: children);

  static const String name = 'GoldDashboardRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i8.GoldDashboardScreen();
    },
  );
}

/// generated route for
/// [_i9.HistoryRequestsScreen]
class HistoryRequestsRoute extends _i23.PageRouteInfo<void> {
  const HistoryRequestsRoute({List<_i23.PageRouteInfo>? children})
    : super(HistoryRequestsRoute.name, initialChildren: children);

  static const String name = 'HistoryRequestsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i9.HistoryRequestsScreen();
    },
  );
}

/// generated route for
/// [_i10.HomeDashboardScreen]
class HomeDashboardRoute extends _i23.PageRouteInfo<void> {
  const HomeDashboardRoute({List<_i23.PageRouteInfo>? children})
    : super(HomeDashboardRoute.name, initialChildren: children);

  static const String name = 'HomeDashboardRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i10.HomeDashboardScreen();
    },
  );
}

/// generated route for
/// [_i11.HomeSurveillanceScreen]
class HomeSurveillanceRoute extends _i23.PageRouteInfo<void> {
  const HomeSurveillanceRoute({List<_i23.PageRouteInfo>? children})
    : super(HomeSurveillanceRoute.name, initialChildren: children);

  static const String name = 'HomeSurveillanceRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i11.HomeSurveillanceScreen();
    },
  );
}

/// generated route for
/// [_i12.LoanHistoryScreen]
class LoanHistoryRoute extends _i23.PageRouteInfo<void> {
  const LoanHistoryRoute({List<_i23.PageRouteInfo>? children})
    : super(LoanHistoryRoute.name, initialChildren: children);

  static const String name = 'LoanHistoryRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i12.LoanHistoryScreen();
    },
  );
}

/// generated route for
/// [_i13.LoanScreen]
class LoanRoute extends _i23.PageRouteInfo<void> {
  const LoanRoute({List<_i23.PageRouteInfo>? children})
    : super(LoanRoute.name, initialChildren: children);

  static const String name = 'LoanRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i13.LoanScreen();
    },
  );
}

/// generated route for
/// [_i14.LoansHomeScreen]
class LoansHomeRoute extends _i23.PageRouteInfo<void> {
  const LoansHomeRoute({List<_i23.PageRouteInfo>? children})
    : super(LoansHomeRoute.name, initialChildren: children);

  static const String name = 'LoansHomeRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i14.LoansHomeScreen();
    },
  );
}

/// generated route for
/// [_i15.MoneyRequestScreen]
class MoneyRequestRoute extends _i23.PageRouteInfo<void> {
  const MoneyRequestRoute({List<_i23.PageRouteInfo>? children})
    : super(MoneyRequestRoute.name, initialChildren: children);

  static const String name = 'MoneyRequestRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i15.MoneyRequestScreen();
    },
  );
}

/// generated route for
/// [_i16.PartnersScreen]
class PartnersRoute extends _i23.PageRouteInfo<PartnersRouteArgs> {
  PartnersRoute({
    _i24.Key? key,
    required String nombre,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         PartnersRoute.name,
         args: PartnersRouteArgs(key: key, nombre: nombre),
         initialChildren: children,
       );

  static const String name = 'PartnersRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PartnersRouteArgs>();
      return _i16.PartnersScreen(key: args.key, nombre: args.nombre);
    },
  );
}

class PartnersRouteArgs {
  const PartnersRouteArgs({this.key, required this.nombre});

  final _i24.Key? key;

  final String nombre;

  @override
  String toString() {
    return 'PartnersRouteArgs{key: $key, nombre: $nombre}';
  }
}

/// generated route for
/// [_i17.PaymentHistoryScreen]
class PaymentHistoryRoute extends _i23.PageRouteInfo<void> {
  const PaymentHistoryRoute({List<_i23.PageRouteInfo>? children})
    : super(PaymentHistoryRoute.name, initialChildren: children);

  static const String name = 'PaymentHistoryRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i17.PaymentHistoryScreen();
    },
  );
}

/// generated route for
/// [_i18.PendingApplicationsScreen]
class PendingApplicationsRoute extends _i23.PageRouteInfo<void> {
  const PendingApplicationsRoute({List<_i23.PageRouteInfo>? children})
    : super(PendingApplicationsRoute.name, initialChildren: children);

  static const String name = 'PendingApplicationsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i18.PendingApplicationsScreen();
    },
  );
}

/// generated route for
/// [_i19.RequestHistoryScreen]
class RequestHistoryRoute extends _i23.PageRouteInfo<void> {
  const RequestHistoryRoute({List<_i23.PageRouteInfo>? children})
    : super(RequestHistoryRoute.name, initialChildren: children);

  static const String name = 'RequestHistoryRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i19.RequestHistoryScreen();
    },
  );
}

/// generated route for
/// [_i20.TreasuryScreen]
class TreasuryRoute extends _i23.PageRouteInfo<void> {
  const TreasuryRoute({List<_i23.PageRouteInfo>? children})
    : super(TreasuryRoute.name, initialChildren: children);

  static const String name = 'TreasuryRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i20.TreasuryScreen();
    },
  );
}

/// generated route for
/// [_i21.UrgentTransactionScreen]
class UrgentTransactionRoute extends _i23.PageRouteInfo<void> {
  const UrgentTransactionRoute({List<_i23.PageRouteInfo>? children})
    : super(UrgentTransactionRoute.name, initialChildren: children);

  static const String name = 'UrgentTransactionRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i21.UrgentTransactionScreen();
    },
  );
}

/// generated route for
/// [_i22.ViewRequestDetailsScreen]
class ViewRequestDetailsRoute
    extends _i23.PageRouteInfo<ViewRequestDetailsRouteArgs> {
  ViewRequestDetailsRoute({
    _i24.Key? key,
    required String id,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         ViewRequestDetailsRoute.name,
         args: ViewRequestDetailsRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ViewRequestDetailsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewRequestDetailsRouteArgs>();
      return _i22.ViewRequestDetailsScreen(key: args.key, id: args.id);
    },
  );
}

class ViewRequestDetailsRouteArgs {
  const ViewRequestDetailsRouteArgs({this.key, required this.id});

  final _i24.Key? key;

  final String id;

  @override
  String toString() {
    return 'ViewRequestDetailsRouteArgs{key: $key, id: $id}';
  }
}
