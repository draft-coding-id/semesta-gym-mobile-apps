import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/components/mainButton.dart';
import 'package:semesta_gym/components/myTextFormField.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/user.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool isLoading = false;

  Future updateUser(User user) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? token = await RememberUserPrefs.readAuthToken();

      final response = await http.put(
        Uri.parse(
            '${dotenv.env['API_USER']}${_currentUser.user.id}/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": user.name,
          "email": user.email,
          "role": _currentUser.user.role,
          "phone": user.phone,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        RememberUserPrefs.updateUserInfo(_currentUser.user).then((value) async {
          _currentUser.user.name = user.name;
          _currentUser.user.email = user.email;
          _currentUser.user.role = _currentUser.user.role;
          _currentUser.user.phone = user.phone;

          await RememberUserPrefs.updateUserInfo(_currentUser.user);

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            confirmBtnText: "Ok",
            showConfirmBtn: true,
            onConfirmBtnTap: () {
                Get.offAll(() => Layout());
            },
            confirmBtnColor: Color(0xFFF68989),
            title: "Success",
            text: "Data berhasil di update.",
          );
        });
      } else {
        print("Response body: ${response.body}");
        Get.snackbar("Error", responseData["message"] ?? "Update dat failed",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (error) {
      print(error);
      Get.snackbar("Error", "Something went wrong. Try again later.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // email
                Text(
                  "Update Email",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 5,
                ),
                MyTextFormField(
                  value: _currentUser.user.email,
                  name: _currentUser.user.email,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Belum ada update pada email");
                    }
                    if (!RegExp("^[a-zA-z0-9+_.-]+@[[a-zA-z0-9.-]+.[a-z]")
                        .hasMatch(value)) {
                      return ("Please Enter a valid email");
                    }
                    return null;
                  },
                  onChange: (value) {
                    _currentUser.user.email = value;
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                // Email-end

                // Username
                Text(
                  "Update Nama",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 5,
                ),
                MyTextFormField(
                  value: _currentUser.user.name,
                  name: _currentUser.user.name,
                  onChange: (value) {
                    _currentUser.user.name = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Belum ada update pada nama";
                    }
                    if (value.length < 3) {
                      return "Name must be at least 3 characters long ";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                // Username end

                // No HP
                Text(
                  "Update No. Handphone",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 5,
                ),
                MyTextFormField(
                  value: _currentUser.user.phone,
                  name: _currentUser.user.phone,
                  onChange: (value) {
                    _currentUser.user.phone = value;
                  },
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Belum ada update pada no. handphone");
                    }
                    if (value.length < 12) {
                      return "Phone Number must be at least 12 characters long ";
                    }
                    return null;
                  },
                ),

                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isLoading
          ? CircularProgressIndicator()
          : Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                child: SizedBox(
                  height: 45,
                  child: MainButton(
                    onPressed: () {
                      updateUser(_currentUser.user);
                    },
                    text: "Confirm Perubahan",
                  ),
                ),
              ),
            ),
    );
  }
}
