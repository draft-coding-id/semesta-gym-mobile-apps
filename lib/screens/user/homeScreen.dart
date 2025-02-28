import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/cardWithStar.dart';
import 'package:semesta_gym/models/trainer.dart';
import 'package:semesta_gym/models/user.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/booking/detailTrainerScreen.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/screens/user/notification/notificationScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Trainer> trainers = [];
  List<Trainer> recommendedTrainers = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchTrainers();
    });
  }

  Future<void> fetchTrainers() async {
    String? token = await RememberUserPrefs.readAuthToken();
    User? userInfo = await RememberUserPrefs.readUserInfo();

    if (userInfo == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    List<int> selectedFocusIds =
        await RememberUserPrefs.getRecommendations(userInfo.id.toString());

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/trainers/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Trainer> allTrainers =
            data.map((json) => Trainer.fromJson(json)).toList();

        List<Trainer> recommendedTrainers = allTrainers.where((trainer) {
          List<int> trainerFocusIds =
              trainer.trainingFocus.map((focus) => focus.id).toList();
          return trainerFocusIds.any((id) => selectedFocusIds.contains(id));
        }).toList();

        setState(() {
          trainers = allTrainers;
          this.recommendedTrainers = recommendedTrainers;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load trainers');
      }
    } catch (error) {
      print("Error fetching trainers: $error");
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
        title: const Text(
          "Personal Trainer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => NotificationScreen());
            },
            icon: const Icon(Icons.notifications),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "REKOMENDASI UNTUK ANDA",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                ),
                itemCount: recommendedTrainers.length,
                itemBuilder: (context, index) {
                  final trainer = recommendedTrainers[index];
                  return Cardwithstar(
                    name: trainer.name,
                    onTap: () {
                      Get.to(() => DetailTrainer(), arguments: trainer);
                    },
                    rating: trainer.rating,
                    imageUrl: "http://10.0.2.2:3000/${trainer.picture}",
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "PERSONAL TRAINER",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                ),
                itemCount: trainers.length,
                itemBuilder: (context, index) {
                  final trainer = trainers[index];
                  return Cardwithstar(
                    name: trainer.name,
                    onTap: () {
                      Get.to(() => DetailTrainer(), arguments: trainer);
                    },
                    rating: trainer.rating,
                    imageUrl: "http://10.0.2.2:3000/${trainer.picture}",
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
