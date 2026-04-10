class SimulateDistributionResponseEntity {
    final bool success;
    final SimulateDistributionDataEntity data;

    SimulateDistributionResponseEntity({
        required this.success,
        required this.data,
    });
}

class SimulateDistributionDataEntity {
    final int numberOfActiveMembers;
    final double amountPerMember;

    SimulateDistributionDataEntity({
        required this.numberOfActiveMembers,
        required this.amountPerMember,
    });
}
