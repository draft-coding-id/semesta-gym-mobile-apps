import 'dart:convert';
import 'package:semesta_gym/models/trainer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberPersonalTrainerPrefs {

  static Future<void> storeTrainerInfo(Trainer trainerInfo, String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String trainerJsonData = jsonEncode(trainerInfo.toJson());
    await preferences.setString("currentTrainer", trainerJsonData);
    await preferences.setString("authToken", token);
  }

  static Future<Trainer?> readTrainerInfo() async {
    Trainer? currentTrainerInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? trainerInfo = preferences.getString("currentTrainer");

    if (trainerInfo != null) {
      Map<String, dynamic> trainerDataMap = jsonDecode(trainerInfo);
      currentTrainerInfo = Trainer.fromJson(trainerDataMap);
    }
    return currentTrainerInfo;
  }

  static Future<String?> readAuthToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("authToken");
  }

  static Future<void> removeTrainerInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentTrainer");
    await preferences.remove("authToken");
  }

  static Future<void> updateTrainerInfo(Trainer updateTrainerInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
        "currentTrainer", jsonEncode(updateTrainerInfo.toJson()));
  }

  /* static Future<void> setRecommendationChosen(
      String userId, bool chosen) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("recommendationChosen_$userId", chosen);
  }

  static Future<bool> hasChosenRecommendation(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("recommendationChosen_$userId") ?? false;
  } */
}
