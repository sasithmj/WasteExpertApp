class WasteItem {
  final String wastetype;
  final double quantity;

  WasteItem({required this.wastetype, required this.quantity});

  // Convert a WasteItem into a Map. The keys must correspond to the names of the
  // fields in the JSON data.
  Map<String, dynamic> toJson() => {
        'wastetype': wastetype,
        'quantity': quantity,
      };
}

class ScheduleData {
  final String userId;
  final List<WasteItem> wasteTypes;
  final DateTime scheduledDate;
  final String location;

  ScheduleData({
    required this.userId,
    required this.wasteTypes,
    required this.scheduledDate,
    required this.location,
  });

  // Convert a ScheduleData into a Map. The keys must correspond to the names of the
  // fields in the JSON data.
  Map<String, dynamic> toJson() => {
        'UserId': userId,
        'WasteType': wasteTypes.map((e) => e.toJson()).toList(),
        'ScheduledDate': scheduledDate.toIso8601String(),
        'Location': location,
      };
}
