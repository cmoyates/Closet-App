import 'package:closetapp/models/ClothingTypes.dart';

// A class that stores all of the field names to be used when doing SQL queries involving outfits
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

// The actual outfit class
class Outfits {
  final int? id;
  final String name;
  final Map<String, int> clothesIds;

  const Outfits({
    this.id,
    required this.name,
    required this.clothesIds
  });

  // Makes a copy of an Outfit object with any specified fields replaced
  Outfits copy({int? id, String? name, Map<String, int>? clothesIds}) {
    // An empty map from string to int
    final Map <String, int> tempClothesIds = {};
    // Makes a deep copy from the Outfit object
    for (var i = 0; i < this.clothesIds.length; i++) {
      tempClothesIds[clothingTypes[i].title] = this.clothesIds[clothingTypes[i].title]!;
    }
    // If any of the parameters are not null replace the values when making the copy
    return Outfits(
      id: id ?? this.id,
      name: name ?? this.name,
      clothesIds: clothesIds ?? tempClothesIds,
    );
  }

    

  // A converter from JSON to an Outfit object
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

  // A converter from an Outfit object to JSON
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