import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/cardWithStar.dart';
import 'package:semesta_gym/screens/user/detailTrainerScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Example data for the cards
  final List<Map<String, dynamic>> trainers = [
    {
      "id": 1,
      "name": "DIKSON",
      "rating": "5.0",
      "imageUrl": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400",
    },
    {
      "id": 2,
      "name": "JOHN DOE",
      "rating": "4.5",
      "imageUrl": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400",
    },
    {
      "id": 3,
      "name": "JANE SMITH",
      "rating": "4.8",
      "imageUrl": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400",
    },
  ];

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
                    name: trainer["name"],
                     onTap: () {
                       Get.to(() => DetailTrainer(), arguments: trainer);
                    },
                    rating: trainer["rating"],
                    imageUrl: trainer["imageUrl"],
                  );
                },
              ),
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
                    name: trainer["name"],
                    onTap: () {
                      Get.to(() => DetailTrainer(), arguments: trainer);
                    },
                    rating: trainer["rating"],
                    imageUrl: trainer["imageUrl"],
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
