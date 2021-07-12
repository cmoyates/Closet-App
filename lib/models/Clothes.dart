// A class that stores all of the field names to be used when doing SQL queries involving clothes
class ClothesFields {
  static final List<String> values = [
    id, name, image
  ];

  static final String id = "_id";
  static final String name = "name";
  static final String image = "image";
}

// The actual Clothes class
class Clothes {
  final int? id;
  final String name;
  final String image;

  const Clothes({
    this.id,
    required this.name,
    required this.image,
  });

  // Makes a copy of the Clothes object with any specified fields replaced
  Clothes copy({int? id, String? name, String? image}) =>
    // If any of the parameters are not null replace the values when making the copy
    Clothes(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
    );

  // A converter from JSON to a Clothes object
  static Clothes fromJson(Map<String, Object?> json) => Clothes(
    id: json[ClothesFields.id] as int?,
    name: json[ClothesFields.name] as String,
    image: json[ClothesFields.image] as String,
  );

  // A converter from a Clothes object to JSON
  Map<String, Object?> toJson() => {
    ClothesFields.id: id,
    ClothesFields.name: name,
    ClothesFields.image: image
  };

  // An object to be used for the "None" option when creating an outfit
  static Clothes noneClothes = Clothes(
    name: "None",
    image: "assets/images/none.jpg"
  );
}