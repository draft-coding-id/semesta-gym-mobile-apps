import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/mainButton.dart';
import 'package:semesta_gym/components/myTextFormField.dart';
import 'package:semesta_gym/components/passwordTextFormField.dart';
import 'package:semesta_gym/screens/auth/user/loginScreen.dart';

class RegisterScreenUser extends StatefulWidget {
  const RegisterScreenUser({super.key});

  @override
  State<RegisterScreenUser> createState() => _RegisterScreenUserState();
}

class _RegisterScreenUserState extends State<RegisterScreenUser> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

    bool obserText = true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
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
                  "Register Anggota",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )),
                SizedBox(
                  height: 40,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // email
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
                    // Email-end

                    // Username
                    Text(
                      "Nama/Username",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: nameController,
                      name: "Nama/Username",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name/username";
                        }
                        if (value.length < 3) {
                          return "Name must be at least 3 characters long ";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        nameController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    // Username end

                    // No HP
                    Text(
                      "No. Handphone",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: phoneNumberController,
                      name: "No. Handphone",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ("Please Enter Your Phone Number");
                        }
                        if (value.length < 12) {
                          return "Phone Number must be at least 12 characters long ";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        phoneNumberController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    // No HP end

                    // Password
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
                    // Password end

                    // Confirm Password
                    Text(
                      "Confirm Password",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    SizedBox(
                      height: 32,
                    ),
                    // Confirm Password end

                    MainButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {}
                        },
                        text: "Register"),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sudah Punya Akun? "),
                        InkWell(
                            onTap: () {
                              Get.offAll(() => LoginScreenUser());
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(color: Color(0xFFF68989)),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
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
