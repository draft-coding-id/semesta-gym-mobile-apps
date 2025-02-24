import 'package:get/get.dart';
import 'package:semesta_gym/models/trainer.dart';
import 'package:semesta_gym/models/user.dart';
import 'package:semesta_gym/preferences/rememberPersonalTrainer.dart';

class CurrentTrainer extends GetxController {
  Rx<Trainer> _currentTrainer = Trainer(
    0,
    User(0, '', '', '', '', [], []),
    '',
    '',
    '',
    '',
    [],
    '',
    '',
    0,
    '',
  ).obs;

  Trainer get trainer => _currentTrainer.value;

  getTrainerInfo() async {
    Trainer? getTrainerInfoFromLocalStorage =
        await RememberPersonalTrainerPrefs.readTrainerInfo();
    if (getTrainerInfoFromLocalStorage != null) {
      _currentTrainer.value = getTrainerInfoFromLocalStorage;
    } else {
      _currentTrainer.value = Trainer(
        0,
        User(0, '', '', '', '', [], []),
        '',
        '',
        '',
        '',
        [],
        '',
        '',
        0,
        '',
      );
    }
    update();
  }
}
