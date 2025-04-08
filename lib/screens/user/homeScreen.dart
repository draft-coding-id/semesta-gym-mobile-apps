import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/components/cardWithStar.dart';
import 'package:semesta_gym/models/trainer.dart' as trainerModel;
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/booking/detailTrainerScreen.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/screens/user/notification/notificationScreen.dart';
import 'package:badges/badges.dart' as badges;
import '../../models/booking.dart' as bookingModel;
import 'package:semesta_gym/models/user.dart' as userModel;
import '../../models/payment.dart' as paymentModel;
import '../../preferences/currentUser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());
  bool isLoading = true;
  List<bookingModel.Booking> bookings = [];
  List<bookingModel.Booking> validBookings = [];
  List<paymentModel.Payment> payments = [];
  List<trainerModel.Trainer> trainers = [];
  List<trainerModel.Trainer> recommendedTrainers = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchTrainers();
      await fetchBooking();
    });
  }

Future<void> fetchBooking() async {
  setState(() {
    isLoading = true;
  });

  try {
    String? token = await RememberUserPrefs.readAuthToken();

    final bookingResponse = await http.get(
      Uri.parse('${dotenv.env['API_BOOKING']}member/${currentUser.user.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (bookingResponse.statusCode == 200) {
      final List<dynamic> data = json.decode(bookingResponse.body);
      bookings = data.map((json) => bookingModel.Booking.fromJson(json)).toList();
    }

    final paymentResponse = await http.get(
      Uri.parse(
            '${dotenv.env['API_PAYMENT_BY_USER_ID']}${currentUser.user.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (paymentResponse.statusCode == 200) {
      final List<dynamic> paymentData = json.decode(paymentResponse.body);
      payments = paymentData.map((json) => paymentModel.Payment.fromJson(json)).toList();
    }

    validBookings = bookings.where((booking) {
      final relatedPayment = payments.firstWhere(
        (payment) => payment.paymentableId == booking.id,
        orElse: () => paymentModel.Payment(0, 0, "", "", "", "", '', 0, paymentModel.User("")),
      );

      return 
        relatedPayment.paymentStatus != "success";
    }).toList();

    setState(() {
      bookings = validBookings;
    });
  } catch (error) {
    print("Error fetching bookings or payments: $error");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  Future<void> fetchTrainers() async {
    String? token = await RememberUserPrefs.readAuthToken();
    userModel.User? userInfo = await RememberUserPrefs.readUserInfo();

    if (userInfo == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final trainerResponse = await http.get(
        Uri.parse('${dotenv.env['API_TRAINER']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (trainerResponse.statusCode != 200) {
        throw Exception('Failed to load trainers');
      }

      List<dynamic> trainerData = json.decode(trainerResponse.body);
      List<trainerModel.Trainer> allTrainers =
          trainerData.map((json) => trainerModel.Trainer.fromJson(json)).toList();

      final recommendationResponse = await http.get(
        Uri.parse('${dotenv.env['API_RECOMMENDATION']}${currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      List<trainerModel.Trainer> recommendedTrainers = [];

      if (recommendationResponse.statusCode == 200) {
        final recommendationData = json.decode(recommendationResponse.body);

        if (recommendationData.containsKey('trainers')) {
          List<dynamic> recommendedTrainerData = recommendationData['trainers'];

          recommendedTrainers = recommendedTrainerData
              .map((json) => trainerModel.Trainer.fromJson(json))
              .toList();
        }
      }
      setState(() {
        trainers = allTrainers;
        this.recommendedTrainers = recommendedTrainers;
        isLoading = false;
      });
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
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              Get.to(() => NotificationScreen());
            },
            child: badges.Badge(
              badgeContent: Text(
                bookings.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              showBadge: bookings.isNotEmpty,
              child: const Icon(Icons.notifications, size: 28),
            ),
          ),
        ),
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
                    imageUrl: "${dotenv.env['BASE_URL_API']}${trainer.picture}",
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
                    imageUrl: "${dotenv.env['BASE_URL_API']}${trainer.picture}",
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



/*   Future<void> fetchBooking() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await RememberUserPrefs.readAuthToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BOOKING']}member/${currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          bookings = data.map((json) => bookingModel.Booking.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (error) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
 */