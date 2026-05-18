import '../../domain/entity/socio_entity.dart';

class SocioModel extends SocioEntity {
  const SocioModel({
    required super.memberId,
    required super.userId,
    required super.fullName,
    required super.email,
    required super.identification,
    required super.phone,
  });

  factory SocioModel.fromJson(Map<String, dynamic> json) {
    return SocioModel(
      memberId: json['member_id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      identification: json['identification'] as String,
      phone: json['phone'] as String,
    );
  }
}

class SociosListModel extends SociosListEntity {
  const SociosListModel({
    required super.items,
    required super.currentPage,
    required super.limit,
    required super.totalRecords,
    required super.hasMoreData,
  });

  factory SociosListModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;
    return SociosListModel(
      items: data
          .map((e) => SocioModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int,
      limit: meta['limit'] as int,
      totalRecords: meta['total_records'] as int,
      hasMoreData: meta['has_more_data'] as bool,
    );
  }
}
