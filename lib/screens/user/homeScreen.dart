import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/cardWithStar.dart';
import 'package:semesta_gym/models/trainer.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/detailTrainerScreen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Trainer> trainers = [];

  @override
  void initState() {
    super.initState();
    fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/trainers/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("token: $token");

      if (response.statusCode == 200) {
        print(response.body);

        List<dynamic> data = json.decode(response.body);
        setState(() {
          trainers = data.map((json) => Trainer.fromJson(json)).toList();
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
              /* GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: trainers.length,
                      itemBuilder: (context, index) {
                        final trainer = trainers[index];
                        return Cardwithstar(
                          name: trainer["name"],
                          onTap: () {
                            Get.to(() => DetailTrainer(), arguments: trainer);
                          },
                          rating: trainer["rating"],
                          imageUrl: trainer["imageUrl"],
                        );
                      },
                    ), */
              Text(
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
                    rating: "5.0",
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
