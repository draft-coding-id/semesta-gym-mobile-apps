import 'dart:convert';
import 'package:semesta_gym/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberUserPrefs {
  static Future<void> storeUserInfo(User userInfo, String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData = jsonEncode(userInfo.toJson());
    await preferences.setString("currentUser", userJsonData);
    await preferences.setString("authToken", token);
  }

  static Future<User?> readUserInfo() async {
    User? currentUserInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userInfo = preferences.getString("currentUser");

    if (userInfo != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userInfo);
      currentUserInfo = User.fromJson(userDataMap);
    }
    return currentUserInfo;
  }

  static Future<String?> readAuthToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("authToken");
  }

  static Future<void> removeUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentUser");
    await preferences.remove("authToken");
  }

  static Future<void> updateUserInfo(User updatedUserInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
        "currentUser", jsonEncode(updatedUserInfo.toJson()));
  }

  static Future<void> setRecommendationChosen(
      String userId, bool chosen) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("recommendationChosen_$userId", chosen);
  }

  static Future<bool> hasChosenRecommendation(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("recommendationChosen_$userId") ?? false;
  }

  static Future<void> setRecommendation(
      String userId, List<int> recommendations) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String encodedList = jsonEncode(recommendations);
    await preferences.setString("recommendations_$userId", encodedList);
  }

  static Future<List<int>> getRecommendations(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? encodedList = preferences.getString("recommendations_$userId");

    if (encodedList != null) {
      List<dynamic> decodedList = jsonDecode(encodedList);
      return decodedList.map((e) => e as int).toList();
    }
    return [];
  }
}
