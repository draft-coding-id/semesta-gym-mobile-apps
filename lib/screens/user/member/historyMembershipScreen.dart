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
    );
  }
}
