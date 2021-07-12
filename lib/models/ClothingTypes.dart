// The clothing type class
class ClothingType {
  final String image, title, singular;
  final int id;

  ClothingType({
    required this.image,
    required this.title,
    required this.singular,
    required this.id
  });
}

// A list of all of the currently supported clothing types
List<ClothingType> clothingTypes = [
  ClothingType(
    id: 0,
    image: "assets/images/hats.jpg",
    title: "Hats",
    singular: "Hat",
  ),
  ClothingType(
    id: 1,
    image: "assets/images/jackets.jpg",
    title: "Jackets",
    singular: "Jacket",
  ),
  ClothingType(
    id: 2,
    image: "assets/images/pants.jpg",
    title: "Pants",
    singular: "Pair of Pants",
  ),
  ClothingType(
    id: 3,
    image: "assets/images/shirts.jpg",
    title: "Shirts",
    singular: "Shirt",
  ),
  ClothingType(
    id: 4,
    image: "assets/images/shoes.jpg",
    title: "Shoes",
    singular: "Pair of Shoes",
  ),
];

// A clothing type object to be used by the "Outfits" button on the home screen
final ClothingType outfitsClothingType = ClothingType(
  image: "assets/images/outfits.jpg", 
  title: "Outfits", 
  singular: "Outfit", 
  id: -11
);