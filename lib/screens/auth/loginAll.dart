import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/screens/auth/user/loginScreen.dart';
import 'package:semesta_gym/screens/menu.dart';

class LoginAllScreen extends StatefulWidget {
  const LoginAllScreen({super.key});

  @override
  State<LoginAllScreen> createState() => _LoginAllScreenState();
}

class _LoginAllScreenState extends State<LoginAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.off(() => MenuScreen(), transition: Transition.cupertino, duration: Duration(milliseconds: 500));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => LoginScreenUser());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF82ACEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Anggota",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF82ACEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Personal Trainer",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
