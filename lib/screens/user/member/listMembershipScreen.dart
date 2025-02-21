import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:semesta_gym/models/membership.dart';
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:http/http.dart' as http;

class ListMembershipScreen extends StatefulWidget {
  const ListMembershipScreen({super.key});

  @override
  State<ListMembershipScreen> createState() => _ListMembershipScreenState();
}

class _ListMembershipScreenState extends State<ListMembershipScreen> {
  bool isLoading = true;
  List<Membership> membership = [];
  int? _selectedMembershipId; 

  @override
  void initState() {
    super.initState();
    fetchMembership();
  }

  Future<void> fetchMembership() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/memberships'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          membership = data.map((json) => Membership.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load membership');
      }
    } catch (error) {
      print("Error fetching membership: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  //POST Register user membership
  
  //Payment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF82ACEF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "List Membership",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : membership.isEmpty
              ? Center(child: Text("Tidak ada list membership"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: membership.length,
                          itemBuilder: (context, index) {
                            final member = membership[index];
                            bool isSelected =
                                member.id == _selectedMembershipId;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMembershipId =
                                      (_selectedMembershipId == member.id)
                                          ? null
                                          : member.id;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected
                                      ? Colors.green[300]
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(4, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                member.name,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                "Rp. ${NumberFormat('#,###').format(member.price)}",
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _selectedMembershipId =
                                                    (value == true)
                                                        ? member.id
                                                        : null;
                                              });
                                            },
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 32),
        child: ElevatedButton(
          onPressed: _selectedMembershipId == null
              ? null
              : () {
                  if (_selectedMembershipId != null) {
                    print("Selected Memberships: $_selectedMembershipId");
                  } else {
                    print("No membership selected.");
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            disabledBackgroundColor: Colors.grey.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Bayar",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
