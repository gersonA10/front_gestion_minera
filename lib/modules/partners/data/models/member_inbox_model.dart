import '../../domain/entity/member_inbox_entity.dart';

class MemberInboxResponseModel extends MemberInboxResponseEntity {
  MemberInboxResponseModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory MemberInboxResponseModel.fromJson(Map<String, dynamic> json) =>
      MemberInboxResponseModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: List<MemberInboxItemModel>.from(
          (json["data"] ?? []).map((x) => MemberInboxItemModel.fromJson(x)),
        ),
      );
}

class MemberInboxItemModel extends MemberInboxItemEntity {
  MemberInboxItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.status,
    required super.date,
    required super.fileUrl,
    required super.person,
    required super.personIsResp,
    required super.location,
  });

  factory MemberInboxItemModel.fromJson(Map<String, dynamic> json) =>
      MemberInboxItemModel(
        id: json["id"]?.toString() ?? '',
        type: json["type"] ?? 'memorando',
        title: json["title"] ?? '',
        status: json["status"] ?? 'PENDIENTE',
        date: json["date"] != null ? DateTime.tryParse(json["date"]) : null,
        fileUrl: json["file_url"],
        person: json["person"],
        personIsResp: json["person_is_resp"] ?? false,
        location: json["location"],
      );
}
