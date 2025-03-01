import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/models/payment.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/screens/user/notification/payBookingScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
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
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BOOKING']}member/${_currentUser.user.id}'),
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

  Future<void> fetchPaymentByType() async {
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
            Get.offAll(() => Layout());
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

                            var relatedPayment = payments.firstWhere(
                              (payment) => payment.paymentableId == booking.id,
                              orElse: () =>
                                  Payment(0, 0, "", "", "", "", '', 0, User("")),
                            );

                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (booking.acceptedTrainer != false &&
                                        booking.reasonRejection == null &&
                                        relatedPayment.paymentStatus != 'success') {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.success,
                                        title: "Booking Diterima",
                                        text: "Silahkan Lakukan Pembayaran",
                                        confirmBtnText: "Lanjut Payment",
                                        onConfirmBtnTap: () {
                                          Get.to(() => PayBookingScreen(),
                                              arguments: booking);
                                        },
                                        showCancelBtn: false,
                                      );
                                    } else if (booking.acceptedTrainer ==
                                            false &&
                                        booking.reasonRejection != null) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.warning,
                                        title: "Booking Ditolak",
                                        text: "Mohon ajukan ulang",
                                        widget: Column(
                                          children: [
                                            Text("Alasan trainer menolak"),
                                            SizedBox(height: 5),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                              initialValue:
                                                  booking.reasonRejection,
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
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                "${dotenv.env['BASE_URL_API']}${booking.trainer.picture}",
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
                                                  Text("Personal Trainer",
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  Text(
                                                    booking.trainer.name,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 12),
                                                  Row(
                                                    spacing: 4,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: booking.acceptedTrainer !=
                                                                      false &&
                                                                  booking.reasonRejection ==
                                                                      null
                                                              ? Colors.green
                                                              : booking.acceptedTrainer ==
                                                                          false &&
                                                                      booking.reasonRejection !=
                                                                          null
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .amber,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4,
                                                                  horizontal:
                                                                      6),
                                                          child: Text(
                                                            booking.acceptedTrainer !=
                                                                        false &&
                                                                    booking.reasonRejection ==
                                                                        null
                                                                ? "Diterima"
                                                                : booking.acceptedTrainer ==
                                                                            false &&
                                                                        booking.reasonRejection !=
                                                                            null
                                                                    ? "Ditolak"
                                                                    : "Waiting",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                      (booking.acceptedTrainer !=
                                                                  false &&
                                                              booking.reasonRejection ==
                                                                  null &&
                                                              relatedPayment
                                                                      .paymentStatus ==
                                                                  "success"
                                                          ? Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Colors
                                                                      .blue),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 4,
                                                                    horizontal:
                                                                        6),
                                                                child: Text(
                                                                  "Sudah Di bayar",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox())
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        (booking.acceptedTrainer != false &&
                                                    relatedPayment
                                                            .paymentStatus !=
                                                        "success" ||
                                                booking.reasonRejection !=
                                                        null &&
                                                    relatedPayment
                                                            .paymentStatus !=
                                                        "success"
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
                                SizedBox(height: 12),
                              ],
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
