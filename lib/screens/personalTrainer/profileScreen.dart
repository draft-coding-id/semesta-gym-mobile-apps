import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/models/trainer.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/menu.dart';
import 'package:semesta_gym/screens/personalTrainer/editProfileScreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProfileScreenPt extends StatefulWidget {
  const ProfileScreenPt({super.key});

  @override
  State<ProfileScreenPt> createState() => _ProfileScreenPtState();
}

class _ProfileScreenPtState extends State<ProfileScreenPt> {
  final CurrentUser _currentUser = Get.put(CurrentUser());

  Trainer? trainer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchTrainers();
    });
  }

  Future<void> fetchTrainers() async {
    String? token = await RememberUserPrefs.readAuthToken();

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_TRAINER']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        Trainer? foundTrainer;
        for (var jsonItem in data) {
          Trainer train = Trainer.fromJson(jsonItem);
          if (train.user.id == _currentUser.user.id) {
            foundTrainer = train;
            break;
          }
        }

        setState(() {
          trainer = foundTrainer;
          isLoading = false;
        });

        if (foundTrainer == null) {
          print("Trainer not found");
        }
      } else {
        throw Exception('Failed to load trainer');
      }
    } catch (error) {
      print("Error fetching trainer: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  signOutTrainer() async {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: CurrentUser(),
        initState: (currentState) {
          _currentUser.getUserInfo();
        },
        builder: (controller) {
          return Scaffold(
            backgroundColor: const Color(0xFF82ACEF),
            appBar: AppBar(
              title: const Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.grey.shade300,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
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
                      child: Row(
                        spacing: 24,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: trainer?.picture != null &&
                                    trainer!.picture.isNotEmpty
                                ? Image.network(
                                    "${dotenv.env['BASE_URL_API']}${trainer!.picture}",
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser.user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(height: 0),
                              Text("No. Hp: ${_currentUser.user.phone}"),
                              Text("Email: ${_currentUser.user.email}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
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
                      onPressed: signOutTrainer,
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
          );
        });
  }
}
