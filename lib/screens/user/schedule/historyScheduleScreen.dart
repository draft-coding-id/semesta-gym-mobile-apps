import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/cardWithStar.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/screens/user/schedule/detailScheduleScreen.dart';

class HistoryScheduleScreen extends StatefulWidget {
  const HistoryScheduleScreen({super.key});

  @override
  State<HistoryScheduleScreen> createState() => _HistoryScheduleScreenState();
}

class _HistoryScheduleScreenState extends State<HistoryScheduleScreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());

  bool isLoading = true;
  List<Booking> bookings = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchBooking();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        title: Text(
          "History Trainer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: bookings
              .where((booking) =>
                  booking.acceptedTrainer == true && booking.done != false)
              .isEmpty
          ? Center(
              child: Text(
                "Belum ada history jadwal booking trainer",
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
                      itemCount: bookings
                          .where((booking) =>
                              booking.acceptedTrainer == true &&
                              booking.done != false)
                          .length,
                      itemBuilder: (context, index) {
                        final booking = bookings
                            .where((booking) =>
                                booking.acceptedTrainer == true &&
                                booking.done != false)
                            .toList()[index];

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
    );
  }
}
