import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/models/review.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:http/http.dart' as http;

class DetailScheduleScreen extends StatefulWidget {
  const DetailScheduleScreen({super.key});

  @override
  State<DetailScheduleScreen> createState() => _DetailScheduleScreenState();
}

class _DetailScheduleScreenState extends State<DetailScheduleScreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());
  late Booking booking = Get.arguments;
  final TextEditingController commentController = TextEditingController();
  late Review review;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchReview();
    });
  }

  Future<void> fetchReview() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/reviews/${booking.trainerId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Find the first review that matches the booking.id
        Review singleReview = data
            .map((json) => Review.fromJson(json))
            .firstWhere((review) => review.bookingId == booking.id,
                orElse: () => Review(
                    id: 0,
                    memberId: 0,
                    trainerId: 0,
                    bookingId: 0,
                    rating: 0,
                    comment: ""));

        setState(() {
          review = singleReview;
          isLoading = false;
        });

        print("Success: Single Review fetched -> ${json.encode(review)}");
      } else {
        throw Exception('Failed to load review');
      }
    } catch (error) {
      print("Error fetching review: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> doneTrain() async {
    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.put(
        Uri.parse("http://10.0.2.2:3000/api/bookings/${booking.id}"),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "done": true,
        }),
      );

      if (response.statusCode == 200) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Latihan telah selesai!",
          onConfirmBtnTap: () {
            showReview();
          },
        );
      } else {
        print("error: ${response.body}");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Gagal mengubah status latihan",
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

  void showDialogDoneTrain() {
    print(booking.trainer.id);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "Apakah Anda Sudah yakin Latihan sudah selesai",
      text: "Cek Terlebih dahulu",
      textColor: Colors.red,
      confirmBtnColor: Color(0xFFF68989),
      onCancelBtnTap: () {
        Get.back();
      },
      confirmBtnText: "Selesai",
      showCancelBtn: true,
      cancelBtnText: "Belum",
      onConfirmBtnTap: () async {
        Get.back();
        doneTrain();
      },
    );
  }

  void showReview() {
    int rating = review.rating ?? 0;
    commentController.text = review.comment ?? "";

    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: review.comment != null && review.comment!.isNotEmpty
          ? "Review anda"
          : "Bagaimana Latihan Anda Dengan Trainer?",
      widget: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                review.comment != null && review.comment!.isNotEmpty
                    ? "Rating Anda"
                    : "Berikan Rating Anda",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap:
                        (review.comment != null && review.comment!.isNotEmpty)
                            ? null
                            : () {
                                setState(() {
                                  rating = (index + 1);
                                });
                              },
                    child: Icon(
                      Icons.star,
                      size: MediaQuery.of(context).size.width * 0.11,
                      color: index < rating ? Colors.yellow : Colors.grey,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                "Review",
                style: TextStyle(fontSize: 20),
              ),
              TextFormField(
                controller: commentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                readOnly: review.comment != null && review.comment!.isNotEmpty,
              ),
            ],
          );
        },
      ),
      textColor: Colors.red,
      confirmBtnColor: const Color(0xFFF68989),
      showCancelBtn:
          review == null || review.comment == null || review.comment!.isEmpty,
      confirmBtnText: (review.comment != null && review.comment!.isNotEmpty)
          ? "Tutup"
          : "Rate",
      onCancelBtnTap: () {
        Get.back();
      },
      onConfirmBtnTap: () {
        if (review == null ||
            review.comment == null ||
            review.comment!.isEmpty) {
          postReview(rating);
        }
        Get.back();
      },
    );
  }

  Future<void> updateWeekStatus(int weekNumber) async {
    print("Mencoba mengupdate status minggu: $weekNumber");
    if (weekNumber > 1 && !(await getWeekDone(weekNumber - 1))) {
      print("Minggu ${weekNumber - 1} belum selesai! Tidak bisa lanjut.");
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Peringatan",
        text: "Minggu ${weekNumber - 1} belum selesai!",
        confirmBtnColor: Color(0xFFF68989),
        confirmBtnText: "Mengerti",
        onConfirmBtnTap: () {
          Get.back();
        },
      );
      return;
    }

    print("Melanjutkan update untuk Minggu $weekNumber");
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
        print("Minggu $weekNumber berhasil diperbarui.");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success",
          text: "Minggu $weekNumber selesai!",
          confirmBtnColor: Color(0xFFF68989),
          confirmBtnText: "Kembali ke halaman",
          onConfirmBtnTap: () {
            Get.back();
          },
        );
      } else {
        print('Gagal memperbarui: ${response.body}');
        Get.snackbar("Error", "Gagal memperbarui status minggu $weekNumber!",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
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

  Future<void> postReview(int rating) async {
    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/api/reviews"),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "memberId": currentUser.user.id,
          "trainerId": booking.trainer.id,
          "bookingId": booking.id,
          "rating": rating,
          "comment": commentController.text
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Terima kasih",
            text: "Telah memberikan rating",
            onConfirmBtnTap: () {
              Get.off(() => Layout());
            },
            confirmBtnText: "Kembali ke home");
      } else {
        print("error: ${response.body}");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Gagal mengirim review",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 260,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "http://10.0.2.2:3000/${booking.trainer.picture}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )),
                backgroundColor:
                    innerBoxIsScrolled ? Colors.white : Colors.transparent,
                elevation: innerBoxIsScrolled ? 4 : 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: innerBoxIsScrolled
                          ? Colors.transparent
                          : Color.fromARGB(50, 0, 0, 0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: innerBoxIsScrolled ? Colors.black : Colors.white,
                      ),
                      onPressed: () {
                        Get.off(() => Layout());
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //PT
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey, width: 1))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Booking',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Jadwal anda Sisa",
                                    style: TextStyle(color: Colors.red),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),

                          Column(
                            children: [
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
                                    final weekDoneStatus =
                                        getWeekDone(weekNumber);

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.warning,
                                              title: "${weekNames[index]}",
                                              text:
                                                  "Apakah Pelatihan Sudah siap ?",
                                              confirmBtnColor:
                                                  Color(0xFFF68989),
                                              confirmBtnText: "Sudah",
                                              onConfirmBtnTap: () {
                                                updateWeekStatus(weekNumber);
                                                Get.back();
                                              },
                                              cancelBtnText: "Belum",
                                              showCancelBtn: true,
                                            );
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: weekDoneStatus
                                                  ? Colors.green
                                                  : Color(0xFF9747FF),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: Offset(4, 6),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 12),
                                              child: Text(
                                                DateFormat('dd-MM-yyyy')
                                                    .format(weekDates[index]),
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
                            ],
                          ),
                        ]),
                  ],
                ),
              ),
            ),
          ])),
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
                    booking.week4Done &&
                    booking.done != true)
                ? () {
                    showDialogDoneTrain();
                  }
                : booking.week1Done &&
                        booking.week2Done &&
                        booking.week3Done &&
                        booking.week4Done &&
                        booking.done == true
                    ? () {
                        showReview();
                      }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF68989),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              booking.week1Done &&
                      booking.week2Done &&
                      booking.week3Done &&
                      booking.week4Done &&
                      booking.done != true
                  ? "Latihan Selesai"
                  : "Review",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )),
        ),
      ),
    );
  }
}

  /*  void showReview() {
    int rating = 0;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: "Bagaimana Latihan Anda Dengan Trainer",
      widget: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                "Berikan Rating Anda",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = (index + 1);
                      });
                    },
                    child: Icon(
                      Icons.star,
                      size: MediaQuery.of(context).size.width * 0.11,
                      color: index < rating ? Colors.yellow : Colors.grey,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                "Review",
                style: TextStyle(fontSize: 20),
              ),
              TextFormField(
                controller: commentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          );
        },
      ),
      textColor: Colors.red,
      confirmBtnColor: const Color(0xFFF68989),
      onCancelBtnTap: () {
        Get.back();
      },
      confirmBtnText: "Rate",
      showCancelBtn: true,
      cancelBtnText: "Tidak",
      onConfirmBtnTap: () {
        postReview(rating);
        Get.back();
      },
    );
  }
 */
  