import 'package:auto_route/auto_route.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/router/guards/auth_guard.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter(this.authGuard);

  final AuthGuard authGuard;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AuthRoute.page, initial: true, guards: [authGuard]),
    AutoRoute(page: PartnersRoute.page),
    AutoRoute(page: ContributeHistoryRoute.page),
    AutoRoute(page: LoanHistoryRoute.page),
    AutoRoute(page: DistributesRoute.page),
    AutoRoute(page: MoneyRequestRoute.page),
    AutoRoute(page: RequestHistoryRoute.page),
    AutoRoute(page: LoanRoute.page),
    AutoRoute(page: HomeSurveillanceRoute.page),
    AutoRoute(page: HistoryRequestsRoute.page),
    AutoRoute(page: ApplicationDetailsRoute.page),
    AutoRoute(page: TreasuryRoute.page),
    AutoRoute(page: HomeDashboardRoute.page),
    AutoRoute(page: GoldDashboardRoute.page),
    AutoRoute(page: LoansHomeRoute.page),
    AutoRoute(page: DistributeHomeRoute.page),
    AutoRoute(page: ContributesHomeRoute.page),
    AutoRoute(page: ViewRequestDetailsRoute.page),
    AutoRoute(page: PendingApplicationsRoute.page),
    AutoRoute(page: FinancialReportsRoute.page),
    AutoRoute(page: UrgentTransactionRoute.page),
    AutoRoute(page: PaymentHistoryRoute.page),
    AutoRoute(page: TransactionDetailsRoute.page),
    AutoRoute(page: NewExtractionRoute.page),
    AutoRoute(page: RegisterSellRoute.page),
    AutoRoute(page: SellPreviewRoute.page),
    AutoRoute(page: SellSummaryRoute.page),
  ];
}
