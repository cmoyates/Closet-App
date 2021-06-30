class ClothesFields {
  static final List<String> values = [
    id, name, image
  ];

  static final String id = "_id";
  static final String name = "name";
  static final String image = "image";
}


class Clothes {
  final int? id;
  final String name;
  final String image;

  const Clothes({
    this.id,
    required this.name,
    required this.image,
  });


  Clothes copy({
    int? id,
    String? name,
    String? image,
  }) =>
    Clothes(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
    );


  static Clothes fromJson(Map<String, Object?> json) => Clothes(
    id: json[ClothesFields.id] as int?,
    name: json[ClothesFields.name] as String,
    image: json[ClothesFields.image] as String,
  );


  Map<String, Object?> toJson() => {
    ClothesFields.id: id,
    ClothesFields.name: name,
    ClothesFields.image: image
  };

  static Clothes noneClothes = Clothes(
    name: "None",
    image: "assets/images/none.jpg"
  );
}