import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
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
            'http://10.0.2.2:3000/api/bookings/member/${_currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          bookings = data.map((json) => Booking.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
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
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        title: Text(
          "Notification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(child: Text("Tidak ada list booking"))
              : SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Permintaan booking",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return Column(children: [
                                GestureDetector(
                                  onTap: () {
                                    if ( booking.acceptedTrainer != false && booking.reasonRejection == null) {
                                      QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.success,
                                          title: "Booking Di Terima",
                                          text: "Silahkan Lakukan Pembayaran",
                                          confirmBtnText: "Lanjut Payment",
                                          onConfirmBtnTap: () {
                                            Get.back();
                                          },
                                          showCancelBtn: false);
                                    } else if (booking.acceptedTrainer == false && booking.reasonRejection != null
                                        ) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.warning,
                                        title: "Booking Di Tolak",
                                        text: "Mohon ajukan ulang",
                                        widget: Column(
                                          children: [
                                            Text("Alasan trainer menolak"),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                              initialValue: booking.reasonRejection,
                                              maxLines: 3,
                                              readOnly: true,
                                            ),
                                          ],
                                        ),
                                        confirmBtnText: "Booking Ulang",
                                        onConfirmBtnTap: () {
                                          Get.offAll(() => Layout());
                                        },
                                      );
                                    } else {
                                      null;
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                "http://10.0.2.2:3000/${booking.trainer.picture}",
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.12,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(Icons.person,
                                                      size: 60,
                                                      color: Colors.grey);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Personal Trainer",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  Text(
                                                    booking.trainer.name,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 12,
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: booking.acceptedTrainer != false && booking.reasonRejection == null 
                                                          ? Colors.green 
                                                          : booking.acceptedTrainer == false && booking.reasonRejection != null 
                                                          ? Colors.red 
                                                          : Colors.amber,
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 6),
                                                      child: Text(
                                                        booking.acceptedTrainer != false && booking.reasonRejection == null 
                                                          ? "Di terima" 
                                                          : booking.acceptedTrainer == false && booking.reasonRejection != null 
                                                          ? "Di tolak" 
                                                          : "Waiting",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        (booking.acceptedTrainer != false || booking.reasonRejection != null
                                            ? Expanded(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "Lihat Detail",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox())
                                      ],
                                    ),
                                  ),
                                ),
                              ]);
                            })
                      ],
                    ),
                  ),
                ),
    );
  }
}
