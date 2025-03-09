import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/user.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  List<Map<String, dynamic>> trainingFocus = [];
  List<int> selectedIds = [];
  User? userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchTrainingFocus();
  }

  Future<void> _loadUser() async {
    User? storedUser = await RememberUserPrefs.readUserInfo();
    setState(() {
      userInfo = storedUser;
    });
  }

  Future<void> _fetchTrainingFocus() async {
    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_TRAINING_FOCUS']}'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          trainingFocus = data
              .map((item) => {
                    "id": item["id"] ?? 0,
                    "name": item["name"] ?? '',
                    "picture": item["picture"] ?? '',
                  })
              .toList();
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

  void _toggleSelection(int id) {
  setState(() {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      if (selectedIds.length < 3) {
        selectedIds.add(id);
      } else {
        Get.snackbar("Peringatan!", "Kamu hanya bisa memilih max. 3 refrensi otot");
      }
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Pilihan Anda",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trainingFocus.isEmpty
              ? const Center(child: Text("No data available"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: trainingFocus.length,
                          itemBuilder: (context, index) {
                            final item = trainingFocus[index];
                            final isSelected = selectedIds.contains(item['id']);

                            return GestureDetector(
                                onTap: () =>
                                    _toggleSelection(item['id'] as int),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  elevation: 4,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: item['picture'] != null &&
                                                    item['picture'].isNotEmpty
                                                ? Image.network(
                                                    '${dotenv.env['BASE_URL_API']}' +
                                                        item['picture'],
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                        'assets/images/placehold.png',
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.asset(
                                                    'assets/images/placehold.png', 
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                          )),
                                      if (isSelected)
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                        ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 77,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  item['name'].toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
          child: SizedBox(
            height: 45,
            child: ElevatedButton(
              onPressed: selectedIds.isNotEmpty ? _confirmRecommendation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF68989),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                "GO!",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRecommendation() async {
    if (userInfo != null) {
      await RememberUserPrefs.setRecommendationChosen(
          userInfo!.id.toString(), true);
      await RememberUserPrefs.setRecommendation(
          userInfo!.id.toString(), selectedIds);
      Get.offAll(() => const Layout());
    } else {
      Get.snackbar("Error", "User data not found.");
    }
  }
}
