import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/membership.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:http/http.dart' as http;

import '../../../preferences/currentUser.dart';

class ListMembershipScreen extends StatefulWidget {
  const ListMembershipScreen({super.key});

  @override
  State<ListMembershipScreen> createState() => _ListMembershipScreenState();
}

class _ListMembershipScreenState extends State<ListMembershipScreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());
  bool isLoading = true;
  List<Membership> membership = [];
  int? _selectedMembershipId;
  String? savedOrderId;

  MidtransSDK? _midtrans;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchMembership();

    });
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

      // Generate Snap Token
      String snapToken = await _generateSnapToken();

      // Start Payment UI Flow
      await _midtrans?.startPaymentUiFlow(token: snapToken);

      print("Waiting for Midtrans transaction result...");

      _midtrans
          ?.setTransactionFinishedCallback((TransactionResult result) async {
        print("Transaction Result: ${result.toJson()}");

        if (result.transactionStatus == TransactionResultStatus.settlement ||
            result.transactionStatus == TransactionResultStatus.capture) {
          print("Payment successful. Checking status...");
          await checkPaymentStatus();
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
    if (_selectedMembershipId == null) {
      throw Exception("No membership selected");
    }

    Membership? selectedMembership = membership.isNotEmpty
        ? membership.firstWhere(
            (m) => m.id == _selectedMembershipId,
            orElse: () => Membership(
                id: 0, name: "", price: 0, duration: 0, description: ""),
          )
        : null;

    if (selectedMembership == null) {
      throw Exception("Selected membership not found");
    }

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
            "gross_amount": selectedMembership.price,
          },
          "item_details": [
            {
              "id": selectedMembership.id,
              "price": selectedMembership.price.toDouble(),
              "quantity": 1,
              "name": selectedMembership.name
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
      print("order-id: $savedOrderId");

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

        if (data == null || !data.containsKey('transaction_status')) {
          print("❌ Error: Response does not contain transaction_status.");
          return;
        }

        String transactionStatus = data['transaction_status'] ?? "unknown";
        print("✅ Payment Status: $transactionStatus");

        if (transactionStatus == "settlement" ||
            transactionStatus == "capture") {
          await postRegisterMembership();
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

  //4. Post register Membership user
  Future<void> postRegisterMembership() async {
    if (_selectedMembershipId == null) {
      throw Exception("No membership selected");
    }

    Membership? selectedMembership = membership.isNotEmpty
        ? membership.firstWhere(
            (m) => m.id == _selectedMembershipId,
            orElse: () => Membership(
                id: 0, name: "", price: 0, duration: 0, description: ""),
          )
        : null;

    if (selectedMembership == null) {
      throw Exception("Selected membership not found");
    }

    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/memberships/register'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "userId": currentUser.user.id,
          "membershipId": selectedMembership.id,
          "startDate": DateTime.now().toUtc().toIso8601String(),
          "endDate": DateTime.now()
              .toUtc()
              .add(Duration(days: selectedMembership.duration))
              .toIso8601String()
        }),
      );
      print("response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Post membership success");

        await fetchMembership();
        setState(() {});
        Get.off(() => Layout(index: 2,),
            arguments: {"triggerPaymentMembership": true});
      } else {
        print("Error Response: ${response.body}");
        Get.snackbar("Error", "Failed to register membership",
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

  Future<void> fetchMembership() async {
    String? token = await RememberUserPrefs.readAuthToken();
    await Future.delayed(Duration(milliseconds: 100));

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/memberships'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          membership = data.map((json) => Membership.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load membership');
      }
    } catch (error) {
      print("Error fetching membership: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF82ACEF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "List Membership",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : membership.isEmpty
              ? Center(child: Text("Tidak ada list membership"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: membership.length,
                          itemBuilder: (context, index) {
                            final member = membership[index];
                            bool isSelected =
                                member.id == _selectedMembershipId;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMembershipId =
                                      (_selectedMembershipId == member.id)
                                          ? null
                                          : member.id;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected
                                      ? Colors.green[300]
                                      : Colors.white,
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
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                member.name,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                "Rp. ${NumberFormat('#,###').format(member.price)}",
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _selectedMembershipId =
                                                    (value == true)
                                                        ? member.id
                                                        : null;
                                              });
                                            },
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 32),
        child: ElevatedButton(
          onPressed: _selectedMembershipId == null
              ? null
              : () {
                  startPayment();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            disabledBackgroundColor: Colors.grey.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Bayar",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
