// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i32;
import 'package:flutter/material.dart' as _i33;
import 'package:front_gestion_minera/modules/admin/presentation/screens/admin_home_screen.dart'
    as _i1;
import 'package:front_gestion_minera/modules/admin/presentation/screens/request_detail_screen.dart'
    as _i24;
import 'package:front_gestion_minera/modules/auth/presentation/screen/auth_screens.dart'
    as _i3;
import 'package:front_gestion_minera/modules/partners/presentation/screens/contribute_history_screen.dart'
    as _i4;
import 'package:front_gestion_minera/modules/partners/presentation/screens/distributes_screen.dart'
    as _i7;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_history_screen.dart'
    as _i13;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_screen.dart'
    as _i14;
import 'package:front_gestion_minera/modules/partners/presentation/screens/money_request_screen.dart'
    as _i17;
import 'package:front_gestion_minera/modules/partners/presentation/screens/partners_screen.dart'
    as _i20;
import 'package:front_gestion_minera/modules/partners/presentation/screens/request_history_screen.dart'
    as _i25;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/application_details_screen.dart'
    as _i2;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/history_requests_screen.dart'
    as _i10;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/home_surveillance_screen.dart'
    as _i12;
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart'
    as _i34;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/contributes_home_screen.dart'
    as _i5;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/distribute_home_screen.dart'
    as _i6;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/home_dashboard_screen.dart'
    as _i11;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/payment_history_screen.dart'
    as _i21;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/pending_applications_screen.dart'
    as _i22;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/transaction_details_screen.dart'
    as _i28;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/urgent_transaction_screen.dart'
    as _i30;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/view_request_detail_screen.dart'
    as _i31;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/gold_dashboard_screen.dart'
    as _i9;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/new_extraction_screen.dart'
    as _i18;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/register_sell_screen.dart'
    as _i23;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/sell_preview_screen.dart'
    as _i26;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/sell_summary_screen.dart'
    as _i27;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loan_simulation_screen.dart'
    as _i15;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loans_home_screen.dart'
    as _i16;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/new_loans_screen.dart'
    as _i19;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/reports/financial_reports_screen.dart'
    as _i8;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/treasury_screen.dart'
    as _i29;
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart'
    as _i35;

/// generated route for
/// [_i1.AdminHomeScreen]
class AdminHomeRoute extends _i32.PageRouteInfo<void> {
  const AdminHomeRoute({List<_i32.PageRouteInfo>? children})
    : super(AdminHomeRoute.name, initialChildren: children);

  static const String name = 'AdminHomeRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i1.AdminHomeScreen();
    },
  );
}

/// generated route for
/// [_i2.ApplicationDetailsScreen]
class ApplicationDetailsRoute
    extends _i32.PageRouteInfo<ApplicationDetailsRouteArgs> {
  ApplicationDetailsRoute({
    _i33.Key? key,
    required String requestId,
    required DateTime createdAt,
    required String name,
    required String rol,
    required String description,
    required String amount,
    required String evidencia,
    required String status,
    String? motivoRechazo,
    List<_i32.PageRouteInfo>? children,
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

  static _i32.PageInfo page = _i32.PageInfo(
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

  final _i33.Key? key;

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
class AuthRoute extends _i32.PageRouteInfo<void> {
  const AuthRoute({List<_i32.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i3.AuthScreen();
    },
  );
}

/// generated route for
/// [_i4.ContributeHistoryScreen]
class ContributeHistoryRoute extends _i32.PageRouteInfo<void> {
  const ContributeHistoryRoute({List<_i32.PageRouteInfo>? children})
    : super(ContributeHistoryRoute.name, initialChildren: children);

  static const String name = 'ContributeHistoryRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i4.ContributeHistoryScreen();
    },
  );
}

/// generated route for
/// [_i5.ContributesHomeScreen]
class ContributesHomeRoute extends _i32.PageRouteInfo<void> {
  const ContributesHomeRoute({List<_i32.PageRouteInfo>? children})
    : super(ContributesHomeRoute.name, initialChildren: children);

  static const String name = 'ContributesHomeRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i5.ContributesHomeScreen();
    },
  );
}

/// generated route for
/// [_i6.DistributeHomeScreen]
class DistributeHomeRoute extends _i32.PageRouteInfo<void> {
  const DistributeHomeRoute({List<_i32.PageRouteInfo>? children})
    : super(DistributeHomeRoute.name, initialChildren: children);

  static const String name = 'DistributeHomeRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i6.DistributeHomeScreen();
    },
  );
}

/// generated route for
/// [_i7.DistributesScreen]
class DistributesRoute extends _i32.PageRouteInfo<void> {
  const DistributesRoute({List<_i32.PageRouteInfo>? children})
    : super(DistributesRoute.name, initialChildren: children);

  static const String name = 'DistributesRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i7.DistributesScreen();
    },
  );
}

/// generated route for
/// [_i8.FinancialReportsScreen]
class FinancialReportsRoute extends _i32.PageRouteInfo<void> {
  const FinancialReportsRoute({List<_i32.PageRouteInfo>? children})
    : super(FinancialReportsRoute.name, initialChildren: children);

  static const String name = 'FinancialReportsRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i8.FinancialReportsScreen();
    },
  );
}

/// generated route for
/// [_i9.GoldDashboardScreen]
class GoldDashboardRoute extends _i32.PageRouteInfo<void> {
  const GoldDashboardRoute({List<_i32.PageRouteInfo>? children})
    : super(GoldDashboardRoute.name, initialChildren: children);

  static const String name = 'GoldDashboardRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i9.GoldDashboardScreen();
    },
  );
}

/// generated route for
/// [_i10.HistoryRequestsScreen]
class HistoryRequestsRoute extends _i32.PageRouteInfo<void> {
  const HistoryRequestsRoute({List<_i32.PageRouteInfo>? children})
    : super(HistoryRequestsRoute.name, initialChildren: children);

  static const String name = 'HistoryRequestsRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i10.HistoryRequestsScreen();
    },
  );
}

/// generated route for
/// [_i11.HomeDashboardScreen]
class HomeDashboardRoute extends _i32.PageRouteInfo<void> {
  const HomeDashboardRoute({List<_i32.PageRouteInfo>? children})
    : super(HomeDashboardRoute.name, initialChildren: children);

  static const String name = 'HomeDashboardRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i11.HomeDashboardScreen();
    },
  );
}

/// generated route for
/// [_i12.HomeSurveillanceScreen]
class HomeSurveillanceRoute extends _i32.PageRouteInfo<void> {
  const HomeSurveillanceRoute({List<_i32.PageRouteInfo>? children})
    : super(HomeSurveillanceRoute.name, initialChildren: children);

  static const String name = 'HomeSurveillanceRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i12.HomeSurveillanceScreen();
    },
  );
}

/// generated route for
/// [_i13.LoanHistoryScreen]
class LoanHistoryRoute extends _i32.PageRouteInfo<void> {
  const LoanHistoryRoute({List<_i32.PageRouteInfo>? children})
    : super(LoanHistoryRoute.name, initialChildren: children);

  static const String name = 'LoanHistoryRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i13.LoanHistoryScreen();
    },
  );
}

/// generated route for
/// [_i14.LoanScreen]
class LoanRoute extends _i32.PageRouteInfo<void> {
  const LoanRoute({List<_i32.PageRouteInfo>? children})
    : super(LoanRoute.name, initialChildren: children);

  static const String name = 'LoanRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i14.LoanScreen();
    },
  );
}

/// generated route for
/// [_i15.LoanSimulationScreen]
class LoanSimulationRoute extends _i32.PageRouteInfo<LoanSimulationRouteArgs> {
  LoanSimulationRoute({
    _i33.Key? key,
    required _i34.NewLoansResponseEntity loan,
    required String name,
    List<_i32.PageRouteInfo>? children,
  }) : super(
         LoanSimulationRoute.name,
         args: LoanSimulationRouteArgs(key: key, loan: loan, name: name),
         initialChildren: children,
       );

  static const String name = 'LoanSimulationRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoanSimulationRouteArgs>();
      return _i15.LoanSimulationScreen(
        key: args.key,
        loan: args.loan,
        name: args.name,
      );
    },
  );
}

class LoanSimulationRouteArgs {
  const LoanSimulationRouteArgs({
    this.key,
    required this.loan,
    required this.name,
  });

  final _i33.Key? key;

  final _i34.NewLoansResponseEntity loan;

  final String name;

  @override
  String toString() {
    return 'LoanSimulationRouteArgs{key: $key, loan: $loan, name: $name}';
  }
}

/// generated route for
/// [_i16.LoansHomeScreen]
class LoansHomeRoute extends _i32.PageRouteInfo<void> {
  const LoansHomeRoute({List<_i32.PageRouteInfo>? children})
    : super(LoansHomeRoute.name, initialChildren: children);

  static const String name = 'LoansHomeRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i16.LoansHomeScreen();
    },
  );
}

/// generated route for
/// [_i17.MoneyRequestScreen]
class MoneyRequestRoute extends _i32.PageRouteInfo<void> {
  const MoneyRequestRoute({List<_i32.PageRouteInfo>? children})
    : super(MoneyRequestRoute.name, initialChildren: children);

  static const String name = 'MoneyRequestRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i17.MoneyRequestScreen();
    },
  );
}

/// generated route for
/// [_i18.NewExtractionScreen]
class NewExtractionRoute extends _i32.PageRouteInfo<void> {
  const NewExtractionRoute({List<_i32.PageRouteInfo>? children})
    : super(NewExtractionRoute.name, initialChildren: children);

  static const String name = 'NewExtractionRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i18.NewExtractionScreen();
    },
  );
}

/// generated route for
/// [_i19.NewLoansScreen]
class NewLoansRoute extends _i32.PageRouteInfo<void> {
  const NewLoansRoute({List<_i32.PageRouteInfo>? children})
    : super(NewLoansRoute.name, initialChildren: children);

  static const String name = 'NewLoansRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i19.NewLoansScreen();
    },
  );
}

/// generated route for
/// [_i20.PartnersScreen]
class PartnersRoute extends _i32.PageRouteInfo<PartnersRouteArgs> {
  PartnersRoute({
    _i33.Key? key,
    required String nombre,
    List<_i32.PageRouteInfo>? children,
  }) : super(
         PartnersRoute.name,
         args: PartnersRouteArgs(key: key, nombre: nombre),
         initialChildren: children,
       );

  static const String name = 'PartnersRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PartnersRouteArgs>();
      return _i20.PartnersScreen(key: args.key, nombre: args.nombre);
    },
  );
}

class PartnersRouteArgs {
  const PartnersRouteArgs({this.key, required this.nombre});

  final _i33.Key? key;

  final String nombre;

  @override
  String toString() {
    return 'PartnersRouteArgs{key: $key, nombre: $nombre}';
  }
}

/// generated route for
/// [_i21.PaymentHistoryScreen]
class PaymentHistoryRoute extends _i32.PageRouteInfo<void> {
  const PaymentHistoryRoute({List<_i32.PageRouteInfo>? children})
    : super(PaymentHistoryRoute.name, initialChildren: children);

  static const String name = 'PaymentHistoryRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i21.PaymentHistoryScreen();
    },
  );
}

/// generated route for
/// [_i22.PendingApplicationsScreen]
class PendingApplicationsRoute extends _i32.PageRouteInfo<void> {
  const PendingApplicationsRoute({List<_i32.PageRouteInfo>? children})
    : super(PendingApplicationsRoute.name, initialChildren: children);

  static const String name = 'PendingApplicationsRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i22.PendingApplicationsScreen();
    },
  );
}

/// generated route for
/// [_i23.RegisterSellScreen]
class RegisterSellRoute extends _i32.PageRouteInfo<void> {
  const RegisterSellRoute({List<_i32.PageRouteInfo>? children})
    : super(RegisterSellRoute.name, initialChildren: children);

  static const String name = 'RegisterSellRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i23.RegisterSellScreen();
    },
  );
}

/// generated route for
/// [_i24.RequestDetailScreen]
class RequestDetailRoute extends _i32.PageRouteInfo<RequestDetailRouteArgs> {
  RequestDetailRoute({
    _i33.Key? key,
    required String requestId,
    List<_i32.PageRouteInfo>? children,
  }) : super(
         RequestDetailRoute.name,
         args: RequestDetailRouteArgs(key: key, requestId: requestId),
         initialChildren: children,
       );

  static const String name = 'RequestDetailRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RequestDetailRouteArgs>();
      return _i24.RequestDetailScreen(key: args.key, requestId: args.requestId);
    },
  );
}

class RequestDetailRouteArgs {
  const RequestDetailRouteArgs({this.key, required this.requestId});

  final _i33.Key? key;

  final String requestId;

  @override
  String toString() {
    return 'RequestDetailRouteArgs{key: $key, requestId: $requestId}';
  }
}

/// generated route for
/// [_i25.RequestHistoryScreen]
class RequestHistoryRoute extends _i32.PageRouteInfo<void> {
  const RequestHistoryRoute({List<_i32.PageRouteInfo>? children})
    : super(RequestHistoryRoute.name, initialChildren: children);

  static const String name = 'RequestHistoryRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i25.RequestHistoryScreen();
    },
  );
}

/// generated route for
/// [_i26.SellPreviewScreen]
class SellPreviewRoute extends _i32.PageRouteInfo<SellPreviewRouteArgs> {
  SellPreviewRoute({
    _i33.Key? key,
    required _i34.SalePreviewResponseEntity previewData,
    required String salesDate,
    required String buyer,
    required double totalGramsSold,
    required double priceBsPerGram,
    required String comprobanteFilePath,
    List<_i32.PageRouteInfo>? children,
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

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SellPreviewRouteArgs>();
      return _i26.SellPreviewScreen(
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

  final _i33.Key? key;

  final _i34.SalePreviewResponseEntity previewData;

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
/// [_i27.SellSummaryScreen]
class SellSummaryRoute extends _i32.PageRouteInfo<SellSummaryRouteArgs> {
  SellSummaryRoute({
    _i33.Key? key,
    required _i34.RegisterSaleResponseEntity saleData,
    List<_i32.PageRouteInfo>? children,
  }) : super(
         SellSummaryRoute.name,
         args: SellSummaryRouteArgs(key: key, saleData: saleData),
         initialChildren: children,
       );

  static const String name = 'SellSummaryRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SellSummaryRouteArgs>();
      return _i27.SellSummaryScreen(key: args.key, saleData: args.saleData);
    },
  );
}

class SellSummaryRouteArgs {
  const SellSummaryRouteArgs({this.key, required this.saleData});

  final _i33.Key? key;

  final _i34.RegisterSaleResponseEntity saleData;

  @override
  String toString() {
    return 'SellSummaryRouteArgs{key: $key, saleData: $saleData}';
  }
}

/// generated route for
/// [_i28.TransactionDetailsScreen]
class TransactionDetailsRoute
    extends _i32.PageRouteInfo<TransactionDetailsRouteArgs> {
  TransactionDetailsRoute({
    _i35.Key? key,
    required String idTransaction,
    List<_i32.PageRouteInfo>? children,
  }) : super(
         TransactionDetailsRoute.name,
         args: TransactionDetailsRouteArgs(
           key: key,
           idTransaction: idTransaction,
         ),
         initialChildren: children,
       );

  static const String name = 'TransactionDetailsRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TransactionDetailsRouteArgs>();
      return _i28.TransactionDetailsScreen(
        key: args.key,
        idTransaction: args.idTransaction,
      );
    },
  );
}

class TransactionDetailsRouteArgs {
  const TransactionDetailsRouteArgs({this.key, required this.idTransaction});

  final _i35.Key? key;

  final String idTransaction;

  @override
  String toString() {
    return 'TransactionDetailsRouteArgs{key: $key, idTransaction: $idTransaction}';
  }
}

/// generated route for
/// [_i29.TreasuryScreen]
class TreasuryRoute extends _i32.PageRouteInfo<void> {
  const TreasuryRoute({List<_i32.PageRouteInfo>? children})
    : super(TreasuryRoute.name, initialChildren: children);

  static const String name = 'TreasuryRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i29.TreasuryScreen();
    },
  );
}

/// generated route for
/// [_i30.UrgentTransactionScreen]
class UrgentTransactionRoute extends _i32.PageRouteInfo<void> {
  const UrgentTransactionRoute({List<_i32.PageRouteInfo>? children})
    : super(UrgentTransactionRoute.name, initialChildren: children);

  static const String name = 'UrgentTransactionRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      return const _i30.UrgentTransactionScreen();
    },
  );
}

/// generated route for
/// [_i31.ViewRequestDetailsScreen]
class ViewRequestDetailsRoute
    extends _i32.PageRouteInfo<ViewRequestDetailsRouteArgs> {
  ViewRequestDetailsRoute({
    _i33.Key? key,
    required String id,
    List<_i32.PageRouteInfo>? children,
  }) : super(
         ViewRequestDetailsRoute.name,
         args: ViewRequestDetailsRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ViewRequestDetailsRoute';

  static _i32.PageInfo page = _i32.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewRequestDetailsRouteArgs>();
      return _i31.ViewRequestDetailsScreen(key: args.key, id: args.id);
    },
  );
}

class ViewRequestDetailsRouteArgs {
  const ViewRequestDetailsRouteArgs({this.key, required this.id});

  final _i33.Key? key;

  final String id;

  @override
  String toString() {
    return 'ViewRequestDetailsRouteArgs{key: $key, id: $id}';
  }
}
