import 'package:get/get.dart';
import 'package:semesta_gym/models/user.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';

class CurrentUser extends GetxController {
  Rx<User> _currentUser = User(0,'', '', '', '', '', [], []).obs;
  
  User get user => _currentUser.value;

  getUserInfo() async {
    User? getUserInfoFromLocalStorage = await RememberUserPrefs.readUserInfo();
    if (getUserInfoFromLocalStorage != null) {
      _currentUser.value = getUserInfoFromLocalStorage;
    } else {
      _currentUser.value = User(0, '', '', '', '', '', [], []);
    }
    update();
  }
}