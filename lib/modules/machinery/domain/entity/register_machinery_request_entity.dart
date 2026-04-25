class RegisterMachineryRequestEntity {
  final String name;
  final String uniqueCode;
  final String typeId;
  final String description;
  final String photoPath;

  RegisterMachineryRequestEntity({
    required this.name,
    required this.uniqueCode,
    required this.typeId,
    required this.description,
    required this.photoPath,
  });
}
