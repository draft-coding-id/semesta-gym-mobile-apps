import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/layout.dart';

class DetailTrainer extends StatefulWidget {
  const DetailTrainer({super.key});

  @override
  State<DetailTrainer> createState() => _DetailTrainerState();
}

class _DetailTrainerState extends State<DetailTrainer> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? trainer = Get.arguments;

    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("${trainer?['imageUrl']}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )),
                backgroundColor:
                    innerBoxIsScrolled ? Colors.white : Colors.transparent,
                elevation: innerBoxIsScrolled ? 4 : 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: innerBoxIsScrolled
                          ? Colors.transparent
                          : Color.fromARGB(50, 0, 0, 0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: innerBoxIsScrolled ? Colors.black : Colors.white,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trainer?['name']}',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GridView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.fitness_center_rounded),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      "Fokus",
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.phone),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      "No. Handphone",
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.schedule),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      "Jadwal",
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('WINGS, SHOULDER, LEG',style: TextStyle(fontSize: 16),),  SizedBox(height: 8,),
                                Text('086256xxxxxx', style: TextStyle(fontSize: 16),), SizedBox(height: 8,),
                                Text('17.00 - 21.00', style: TextStyle(fontSize: 16),)
                              ],
                            )
                          ],
                        ),
                        
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
