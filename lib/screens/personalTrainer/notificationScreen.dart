import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/personalTrainer/bookingDetailScreen.dart';
import 'package:semesta_gym/screens/personalTrainer/layoutPt.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());

  bool isLoading = true;
  List<Booking> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBooking();
  }

  Future<void> fetchBooking() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/bookings/trainer/${_currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        List<dynamic> data = json.decode(response.body);
        setState(() {
        bookings = data
            .map((json) => Booking.fromJson(json))
            .where((booking) => booking.reasonRejection == null && booking.acceptedTrainer == false)
            .toList();
        isLoading = false;
      });
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (error) {
      print("Error fetching bookings: $error");
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
        centerTitle: true,
        title: const Text(
          "Notification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.offAll(() => LayoutPt());
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Text(
                    "Tidak ada yang booking.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(()=> BookingDetailScreen(), arguments: booking);
                      },
                      
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
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
                              vertical: 16, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.member.name ?? "Unknown",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text("No. Hp : ${booking.member.phone ?? "N/A"}")
                                ],
                              ),
                              Icon(
                                Icons.person,
                                size: 44,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
