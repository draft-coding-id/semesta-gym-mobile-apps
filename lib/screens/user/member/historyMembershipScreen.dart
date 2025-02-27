import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/models/payment.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:http/http.dart' as http;

class HistoryMembershipScreen extends StatefulWidget {
  const HistoryMembershipScreen({super.key});

  @override
  State<HistoryMembershipScreen> createState() =>
      _HistoryMembershipScreenState();
}

class _HistoryMembershipScreenState extends State<HistoryMembershipScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  bool isLoading = true;
  List<Payment> payments = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchPaymentByUserId();
    });
  }

  Future<void> fetchPaymentByUserId() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/payments/user/${_currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          payments = data.map((json) => Payment.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load payments: ${response.statusCode}');
      }
    } catch (error) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF82ACEF),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "History Pembayaran",
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
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                      child: Text(
                        "19-JAN-25",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                        child: Center(
                            child: Text(
                          "Membeli Paket Membership",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                      child: Text(
                        "Rp. 100.000",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
