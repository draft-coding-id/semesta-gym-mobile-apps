import 'package:flutter/material.dart';
import 'package:semesta_gym/screens/auth/loginAll.dart';
import 'package:semesta_gym/screens/auth/registAll.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Semesta GYM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginAllScreen(),
    );
  }
}