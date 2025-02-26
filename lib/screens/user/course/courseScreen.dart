import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/models/courseByUserId.dart';
import 'package:semesta_gym/models/trainingFocus.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/preferences/currentUser.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/course/trainingCourse.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final CurrentUser currentUser = Get.put(CurrentUser());

  List<TrainingFocus> trainingFocus = [];
  List<CourseByUserId> courseUser = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchCourseByUserId();
      await fetchTrainingFocus();
    });
  }

  Future<void> fetchCourseByUserId() async {
    String? token = await RememberUserPrefs.readAuthToken();

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/courses/user/${currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          courseUser = data.isNotEmpty
              ? data.map((json) => CourseByUserId.fromJson(json)).toList()
              : [];
          isLoading = false;
        });

        if (courseUser.isNotEmpty) {
          print("endDate last array list: ${courseUser.last.endDate}");
        } else {
          print("No courses available for this user.");
        }
      } else {
        print("Error: ${response.body}");
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        courseUser = [];
      });
      Get.snackbar("Error", "Failed to load Course User");
    }
  }

  Future<void> fetchTrainingFocus() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/training-focus'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          trainingFocus =
              data.map((json) => TrainingFocus.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Error", "Failed to load training focus data");
    }
  }

  bool isCourseExpired() {
    if (courseUser.isEmpty) return true;

    try {
      DateTime endDate = DateTime.parse(courseUser.last.endDate);
      return endDate.isBefore(DateTime.now());
    } catch (e) {
      print("Error parsing endDate: $e");
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool expired = isCourseExpired();

    return Scaffold(
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        title: const Text(
          "Course",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Expired",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      child: Center(
                        child: Text(
                          courseUser.isNotEmpty ? courseUser.last.endDate : "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: trainingFocus.length,
                    itemBuilder: (context, index) {
                      final trainingFocusData = trainingFocus[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => TrainingCourseScreen(),
                                  arguments: trainingFocusData);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 160,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        "http://10.0.2.2:3000/${trainingFocusData.picture}"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    trainingFocusData.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Modal Overlay
          if (expired) ...[
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 52,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Belum Berlangganan Course?",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Course expired / belum berlangganan silahkan cek terlebih dahulu sebelum melakukan pembayaran",
                      style: TextStyle(fontSize: 14, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "1 Bulan Course\nRp. 20.000",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: Text("Bayar", style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF82ACEF),
      appBar: AppBar(
        title: const Text(
          "Course",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : trainingFocus.isEmpty
              ? Center(child: Text("Tidak ada list course"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Expired",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Center(
                              child: Text(
                                courseUser.isNotEmpty
                                    ? courseUser.last.endDate
                                    : "-",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: trainingFocus.length,
                          itemBuilder: (context, index) {
                            final trainingFocusData = trainingFocus[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => TrainingCourseScreen(),
                                        arguments: trainingFocusData);
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 160,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              "http://10.0.2.2:3000/${trainingFocusData.picture}"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          trainingFocusData.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(2, 2),
                                                blurRadius: 4,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 14,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
} */

/*   Future<void> _fetchCoursesByUserId() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/user/${currentUser.user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
        user = User.fromJson(data);
        isLoading = false;
      });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Error", "Failed to load user data");
    }
  }
 */
