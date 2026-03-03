import 'package:flutter/material.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';

void main() async {
  InjectorContainer.setupGetIt();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = InjectorContainer.getIt<AppRouter>();
    return MaterialApp.router(routerConfig: appRouter.config());
  }
}
/**
void main() async {
  ///This .env file contains the private URL.
  await dotenv.load(fileName: '.env');

  ///This is the main container where all containers will be declared.
  InjectorContainer.setupGetIt();

  ///hive declaration
  await SecureHive.init();

  runApp(
    BlocProvider<ThemeCubit>.value(
      value: InjectorContainer.getIt<ThemeCubit>(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = InjectorContainer.getIt<AppRouter>();
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: 'Prodem',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          darkTheme: ThemeData.light(),
          themeMode: themeMode,

          /// Aquí agregamos las localizaciones
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          /// Soporte para idiomas (español e inglés por ejemplo)
          supportedLocales: const [
            Locale('es', ''), // Español
            Locale('en', ''), // Inglés
          ],
          routerConfig: appRouter.config(),
        );
      },
    );
  }
}
 */