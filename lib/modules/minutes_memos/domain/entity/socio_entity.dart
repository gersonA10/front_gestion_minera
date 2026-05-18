class SocioEntity {
  final String memberId;
  final String userId;
  final String fullName;
  final String email;
  final String identification;
  final String phone;

  const SocioEntity({
    required this.memberId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.identification,
    required this.phone,
  });
}

class SociosListEntity {
  final List<SocioEntity> items;
  final int currentPage;
  final int limit;
  final int totalRecords;
  final bool hasMoreData;

  const SociosListEntity({
    required this.items,
    required this.currentPage,
    required this.limit,
    required this.totalRecords,
    required this.hasMoreData,
  });
}
