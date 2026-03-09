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
    AutoRoute(page: TreasuryRoute.page),
    AutoRoute(page: ContributeHistoryRoute.page),
    AutoRoute(page: LoanHistoryRoute.page),
    AutoRoute(page: DistributesRoute.page),
    AutoRoute(page: MoneyRequestRoute.page),
    AutoRoute(page: RequestHistoryRoute.page),
    AutoRoute(page: LoanRoute.page),
    AutoRoute(page: HomeSurveillanceRoute.page),
    AutoRoute(page: HistoryRequestsRoute.page),
  ];
}
