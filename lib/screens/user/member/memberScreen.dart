import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/membershipByUserId.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/member/historyMembershipScreen.dart';
import 'package:semesta_gym/screens/user/member/listMembershipScreen.dart';
import 'package:http/http.dart' as http;

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());
  List<MembershipByUserId> membership = [];

  bool? isLoading;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchMembershipByUserId();
      if (Get.arguments != null &&
          Get.arguments is Map &&
          Get.arguments["triggerPaymentMembership"] == true) {
        await postDataPaymentMembership();
        Get.off(() => Layout(index: 2));
      }
    });
  }

  Future<void> fetchMembershipByUserId() async {
    String? token = await RememberUserPrefs.readAuthToken();

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/memberships/user/${currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          membership = data.isNotEmpty
              ? data.map((json) => MembershipByUserId.fromJson(json)).toList()
              : [];
          isLoading = false;
        });

        print("membership ${response.body}");

        if (membership.isNotEmpty) {
          print(
              "endDate last array list membership: ${membership.last.endDate}");
        } else {
          print("No membership available for this user.");
        }
      } else {
        print("Error: ${response.body}");
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        membership = [];
      });
      Get.snackbar("Error", "Failed to load Course User");
    }
  }

  Future<void> postDataPaymentMembership() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/payments/membership'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "userMembershipId": membership.last.id,
          "amount": membership.last.membership.price,
          "paidAt": DateTime.now().toUtc().toIso8601String(),
          "userId": currentUser.user.id,
          "paymentStatus": "success"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnText: "Kembali ke halaman",
          onConfirmBtnTap: () => Get.back(),
          title: "Success",
          text: "Payment Success",
          textColor: Colors.red,
          confirmBtnColor: Color(0xFFF68989),
        );
      } else {
        print("Error Response: ${response.body}");
        Get.snackbar("Error", "Failed to process payment",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (error) {
      print("payment error : $error");
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
      backgroundColor: Color(0xFF82ACEF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Member ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 240,
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Center(
                      child: Text(
                        (membership.isNotEmpty &&
                                DateTime.parse(membership.last.endDate)
                                    .isAfter(DateTime.now()))
                            ? "Member"
                            : "User",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Expired",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Container(
                  width: 240,
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Center(
                      child: Text(
                        (membership.isNotEmpty &&
                                DateTime.parse(membership.last.endDate)
                                    .isAfter(DateTime.now()))
                            ? DateFormat('dd-MM-yyyy')
                                .format(DateTime.parse(membership.last.endDate))
                            : "-",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            SizedBox(
              width: 240,
              child: ElevatedButton(
                onPressed: membership.isNotEmpty &&
                        DateTime.parse(membership.last.endDate)
                            .isAfter(DateTime.now())
                    ? null
                    : () {
                        Get.to(() => ListMembershipScreen());
                      },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey;
                      }
                      return Color(0xFF25D366);
                    },
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: Text(
                  (membership.isNotEmpty &&
                          DateTime.parse(membership.last.endDate)
                              .isAfter(DateTime.now()))
                      ? "Sudah Menjadi Member"
                      : "Mulai Member",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => HistoryMembershipScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "History",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
