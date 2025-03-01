import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/screens/auth/loginAll.dart';
import 'package:semesta_gym/screens/auth/registAll.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/menu.jpg",
              fit: BoxFit.cover,
            ),
          ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // Button Section
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, bottom: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => RegistAllScreen(),
                          transition: Transition.cupertino,
                          duration: Duration(milliseconds: 500));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFFF00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Space between buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => LoginAllScreen(),
                          transition: Transition.cupertino,
                          duration: Duration(milliseconds: 500));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF82ACEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
