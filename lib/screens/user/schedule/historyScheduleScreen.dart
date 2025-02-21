import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/cardWithStar.dart';

class HistoryScheduleScreen extends StatefulWidget {
  const HistoryScheduleScreen({super.key});

  @override
  State<HistoryScheduleScreen> createState() => _HistoryScheduleScreenState();
}

class _HistoryScheduleScreenState extends State<HistoryScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "History Trainer",
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  /* final trainer = trainers[index]; */
                  return Cardwithstar(
                    name: "test",
                    onTap: () {},
                    rating: "5.0",
                    imageUrl:
                        "https://www.churchmotiongraphics.com/wp-content/uploads/2014/03/IndianHeadTestPattern16x9.png",
                    showRating: false,
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
