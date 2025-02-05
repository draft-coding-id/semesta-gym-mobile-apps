import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/mainButton.dart';
import 'package:semesta_gym/components/myTextFormField.dart';
import 'package:semesta_gym/components/passwordTextFormField.dart';
import 'package:semesta_gym/screens/auth/loginAll.dart';
import 'package:semesta_gym/screens/auth/user/registerScreen.dart';

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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    MainButton(onPressed: () {
                      if(_formKey.currentState!.validate()) {
                        
                      }
                    }, text: "Login"),
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
                    SizedBox(height: 12,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Lupa Password? "),
                        InkWell(
                            onTap: () {},
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
