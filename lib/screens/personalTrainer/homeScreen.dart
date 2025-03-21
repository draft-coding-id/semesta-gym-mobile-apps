import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/personalTrainer/historyScreen.dart';
import 'package:semesta_gym/screens/personalTrainer/notificationScreen.dart';
import 'package:semesta_gym/screens/personalTrainer/scheduleScreen.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;

class HomeScreenPt extends StatefulWidget {
  const HomeScreenPt({super.key});

  @override
  State<HomeScreenPt> createState() => _HomeScreenPtState();
}

class _HomeScreenPtState extends State<HomeScreenPt> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  bool isLoading = true;
  List<Booking> bookings = [];
  List<Booking> bookingBadges = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchBooking();
    });
  }

  Future<void> fetchBooking() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BOOKING']}trainer/${_currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("_currentUser.user.id : ${_currentUser.user.id}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Raw Bookings Data: $data");

        setState(() {
          // List for ListView.builder
          bookings = data
              .map((json) => Booking.fromJson(json))
              .where((booking) =>
                  booking.acceptedTrainer == true && booking.done == false)
              .toList();

          // List for Badge Count in AppBar
          bookingBadges = data
              .map((json) => Booking.fromJson(json))
              .where((booking) =>
                  booking.reasonRejection == null &&
                  booking.acceptedTrainer == false)
              .toList();
        });

        print("Filtered Bookings for ListView: $bookings");
        print("Filtered Bookings for Badge: $bookingBadges");
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching bookings: $error");
    } finally {
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
        title: const Text(
          "Member",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Get.to(() => NotificationScreen());
              },
              child: badges.Badge(
                badgeContent: Text(
                  bookingBadges.length.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                showBadge: bookingBadges.isNotEmpty,
                child: const Icon(Icons.notifications, size: 28),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.grey.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookings.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada member booking",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: bookings.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ScheduleScreenPt(), arguments: booking);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(4, 6),
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        "No. Hp : ${booking.member.phone ?? "N/A"}"),
                                  ],
                                ),
                                const Icon(Icons.person, size: 44),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 66, vertical: 16),
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => HistoryScreenPt());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "History",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
