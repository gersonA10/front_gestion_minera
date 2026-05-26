// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i68;
import 'package:flutter/material.dart' as _i69;
import 'package:front_gestion_minera/modules/admin/home/presentation/screens/admin_home_screen.dart'
    as _i2;
import 'package:front_gestion_minera/modules/admin/home/presentation/screens/create_contribution_screen.dart'
    as _i9;
import 'package:front_gestion_minera/modules/admin/home/presentation/screens/request_detail_screen.dart'
    as _i52;
import 'package:front_gestion_minera/modules/admin/users/presentation/screens/user_form_screen.dart'
    as _i64;
import 'package:front_gestion_minera/modules/admin/users/presentation/screens/users_management_screen.dart'
    as _i65;
import 'package:front_gestion_minera/modules/auth/presentation/screen/auth_screens.dart'
    as _i4;
import 'package:front_gestion_minera/modules/camp/presentation/screens/home_dashboard__camp_screen.dart'
    as _i20;
import 'package:front_gestion_minera/modules/camp/presentation/screens/new_request_screen.dart'
    as _i37;
import 'package:front_gestion_minera/modules/camp/presentation/screens/request_progress_details_screen.dart'
    as _i55;
import 'package:front_gestion_minera/modules/camp/presentation/screens/transaction_history_screen.dart'
    as _i60;
import 'package:front_gestion_minera/modules/camp/presentation/screens/upload_receipt_evidence_screen.dart'
    as _i62;
import 'package:front_gestion_minera/modules/machinery/presentation/screens/detail_machinery_screen.dart'
    as _i10;
import 'package:front_gestion_minera/modules/machinery/presentation/screens/detail_maintenance_screen.dart'
    as _i11;
import 'package:front_gestion_minera/modules/machinery/presentation/screens/home_machinary_screen.dart'
    as _i22;
import 'package:front_gestion_minera/modules/machinery/presentation/screens/list_machinery_screen.dart'
    as _i25;
import 'package:front_gestion_minera/modules/machinery/presentation/screens/maintenance_request_history_screen.dart'
    as _i31;
import 'package:front_gestion_minera/modules/machinery/presentation/screens/registration_of_new_machinery_screen.dart'
    as _i51;
import 'package:front_gestion_minera/modules/machinery/presentation/screens/request_maintenance_screen.dart'
    as _i54;
import 'package:front_gestion_minera/modules/minutes_memos/presentation/screens/acta_details_screen.dart'
    as _i1;
import 'package:front_gestion_minera/modules/minutes_memos/presentation/screens/internal_memorandum_details_screen.dart'
    as _i24;
import 'package:front_gestion_minera/modules/minutes_memos/presentation/screens/minutes_memos_main_screen.dart'
    as _i32;
import 'package:front_gestion_minera/modules/minutes_memos/presentation/screens/register_minutes_memos_screen.dart'
    as _i48;
import 'package:front_gestion_minera/modules/partners/presentation/screens/contribute_history_screen.dart'
    as _i6;
import 'package:front_gestion_minera/modules/partners/presentation/screens/distributes_screen.dart'
    as _i13;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_history_screen.dart'
    as _i27;
import 'package:front_gestion_minera/modules/partners/presentation/screens/loan_screen.dart'
    as _i28;
import 'package:front_gestion_minera/modules/partners/presentation/screens/money_request_screen.dart'
    as _i33;
import 'package:front_gestion_minera/modules/partners/presentation/screens/partners_screen.dart'
    as _i38;
import 'package:front_gestion_minera/modules/partners/presentation/screens/request_history_screen.dart'
    as _i53;
import 'package:front_gestion_minera/modules/staff/presentation/screens/employee_check_out_log_screen.dart'
    as _i15;
import 'package:front_gestion_minera/modules/staff/presentation/screens/employee_entry_register_screen.dart'
    as _i16;
import 'package:front_gestion_minera/modules/staff/presentation/screens/payroll_screen.dart'
    as _i43;
import 'package:front_gestion_minera/modules/staff/presentation/screens/register_staff_screen.dart'
    as _i50;
import 'package:front_gestion_minera/modules/staff/presentation/screens/staff_main_screen.dart'
    as _i58;
import 'package:front_gestion_minera/modules/staff/presentation/screens/workers_screen.dart'
    as _i67;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/application_details_screen.dart'
    as _i3;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/history_requests_screen.dart'
    as _i19;
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/home_surveillance_screen.dart'
    as _i23;
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart'
    as _i71;
import 'package:front_gestion_minera/modules/treasury/domain/entity/loans/payment_process_entity.dart'
    as _i73;
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart'
    as _i72;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/contributes_home_screen.dart'
    as _i8;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/contribution_history_screen.dart'
    as _i45;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/details_of_a_contribution_screen.dart'
    as _i7;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/payment_details_screen.dart'
    as _i39;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/contributes/record_contribution_payment_screen.dart'
    as _i46;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/details_distribute_screen.dart'
    as _i14;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/distribute_home_screen.dart'
    as _i12;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/new_distribute_screen.dart'
    as _i34;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/distributes/payment_distribute_screen.dart'
    as _i41;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/home_dashboard_screen.dart'
    as _i21;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/payment_history_screen.dart'
    as _i40;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/pending_applications_screen.dart'
    as _i44;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/transaction_details_screen.dart'
    as _i59;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/urgent_transaction_screen.dart'
    as _i63;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/view_request_detail_screen.dart'
    as _i66;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/batch_detail_screen.dart'
    as _i5;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/gold_dashboard_screen.dart'
    as _i18;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/new_extraction_screen.dart'
    as _i35;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/register_sell_screen.dart'
    as _i49;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/sell_preview_screen.dart'
    as _i56;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/goldInventory/sell_summary_screen.dart'
    as _i57;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loan_details_screen.dart'
    as _i26;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loan_simulation_screen.dart'
    as _i29;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/loans_home_screen.dart'
    as _i30;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/new_loans_screen.dart'
    as _i36;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/payment_success_screen.dart'
    as _i42;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/loans/record_payment_screen.dart'
    as _i47;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/reports/financial_reports_screen.dart'
    as _i17;
import 'package:front_gestion_minera/modules/treasury/presentation/screens/treasury_screen.dart'
    as _i61;
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart'
    as _i70;

/// generated route for
/// [_i1.ActaDetailsScreen]
class ActaDetailsRoute extends _i68.PageRouteInfo<ActaDetailsRouteArgs> {
  ActaDetailsRoute({
    _i69.Key? key,
    required String actaId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ActaDetailsRoute.name,
         args: ActaDetailsRouteArgs(key: key, actaId: actaId),
         initialChildren: children,
       );

  static const String name = 'ActaDetailsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ActaDetailsRouteArgs>();
      return _i1.ActaDetailsScreen(key: args.key, actaId: args.actaId);
    },
  );
}

class ActaDetailsRouteArgs {
  const ActaDetailsRouteArgs({this.key, required this.actaId});

  final _i69.Key? key;

  final String actaId;

  @override
  String toString() {
    return 'ActaDetailsRouteArgs{key: $key, actaId: $actaId}';
  }
}

/// generated route for
/// [_i2.AdminHomeScreen]
class AdminHomeRoute extends _i68.PageRouteInfo<void> {
  const AdminHomeRoute({List<_i68.PageRouteInfo>? children})
    : super(AdminHomeRoute.name, initialChildren: children);

  static const String name = 'AdminHomeRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdminHomeScreen();
    },
  );
}

/// generated route for
/// [_i3.ApplicationDetailsScreen]
class ApplicationDetailsRoute
    extends _i68.PageRouteInfo<ApplicationDetailsRouteArgs> {
  ApplicationDetailsRoute({
    _i69.Key? key,
    required String requestId,
    required DateTime createdAt,
    required String name,
    required String rol,
    required String description,
    required String amount,
    required String evidencia,
    required String status,
    String? motivoRechazo,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ApplicationDetailsRouteArgs>();
      return _i3.ApplicationDetailsScreen(
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

  final _i69.Key? key;

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
/// [_i4.AuthScreen]
class AuthRoute extends _i68.PageRouteInfo<void> {
  const AuthRoute({List<_i68.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i4.AuthScreen();
    },
  );
}

/// generated route for
/// [_i5.BatchDetailScreen]
class BatchDetailRoute extends _i68.PageRouteInfo<BatchDetailRouteArgs> {
  BatchDetailRoute({
    _i69.Key? key,
    required String batchId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         BatchDetailRoute.name,
         args: BatchDetailRouteArgs(key: key, batchId: batchId),
         initialChildren: children,
       );

  static const String name = 'BatchDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BatchDetailRouteArgs>();
      return _i5.BatchDetailScreen(key: args.key, batchId: args.batchId);
    },
  );
}

class BatchDetailRouteArgs {
  const BatchDetailRouteArgs({this.key, required this.batchId});

  final _i69.Key? key;

  final String batchId;

  @override
  String toString() {
    return 'BatchDetailRouteArgs{key: $key, batchId: $batchId}';
  }
}

/// generated route for
/// [_i6.ContributeHistoryScreen]
class ContributeHistoryRoute extends _i68.PageRouteInfo<void> {
  const ContributeHistoryRoute({List<_i68.PageRouteInfo>? children})
    : super(ContributeHistoryRoute.name, initialChildren: children);

  static const String name = 'ContributeHistoryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i6.ContributeHistoryScreen();
    },
  );
}

/// generated route for
/// [_i7.ContributesDetailScreen]
class ContributesDetailRoute
    extends _i68.PageRouteInfo<ContributesDetailRouteArgs> {
  ContributesDetailRoute({
    _i70.Key? key,
    required String contributionId,
    required DateTime dateContibution,
    required String titleContibuton,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ContributesDetailRoute.name,
         args: ContributesDetailRouteArgs(
           key: key,
           contributionId: contributionId,
           dateContibution: dateContibution,
           titleContibuton: titleContibuton,
         ),
         initialChildren: children,
       );

  static const String name = 'ContributesDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContributesDetailRouteArgs>();
      return _i7.ContributesDetailScreen(
        key: args.key,
        contributionId: args.contributionId,
        dateContibution: args.dateContibution,
        titleContibuton: args.titleContibuton,
      );
    },
  );
}

class ContributesDetailRouteArgs {
  const ContributesDetailRouteArgs({
    this.key,
    required this.contributionId,
    required this.dateContibution,
    required this.titleContibuton,
  });

  final _i70.Key? key;

  final String contributionId;

  final DateTime dateContibution;

  final String titleContibuton;

  @override
  String toString() {
    return 'ContributesDetailRouteArgs{key: $key, contributionId: $contributionId, dateContibution: $dateContibution, titleContibuton: $titleContibuton}';
  }
}

/// generated route for
/// [_i8.ContributesHomeScreen]
class ContributesHomeRoute extends _i68.PageRouteInfo<void> {
  const ContributesHomeRoute({List<_i68.PageRouteInfo>? children})
    : super(ContributesHomeRoute.name, initialChildren: children);

  static const String name = 'ContributesHomeRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i8.ContributesHomeScreen();
    },
  );
}

/// generated route for
/// [_i9.CreateContributionScreen]
class CreateContributionRoute extends _i68.PageRouteInfo<void> {
  const CreateContributionRoute({List<_i68.PageRouteInfo>? children})
    : super(CreateContributionRoute.name, initialChildren: children);

  static const String name = 'CreateContributionRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i9.CreateContributionScreen();
    },
  );
}

/// generated route for
/// [_i10.DetailMachineryScreen]
class DetailMachineryRoute
    extends _i68.PageRouteInfo<DetailMachineryRouteArgs> {
  DetailMachineryRoute({
    _i69.Key? key,
    required String machineId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         DetailMachineryRoute.name,
         args: DetailMachineryRouteArgs(key: key, machineId: machineId),
         initialChildren: children,
       );

  static const String name = 'DetailMachineryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailMachineryRouteArgs>();
      return _i10.DetailMachineryScreen(
        key: args.key,
        machineId: args.machineId,
      );
    },
  );
}

class DetailMachineryRouteArgs {
  const DetailMachineryRouteArgs({this.key, required this.machineId});

  final _i69.Key? key;

  final String machineId;

  @override
  String toString() {
    return 'DetailMachineryRouteArgs{key: $key, machineId: $machineId}';
  }
}

/// generated route for
/// [_i11.DetailMaintenanceScreen]
class DetailMaintenanceRoute
    extends _i68.PageRouteInfo<DetailMaintenanceRouteArgs> {
  DetailMaintenanceRoute({
    _i69.Key? key,
    required String maintenanceId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         DetailMaintenanceRoute.name,
         args: DetailMaintenanceRouteArgs(
           key: key,
           maintenanceId: maintenanceId,
         ),
         initialChildren: children,
       );

  static const String name = 'DetailMaintenanceRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailMaintenanceRouteArgs>();
      return _i11.DetailMaintenanceScreen(
        key: args.key,
        maintenanceId: args.maintenanceId,
      );
    },
  );
}

class DetailMaintenanceRouteArgs {
  const DetailMaintenanceRouteArgs({this.key, required this.maintenanceId});

  final _i69.Key? key;

  final String maintenanceId;

  @override
  String toString() {
    return 'DetailMaintenanceRouteArgs{key: $key, maintenanceId: $maintenanceId}';
  }
}

/// generated route for
/// [_i12.DistributeHomeScreen]
class DistributeHomeRoute extends _i68.PageRouteInfo<void> {
  const DistributeHomeRoute({List<_i68.PageRouteInfo>? children})
    : super(DistributeHomeRoute.name, initialChildren: children);

  static const String name = 'DistributeHomeRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i12.DistributeHomeScreen();
    },
  );
}

/// generated route for
/// [_i13.DistributesScreen]
class DistributesRoute extends _i68.PageRouteInfo<void> {
  const DistributesRoute({List<_i68.PageRouteInfo>? children})
    : super(DistributesRoute.name, initialChildren: children);

  static const String name = 'DistributesRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i13.DistributesScreen();
    },
  );
}

/// generated route for
/// [_i14.DividendDistributionDetailsScreen]
class DividendDistributionDetailsRoute
    extends _i68.PageRouteInfo<DividendDistributionDetailsRouteArgs> {
  DividendDistributionDetailsRoute({
    _i70.Key? key,
    required String distributionId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         DividendDistributionDetailsRoute.name,
         args: DividendDistributionDetailsRouteArgs(
           key: key,
           distributionId: distributionId,
         ),
         initialChildren: children,
       );

  static const String name = 'DividendDistributionDetailsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DividendDistributionDetailsRouteArgs>();
      return _i14.DividendDistributionDetailsScreen(
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

  final _i70.Key? key;

  final String distributionId;

  @override
  String toString() {
    return 'DividendDistributionDetailsRouteArgs{key: $key, distributionId: $distributionId}';
  }
}

/// generated route for
/// [_i15.EmployeeCheckOutLogScreen]
class EmployeeCheckOutLogRoute
    extends _i68.PageRouteInfo<EmployeeCheckOutLogRouteArgs> {
  EmployeeCheckOutLogRoute({
    _i69.Key? key,
    required String attendanceId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         EmployeeCheckOutLogRoute.name,
         args: EmployeeCheckOutLogRouteArgs(
           key: key,
           attendanceId: attendanceId,
         ),
         initialChildren: children,
       );

  static const String name = 'EmployeeCheckOutLogRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmployeeCheckOutLogRouteArgs>();
      return _i15.EmployeeCheckOutLogScreen(
        key: args.key,
        attendanceId: args.attendanceId,
      );
    },
  );
}

class EmployeeCheckOutLogRouteArgs {
  const EmployeeCheckOutLogRouteArgs({this.key, required this.attendanceId});

  final _i69.Key? key;

  final String attendanceId;

  @override
  String toString() {
    return 'EmployeeCheckOutLogRouteArgs{key: $key, attendanceId: $attendanceId}';
  }
}

/// generated route for
/// [_i16.EmployeeEntryRegisterScreen]
class EmployeeEntryRegisterRoute
    extends _i68.PageRouteInfo<EmployeeEntryRegisterRouteArgs> {
  EmployeeEntryRegisterRoute({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         EmployeeEntryRegisterRoute.name,
         args: EmployeeEntryRegisterRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'EmployeeEntryRegisterRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmployeeEntryRegisterRouteArgs>();
      return _i16.EmployeeEntryRegisterScreen(key: args.key, id: args.id);
    },
  );
}

class EmployeeEntryRegisterRouteArgs {
  const EmployeeEntryRegisterRouteArgs({this.key, required this.id});

  final _i69.Key? key;

  final String id;

  @override
  String toString() {
    return 'EmployeeEntryRegisterRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i17.FinancialReportsScreen]
class FinancialReportsRoute extends _i68.PageRouteInfo<void> {
  const FinancialReportsRoute({List<_i68.PageRouteInfo>? children})
    : super(FinancialReportsRoute.name, initialChildren: children);

  static const String name = 'FinancialReportsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i17.FinancialReportsScreen();
    },
  );
}

/// generated route for
/// [_i18.GoldDashboardScreen]
class GoldDashboardRoute extends _i68.PageRouteInfo<void> {
  const GoldDashboardRoute({List<_i68.PageRouteInfo>? children})
    : super(GoldDashboardRoute.name, initialChildren: children);

  static const String name = 'GoldDashboardRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i18.GoldDashboardScreen();
    },
  );
}

/// generated route for
/// [_i19.HistoryRequestsScreen]
class HistoryRequestsRoute extends _i68.PageRouteInfo<void> {
  const HistoryRequestsRoute({List<_i68.PageRouteInfo>? children})
    : super(HistoryRequestsRoute.name, initialChildren: children);

  static const String name = 'HistoryRequestsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i19.HistoryRequestsScreen();
    },
  );
}

/// generated route for
/// [_i20.HomeDashboardCampScreen]
class HomeDashboardCampRoute extends _i68.PageRouteInfo<void> {
  const HomeDashboardCampRoute({List<_i68.PageRouteInfo>? children})
    : super(HomeDashboardCampRoute.name, initialChildren: children);

  static const String name = 'HomeDashboardCampRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i20.HomeDashboardCampScreen();
    },
  );
}

/// generated route for
/// [_i21.HomeDashboardScreen]
class HomeDashboardRoute extends _i68.PageRouteInfo<void> {
  const HomeDashboardRoute({List<_i68.PageRouteInfo>? children})
    : super(HomeDashboardRoute.name, initialChildren: children);

  static const String name = 'HomeDashboardRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i21.HomeDashboardScreen();
    },
  );
}

/// generated route for
/// [_i22.HomeMachinaryScreen]
class HomeMachinaryRoute extends _i68.PageRouteInfo<void> {
  const HomeMachinaryRoute({List<_i68.PageRouteInfo>? children})
    : super(HomeMachinaryRoute.name, initialChildren: children);

  static const String name = 'HomeMachinaryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i22.HomeMachinaryScreen();
    },
  );
}

/// generated route for
/// [_i23.HomeSurveillanceScreen]
class HomeSurveillanceRoute extends _i68.PageRouteInfo<void> {
  const HomeSurveillanceRoute({List<_i68.PageRouteInfo>? children})
    : super(HomeSurveillanceRoute.name, initialChildren: children);

  static const String name = 'HomeSurveillanceRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i23.HomeSurveillanceScreen();
    },
  );
}

/// generated route for
/// [_i24.InternalMemorandumDetailsScreen]
class InternalMemorandumDetailsRoute
    extends _i68.PageRouteInfo<InternalMemorandumDetailsRouteArgs> {
  InternalMemorandumDetailsRoute({
    _i69.Key? key,
    required String memoId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         InternalMemorandumDetailsRoute.name,
         args: InternalMemorandumDetailsRouteArgs(key: key, memoId: memoId),
         initialChildren: children,
       );

  static const String name = 'InternalMemorandumDetailsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InternalMemorandumDetailsRouteArgs>();
      return _i24.InternalMemorandumDetailsScreen(
        key: args.key,
        memoId: args.memoId,
      );
    },
  );
}

class InternalMemorandumDetailsRouteArgs {
  const InternalMemorandumDetailsRouteArgs({this.key, required this.memoId});

  final _i69.Key? key;

  final String memoId;

  @override
  String toString() {
    return 'InternalMemorandumDetailsRouteArgs{key: $key, memoId: $memoId}';
  }
}

/// generated route for
/// [_i25.ListMachineryScreen]
class ListMachineryRoute extends _i68.PageRouteInfo<void> {
  const ListMachineryRoute({List<_i68.PageRouteInfo>? children})
    : super(ListMachineryRoute.name, initialChildren: children);

  static const String name = 'ListMachineryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i25.ListMachineryScreen();
    },
  );
}

/// generated route for
/// [_i26.LoanDetailsScreen]
class LoanDetailsRoute extends _i68.PageRouteInfo<LoanDetailsRouteArgs> {
  LoanDetailsRoute({
    _i70.Key? key,
    required String idLoan,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         LoanDetailsRoute.name,
         args: LoanDetailsRouteArgs(key: key, idLoan: idLoan),
         initialChildren: children,
       );

  static const String name = 'LoanDetailsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoanDetailsRouteArgs>();
      return _i26.LoanDetailsScreen(key: args.key, idLoan: args.idLoan);
    },
  );
}

class LoanDetailsRouteArgs {
  const LoanDetailsRouteArgs({this.key, required this.idLoan});

  final _i70.Key? key;

  final String idLoan;

  @override
  String toString() {
    return 'LoanDetailsRouteArgs{key: $key, idLoan: $idLoan}';
  }
}

/// generated route for
/// [_i27.LoanHistoryScreen]
class LoanHistoryRoute extends _i68.PageRouteInfo<void> {
  const LoanHistoryRoute({List<_i68.PageRouteInfo>? children})
    : super(LoanHistoryRoute.name, initialChildren: children);

  static const String name = 'LoanHistoryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i27.LoanHistoryScreen();
    },
  );
}

/// generated route for
/// [_i28.LoanScreen]
class LoanRoute extends _i68.PageRouteInfo<void> {
  const LoanRoute({List<_i68.PageRouteInfo>? children})
    : super(LoanRoute.name, initialChildren: children);

  static const String name = 'LoanRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i28.LoanScreen();
    },
  );
}

/// generated route for
/// [_i29.LoanSimulationScreen]
class LoanSimulationRoute extends _i68.PageRouteInfo<LoanSimulationRouteArgs> {
  LoanSimulationRoute({
    _i70.Key? key,
    required _i71.NewLoansResponseEntity loan,
    required _i71.CashResponseEntity cash,
    required String name,
    required String date,
    required double annualInterestRate,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoanSimulationRouteArgs>();
      return _i29.LoanSimulationScreen(
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

  final _i70.Key? key;

  final _i71.NewLoansResponseEntity loan;

  final _i71.CashResponseEntity cash;

  final String name;

  final String date;

  final double annualInterestRate;

  @override
  String toString() {
    return 'LoanSimulationRouteArgs{key: $key, loan: $loan, cash: $cash, name: $name, date: $date, annualInterestRate: $annualInterestRate}';
  }
}

/// generated route for
/// [_i30.LoansHomeScreen]
class LoansHomeRoute extends _i68.PageRouteInfo<void> {
  const LoansHomeRoute({List<_i68.PageRouteInfo>? children})
    : super(LoansHomeRoute.name, initialChildren: children);

  static const String name = 'LoansHomeRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i30.LoansHomeScreen();
    },
  );
}

/// generated route for
/// [_i31.MaintenanceRequestHistoryScreen]
class MaintenanceRequestHistoryRoute
    extends _i68.PageRouteInfo<MaintenanceRequestHistoryRouteArgs> {
  MaintenanceRequestHistoryRoute({
    _i69.Key? key,
    required String machineId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         MaintenanceRequestHistoryRoute.name,
         args: MaintenanceRequestHistoryRouteArgs(
           key: key,
           machineId: machineId,
         ),
         initialChildren: children,
       );

  static const String name = 'MaintenanceRequestHistoryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintenanceRequestHistoryRouteArgs>();
      return _i31.MaintenanceRequestHistoryScreen(
        key: args.key,
        machineId: args.machineId,
      );
    },
  );
}

class MaintenanceRequestHistoryRouteArgs {
  const MaintenanceRequestHistoryRouteArgs({this.key, required this.machineId});

  final _i69.Key? key;

  final String machineId;

  @override
  String toString() {
    return 'MaintenanceRequestHistoryRouteArgs{key: $key, machineId: $machineId}';
  }
}

/// generated route for
/// [_i32.MinutesMemosMainScreen]
class MinutesMemosMainRoute extends _i68.PageRouteInfo<void> {
  const MinutesMemosMainRoute({List<_i68.PageRouteInfo>? children})
    : super(MinutesMemosMainRoute.name, initialChildren: children);

  static const String name = 'MinutesMemosMainRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i32.MinutesMemosMainScreen();
    },
  );
}

/// generated route for
/// [_i33.MoneyRequestScreen]
class MoneyRequestRoute extends _i68.PageRouteInfo<void> {
  const MoneyRequestRoute({List<_i68.PageRouteInfo>? children})
    : super(MoneyRequestRoute.name, initialChildren: children);

  static const String name = 'MoneyRequestRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i33.MoneyRequestScreen();
    },
  );
}

/// generated route for
/// [_i34.NewDistributionScreen]
class NewDistributionRoute extends _i68.PageRouteInfo<void> {
  const NewDistributionRoute({List<_i68.PageRouteInfo>? children})
    : super(NewDistributionRoute.name, initialChildren: children);

  static const String name = 'NewDistributionRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i34.NewDistributionScreen();
    },
  );
}

/// generated route for
/// [_i35.NewExtractionScreen]
class NewExtractionRoute extends _i68.PageRouteInfo<void> {
  const NewExtractionRoute({List<_i68.PageRouteInfo>? children})
    : super(NewExtractionRoute.name, initialChildren: children);

  static const String name = 'NewExtractionRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i35.NewExtractionScreen();
    },
  );
}

/// generated route for
/// [_i36.NewLoansScreen]
class NewLoansRoute extends _i68.PageRouteInfo<void> {
  const NewLoansRoute({List<_i68.PageRouteInfo>? children})
    : super(NewLoansRoute.name, initialChildren: children);

  static const String name = 'NewLoansRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i36.NewLoansScreen();
    },
  );
}

/// generated route for
/// [_i37.NewRequestScreen]
class NewRequestRoute extends _i68.PageRouteInfo<void> {
  const NewRequestRoute({List<_i68.PageRouteInfo>? children})
    : super(NewRequestRoute.name, initialChildren: children);

  static const String name = 'NewRequestRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i37.NewRequestScreen();
    },
  );
}

/// generated route for
/// [_i38.PartnersScreen]
class PartnersRoute extends _i68.PageRouteInfo<PartnersRouteArgs> {
  PartnersRoute({
    _i69.Key? key,
    required String nombre,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         PartnersRoute.name,
         args: PartnersRouteArgs(key: key, nombre: nombre),
         initialChildren: children,
       );

  static const String name = 'PartnersRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PartnersRouteArgs>();
      return _i38.PartnersScreen(key: args.key, nombre: args.nombre);
    },
  );
}

class PartnersRouteArgs {
  const PartnersRouteArgs({this.key, required this.nombre});

  final _i69.Key? key;

  final String nombre;

  @override
  String toString() {
    return 'PartnersRouteArgs{key: $key, nombre: $nombre}';
  }
}

/// generated route for
/// [_i39.PaymentConfirmationScreen]
class PaymentConfirmationRoute
    extends _i68.PageRouteInfo<PaymentConfirmationRouteArgs> {
  PaymentConfirmationRoute({
    _i69.Key? key,
    required String transactionId,
    required bool screen,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         PaymentConfirmationRoute.name,
         args: PaymentConfirmationRouteArgs(
           key: key,
           transactionId: transactionId,
           screen: screen,
         ),
         initialChildren: children,
       );

  static const String name = 'PaymentConfirmationRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentConfirmationRouteArgs>();
      return _i39.PaymentConfirmationScreen(
        key: args.key,
        transactionId: args.transactionId,
        screen: args.screen,
      );
    },
  );
}

class PaymentConfirmationRouteArgs {
  const PaymentConfirmationRouteArgs({
    this.key,
    required this.transactionId,
    required this.screen,
  });

  final _i69.Key? key;

  final String transactionId;

  final bool screen;

  @override
  String toString() {
    return 'PaymentConfirmationRouteArgs{key: $key, transactionId: $transactionId, screen: $screen}';
  }
}

/// generated route for
/// [_i40.PaymentHistoryScreen]
class PaymentHistoryRoute extends _i68.PageRouteInfo<void> {
  const PaymentHistoryRoute({List<_i68.PageRouteInfo>? children})
    : super(PaymentHistoryRoute.name, initialChildren: children);

  static const String name = 'PaymentHistoryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i40.PaymentHistoryScreen();
    },
  );
}

/// generated route for
/// [_i41.PaymentSuccessDistributionScreen]
class PaymentSuccessDistributionRoute
    extends _i68.PageRouteInfo<PaymentSuccessDistributionRouteArgs> {
  PaymentSuccessDistributionRoute({
    _i69.Key? key,
    required String receiptId,
    required _i72.TreasuryBloc bloc,
    required bool isFromDetails,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         PaymentSuccessDistributionRoute.name,
         args: PaymentSuccessDistributionRouteArgs(
           key: key,
           receiptId: receiptId,
           bloc: bloc,
           isFromDetails: isFromDetails,
         ),
         initialChildren: children,
       );

  static const String name = 'PaymentSuccessDistributionRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentSuccessDistributionRouteArgs>();
      return _i41.PaymentSuccessDistributionScreen(
        key: args.key,
        receiptId: args.receiptId,
        bloc: args.bloc,
        isFromDetails: args.isFromDetails,
      );
    },
  );
}

class PaymentSuccessDistributionRouteArgs {
  const PaymentSuccessDistributionRouteArgs({
    this.key,
    required this.receiptId,
    required this.bloc,
    required this.isFromDetails,
  });

  final _i69.Key? key;

  final String receiptId;

  final _i72.TreasuryBloc bloc;

  final bool isFromDetails;

  @override
  String toString() {
    return 'PaymentSuccessDistributionRouteArgs{key: $key, receiptId: $receiptId, bloc: $bloc, isFromDetails: $isFromDetails}';
  }
}

/// generated route for
/// [_i42.PaymentSuccessScreen]
class PaymentSuccessRoute extends _i68.PageRouteInfo<PaymentSuccessRouteArgs> {
  PaymentSuccessRoute({
    _i69.Key? key,
    required _i73.PayTheFeeResponseEntity paymentData,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         PaymentSuccessRoute.name,
         args: PaymentSuccessRouteArgs(key: key, paymentData: paymentData),
         initialChildren: children,
       );

  static const String name = 'PaymentSuccessRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentSuccessRouteArgs>();
      return _i42.PaymentSuccessScreen(
        key: args.key,
        paymentData: args.paymentData,
      );
    },
  );
}

class PaymentSuccessRouteArgs {
  const PaymentSuccessRouteArgs({this.key, required this.paymentData});

  final _i69.Key? key;

  final _i73.PayTheFeeResponseEntity paymentData;

  @override
  String toString() {
    return 'PaymentSuccessRouteArgs{key: $key, paymentData: $paymentData}';
  }
}

/// generated route for
/// [_i43.PayrollScreen]
class PayrollRoute extends _i68.PageRouteInfo<void> {
  const PayrollRoute({List<_i68.PageRouteInfo>? children})
    : super(PayrollRoute.name, initialChildren: children);

  static const String name = 'PayrollRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i43.PayrollScreen();
    },
  );
}

/// generated route for
/// [_i44.PendingApplicationsScreen]
class PendingApplicationsRoute extends _i68.PageRouteInfo<void> {
  const PendingApplicationsRoute({List<_i68.PageRouteInfo>? children})
    : super(PendingApplicationsRoute.name, initialChildren: children);

  static const String name = 'PendingApplicationsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i44.PendingApplicationsScreen();
    },
  );
}

/// generated route for
/// [_i45.ReceiptsHistoryScreen]
class ReceiptsHistoryRoute
    extends _i68.PageRouteInfo<ReceiptsHistoryRouteArgs> {
  ReceiptsHistoryRoute({
    _i69.Key? key,
    required String contributionId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ReceiptsHistoryRoute.name,
         args: ReceiptsHistoryRouteArgs(
           key: key,
           contributionId: contributionId,
         ),
         initialChildren: children,
       );

  static const String name = 'ReceiptsHistoryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReceiptsHistoryRouteArgs>();
      return _i45.ReceiptsHistoryScreen(
        key: args.key,
        contributionId: args.contributionId,
      );
    },
  );
}

class ReceiptsHistoryRouteArgs {
  const ReceiptsHistoryRouteArgs({this.key, required this.contributionId});

  final _i69.Key? key;

  final String contributionId;

  @override
  String toString() {
    return 'ReceiptsHistoryRouteArgs{key: $key, contributionId: $contributionId}';
  }
}

/// generated route for
/// [_i46.RecordContributionPaymentScreen]
class RecordContributionPaymentRoute
    extends _i68.PageRouteInfo<RecordContributionPaymentRouteArgs> {
  RecordContributionPaymentRoute({
    _i69.Key? key,
    required DateTime dateContibution,
    required String titleContibuton,
    required _i71.ContributionDetailMemberEntity item,
    required _i71.CashResponseEntity cash,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         RecordContributionPaymentRoute.name,
         args: RecordContributionPaymentRouteArgs(
           key: key,
           dateContibution: dateContibution,
           titleContibuton: titleContibuton,
           item: item,
           cash: cash,
         ),
         initialChildren: children,
       );

  static const String name = 'RecordContributionPaymentRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecordContributionPaymentRouteArgs>();
      return _i46.RecordContributionPaymentScreen(
        key: args.key,
        dateContibution: args.dateContibution,
        titleContibuton: args.titleContibuton,
        item: args.item,
        cash: args.cash,
      );
    },
  );
}

class RecordContributionPaymentRouteArgs {
  const RecordContributionPaymentRouteArgs({
    this.key,
    required this.dateContibution,
    required this.titleContibuton,
    required this.item,
    required this.cash,
  });

  final _i69.Key? key;

  final DateTime dateContibution;

  final String titleContibuton;

  final _i71.ContributionDetailMemberEntity item;

  final _i71.CashResponseEntity cash;

  @override
  String toString() {
    return 'RecordContributionPaymentRouteArgs{key: $key, dateContibution: $dateContibution, titleContibuton: $titleContibuton, item: $item, cash: $cash}';
  }
}

/// generated route for
/// [_i47.RecordPaymentScreen]
class RecordPaymentRoute extends _i68.PageRouteInfo<RecordPaymentRouteArgs> {
  RecordPaymentRoute({
    _i69.Key? key,
    required String quotaId,
    required String textoCuota,
    required int montoTotalCuota,
    required _i71.CashResponseEntity cash,
    required String idLoan,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         RecordPaymentRoute.name,
         args: RecordPaymentRouteArgs(
           key: key,
           quotaId: quotaId,
           textoCuota: textoCuota,
           montoTotalCuota: montoTotalCuota,
           cash: cash,
           idLoan: idLoan,
         ),
         initialChildren: children,
       );

  static const String name = 'RecordPaymentRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecordPaymentRouteArgs>();
      return _i47.RecordPaymentScreen(
        key: args.key,
        quotaId: args.quotaId,
        textoCuota: args.textoCuota,
        montoTotalCuota: args.montoTotalCuota,
        cash: args.cash,
        idLoan: args.idLoan,
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
    required this.idLoan,
  });

  final _i69.Key? key;

  final String quotaId;

  final String textoCuota;

  final int montoTotalCuota;

  final _i71.CashResponseEntity cash;

  final String idLoan;

  @override
  String toString() {
    return 'RecordPaymentRouteArgs{key: $key, quotaId: $quotaId, textoCuota: $textoCuota, montoTotalCuota: $montoTotalCuota, cash: $cash, idLoan: $idLoan}';
  }
}

/// generated route for
/// [_i48.RegisterMinutesMemosScreen]
class RegisterMinutesMemosRoute
    extends _i68.PageRouteInfo<RegisterMinutesMemosRouteArgs> {
  RegisterMinutesMemosRoute({
    _i69.Key? key,
    required int isOption,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         RegisterMinutesMemosRoute.name,
         args: RegisterMinutesMemosRouteArgs(key: key, isOption: isOption),
         initialChildren: children,
       );

  static const String name = 'RegisterMinutesMemosRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegisterMinutesMemosRouteArgs>();
      return _i48.RegisterMinutesMemosScreen(
        key: args.key,
        isOption: args.isOption,
      );
    },
  );
}

class RegisterMinutesMemosRouteArgs {
  const RegisterMinutesMemosRouteArgs({this.key, required this.isOption});

  final _i69.Key? key;

  final int isOption;

  @override
  String toString() {
    return 'RegisterMinutesMemosRouteArgs{key: $key, isOption: $isOption}';
  }
}

/// generated route for
/// [_i49.RegisterSellScreen]
class RegisterSellRoute extends _i68.PageRouteInfo<void> {
  const RegisterSellRoute({List<_i68.PageRouteInfo>? children})
    : super(RegisterSellRoute.name, initialChildren: children);

  static const String name = 'RegisterSellRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i49.RegisterSellScreen();
    },
  );
}

/// generated route for
/// [_i50.RegisterStaffScreen]
class RegisterStaffRoute extends _i68.PageRouteInfo<void> {
  const RegisterStaffRoute({List<_i68.PageRouteInfo>? children})
    : super(RegisterStaffRoute.name, initialChildren: children);

  static const String name = 'RegisterStaffRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i50.RegisterStaffScreen();
    },
  );
}

/// generated route for
/// [_i51.RegistrationOfNewMachineryScreen]
class RegistrationOfNewMachineryRoute extends _i68.PageRouteInfo<void> {
  const RegistrationOfNewMachineryRoute({List<_i68.PageRouteInfo>? children})
    : super(RegistrationOfNewMachineryRoute.name, initialChildren: children);

  static const String name = 'RegistrationOfNewMachineryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i51.RegistrationOfNewMachineryScreen();
    },
  );
}

/// generated route for
/// [_i52.RequestDetailScreen]
class RequestDetailRoute extends _i68.PageRouteInfo<RequestDetailRouteArgs> {
  RequestDetailRoute({
    _i69.Key? key,
    required String requestId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         RequestDetailRoute.name,
         args: RequestDetailRouteArgs(key: key, requestId: requestId),
         initialChildren: children,
       );

  static const String name = 'RequestDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RequestDetailRouteArgs>();
      return _i52.RequestDetailScreen(key: args.key, requestId: args.requestId);
    },
  );
}

class RequestDetailRouteArgs {
  const RequestDetailRouteArgs({this.key, required this.requestId});

  final _i69.Key? key;

  final String requestId;

  @override
  String toString() {
    return 'RequestDetailRouteArgs{key: $key, requestId: $requestId}';
  }
}

/// generated route for
/// [_i53.RequestHistoryScreen]
class RequestHistoryRoute extends _i68.PageRouteInfo<void> {
  const RequestHistoryRoute({List<_i68.PageRouteInfo>? children})
    : super(RequestHistoryRoute.name, initialChildren: children);

  static const String name = 'RequestHistoryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i53.RequestHistoryScreen();
    },
  );
}

/// generated route for
/// [_i54.RequestMaintenanceScreen]
class RequestMaintenanceRoute
    extends _i68.PageRouteInfo<RequestMaintenanceRouteArgs> {
  RequestMaintenanceRoute({
    _i69.Key? key,
    required String machineId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         RequestMaintenanceRoute.name,
         args: RequestMaintenanceRouteArgs(key: key, machineId: machineId),
         initialChildren: children,
       );

  static const String name = 'RequestMaintenanceRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RequestMaintenanceRouteArgs>();
      return _i54.RequestMaintenanceScreen(
        key: args.key,
        machineId: args.machineId,
      );
    },
  );
}

class RequestMaintenanceRouteArgs {
  const RequestMaintenanceRouteArgs({this.key, required this.machineId});

  final _i69.Key? key;

  final String machineId;

  @override
  String toString() {
    return 'RequestMaintenanceRouteArgs{key: $key, machineId: $machineId}';
  }
}

/// generated route for
/// [_i55.RequestProgressDetailsScreen]
class RequestProgressDetailsRoute
    extends _i68.PageRouteInfo<RequestProgressDetailsRouteArgs> {
  RequestProgressDetailsRoute({
    _i69.Key? key,
    required String requestId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         RequestProgressDetailsRoute.name,
         args: RequestProgressDetailsRouteArgs(key: key, requestId: requestId),
         initialChildren: children,
       );

  static const String name = 'RequestProgressDetailsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RequestProgressDetailsRouteArgs>();
      return _i55.RequestProgressDetailsScreen(
        key: args.key,
        requestId: args.requestId,
      );
    },
  );
}

class RequestProgressDetailsRouteArgs {
  const RequestProgressDetailsRouteArgs({this.key, required this.requestId});

  final _i69.Key? key;

  final String requestId;

  @override
  String toString() {
    return 'RequestProgressDetailsRouteArgs{key: $key, requestId: $requestId}';
  }
}

/// generated route for
/// [_i56.SellPreviewScreen]
class SellPreviewRoute extends _i68.PageRouteInfo<SellPreviewRouteArgs> {
  SellPreviewRoute({
    _i69.Key? key,
    required _i71.SalePreviewResponseEntity previewData,
    required String salesDate,
    required String buyer,
    required double totalGramsSold,
    required double priceBsPerGram,
    required String comprobanteFilePath,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SellPreviewRouteArgs>();
      return _i56.SellPreviewScreen(
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

  final _i69.Key? key;

  final _i71.SalePreviewResponseEntity previewData;

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
/// [_i57.SellSummaryScreen]
class SellSummaryRoute extends _i68.PageRouteInfo<SellSummaryRouteArgs> {
  SellSummaryRoute({
    _i69.Key? key,
    required _i71.RegisterSaleResponseEntity saleData,
    bool isFromHistory = false,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         SellSummaryRoute.name,
         args: SellSummaryRouteArgs(
           key: key,
           saleData: saleData,
           isFromHistory: isFromHistory,
         ),
         initialChildren: children,
       );

  static const String name = 'SellSummaryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SellSummaryRouteArgs>();
      return _i57.SellSummaryScreen(
        key: args.key,
        saleData: args.saleData,
        isFromHistory: args.isFromHistory,
      );
    },
  );
}

class SellSummaryRouteArgs {
  const SellSummaryRouteArgs({
    this.key,
    required this.saleData,
    this.isFromHistory = false,
  });

  final _i69.Key? key;

  final _i71.RegisterSaleResponseEntity saleData;

  final bool isFromHistory;

  @override
  String toString() {
    return 'SellSummaryRouteArgs{key: $key, saleData: $saleData, isFromHistory: $isFromHistory}';
  }
}

/// generated route for
/// [_i58.StaffMainScreen]
class StaffMainRoute extends _i68.PageRouteInfo<void> {
  const StaffMainRoute({List<_i68.PageRouteInfo>? children})
    : super(StaffMainRoute.name, initialChildren: children);

  static const String name = 'StaffMainRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i58.StaffMainScreen();
    },
  );
}

/// generated route for
/// [_i59.TransactionDetailsScreen]
class TransactionDetailsRoute
    extends _i68.PageRouteInfo<TransactionDetailsRouteArgs> {
  TransactionDetailsRoute({
    _i70.Key? key,
    required String idTransaction,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         TransactionDetailsRoute.name,
         args: TransactionDetailsRouteArgs(
           key: key,
           idTransaction: idTransaction,
         ),
         initialChildren: children,
       );

  static const String name = 'TransactionDetailsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TransactionDetailsRouteArgs>();
      return _i59.TransactionDetailsScreen(
        key: args.key,
        idTransaction: args.idTransaction,
      );
    },
  );
}

class TransactionDetailsRouteArgs {
  const TransactionDetailsRouteArgs({this.key, required this.idTransaction});

  final _i70.Key? key;

  final String idTransaction;

  @override
  String toString() {
    return 'TransactionDetailsRouteArgs{key: $key, idTransaction: $idTransaction}';
  }
}

/// generated route for
/// [_i60.TransactionHistoryScreen]
class TransactionHistoryRoute extends _i68.PageRouteInfo<void> {
  const TransactionHistoryRoute({List<_i68.PageRouteInfo>? children})
    : super(TransactionHistoryRoute.name, initialChildren: children);

  static const String name = 'TransactionHistoryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i60.TransactionHistoryScreen();
    },
  );
}

/// generated route for
/// [_i61.TreasuryScreen]
class TreasuryRoute extends _i68.PageRouteInfo<void> {
  const TreasuryRoute({List<_i68.PageRouteInfo>? children})
    : super(TreasuryRoute.name, initialChildren: children);

  static const String name = 'TreasuryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i61.TreasuryScreen();
    },
  );
}

/// generated route for
/// [_i62.UploadReceiptEvidenceScreen]
class UploadReceiptEvidenceRoute
    extends _i68.PageRouteInfo<UploadReceiptEvidenceRouteArgs> {
  UploadReceiptEvidenceRoute({
    _i69.Key? key,
    required String requestId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         UploadReceiptEvidenceRoute.name,
         args: UploadReceiptEvidenceRouteArgs(key: key, requestId: requestId),
         initialChildren: children,
       );

  static const String name = 'UploadReceiptEvidenceRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UploadReceiptEvidenceRouteArgs>();
      return _i62.UploadReceiptEvidenceScreen(
        key: args.key,
        requestId: args.requestId,
      );
    },
  );
}

class UploadReceiptEvidenceRouteArgs {
  const UploadReceiptEvidenceRouteArgs({this.key, required this.requestId});

  final _i69.Key? key;

  final String requestId;

  @override
  String toString() {
    return 'UploadReceiptEvidenceRouteArgs{key: $key, requestId: $requestId}';
  }
}

/// generated route for
/// [_i63.UrgentTransactionScreen]
class UrgentTransactionRoute extends _i68.PageRouteInfo<void> {
  const UrgentTransactionRoute({List<_i68.PageRouteInfo>? children})
    : super(UrgentTransactionRoute.name, initialChildren: children);

  static const String name = 'UrgentTransactionRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i63.UrgentTransactionScreen();
    },
  );
}

/// generated route for
/// [_i64.UserFormScreen]
class UserFormRoute extends _i68.PageRouteInfo<UserFormRouteArgs> {
  UserFormRoute({
    _i69.Key? key,
    String? userId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         UserFormRoute.name,
         args: UserFormRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'UserFormRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserFormRouteArgs>(
        orElse: () => const UserFormRouteArgs(),
      );
      return _i64.UserFormScreen(key: args.key, userId: args.userId);
    },
  );
}

class UserFormRouteArgs {
  const UserFormRouteArgs({this.key, this.userId});

  final _i69.Key? key;

  final String? userId;

  @override
  String toString() {
    return 'UserFormRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [_i65.UsersManagementScreen]
class UsersManagementRoute extends _i68.PageRouteInfo<void> {
  const UsersManagementRoute({List<_i68.PageRouteInfo>? children})
    : super(UsersManagementRoute.name, initialChildren: children);

  static const String name = 'UsersManagementRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i65.UsersManagementScreen();
    },
  );
}

/// generated route for
/// [_i66.ViewRequestDetailsScreen]
class ViewRequestDetailsRoute
    extends _i68.PageRouteInfo<ViewRequestDetailsRouteArgs> {
  ViewRequestDetailsRoute({
    _i70.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ViewRequestDetailsRoute.name,
         args: ViewRequestDetailsRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ViewRequestDetailsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewRequestDetailsRouteArgs>();
      return _i66.ViewRequestDetailsScreen(key: args.key, id: args.id);
    },
  );
}

class ViewRequestDetailsRouteArgs {
  const ViewRequestDetailsRouteArgs({this.key, required this.id});

  final _i70.Key? key;

  final String id;

  @override
  String toString() {
    return 'ViewRequestDetailsRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i67.WorkersScreen]
class WorkersRoute extends _i68.PageRouteInfo<void> {
  const WorkersRoute({List<_i68.PageRouteInfo>? children})
    : super(WorkersRoute.name, initialChildren: children);

  static const String name = 'WorkersRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i67.WorkersScreen();
    },
  );
}
