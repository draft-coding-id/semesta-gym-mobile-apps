import 'dart:convert';
import 'package:semesta_gym/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberUserPrefs {

  static Future<void> storeUserInfo(User userInfo, String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData = jsonEncode(userInfo.toJson());
    await preferences.setString("currentUser", userJsonData);
    await preferences.setString("authToken", token); // Save the token
  }

  static Future<User?> readUserInfo() async {
    User? currentUserInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userInfo = preferences.getString("currentUser");

    if(userInfo != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userInfo);
      currentUserInfo = User.fromJson(userDataMap);
    } 
    return currentUserInfo;
  }

  static Future<String?> readAuthToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("authToken");
  }

  static Future<void> removeUserInfo() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentUser");
    await preferences.remove("authToken");
  }

  static Future<void> updateUserInfo(User updatedUserInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("currentUser", jsonEncode(updatedUserInfo.toJson()));
  }

  static Future<void> setRecommendationChosen(String userId, bool chosen) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("recommendationChosen_$userId", chosen);
  }

  static Future<bool> hasChosenRecommendation(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("recommendationChosen_$userId") ?? false;
  }
}


/* class RememberUserPrefs {

  static Future<void> storeUserInfo(User userInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData = jsonEncode(userInfo.toJson());
    await preferences.setString("currentUser", userJsonData);
  }

  static Future<User?> readUserInfo() async {
    User? currentUserInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userInfo = preferences.getString("currentUser");

    if(userInfo != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userInfo);
      currentUserInfo = User.fromJson(userDataMap);
    } 
    return currentUserInfo;
  }
  
  static Future<void> removeUserInfo() async{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove("currentUser");
    }

  static Future<void> updateUserInfo(User updatedUserInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("currentUser", jsonEncode(updatedUserInfo.toJson()));
  }

  // Simpan status apakah user sudah memilih rekomendasi berdasarkan userId
  static Future<void> setRecommendationChosen(String userId, bool chosen) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("recommendationChosen_$userId", chosen);
  }

  // Periksa apakah user sudah memilih rekomendasi berdasarkan userId
  static Future<bool> hasChosenRecommendation(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("recommendationChosen_$userId") ?? false;
  }
}
 */