import 'package:flutter/foundation.dart';

/// Cambio de estado de una máquina (valor canónico: ACTIVO / INACTIVO /
/// EN MANTENIMIENTO).
class MachineryStatusChange {
  final String machineId;
  final String status;

  const MachineryStatusChange({required this.machineId, required this.status});
}

/// Señal global para reflejar de inmediato (optimista) un cambio de estado
/// en las pantallas que muestran el inventario, sin esperar a la recarga de
/// red. La recarga posterior solo confirma el dato.
final ValueNotifier<MachineryStatusChange?> machineryStatusChangedSignal =
    ValueNotifier<MachineryStatusChange?>(null);
