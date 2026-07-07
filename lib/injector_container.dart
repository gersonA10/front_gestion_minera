import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/guards/auth_guard.dart';
import 'package:front_gestion_minera/modules/auth/auth_container.dart';
import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/admin/admin_container.dart';
import 'package:front_gestion_minera/modules/camp/camp_container.dart';
import 'package:front_gestion_minera/modules/machinery/machinery_container.dart';
import 'package:front_gestion_minera/modules/minutes_memos/minutes_memos_container.dart';
import 'package:front_gestion_minera/modules/member_loans/member_loans_container.dart';
import 'package:front_gestion_minera/modules/partners/partners_container.dart';
import 'package:front_gestion_minera/modules/staff/staff_container.dart';
import 'package:front_gestion_minera/modules/surveillance/surveillance_container.dart';
import 'package:front_gestion_minera/modules/treasury/treasury_container.dart';
import 'package:get_it/get_it.dart';

class InjectorContainer {
  InjectorContainer();

  static final getIt = GetIt.instance;

  static void setupGetIt() {
    getIt.registerLazySingleton<AuthGuard>(() => AuthGuard());
    getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<AuthGuard>()));

    // Registrar el ApiClient para que los datasources puedan usarlo
    getIt.registerLazySingleton<ApiClient>(() => ApiClient());

    initAuthContainer(getIt);
    initCampContainer(getIt);
    initPartnersContainer(getIt);
    initMemberLoansContainer(getIt);
    initSurveillanceContainer(getIt);
    initTreasuryContainer(getIt);
    initAdminContainer(getIt);
    initMachineryContainer(getIt);
    initMinutesMemosContainer(getIt);
    initStaffContainer(getIt);
  }
}
