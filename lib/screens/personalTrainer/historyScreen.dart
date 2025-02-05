import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/screens/personalTrainer/layoutPt.dart';

class HistoryScreenPt extends StatefulWidget {
  const HistoryScreenPt({super.key});

  @override
  State<HistoryScreenPt> createState() => _HistoryScreenPtState();
}

class _HistoryScreenPtState extends State<HistoryScreenPt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            onPressed: () {
              Get.offAll(() => LayoutPt());
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
        ],
        backgroundColor: Colors.grey.shade300,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                
              },
              child: Container(
                width: double.infinity,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "{nameMember}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(
                            height: 0,
                          ),
                          Text("No. Hp : {numberPhone}")
                        ],
                      ),
                      Icon(
                        Icons.person,
                        size: 44,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
