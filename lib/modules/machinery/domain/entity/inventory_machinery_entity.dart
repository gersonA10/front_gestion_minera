class MachineryEntity {
    final String machineId;
    final String uniqueCode;
    final String name;
    final String type;
    final String status;
    final String description;
    final String? photoUrl;
    final String lastMaintenance;
    final DateTime registeredAt;

    MachineryEntity({
        required this.machineId,
        required this.uniqueCode,
        required this.name,
        required this.type,
        required this.status,
        required this.description,
        required this.photoUrl,
        required this.lastMaintenance,
        required this.registeredAt,
    });

}

class InventoryMachineryEntity {
    final int currentPage;
    final int limit;
    final int totalRecords;
    final bool hasMore;
    final List<MachineryEntity> machine;
    InventoryMachineryEntity({
        required this.currentPage,
        required this.limit,
        required this.totalRecords,
        required this.hasMore, 
        required this.machine,
    });
}
