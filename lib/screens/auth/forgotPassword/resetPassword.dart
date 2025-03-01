import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/components/mainButton.dart';
import 'package:semesta_gym/components/passwordTextFormField.dart';
import 'package:semesta_gym/screens/auth/personalTrainer/loginScreen.dart';
import 'package:semesta_gym/screens/auth/user/loginScreen.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  final String token;

  const ResetPassword({super.key, required this.email, required this.token});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    print("Token: ${widget.token}");
    print("Email: ${widget.email}");

    try {
      final userResponse = await http.get(
        Uri.parse('${dotenv.env['API_USER']}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (userResponse.statusCode == 200) {
        List<dynamic> users = jsonDecode(userResponse.body);

        var user = users.firstWhere(
          (user) {
            print("Checking user: ${user["email"]} against ${widget.email}");
            return user["email"] == widget.email;
          },
          orElse: () {
            print("No user found with email: ${widget.email}");
            return null;
          },
        );

        if (user == null) {
          Get.snackbar(
            "Error",
            "User with this email does not exist.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        int userId = user["id"];
        String userRole = user["role"];
        print("User Found: ID = $userId, Role = $userRole");

        final updateResponse = await http.put(
          Uri.parse('${dotenv.env['API_USER']}$userId/update'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${widget.token}",
          },
          body: jsonEncode({
            "email": widget.email,
            "password": passwordController.text,
          }),
        );

        final responseData = jsonDecode(updateResponse.body);
        print("Update Password Response: $responseData");

        if (updateResponse.statusCode == 200) {
          Get.snackbar(
            "Success",
            "Password successfully updated!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          if (userRole == "member") {
            Get.offAll(() => LoginScreenUser());
          } else if (userRole == "trainer") {
            Get.offAll(() => LoginScreenTrainer());
          } else {
            Get.snackbar(
              "Error",
              "Invalid role. Contact support.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            "Error",
            responseData["message"] ?? "Failed to reset password",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch user data.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      print("Error occurred: $error");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    return ("Password is required for Register");
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
                height: 12,
              ),

              Text(
                "Confirm Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(
                height: 5,
              ),
              PasswordTextFormField(
                controller: confirmPasswordController,
                name: "Confirm Password",
                validator: (value) {
                  RegExp regex = RegExp(r'^.{6,}$');
                  if (value!.isEmpty) {
                    return ("Password is required for Register");
                  }
                  if (!regex.hasMatch(value)) {
                    return ("Enter Valid Password(Min. 6 Character)");
                  }
                  if (value != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
                onSaved: (value) {
                  confirmPasswordController.text = value!;
                },
              ),

              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MainButton(
                      onPressed: _resetPassword, text: "Reset Password"),
            ],
          ),
        ),
      ),
    );
  }
}
