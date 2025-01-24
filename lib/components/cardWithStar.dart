import 'package:flutter/material.dart';

class Cardwithstar extends StatelessWidget {
  final String name;
  final String rating;
  final String imageUrl;
  final VoidCallback onTap;
  
  const Cardwithstar({
    Key? key,
    required this.name,
    required this.rating,
    required this.imageUrl,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 5.0,
        margin: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                SizedBox(height: 5,),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow,),
                    SizedBox(width: 8,),
                    Text(rating, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)
                  ],
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}