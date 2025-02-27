import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/components/dateTextFormField.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/trainer.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/preferences/rememberUser.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String convertToISO8601(String date) {
    try {
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateTime dateTime = inputFormat.parse(date);
      return dateTime.toIso8601String();
    } catch (e) {
      print("Error converting date: $e");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final CurrentUser _currentUser = Get.put(CurrentUser());
    final Trainer? trainer = Get.arguments;
    final _formKey = GlobalKey<FormState>();
    final TextEditingController week1DateController = TextEditingController();
    final TextEditingController week2DateController = TextEditingController();
    final TextEditingController week3DateController = TextEditingController();
    final TextEditingController week4DateController = TextEditingController();
    bool isLoading = false;

    Future<void> booking() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      String? token = await RememberUserPrefs.readAuthToken();
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/api/bookings'),
          headers: {
            'Authorization': 'Bearer $token',
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "memberId": _currentUser.user.id,
            "trainerId": trainer?.user.id,
            "week1Date": convertToISO8601(week1DateController.text),
            "week2Date": convertToISO8601(week2DateController.text),
            "week3Date": convertToISO8601(week3DateController.text),
            "week4Date": convertToISO8601(week4DateController.text),
            "endDate": DateTime.now()
              .toUtc()
              .add(Duration(days: 30))
              .toIso8601String()
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            confirmBtnText: "Balik Ke Halaman",
            onConfirmBtnTap: () => Get.offAll(() => Layout(index: 0,)),
            title: "Booking sedang di ajukan",
            text: "Harap untuk tidak melakukan Payment Sebelum di Approve",
            textColor: Colors.red,
            confirmBtnColor: Color(0xFFF68989),
          );
        } else {
          print("Error Response: ${response.body}");
          Get.snackbar(
              "Error", responseData["message"] ?? "Registration failed",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } catch (error) {
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

    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 260,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "http://10.0.2.2:3000/${trainer?.picture}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )),
                backgroundColor:
                    innerBoxIsScrolled ? Colors.white : Colors.transparent,
                elevation: innerBoxIsScrolled ? 4 : 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: innerBoxIsScrolled
                          ? Colors.transparent
                          : Color.fromARGB(50, 0, 0, 0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: innerBoxIsScrolled ? Colors.black : Colors.white,
                      ),
                      onPressed: () {
                        Get.to(() => Layout(index: 0,));
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 1))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Pastikan isi tanggal sesuai jadwal !!',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 1))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Minggu 1",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                DateTextFormField(
                                  controller: week1DateController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Masukkan tanggal di minggu 1";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    week1DateController.text = value!;
                                  },
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Minggu 2",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                DateTextFormField(
                                  controller: week2DateController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Masukkan tanggal di minggu 2";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    week2DateController.text = value!;
                                  },
                                ),
                                Text(
                                  "Minggu 3",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                DateTextFormField(
                                  controller: week3DateController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Masukkan tanggal di minggu 3";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    week3DateController.text = value!;
                                  },
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Minggu 4",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                DateTextFormField(
                                  controller: week4DateController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Masukkan tanggal di minggu 4";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    week4DateController.text = value!;
                                  },
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Session and price
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "1 Bulan",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "4 Session",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                width: 301,
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
                                      vertical: 5, horizontal: 5),
                                  child: Center(
                                    child: Text(
                                      "Rp. ${NumberFormat('#,###').format(trainer?.price ?? 0)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ])),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 32),
        child: Container(
          color: Colors.white,
          child: isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: booking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF68989),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Booking",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
        ),
      ),
    );
  }
}
