import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wasteexpert/models/Reward/RewardModel.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;

class GarbageWeightController {
  final String apiUrl = UrlConfig.getRewardsUrl;

  Future<List<Reward>> fetchGarbageWeights(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final rewardsList = data['rewards'] as List;
          return rewardsList
              .map((rewardJson) {
                try {
                  return Reward.fromJson(rewardJson);
                } catch (e) {
                  print('Error parsing reward: $e');
                  print('Problematic JSON: $rewardJson');
                  return null;
                }
              })
              .whereType<Reward>()
              .toList();
        } else {
          throw Exception('Failed to load rewards: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load rewards: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchGarbageWeights: $e');
      rethrow;
    }
  }
}
