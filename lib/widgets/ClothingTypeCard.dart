import 'package:flutter/material.dart';
import 'package:closetapp/models/ClothingTypes.dart';

class ClothingTypeCard extends StatelessWidget {
  // The type of clothing being shown by the card
  final ClothingType clothingType;
  // The function that will run when the card is "pressed" (tapped)
  final Function onPress;

  const ClothingTypeCard({Key? key, required this.clothingType, required this.onPress}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black45, BlendMode.multiply),
              child: Image.asset(
              clothingType.image,
              width: 420,
              height: 420,
              fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Text(
                clothingType.title,
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white
                ),
              )
            )
          ]
        ),
      ),
      onTap: () => {onPress()},
    );
  }
}