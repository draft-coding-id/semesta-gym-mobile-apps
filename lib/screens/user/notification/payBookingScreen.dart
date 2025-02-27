import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/notification/notificationScreen.dart';
import 'package:http/http.dart' as http;

class PayBookingScreen extends StatefulWidget {
  const PayBookingScreen({super.key});

  @override
  State<PayBookingScreen> createState() => _PayBookingScreenState();
}

class _PayBookingScreenState extends State<PayBookingScreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());
  final Booking booking = Get.arguments;
  bool? isLoading;
  String? savedOrderId;

  MidtransSDK? _midtrans;

  @override
  void initState() {
    super.initState();
    _initMidtrans();
  }

  void _initMidtrans() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        merchantBaseUrl: "",
        clientKey: "SB-Mid-client-A4xo8S8KfljkK5QP",
      ),
    );
    _midtrans?.setUIKitCustomSetting(skipCustomerDetailsPages: true);

    setState(() {});
  }

  // Flow
  // first startPayment
  void startPayment() async {
    if (_midtrans == null) {
      print("Midtrans SDK not initialized yet.");
      return;
    }

    if (currentUser.user == null) {
      print("User data not available.");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // Step 1: Generate Snap Token
      String snapToken = await _generateSnapToken();

      // Step 2: Start Midtrans UI Flow
      await _midtrans?.startPaymentUiFlow(token: snapToken);

      print("Waiting for Midtrans transaction result...");

      // Step 3: Set up Midtrans callback listener
      _midtrans
          ?.setTransactionFinishedCallback((TransactionResult result) async {
        print("Transaction Result: ${result.toJson()}");

        if (result.transactionStatus == TransactionResultStatus.settlement ||
            result.transactionStatus == TransactionResultStatus.capture) {
          print("Payment successful. Checking status...");

          // Step 4: Check Payment Status
          await checkPaymentStatus();
        } /* else if (result.transactionStatus == TransactionResultStatus.pending) {

        } */
        else if (result.transactionStatus == TransactionResultStatus.cancel) {
          print("Payment was canceled by the user.");
        } else {
          print("Payment failed.");
        }

        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      print("Error starting payment: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  //2. generateToken
  Future<String> _generateSnapToken() async {
    savedOrderId = "ORDER-${DateTime.now().millisecondsSinceEpoch}";
    final String serverKey = "SB-Mid-server-10Dr4ULfMa42pHA6VbJOxEOt";
    final String base64Auth =
        "Basic " + base64Encode(utf8.encode("$serverKey:"));

    try {
      final response = await http.post(
        Uri.parse("https://app.sandbox.midtrans.com/snap/v1/transactions"),
        headers: {
          'Authorization': base64Auth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "transaction_details": {
            "order_id": savedOrderId,
            "gross_amount": booking.trainer.price,
          },
          "item_details": [
            {
              "price": booking.trainer.price,
              "quantity": 1,
              "name": "1 Bulan Personal Trainer (${booking.trainer.name})"
            },
          ],
          "customer_details": {
            "first_name": currentUser.user.name,
            "email": currentUser.user.email,
            "phone": currentUser.user.phone
          }
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      print("order-id ${savedOrderId}");

      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        return data['token'];
      } else {
        throw Exception("Failed to fetch Snap Token: ${response.body}");
      }
    } catch (e) {
      print("Error generating Snap Token: $e");
      rethrow;
    }
  }

  //3. checkPaymentStatus and waiting before do next function
  Future<void> checkPaymentStatus() async {
    if (savedOrderId == null || savedOrderId!.isEmpty) {
      print("❌ Order ID tidak tersedia.");
      return;
    }

    String serverKey = "SB-Mid-server-10Dr4ULfMa42pHA6VbJOxEOt";
    String base64Auth = "Basic " + base64Encode(utf8.encode("$serverKey:"));

    try {
      final response = await http.get(
        Uri.parse("https://api.sandbox.midtrans.com/v2/$savedOrderId/status"),
        headers: {
          'Authorization': base64Auth,
          'Content-Type': 'application/json'
        },
      );

      print("🟡 Full Midtrans Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check if response contains `transaction_status`
        if (data == null || !data.containsKey('transaction_status')) {
          print(
              "❌ Error: Response does not contain transaction_status. Full response: $data");
          return;
        }

        String transactionStatus = data['transaction_status'] ?? "unknown";
        print("✅ Payment Status: $transactionStatus");

        if (transactionStatus == "settlement" ||
            transactionStatus == "capture") {
          await postDataPaymentBooking();
          return;
        } else if (transactionStatus == "pending") {
          await Future.delayed(Duration(seconds: 5));
        } else {
          print("❌ Payment failed or canceled.");
          setState(() {
            isLoading = false;
          });
          return;
        }
      } else {
        print("❌ Failed to fetch transaction status: ${response.body}");
      }
    } catch (e) {
      print("❌ Error checking payment status: $e");
    }

    print("⏳ Payment status check timed out.");
    setState(() {
      isLoading = false;
    });
  }

  //4. last postDataPaymentCourse
  Future<void> postDataPaymentBooking() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/payments/booking'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "bookingId": booking.id,
          "amount": booking.trainer.price,
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
          onConfirmBtnTap: () => Get.offAll(() => NotificationScreen()),
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
                        Get.off(() => NotificationScreen());
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
                    Column(children: [
                      //PT
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${booking.trainer.name}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              // No. hp
                              Row(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.phone),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "No. Handphone",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    booking.trainer.phone,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              // Jadwal
                              Row(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.schedule),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "Jadwal",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    booking.trainer.hoursOfPractice,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),

                      //Session and price
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1))),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "1 Bulan",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "4 Session",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                width: 301,
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
                                      vertical: 5, horizontal: 5),
                                  child: Center(
                                    child: Text(
                                      "Rp. ${NumberFormat('#,###').format(booking.trainer.price)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
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
                              children: [
                                Text(
                                  "Jadwal booking",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Column(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Color(0xFF9747FF),
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 12),
                                            child: Text(
                                              DateFormat('dd-MM-yyyy')
                                                  .format(weekDates[index]),
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
                              ],
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 32),
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  startPayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF68989),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Payment",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
