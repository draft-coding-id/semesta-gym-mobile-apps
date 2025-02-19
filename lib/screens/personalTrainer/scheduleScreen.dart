import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/personalTrainer/layoutPt.dart';

class ScheduleScreenPt extends StatefulWidget {
  const ScheduleScreenPt({super.key});

  @override
  State<ScheduleScreenPt> createState() => _ScheduleScreenPtState();
}

class _ScheduleScreenPtState extends State<ScheduleScreenPt> {
  late Booking booking = Get.arguments;

  Future<void> updateWeekStatus(int weekNumber) async {
    // Cek apakah minggu sebelumnya sudah selesai
    if (weekNumber > 1 && !getWeekDone(weekNumber - 1)) {
      Get.snackbar("Error", "Minggu ${weekNumber - 1} belum selesai!",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    String weekKey = "week${weekNumber}Done";
    Map<String, dynamic> updatedData = {weekKey: true};

    try {
      String? token = await RememberUserPrefs.readAuthToken();
      var response = await http.put(
        Uri.parse("http://10.0.2.2:3000/api/bookings/${booking.id}"),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        setState(() {
          setWeekDone(weekNumber, true);
        });
        Get.snackbar("Success", "Minggu $weekNumber selesai!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        print('respon body: ${response.body}');
        Get.snackbar("Error", "Gagal memperbarui status minggu $weekNumber!",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('respon body: ${e}');
      Get.snackbar("Error", "Terjadi kesalahan!",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  bool getWeekDone(int weekNumber) {
    switch (weekNumber) {
      case 1:
        return booking.week1Done;
      case 2:
        return booking.week2Done;
      case 3:
        return booking.week3Done;
      case 4:
        return booking.week4Done;
      default:
        return false;
    }
  }

  void setWeekDone(int weekNumber, bool value) {
    setState(() {
      booking = Booking(
        id: booking.id,
        memberId: booking.memberId,
        trainerId: booking.trainerId,
        week1Date: booking.week1Date,
        week1Done: weekNumber == 1 ? value : booking.week1Done,
        week2Date: booking.week2Date,
        week2Done: weekNumber == 2 ? value : booking.week2Done,
        week3Date: booking.week3Date,
        week3Done: weekNumber == 3 ? value : booking.week3Done,
        week4Date: booking.week4Date,
        week4Done: weekNumber == 4 ? value : booking.week4Done,
        acceptedTrainer: booking.acceptedTrainer,
        done: booking.done,
        reasonRejection: booking.reasonRejection,
        createdAt: booking.createdAt,
        updatedAt: DateTime.now(),
        member: booking.member,
        trainer: booking.trainer,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Get.offAll(() => LayoutPt());
          },
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
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone),
                        SizedBox(width: 6),
                        Text("No. Handphone: "),
                        SizedBox(width: 32),
                        Text(booking.member.phone),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Anggota",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                  final weekNumber = index + 1;
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
                  final weekDoneStatus = getWeekDone(weekNumber);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weekNames[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Get.defaultDialog(
                            title: "Konfirmasi",
                            middleText:
                                "Apakah Anda yakin ingin menyelesaikan ${weekNames[index]}?",
                            textConfirm: "Ya",
                            textCancel: "Batal",
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              updateWeekStatus(weekNumber);
                              Get.back();
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: weekDoneStatus
                                ? Colors.green
                                : Color(0xFF9747FF),
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
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                }),
              ),
            ),
            SizedBox(height: 16),
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
              child: ElevatedButton(
            onPressed: (booking.week1Done &&
                    booking.week2Done &&
                    booking.week3Done &&
                    booking.week4Done)
                ? () {
                    // Handle latihan selesai action here
                  }
                : null, // Disable button if any week is not done
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF68989),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Latihan Selesai",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )),
        ),
      ),
    );
  }
}
