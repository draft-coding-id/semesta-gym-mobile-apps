import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:semesta_gym/layout.dart';
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
            '${dotenv.env['API_PAYMENT_BY_USER_ID']}${_currentUser.user.id}'),
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
              Get.offAll(() => Layout(index: 2,));
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : payments.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada riwayat pembayaran",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 8),
                              child: Center(
                                child: Text(
                                  DateFormat("dd-MM-yyyy").format(
                                      DateTime.tryParse(payment.paidAt) ??
                                          DateTime(2000, 1, 1)),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 8),
                                child: Center(
                                    child: Text(
                                  payment.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width*0.3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 8),
                              child: Center(
                                child: Text(
                                  "Rp. ${NumberFormat("#,##0", "id_ID").format(double.tryParse(payment.amount) ?? 0)}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ));
  }
}
