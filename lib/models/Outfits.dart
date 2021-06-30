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
  final int hatIndex;
  final int jacketIndex;
  final int pantsIndex;
  final int shirtIndex;
  final int shoesIndex;

  const Outfits({
    this.id,
    required this.name,
    required this.hatIndex,
    required this.jacketIndex,
    required this.pantsIndex,
    required this.shirtIndex,
    required this.shoesIndex,
  });


  Outfits copy({
    int? id,
    String? name,
    int? hatIndex,
    int? jacketIndex,
    int? pantsIndex,
    int? shirtIndex,
    int? shoesIndex,
  }) =>
    Outfits(
      id: id ?? this.id,
      name: name ?? this.name,
      hatIndex: hatIndex ?? this.hatIndex,
      jacketIndex: jacketIndex ?? this.jacketIndex,
      pantsIndex: pantsIndex ?? this.pantsIndex,
      shirtIndex: shirtIndex ?? this.shirtIndex,
      shoesIndex: shoesIndex ?? this.shoesIndex,
    );


  static Outfits fromJson(Map<String, Object?> json) => Outfits(
    id: json[OutfitsFields.id] as int?,
    name: json[OutfitsFields.name] as String,
    hatIndex: json[OutfitsFields.hatIndex] as int,
    jacketIndex: json[OutfitsFields.jacketIndex] as int,
    pantsIndex: json[OutfitsFields.pantsIndex] as int,
    shirtIndex: json[OutfitsFields.shirtIndex] as int,
    shoesIndex: json[OutfitsFields.shoesIndex] as int,
  );


  Map<String, Object?> toJson() => {
    OutfitsFields.id: id,
    OutfitsFields.name: name,
    OutfitsFields.hatIndex: hatIndex,
    OutfitsFields.jacketIndex: jacketIndex,
    OutfitsFields.pantsIndex: pantsIndex,
    OutfitsFields.shirtIndex: shirtIndex,
    OutfitsFields.shoesIndex: shoesIndex,
  };
}