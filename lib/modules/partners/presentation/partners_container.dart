import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:get_it/get_it.dart';


void initPartnersContainer(GetIt getIt) {
  // Repository
  
  // Bloc
  getIt.registerFactory(() => PartnersBloc());
}