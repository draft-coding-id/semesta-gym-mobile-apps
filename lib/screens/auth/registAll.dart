import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/screens/auth/personalTrainer/registerScreen.dart';
import 'package:semesta_gym/screens/auth/user/registerScreen.dart';
import 'package:semesta_gym/screens/menu.dart';

class RegistAllScreen extends StatefulWidget {
  const RegistAllScreen({super.key});

  @override
  State<RegistAllScreen> createState() => _RegistAllScreenState();
}

class _RegistAllScreenState extends State<RegistAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/register.jpg",
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
                    Colors.white.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Get.off(() => MenuScreen(),
                            transition: Transition.cupertino,
                            duration: Duration(milliseconds: 500));
                      },
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => RegisterScreenUser());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFF700),
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
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => RegisterScreenTrainer());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFF700),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
