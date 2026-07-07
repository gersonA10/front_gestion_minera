import 'package:flutter/widgets.dart';

/// Observer global de rutas. Permite que una pantalla refresque sus datos
/// cuando vuelve a primer plano (al cerrarse la ruta que estaba encima),
/// implementando [RouteAware] y reaccionando en `didPopNext`.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
