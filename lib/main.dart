import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/user.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/menu.dart';
import 'package:semesta_gym/screens/personalTrainer/layoutPt.dart';
import 'package:semesta_gym/screens/splashScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 3)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Semesta GYM',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: FutureBuilder(
              future: RememberUserPrefs.readUserInfo(),
              builder: (context, dataSnapShot) {
                if (dataSnapShot.data == null) {
                  return MenuScreen();
                } else {
                  User userInfo = dataSnapShot.data as User;
                  if (userInfo.role == 'trainer') {
                    return LayoutPt();
                  } else {
                    return Layout();
                  }
                }
              },
            ),
          );
        } else {
          return const GetMaterialApp(
            debugShowCheckedModeBanner: false,
            home: Splashscreen(),
          );
        }
      },
    );
  }
}
