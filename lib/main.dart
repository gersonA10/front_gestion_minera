import 'dart:async'; // <-- 1. Importante para usar Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';
import 'package:in_app_update/in_app_update.dart'; 

import 'package:front_gestion_minera/config/theme/app_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await UserSession.loadSession();
  await dotenv.load(fileName: '.env');
  InjectorContainer.setupGetIt();
  await initializeDateFormatting('es');
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  
  late final AppLifecycleListener _lifecycleListener;
  DateTime? _pausedTime;
  
  Timer? _inactivityTimer;
  final int _timeoutMinutes = 5;

  @override
  void initState() {
    super.initState();
    
    _startInactivityTimer();
    
    _lifecycleListener = AppLifecycleListener(
      onHide: () {
        // En algunos dispositivos el app pasa a 'hidden' antes que 'paused'
        _pausedTime ??= DateTime.now();
        _inactivityTimer?.cancel();
      },
      onPause: () {
        _pausedTime ??= DateTime.now();
        _inactivityTimer?.cancel();
      },
      onResume: () async {
        if (_pausedTime != null) {
          final diff = DateTime.now().difference(_pausedTime!);
          _pausedTime = null;
          final hasSession = await UserSession.isSession();
          if (!hasSession) {
            _startInactivityTimer();
            return;
          }
          if (diff.inMinutes >= _timeoutMinutes) {
            SessionActions.logout(SessionLogoutReason.inactivity);
            return;
          }
        }
        _startInactivityTimer();
      },
    );

    _checkForUpdate(); 
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(minutes: _timeoutMinutes), () async {
      final hasSession = await UserSession.isSession();
      if (hasSession) {
        SessionActions.logout(SessionLogoutReason.inactivity);
      }
    });
  }

  void _handleUserInteraction([_]) {
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _inactivityTimer?.cancel(); 
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } 
        else if (info.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate(); 
        }
      }
    } catch (e) {
      debugPrint("Error al comprobar la actualización: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = InjectorContainer.getIt<AppRouter>();
    
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction, 
      child: MaterialApp.router(
        title: 'Tigres Dorados',
        debugShowCheckedModeBanner: false,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: ThemeMode.light,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.lightTheme,
        routerConfig: appRouter.config(),
      ),
    );
  }
}