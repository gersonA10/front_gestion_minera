// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i37;
import 'package:flutter/material.dart' as _i38;
import 'package:front_gestion_minera/modules/admin/presentation/screens/admin_home_screen.dart'
    as _i1;
import 'package:front_gestion_minera/modules/admin/presentation/screens/request_detail_screen.dart'
    as _i29;
import 'package:front_gestion_minera/modules/auth/presentation/screen/auth_screens.dart'
    as _i3;
import 'package:front_gestion_minera/modules/partners/presentation/screens/contribute_history_screen.dart'
    as _i5;
import 'package:front_gestion_minera/modules/partners/presentation/screens/distributes_screen.dart'
    as _i8;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_history_screen.dart'
    as _i16;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_screen.dart'
    as _i17;
import 'package:front_gestion_minera/modules/partners/presentation/screens/money_request_screen.dart'
    as _i20;
import 'package:front_gestion_minera/modules/partners/presentation/screens/partners_screen.dart'
    as _i23;
import 'package:front_gestion_minera/modules/partners/presentation/screens/request_history_screen.dart'
    as _i30;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/application_details_screen.dart'
    as _i2;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/history_requests_screen.dart'
    as _i12;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/home_surveillance_screen.dart'
    as _i14;
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart'
    as _i40;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/contributes_home_screen.dart'
    as _i6;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/details_distribute_screen.dart'
    as _i9;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/distribute_home_screen.dart'
    as _i7;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/payment_distribute_screen.dart'
    as _i25;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/home_dashboard_screen.dart'
    as _i13;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/payment_history_screen.dart'
    as _i24;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/pending_applications_screen.dart'
    as _i26;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/transaction_details_screen.dart'
    as _i33;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/urgent_transaction_screen.dart'
    as _i35;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/view_request_detail_screen.dart'
    as _i36;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/batch_detail_screen.dart'
    as _i4;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/gold_dashboard_screen.dart'
    as _i11;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/new_extraction_screen.dart'
    as _i21;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/register_sell_screen.dart'
    as _i28;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/sell_preview_screen.dart'
    as _i31;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/sell_summary_screen.dart'
    as _i32;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loan_details_screen.dart'
    as _i15;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loan_simulation_screen.dart'
    as _i18;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loans_home_screen.dart'
    as _i19;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/new_loans_screen.dart'
    as _i22;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/record_payment_screen.dart'
    as _i27;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/reports/financial_reports_screen.dart'
    as _i10;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/treasury_screen.dart'
    as _i34;
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart'
    as _i39;

/// generated route for
/// [_i1.AdminHomeScreen]
class AdminHomeRoute extends _i37.PageRouteInfo<void> {
  const AdminHomeRoute({List<_i37.PageRouteInfo>? children})
    : super(AdminHomeRoute.name, initialChildren: children);

  static const String name = 'AdminHomeRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i1.AdminHomeScreen();
    },
  );
}

/// generated route for
/// [_i2.ApplicationDetailsScreen]
class ApplicationDetailsRoute
    extends _i37.PageRouteInfo<ApplicationDetailsRouteArgs> {
  ApplicationDetailsRoute({
    _i38.Key? key,
    required String requestId,
    required DateTime createdAt,
    required String name,
    required String rol,
    required String description,
    required String amount,
    required String evidencia,
    required String status,
    String? motivoRechazo,
    List<_i37.PageRouteInfo>? children,
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

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ApplicationDetailsRouteArgs>();
      return _i2.ApplicationDetailsScreen(
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

  final _i38.Key? key;

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
/// [_i3.AuthScreen]
class AuthRoute extends _i37.PageRouteInfo<void> {
  const AuthRoute({List<_i37.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i3.AuthScreen();
    },
  );
}

/// generated route for
/// [_i4.BatchDetailScreen]
class BatchDetailRoute extends _i37.PageRouteInfo<void> {
  const BatchDetailRoute({List<_i37.PageRouteInfo>? children})
    : super(BatchDetailRoute.name, initialChildren: children);

  static const String name = 'BatchDetailRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i4.BatchDetailScreen();
    },
  );
}

/// generated route for
/// [_i5.ContributeHistoryScreen]
class ContributeHistoryRoute extends _i37.PageRouteInfo<void> {
  const ContributeHistoryRoute({List<_i37.PageRouteInfo>? children})
    : super(ContributeHistoryRoute.name, initialChildren: children);

  static const String name = 'ContributeHistoryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i5.ContributeHistoryScreen();
    },
  );
}

/// generated route for
/// [_i6.ContributesHomeScreen]
class ContributesHomeRoute extends _i37.PageRouteInfo<void> {
  const ContributesHomeRoute({List<_i37.PageRouteInfo>? children})
    : super(ContributesHomeRoute.name, initialChildren: children);

  static const String name = 'ContributesHomeRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i6.ContributesHomeScreen();
    },
  );
}

/// generated route for
/// [_i7.DistributeHomeScreen]
class DistributeHomeRoute extends _i37.PageRouteInfo<void> {
  const DistributeHomeRoute({List<_i37.PageRouteInfo>? children})
    : super(DistributeHomeRoute.name, initialChildren: children);

  static const String name = 'DistributeHomeRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i7.DistributeHomeScreen();
    },
  );
}

/// generated route for
/// [_i8.DistributesScreen]
class DistributesRoute extends _i37.PageRouteInfo<void> {
  const DistributesRoute({List<_i37.PageRouteInfo>? children})
    : super(DistributesRoute.name, initialChildren: children);

  static const String name = 'DistributesRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i8.DistributesScreen();
    },
  );
}

/// generated route for
/// [_i9.DividendDistributionDetailsScreen]
class DividendDistributionDetailsRoute
    extends _i37.PageRouteInfo<DividendDistributionDetailsRouteArgs> {
  DividendDistributionDetailsRoute({
    _i38.Key? key,
    required String distributionId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         DividendDistributionDetailsRoute.name,
         args: DividendDistributionDetailsRouteArgs(
           key: key,
           distributionId: distributionId,
         ),
         initialChildren: children,
       );

  static const String name = 'DividendDistributionDetailsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DividendDistributionDetailsRouteArgs>();
      return _i9.DividendDistributionDetailsScreen(
        key: args.key,
        distributionId: args.distributionId,
      );
    },
  );
}

class DividendDistributionDetailsRouteArgs {
  const DividendDistributionDetailsRouteArgs({
    this.key,
    required this.distributionId,
  });

  final _i38.Key? key;

  final String distributionId;

  @override
  String toString() {
    return 'DividendDistributionDetailsRouteArgs{key: $key, distributionId: $distributionId}';
  }
}

/// generated route for
/// [_i10.FinancialReportsScreen]
class FinancialReportsRoute extends _i37.PageRouteInfo<void> {
  const FinancialReportsRoute({List<_i37.PageRouteInfo>? children})
    : super(FinancialReportsRoute.name, initialChildren: children);

  static const String name = 'FinancialReportsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i10.FinancialReportsScreen();
    },
  );
}

/// generated route for
/// [_i11.GoldDashboardScreen]
class GoldDashboardRoute extends _i37.PageRouteInfo<void> {
  const GoldDashboardRoute({List<_i37.PageRouteInfo>? children})
    : super(GoldDashboardRoute.name, initialChildren: children);

  static const String name = 'GoldDashboardRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i11.GoldDashboardScreen();
    },
  );
}

/// generated route for
/// [_i12.HistoryRequestsScreen]
class HistoryRequestsRoute extends _i37.PageRouteInfo<void> {
  const HistoryRequestsRoute({List<_i37.PageRouteInfo>? children})
    : super(HistoryRequestsRoute.name, initialChildren: children);

  static const String name = 'HistoryRequestsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i12.HistoryRequestsScreen();
    },
  );
}

/// generated route for
/// [_i13.HomeDashboardScreen]
class HomeDashboardRoute extends _i37.PageRouteInfo<void> {
  const HomeDashboardRoute({List<_i37.PageRouteInfo>? children})
    : super(HomeDashboardRoute.name, initialChildren: children);

  static const String name = 'HomeDashboardRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i13.HomeDashboardScreen();
    },
  );
}

/// generated route for
/// [_i14.HomeSurveillanceScreen]
class HomeSurveillanceRoute extends _i37.PageRouteInfo<void> {
  const HomeSurveillanceRoute({List<_i37.PageRouteInfo>? children})
    : super(HomeSurveillanceRoute.name, initialChildren: children);

  static const String name = 'HomeSurveillanceRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i14.HomeSurveillanceScreen();
    },
  );
}

/// generated route for
/// [_i15.LoanDetailsScreen]
class LoanDetailsRoute extends _i37.PageRouteInfo<LoanDetailsRouteArgs> {
  LoanDetailsRoute({
    _i39.Key? key,
    required String idLoan,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         LoanDetailsRoute.name,
         args: LoanDetailsRouteArgs(key: key, idLoan: idLoan),
         initialChildren: children,
       );

  static const String name = 'LoanDetailsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoanDetailsRouteArgs>();
      return _i15.LoanDetailsScreen(key: args.key, idLoan: args.idLoan);
    },
  );
}

class LoanDetailsRouteArgs {
  const LoanDetailsRouteArgs({this.key, required this.idLoan});

  final _i39.Key? key;

  final String idLoan;

  @override
  String toString() {
    return 'LoanDetailsRouteArgs{key: $key, idLoan: $idLoan}';
  }
}

/// generated route for
/// [_i16.LoanHistoryScreen]
class LoanHistoryRoute extends _i37.PageRouteInfo<void> {
  const LoanHistoryRoute({List<_i37.PageRouteInfo>? children})
    : super(LoanHistoryRoute.name, initialChildren: children);

  static const String name = 'LoanHistoryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i16.LoanHistoryScreen();
    },
  );
}

/// generated route for
/// [_i17.LoanScreen]
class LoanRoute extends _i37.PageRouteInfo<void> {
  const LoanRoute({List<_i37.PageRouteInfo>? children})
    : super(LoanRoute.name, initialChildren: children);

  static const String name = 'LoanRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i17.LoanScreen();
    },
  );
}

/// generated route for
/// [_i18.LoanSimulationScreen]
class LoanSimulationRoute extends _i37.PageRouteInfo<LoanSimulationRouteArgs> {
  LoanSimulationRoute({
    _i39.Key? key,
    required _i40.NewLoansResponseEntity loan,
    required _i40.CashResponseEntity cash,
    required String name,
    required String date,
    required double annualInterestRate,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         LoanSimulationRoute.name,
         args: LoanSimulationRouteArgs(
           key: key,
           loan: loan,
           cash: cash,
           name: name,
           date: date,
           annualInterestRate: annualInterestRate,
         ),
         initialChildren: children,
       );

  static const String name = 'LoanSimulationRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoanSimulationRouteArgs>();
      return _i18.LoanSimulationScreen(
        key: args.key,
        loan: args.loan,
        cash: args.cash,
        name: args.name,
        date: args.date,
        annualInterestRate: args.annualInterestRate,
      );
    },
  );
}

class LoanSimulationRouteArgs {
  const LoanSimulationRouteArgs({
    this.key,
    required this.loan,
    required this.cash,
    required this.name,
    required this.date,
    required this.annualInterestRate,
  });

  final _i39.Key? key;

  final _i40.NewLoansResponseEntity loan;

  final _i40.CashResponseEntity cash;

  final String name;

  final String date;

  final double annualInterestRate;

  @override
  String toString() {
    return 'LoanSimulationRouteArgs{key: $key, loan: $loan, cash: $cash, name: $name, date: $date, annualInterestRate: $annualInterestRate}';
  }
}

/// generated route for
/// [_i19.LoansHomeScreen]
class LoansHomeRoute extends _i37.PageRouteInfo<void> {
  const LoansHomeRoute({List<_i37.PageRouteInfo>? children})
    : super(LoansHomeRoute.name, initialChildren: children);

  static const String name = 'LoansHomeRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i19.LoansHomeScreen();
    },
  );
}

/// generated route for
/// [_i20.MoneyRequestScreen]
class MoneyRequestRoute extends _i37.PageRouteInfo<void> {
  const MoneyRequestRoute({List<_i37.PageRouteInfo>? children})
    : super(MoneyRequestRoute.name, initialChildren: children);

  static const String name = 'MoneyRequestRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i20.MoneyRequestScreen();
    },
  );
}

/// generated route for
/// [_i21.NewExtractionScreen]
class NewExtractionRoute extends _i37.PageRouteInfo<void> {
  const NewExtractionRoute({List<_i37.PageRouteInfo>? children})
    : super(NewExtractionRoute.name, initialChildren: children);

  static const String name = 'NewExtractionRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i21.NewExtractionScreen();
    },
  );
}

/// generated route for
/// [_i22.NewLoansScreen]
class NewLoansRoute extends _i37.PageRouteInfo<void> {
  const NewLoansRoute({List<_i37.PageRouteInfo>? children})
    : super(NewLoansRoute.name, initialChildren: children);

  static const String name = 'NewLoansRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i22.NewLoansScreen();
    },
  );
}

/// generated route for
/// [_i23.PartnersScreen]
class PartnersRoute extends _i37.PageRouteInfo<PartnersRouteArgs> {
  PartnersRoute({
    _i38.Key? key,
    required String nombre,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         PartnersRoute.name,
         args: PartnersRouteArgs(key: key, nombre: nombre),
         initialChildren: children,
       );

  static const String name = 'PartnersRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PartnersRouteArgs>();
      return _i23.PartnersScreen(key: args.key, nombre: args.nombre);
    },
  );
}

class PartnersRouteArgs {
  const PartnersRouteArgs({this.key, required this.nombre});

  final _i38.Key? key;

  final String nombre;

  @override
  String toString() {
    return 'PartnersRouteArgs{key: $key, nombre: $nombre}';
  }
}

/// generated route for
/// [_i24.PaymentHistoryScreen]
class PaymentHistoryRoute extends _i37.PageRouteInfo<void> {
  const PaymentHistoryRoute({List<_i37.PageRouteInfo>? children})
    : super(PaymentHistoryRoute.name, initialChildren: children);

  static const String name = 'PaymentHistoryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i24.PaymentHistoryScreen();
    },
  );
}

/// generated route for
/// [_i25.PaymentSuccessDistributionScreen]
class PaymentSuccessDistributionRoute
    extends _i37.PageRouteInfo<PaymentSuccessDistributionRouteArgs> {
  PaymentSuccessDistributionRoute({
    _i38.Key? key,
    required String beneficiario,
    required String montoPagado,
    required String periodo,
    required String fechaHora,
    required String cajaOrigen,
    required String saldoRestante,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         PaymentSuccessDistributionRoute.name,
         args: PaymentSuccessDistributionRouteArgs(
           key: key,
           beneficiario: beneficiario,
           montoPagado: montoPagado,
           periodo: periodo,
           fechaHora: fechaHora,
           cajaOrigen: cajaOrigen,
           saldoRestante: saldoRestante,
         ),
         initialChildren: children,
       );

  static const String name = 'PaymentSuccessDistributionRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentSuccessDistributionRouteArgs>();
      return _i25.PaymentSuccessDistributionScreen(
        key: args.key,
        beneficiario: args.beneficiario,
        montoPagado: args.montoPagado,
        periodo: args.periodo,
        fechaHora: args.fechaHora,
        cajaOrigen: args.cajaOrigen,
        saldoRestante: args.saldoRestante,
      );
    },
  );
}

class PaymentSuccessDistributionRouteArgs {
  const PaymentSuccessDistributionRouteArgs({
    this.key,
    required this.beneficiario,
    required this.montoPagado,
    required this.periodo,
    required this.fechaHora,
    required this.cajaOrigen,
    required this.saldoRestante,
  });

  final _i38.Key? key;

  final String beneficiario;

  final String montoPagado;

  final String periodo;

  final String fechaHora;

  final String cajaOrigen;

  final String saldoRestante;

  @override
  String toString() {
    return 'PaymentSuccessDistributionRouteArgs{key: $key, beneficiario: $beneficiario, montoPagado: $montoPagado, periodo: $periodo, fechaHora: $fechaHora, cajaOrigen: $cajaOrigen, saldoRestante: $saldoRestante}';
  }
}

/// generated route for
/// [_i26.PendingApplicationsScreen]
class PendingApplicationsRoute extends _i37.PageRouteInfo<void> {
  const PendingApplicationsRoute({List<_i37.PageRouteInfo>? children})
    : super(PendingApplicationsRoute.name, initialChildren: children);

  static const String name = 'PendingApplicationsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i26.PendingApplicationsScreen();
    },
  );
}

/// generated route for
/// [_i27.RecordPaymentScreen]
class RecordPaymentRoute extends _i37.PageRouteInfo<RecordPaymentRouteArgs> {
  RecordPaymentRoute({
    _i38.Key? key,
    required String quotaId,
    required String textoCuota,
    required int montoTotalCuota,
    required _i40.CashResponseEntity cash,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         RecordPaymentRoute.name,
         args: RecordPaymentRouteArgs(
           key: key,
           quotaId: quotaId,
           textoCuota: textoCuota,
           montoTotalCuota: montoTotalCuota,
           cash: cash,
         ),
         initialChildren: children,
       );

  static const String name = 'RecordPaymentRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecordPaymentRouteArgs>();
      return _i27.RecordPaymentScreen(
        key: args.key,
        quotaId: args.quotaId,
        textoCuota: args.textoCuota,
        montoTotalCuota: args.montoTotalCuota,
        cash: args.cash,
      );
    },
  );
}

class RecordPaymentRouteArgs {
  const RecordPaymentRouteArgs({
    this.key,
    required this.quotaId,
    required this.textoCuota,
    required this.montoTotalCuota,
    required this.cash,
  });

  final _i38.Key? key;

  final String quotaId;

  final String textoCuota;

  final int montoTotalCuota;

  final _i40.CashResponseEntity cash;

  @override
  String toString() {
    return 'RecordPaymentRouteArgs{key: $key, quotaId: $quotaId, textoCuota: $textoCuota, montoTotalCuota: $montoTotalCuota, cash: $cash}';
  }
}

/// generated route for
/// [_i28.RegisterSellScreen]
class RegisterSellRoute extends _i37.PageRouteInfo<void> {
  const RegisterSellRoute({List<_i37.PageRouteInfo>? children})
    : super(RegisterSellRoute.name, initialChildren: children);

  static const String name = 'RegisterSellRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i28.RegisterSellScreen();
    },
  );
}

/// generated route for
/// [_i29.RequestDetailScreen]
class RequestDetailRoute extends _i37.PageRouteInfo<RequestDetailRouteArgs> {
  RequestDetailRoute({
    _i38.Key? key,
    required String requestId,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         RequestDetailRoute.name,
         args: RequestDetailRouteArgs(key: key, requestId: requestId),
         initialChildren: children,
       );

  static const String name = 'RequestDetailRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RequestDetailRouteArgs>();
      return _i29.RequestDetailScreen(key: args.key, requestId: args.requestId);
    },
  );
}

class RequestDetailRouteArgs {
  const RequestDetailRouteArgs({this.key, required this.requestId});

  final _i38.Key? key;

  final String requestId;

  @override
  String toString() {
    return 'RequestDetailRouteArgs{key: $key, requestId: $requestId}';
  }
}

/// generated route for
/// [_i30.RequestHistoryScreen]
class RequestHistoryRoute extends _i37.PageRouteInfo<void> {
  const RequestHistoryRoute({List<_i37.PageRouteInfo>? children})
    : super(RequestHistoryRoute.name, initialChildren: children);

  static const String name = 'RequestHistoryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i30.RequestHistoryScreen();
    },
  );
}

/// generated route for
/// [_i31.SellPreviewScreen]
class SellPreviewRoute extends _i37.PageRouteInfo<SellPreviewRouteArgs> {
  SellPreviewRoute({
    _i38.Key? key,
    required _i40.SalePreviewResponseEntity previewData,
    required String salesDate,
    required String buyer,
    required double totalGramsSold,
    required double priceBsPerGram,
    required String comprobanteFilePath,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         SellPreviewRoute.name,
         args: SellPreviewRouteArgs(
           key: key,
           previewData: previewData,
           salesDate: salesDate,
           buyer: buyer,
           totalGramsSold: totalGramsSold,
           priceBsPerGram: priceBsPerGram,
           comprobanteFilePath: comprobanteFilePath,
         ),
         initialChildren: children,
       );

  static const String name = 'SellPreviewRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SellPreviewRouteArgs>();
      return _i31.SellPreviewScreen(
        key: args.key,
        previewData: args.previewData,
        salesDate: args.salesDate,
        buyer: args.buyer,
        totalGramsSold: args.totalGramsSold,
        priceBsPerGram: args.priceBsPerGram,
        comprobanteFilePath: args.comprobanteFilePath,
      );
    },
  );
}

class SellPreviewRouteArgs {
  const SellPreviewRouteArgs({
    this.key,
    required this.previewData,
    required this.salesDate,
    required this.buyer,
    required this.totalGramsSold,
    required this.priceBsPerGram,
    required this.comprobanteFilePath,
  });

  final _i38.Key? key;

  final _i40.SalePreviewResponseEntity previewData;

  final String salesDate;

  final String buyer;

  final double totalGramsSold;

  final double priceBsPerGram;

  final String comprobanteFilePath;

  @override
  String toString() {
    return 'SellPreviewRouteArgs{key: $key, previewData: $previewData, salesDate: $salesDate, buyer: $buyer, totalGramsSold: $totalGramsSold, priceBsPerGram: $priceBsPerGram, comprobanteFilePath: $comprobanteFilePath}';
  }
}

/// generated route for
/// [_i32.SellSummaryScreen]
class SellSummaryRoute extends _i37.PageRouteInfo<SellSummaryRouteArgs> {
  SellSummaryRoute({
    _i38.Key? key,
    required _i40.RegisterSaleResponseEntity saleData,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         SellSummaryRoute.name,
         args: SellSummaryRouteArgs(key: key, saleData: saleData),
         initialChildren: children,
       );

  static const String name = 'SellSummaryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SellSummaryRouteArgs>();
      return _i32.SellSummaryScreen(key: args.key, saleData: args.saleData);
    },
  );
}

class SellSummaryRouteArgs {
  const SellSummaryRouteArgs({this.key, required this.saleData});

  final _i38.Key? key;

  final _i40.RegisterSaleResponseEntity saleData;

  @override
  String toString() {
    return 'SellSummaryRouteArgs{key: $key, saleData: $saleData}';
  }
}

/// generated route for
/// [_i33.TransactionDetailsScreen]
class TransactionDetailsRoute
    extends _i37.PageRouteInfo<TransactionDetailsRouteArgs> {
  TransactionDetailsRoute({
    _i39.Key? key,
    required String idTransaction,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         TransactionDetailsRoute.name,
         args: TransactionDetailsRouteArgs(
           key: key,
           idTransaction: idTransaction,
         ),
         initialChildren: children,
       );

  static const String name = 'TransactionDetailsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TransactionDetailsRouteArgs>();
      return _i33.TransactionDetailsScreen(
        key: args.key,
        idTransaction: args.idTransaction,
      );
    },
  );
}

class TransactionDetailsRouteArgs {
  const TransactionDetailsRouteArgs({this.key, required this.idTransaction});

  final _i39.Key? key;

  final String idTransaction;

  @override
  String toString() {
    return 'TransactionDetailsRouteArgs{key: $key, idTransaction: $idTransaction}';
  }
}

/// generated route for
/// [_i34.TreasuryScreen]
class TreasuryRoute extends _i37.PageRouteInfo<void> {
  const TreasuryRoute({List<_i37.PageRouteInfo>? children})
    : super(TreasuryRoute.name, initialChildren: children);

  static const String name = 'TreasuryRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i34.TreasuryScreen();
    },
  );
}

/// generated route for
/// [_i35.UrgentTransactionScreen]
class UrgentTransactionRoute extends _i37.PageRouteInfo<void> {
  const UrgentTransactionRoute({List<_i37.PageRouteInfo>? children})
    : super(UrgentTransactionRoute.name, initialChildren: children);

  static const String name = 'UrgentTransactionRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      return const _i35.UrgentTransactionScreen();
    },
  );
}

/// generated route for
/// [_i36.ViewRequestDetailsScreen]
class ViewRequestDetailsRoute
    extends _i37.PageRouteInfo<ViewRequestDetailsRouteArgs> {
  ViewRequestDetailsRoute({
    _i38.Key? key,
    required String id,
    List<_i37.PageRouteInfo>? children,
  }) : super(
         ViewRequestDetailsRoute.name,
         args: ViewRequestDetailsRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ViewRequestDetailsRoute';

  static _i37.PageInfo page = _i37.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewRequestDetailsRouteArgs>();
      return _i36.ViewRequestDetailsScreen(key: args.key, id: args.id);
    },
  );
}

class ViewRequestDetailsRouteArgs {
  const ViewRequestDetailsRouteArgs({this.key, required this.id});

  final _i38.Key? key;

  final String id;

  @override
  String toString() {
    return 'ViewRequestDetailsRouteArgs{key: $key, id: $id}';
  }
}
