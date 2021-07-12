import 'dart:io';
import 'package:closetapp/models/Clothes.dart';
import 'package:flutter/material.dart';

class OutfitListClothing extends StatelessWidget {
  const OutfitListClothing({Key? key, required this.item}) : super(key: key);
  // The clothes object that is being shown
  final Clothes item;
  // The stuff that's actually being shown
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "    ${item.name}",
            style: TextStyle(
              fontSize: 16
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Image.file(
            File(item.image),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        )
      ],
    );
  }
}