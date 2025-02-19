import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/personalTrainer/homeScreen.dart';
import 'package:semesta_gym/screens/personalTrainer/notificationScreen.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final Booking booking = Get.arguments;
  final TextEditingController _reasonController = TextEditingController();

  Future<void> acceptedBooking() async {
    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.put(
        Uri.parse("http://10.0.2.2:3000/api/bookings/${booking.id}"),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "week1Date": booking.week1Date.toIso8601String(),
          "week1Done": false,
          "week2Date": booking.week2Date.toIso8601String(),
          "week2Done": false,
          "week3Date": booking.week3Date.toIso8601String(),
          "week3Done": false,
          "week4Date": booking.week4Date.toIso8601String(),
          "week4Done": false,
          "acceptedTrainer": true,
          "done": false,
        }),
      );

      if (response.statusCode == 200) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Booking berhasil diterima!",
          onConfirmBtnTap: () {
            Get.off(() => HomeScreenPt());
          },
        );
      } else {
        print("error: ${response.body}");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Gagal menerima booking!",
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Terjadi kesalahan: $e",
      );
    }
  }

  void showAcceptedDialog() {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: "Apakah Jadwal  Latihan Cocok?",
        text: "Pastikan Cek Terlebih dahulu ",
        textColor: Colors.red,
        confirmBtnColor: Color(0xFFF68989),
        confirmBtnText: "Terima",
        onConfirmBtnTap: acceptedBooking,
        cancelBtnText: "Batal",
        showCancelBtn: true);
  }

  Future<void> rejectBooking() async {
    if (_reasonController.text.isEmpty) {
      Get.snackbar("Error", "Harap isi alasan penolakan!",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.put(
        Uri.parse("http://10.0.2.2:3000/api/bookings/${booking.id}"),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "week1Date": booking.week1Date.toIso8601String(),
          "week1Done": false,
          "week2Date": booking.week2Date.toIso8601String(),
          "week2Done": false,
          "week3Date": booking.week3Date.toIso8601String(),
          "week3Done": false,
          "week4Date": booking.week4Date.toIso8601String(),
          "week4Done": false,
          "acceptedTrainer": false,
          "done": false,
          "reasonRejection": _reasonController.text
        }),
      );

      if (response.statusCode == 200) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Booking berhasil ditolak!",
          onConfirmBtnTap: () {
            Get.off(() => NotificationScreen());
          },
        );
      } else {
        print("error: ${response.body}");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Gagal menolak booking!",
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Terjadi kesalahan: $e",
      );
    }
  }

  void showRejectDialog() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: "Penolakan Jadwal Anggota",
      text: "Berikan Alasan Penolakan Anda",
      widget: Column(
        children: [
          TextFormField(
            controller: _reasonController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      confirmBtnColor: Color(0xFFF68989),
      confirmBtnText: "Kirim",
      onConfirmBtnTap: rejectBooking,
      cancelBtnText: "Batal",
      showCancelBtn: true,
      onCancelBtnTap: () {
        _reasonController.clear();
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Colors.grey.shade400, width: 0.5))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.member.name,
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(Icons.phone),
                        SizedBox(
                          width: 6,
                        ),
                        Text("No. Handphone: "),
                        SizedBox(
                          width: 32,
                        ),
                        Text("${booking.member.phone}")
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(4, (index) {
                  final weekNames = [
                    "Minggu 1",
                    "Minggu 2",
                    "Minggu 3",
                    "Minggu 4"
                  ];
                  final weekDates = [
                    booking.week1Date,
                    booking.week2Date,
                    booking.week3Date,
                    booking.week4Date
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weekNames[index],
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF9747FF),
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
                              vertical: 12, horizontal: 12),
                          child: Text(
                            DateFormat('dd-MM-yyyy').format(weekDates[index]),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                }),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                top: BorderSide(color: Colors.grey.shade400, width: 0.5),
              )),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Harga",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Center(
                      child: Text(
                        "Rp. ${NumberFormat('#,###').format(booking.trainer.price)}",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.grey.shade400, width: 0.5))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 66, vertical: 16),
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: showRejectDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Tolak",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: showAcceptedDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Terima",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
