class UpdateMachineryRequestEntity {
  final String machineId;
  final String name;
  final String typeId;
  final String description;

  /// Ruta local de la nueva foto. Si es null, el backend conserva la actual.
  final String? photoPath;

  UpdateMachineryRequestEntity({
    required this.machineId,
    required this.name,
    required this.typeId,
    required this.description,
    this.photoPath,
  });
}
