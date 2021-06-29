import 'package:flutter/material.dart';

class ClothingType {
  final String image, title;
  final int id;

  ClothingType({
    required this.image,
    required this.title,
    required this.id
  });
}

List<ClothingType> clothingTypes = [
  ClothingType(
    id: 0,
    image: "assets/images/hats.jpg",
    title: "Hats"
  ),
  ClothingType(
    id: 1,
    image: "assets/images/jackets.jpg",
    title: "Jackets"
  ),
  ClothingType(
    id: 2,
    image: "assets/images/pants.jpg",
    title: "Pants"
  ),
  ClothingType(
    id: 3,
    image: "assets/images/shirts.jpg",
    title: "Shirts"
  ),
  ClothingType(
    id: 4,
    image: "assets/images/shoes.jpg",
    title: "Shoes"
  ),
];