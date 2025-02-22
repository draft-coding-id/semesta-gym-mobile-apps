import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryMembershipScreen extends StatefulWidget {
  const HistoryMembershipScreen({super.key});

  @override
  State<HistoryMembershipScreen> createState() =>
      _HistoryMembershipScreenState();
}

class _HistoryMembershipScreenState extends State<HistoryMembershipScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF82ACEF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "History Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("17-JAN-2025",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Rp. xxx.xxx",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Paket",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Membership",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
