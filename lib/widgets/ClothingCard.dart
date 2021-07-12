import 'dart:io';
import 'package:closetapp/models/Clothes.dart';
import 'package:flutter/material.dart';

class ClothingCard extends StatelessWidget {
  const ClothingCard({Key? key, required this.clothes, required this.onCardLongPressed, required this.onCardTapped}) : super(key: key);
  // The item of clothing that the card is displaying
  final Clothes clothes;
  // Callbacks so that some functions can be passed as arguments
  final VoidCallback onCardLongPressed, onCardTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          child: Card(
            child: Stack(
              children: [
                (clothes.image == "assets/images/none.jpg") ? 
                Image.asset(clothes.image,
                  fit: BoxFit.cover,
                  width: 420,
                  height: 420,
                ) : Image.file(File(clothes.image),
                  fit: BoxFit.cover,
                  width: 420,
                  height: 420,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(clothes.name),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            // Run the tapped function when the card is tapped
            onCardTapped();
          },
          onLongPress: () {
            // Run the long pressed function when the card is "long pressed"
            onCardLongPressed();
          },
        );
  }
}