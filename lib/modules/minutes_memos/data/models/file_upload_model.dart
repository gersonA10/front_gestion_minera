import '../../domain/entity/entity.dart';

class FileUploadModel extends FileUploadEntity {
  FileUploadModel({required super.documentType, required super.file});

  factory FileUploadModel.fromEntity(FileUploadEntity entity) {
    return FileUploadModel(
      documentType: entity.documentType,
      file: entity.file,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_type': documentType
    };
  }
}
