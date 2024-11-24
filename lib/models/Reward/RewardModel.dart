class Reward {
  final String? id;
  final List<WasteItem> wasteList;
  final int rewardPoints;
  final String? scheduleId;
  final int withdrawnRewards;

  Reward({
    this.id,
    required this.wasteList,
    required this.rewardPoints,
    this.scheduleId,
    required this.withdrawnRewards,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['_id'],
      wasteList: (json['wasteList'] as List?)
              ?.map((item) => WasteItem.fromJson(item))
              .toList() ??
          [],
      rewardPoints: json['rewardPoints'] ?? 0,
      scheduleId: json['scheduleId'],
      withdrawnRewards: json['withdrawnRewards'] ?? 0,
    );
  }
}

class WasteItem {
  final int quantity;
  final String wastetype;

  WasteItem({required this.quantity, required this.wastetype});

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      quantity: json['quantity'] ?? 0,
      wastetype: json['wastetype'] ?? 'Unknown',
    );
  }
}
