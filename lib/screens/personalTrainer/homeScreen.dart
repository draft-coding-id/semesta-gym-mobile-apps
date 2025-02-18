import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/screens/personalTrainer/historyScreen.dart';
import 'package:semesta_gym/screens/personalTrainer/notificationScreen.dart';
import 'package:semesta_gym/screens/personalTrainer/scheduleScreen.dart';

class HomeScreenPt extends StatefulWidget {
  const HomeScreenPt({super.key});

  @override
  State<HomeScreenPt> createState() => _HomeScreenPtState();
}

class _HomeScreenPtState extends State<HomeScreenPt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        title: const Text(
          "Member",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {
            Get.to(() => NotificationScreen());
          }, icon: Icon(Icons.notifications))
        ],
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: (){
                  Get.to(() => ScheduleScreenPt());
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
                        Icon(Icons.person, size: 44,)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 66, vertical: 16),
        child: SizedBox(
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => HistoryScreenPt());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "History",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
