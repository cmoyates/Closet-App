import 'package:closetapp/models/ClothingTypes.dart';

class OutfitsFields {
  static final List<String> values = [
    id, name, hatIndex, jacketIndex, pantsIndex, shirtIndex, shoesIndex
  ];

  static final String id = "_id";
  static final String name = "name";
  static final String hatIndex = "hatIndex";
  static final String jacketIndex = "jacketIndex";
  static final String pantsIndex = "pantsIndex";
  static final String shirtIndex = "shirtIndex";
  static final String shoesIndex = "shoesIndex";
}

class Outfits {
  final int? id;
  final String name;
  final Map<String, int> clothesIds;

  const Outfits({
    this.id,
    required this.name,
    required this.clothesIds
  });


  Outfits copy({
    int? id,
    String? name,
    Map<String, int>? clothesIds,
  }) {

    final Map <String, int> tempClothesIds = {};

    for (var i = 0; i < this.clothesIds.length; i++) {
      tempClothesIds[clothingTypes[i].title] = this.clothesIds[clothingTypes[i].title]!;
    }

    return Outfits(
      id: id ?? this.id,
      name: name ?? this.name,
      clothesIds: clothesIds ?? tempClothesIds,
    );
  }

    


  static Outfits fromJson(Map<String, Object?> json) => Outfits(
    id: json[OutfitsFields.id] as int?,
    name: json[OutfitsFields.name] as String,
    clothesIds: {
      "Hats": json[OutfitsFields.hatIndex] as int,
      "Jackets": json[OutfitsFields.jacketIndex] as int,
      "Pants": json[OutfitsFields.pantsIndex] as int,
      "Shirts": json[OutfitsFields.shirtIndex] as int,
      "Shoes": json[OutfitsFields.shoesIndex] as int,
    }
  );


  Map<String, Object?> toJson() => {
    OutfitsFields.id: id,
    OutfitsFields.name: name,
    OutfitsFields.hatIndex: clothesIds[clothingTypes[0].title],
    OutfitsFields.jacketIndex: clothesIds[clothingTypes[1].title],
    OutfitsFields.pantsIndex: clothesIds[clothingTypes[2].title],
    OutfitsFields.shirtIndex: clothesIds[clothingTypes[3].title],
    OutfitsFields.shoesIndex: clothesIds[clothingTypes[4].title],
  };
}