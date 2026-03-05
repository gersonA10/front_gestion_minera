import 'package:auto_route/auto_route.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AuthRoute.page, initial: true),
    AutoRoute(page: PartnersRoute.page),
    AutoRoute(page: TreasuryRoute.page),
    AutoRoute(page: ContributeHistoryRoute.page),
  ];
}
