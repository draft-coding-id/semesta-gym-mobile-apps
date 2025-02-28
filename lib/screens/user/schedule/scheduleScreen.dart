import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/cardWithStar.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/models/payment.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/schedule/detailScheduleScreen.dart';
import 'package:semesta_gym/screens/user/schedule/historyScheduleScreen.dart';
import 'package:http/http.dart' as http;

class Schedulescreen extends StatefulWidget {
  const Schedulescreen({super.key});

  @override
  State<Schedulescreen> createState() => _SchedulescreenState();
}

class _SchedulescreenState extends State<Schedulescreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());

  bool isLoading = true;
  List<Booking> bookings = [];
  List<Payment> payments = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchBooking();
      await fetchPaymentByType();
    });
  }

  Future<void> fetchBooking() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/bookings/member/${currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          bookings = data.map((json) => Booking.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load trainers');
      }
    } catch (error) {
      print("Error fetching trainers schedule: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPaymentByType() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/payments/user/${currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Payment> allPayments =
            data.map((json) => Payment.fromJson(json)).toList();

        setState(() {
          payments = allPayments
              .where((payment) =>
                  payment.paymentableType.toLowerCase() == "booking")
              .toList();
        });

        print("Filtered payments => ${payments.length}");
        print("Filtered payments => ${response.body}");
      } else {
        throw Exception('Failed to load payment: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredBookings = bookings.where((booking) {
      var relatedPayment = payments.firstWhere(
          (payment) => payment.paymentableId == booking.id,
          orElse: () => Payment(0, 0, "", "", "", "",'', 0, User("")));

      return booking.acceptedTrainer == true &&
          booking.done != true &&
          relatedPayment.paymentStatus == 'success';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Jadwal Trainer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: filteredBookings.isEmpty
          ? Center(
              child: Text(
                "Belum ada jadwal booking trainer",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];

                        return Cardwithstar(
                          name: booking.trainer.name,
                          onTap: () {
                            Get.to(() => DetailScheduleScreen(),
                                arguments: booking);
                          },
                          showRating: false,
                          rating: '',
                          imageUrl:
                              "http://10.0.2.2:3000/${booking.trainer.picture}",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 66, vertical: 16),
        child: SizedBox(
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => HistoryScheduleScreen());
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
      ),
    );
  }
}
