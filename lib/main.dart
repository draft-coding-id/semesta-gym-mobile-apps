import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/screens/auth/loginAll.dart';
import 'package:semesta_gym/screens/auth/registAll.dart';
import 'package:semesta_gym/screens/user/detailTrainerScreen.dart';
import 'package:semesta_gym/screens/user/homeScreen.dart';
import 'package:semesta_gym/screens/user/recommendation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    /* FutureBuilder(
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
            home: MenuScreen(),
          );
        } else {
          return const GetMaterialApp(
            debugShowCheckedModeBanner: false,
            home: Splashscreen(),
          );
        }
      },
    ); */
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Semesta GYM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Layout(),
    );
    
  }
}