import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/menu.dart';
import 'package:semesta_gym/screens/user/profile/editProfileScreen.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    final CurrentUser _currentUser = Get.put(CurrentUser());
    signOutUser() async {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        confirmBtnText: "Ya",
        cancelBtnText: "Tidak",
        showCancelBtn: true,
        showConfirmBtn: true,
        onCancelBtnTap: () => Get.back(),
        onConfirmBtnTap: () {
          RememberUserPrefs.removeUserInfo().then((value) {
            Get.off(() => MenuScreen());
          });
        },
        confirmBtnColor: Color(0xFFF68989),
        title: "Logout",
        text: "Ingin Logout dari apps?",
      );
    }

    return GetBuilder(
        init: CurrentUser(),
        initState: (currentState) {
          _currentUser.getUserInfo();
        },
        builder: (controller) {
          return Scaffold(
            backgroundColor: const Color(0xFF82ACEF),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.grey.shade300,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(4, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser.user.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text("No. Hp : ${_currentUser.user.phone}")
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => EditProfileScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          signOutUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
