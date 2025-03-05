import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/courseByUserId.dart';
import 'package:semesta_gym/models/trainingFocus.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/course/trainingCourse.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());

  List<TrainingFocus> trainingFocus = [];
  List<CourseByUserId> courseUser = [];
  bool isLoading = true;
  int coursePricePayment = 20000;
  String? savedOrderId;

  MidtransSDK? _midtrans;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchCourseByUserId();
      await fetchTrainingFocus();
      if (Get.arguments != null && Get.arguments["triggerPayment"] == false) {
        await postDataPaymentCourse();
        Get.offAll(() => Layout(
              index: 3,
            ));
      }
    });
    _initMidtrans();
  }

  void _initMidtrans() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
          merchantBaseUrl: "",
          clientKey: "${dotenv.env['MIDTRANS_CLIENT_KEY']}"),
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
        } else if (result.transactionStatus ==
            TransactionResultStatus.pending) {
          print("🟡 Payment is still pending. Informing the user...");

          await QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            confirmBtnText: "OK",
            title: "Pending Payment",
            text:
                "Transaksi kamu dalam status pending. Tolong selesaikan payment dan tetap berada di screen ini sampai transaksi selesai.",
            confirmBtnColor: Colors.orange,
          );

          checkPaymentStatus();
        } else if (result.transactionStatus == TransactionResultStatus.cancel) {
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
    final String serverKey = "${dotenv.env['MIDTRANS_SERVER_KEY']}";
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
            "gross_amount": coursePricePayment,
          },
          "item_details": [
            {
              "price": coursePricePayment,
              "quantity": 1,
              "name": "1 Bulan Course"
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
      print("❌ Order ID not available.");
      return;
    }

    String serverKey = "${dotenv.env['MIDTRANS_SERVER_KEY']}";
    String base64Auth = "Basic " + base64Encode(utf8.encode("$serverKey:"));

    int retryCount = 0;
    const int maxRetries = 300;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse("https://api.sandbox.midtrans.com/v2/$savedOrderId/status"),
          headers: {
            'Authorization': base64Auth,
            'Content-Type': 'application/json'
          },
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (!data.containsKey('transaction_status')) {
            print("❌ Error: No transaction_status in response.");
            return;
          }

          String transactionStatus = data['transaction_status'] ?? "unknown";
          print("🔍 Payment Status: $transactionStatus");

          if (transactionStatus == "settlement" ||
              transactionStatus == "capture") {
            print("✅ Payment successful!");
            await postCourseUser();
            return;
          } else if (transactionStatus == "pending") {
            print("⏳ Payment still pending. Retrying in 6 seconds...");
            await Future.delayed(Duration(seconds: 6));
            retryCount++;
          } else {
            print("❌ Payment failed or canceled.");
            return;
          }
        } else {
          print("❌ Failed to fetch status: ${response.body}");
        }
      } catch (e) {
        print("❌ Error checking payment status: $e");
      }
    }

    print("⏳ Payment status check timed out.");
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: "Payment Failed",
      text: "Telah melebihi batas waktu yang diberikan ",
      confirmBtnText: "OK",
      confirmBtnColor: Colors.red,
    );
  }

  //4. if Success do postCourseUser
  Future<void> postCourseUser() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_REGISTER_COURSES_USER']}'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "userId": currentUser.user.id,
          "price": coursePricePayment,
          "startDate": DateTime.now().toUtc().toIso8601String(),
          "endDate":
              DateTime.now().toUtc().add(Duration(days: 30)).toIso8601String()
        }),
      );
      print("response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Post course success");

        Get.offAll(
            () => Layout(
                  index: 3,
                ),
            arguments: {"triggerPayment": false});
      } else {
        print("Error Response: ${response.body}");
        Get.snackbar("Error", "Failed to register course",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (error) {
      Get.snackbar("Error", "Something went wrong. Try again later.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  //5. last postDataPaymentCourse
  Future<void> postDataPaymentCourse() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_PAYMENT_COURSE']}'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "courseId": courseUser.last.id,
          "amount": 20000,
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
          onConfirmBtnTap: () => Get.back(),
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

  Future<void> fetchCourseByUserId() async {
    String? token = await RememberUserPrefs.readAuthToken();

    try {
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_REGISTER_COURSES_USER']}user/${currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          courseUser = data.isNotEmpty
              ? data.map((json) => CourseByUserId.fromJson(json)).toList()
              : [];
          isLoading = false;
        });

        if (courseUser.isNotEmpty) {
          print("endDate last array list: ${courseUser.last.endDate}");
        } else {
          print("No courses available for this user.");
        }
      } else {
        print("Error: ${response.body}");
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        courseUser = [];
      });
      Get.snackbar("Error", "Failed to load Course User");
    }
  }

  Future<void> fetchTrainingFocus() async {
    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_TRAINING_FOCUS']}'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          trainingFocus =
              data.map((json) => TrainingFocus.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Error", "Failed to load training focus data");
    }
  }

  bool isCourseExpired() {
    if (courseUser.isEmpty) return true;

    try {
      DateTime endDate = DateTime.parse(courseUser.last.endDate);
      return endDate.isBefore(DateTime.now());
    } catch (e) {
      print("Error parsing endDate: $e");
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool expired = isCourseExpired();

    return Scaffold(
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Course",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Expired",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
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
                          courseUser.isNotEmpty
                              ? DateFormat('dd-MM-yyyy').format(
                                  DateTime.parse(courseUser.last.endDate))
                              : "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: trainingFocus.length,
                    itemBuilder: (context, index) {
                      final trainingFocusData = trainingFocus[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => TrainingCourseScreen(),
                                  arguments: trainingFocusData);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 160,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: trainingFocusData.picture != null &&
                                            trainingFocusData.picture.isNotEmpty
                                        ? NetworkImage(
                                            "${dotenv.env['BASE_URL_API']}${trainingFocusData.picture}")
                                        : const AssetImage(
                                            'assets/images/placehold.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    trainingFocusData.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Modal Overlay
          if (expired) ...[
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 52,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Belum Berlangganan Course?",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Course expired / belum berlangganan silahkan cek terlebih dahulu sebelum melakukan pembayaran",
                      style: TextStyle(fontSize: 14, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "1 Bulan Course\nRp. 20.000",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        startPayment();
                      },
                      child: Text(
                        "Bayar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
