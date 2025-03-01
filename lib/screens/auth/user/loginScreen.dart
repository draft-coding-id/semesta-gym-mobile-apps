import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/mainButton.dart';
import 'package:semesta_gym/components/myTextFormField.dart';
import 'package:semesta_gym/components/passwordTextFormField.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/user.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/auth/forgotPassword/forgotPasswordScreen.dart';
import 'package:semesta_gym/screens/auth/loginAll.dart';
import 'package:semesta_gym/screens/auth/user/registerScreen.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/screens/user/recommendation.dart';

class LoginScreenUser extends StatefulWidget {
  const LoginScreenUser({super.key});

  @override
  State<LoginScreenUser> createState() => _LoginScreenUserState();
}

class _LoginScreenUserState extends State<LoginScreenUser> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool obserText = true;
    bool isLoading = false;

    Future<void> loginUser() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${dotenv.env['AUTH_LOGIN']}'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": emailController.text,
            "password": passwordController.text,
          }),
        );

        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          User userInfo = User.fromJson(responseData["user"]);
          String token = responseData["token"];

          if (userInfo.role != 'member') {
            Get.snackbar(
              "Error",
              "Login dengan akun member/anggota",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else {
            await RememberUserPrefs.storeUserInfo(userInfo, token);
            bool hasChosen = await RememberUserPrefs.hasChosenRecommendation(
                userInfo.id.toString());

            if (!hasChosen) {
              Get.snackbar(
                "Success",
                "Login successful!",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              Future.delayed(Duration(milliseconds: 2000), () {
                Get.offAll(() => RecommendationScreen());
              });
            } else {
              Get.snackbar(
                "Success",
                "Login successful!",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              Future.delayed(Duration(milliseconds: 2000), () {
                Get.offAll(() => Layout());
              });
            }
          }
        } else {
          print(response.body);
          Get.snackbar(
            "Error",
            responseData["message"] ??
                "Email atau Password salah atau tidak terdaftar",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (error) {
        print("Error: $error");
        Get.snackbar(
          "Error",
          "Something went wrong. Try again later.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.offAll(() => LoginAllScreen());
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Center(
                    child: Text(
                  "Login Anggota",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )),
                SizedBox(
                  height: 100,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: emailController,
                      name: "Email",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ("Please Enter Your Email");
                        }
                        if (!RegExp("^[a-zA-z0-9+_.-]+@[[a-zA-z0-9.-]+.[a-z]")
                            .hasMatch(value)) {
                          return ("Please Enter a valid email");
                        }
                        return null;
                      },
                      onSaved: (value) {
                        emailController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Password",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    PasswordTextFormField(
                      controller: passwordController,
                      name: "Password",
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return ("Password is required for login");
                        }
                        if (!regex.hasMatch(value)) {
                          return ("Enter Valid Password(Min. 6 Character)");
                        }
                        return null;
                      },
                      onSaved: (value) {
                        passwordController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : MainButton(onPressed: loginUser, text: "Login"),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Belum Punya Akun? "),
                        InkWell(
                            onTap: () {
                              Get.to(() => RegisterScreenUser());
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(color: Color(0xFFF68989)),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Lupa Password? "),
                        InkWell(
                            onTap: () {
                              Get.to(() => ForgotPasswordScreen());
                            },
                            child: Text(
                              "Click di sini!",
                              style: TextStyle(color: Color(0xFFF68989)),
                            ))
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
