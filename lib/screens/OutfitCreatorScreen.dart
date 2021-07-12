import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/models/Clothes.dart';
import 'package:closetapp/widgets/ClothingCard.dart';
import 'package:flutter/material.dart';
import 'package:closetapp/models/ClothingTypes.dart';
import 'package:closetapp/models/Outfits.dart';

class OutfitCreatorScreen extends StatefulWidget {
  OutfitCreatorScreen({Key? key}) : super(key: key);

  // The key used by the navigator
  static const valueKey = ValueKey("OutfitCreatorScreen");

  @override
  _OutfitCreatorScreenState createState() => _OutfitCreatorScreenState();
}

class _OutfitCreatorScreenState extends State<OutfitCreatorScreen> {
  // List of the clothes currently being shown
  late List<Clothes> clothesList = [];
  // List of clothing IDs for the selected clothing
  List<int> totalOutfit = [];
  // Some stuff to make sure the clothing gets added in a specific order
  int currentClothingType = 3;
  List<int> clothingTypeOrder = [3, 2, 4, 1, 0];
  // Loading bool for refreshing the clothes
  bool isLoading = false;

  // Refresh the clothes being shown when the screen loads
  @override
  void initState() {
    super.initState();

    refreshClothes();
  }

  Future refreshClothes() async {
    setState(() => isLoading = true);

    // Load in the new type of clothes to be displayed
    this.clothesList = await ClothesDatabase.instance.readAllClothes(clothingTypes[currentClothingType].title);
    // If it's after the first 3 types, add a "none" option
    if (totalOutfit.length > 2)
      this.clothesList.insert(0, Clothes.noneClothes);

    setState(() => isLoading = false);
  }

  // This is a utility function that shows messages at the bottom of the app
  showSnackBar(stringToShow) {
    SnackBar sb = SnackBar(content: Text(stringToShow));
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }

  // Shows the outfit name dialog
  outfitNameDialog(BuildContext context) async {
    // This is the controller for the text form
    TextEditingController customController = TextEditingController();
    // This is the key used for validating the form
    final _formKey = GlobalKey<FormState>();
    // This is what's actually shown
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Name this outfit:"),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: customController,
            autofocus: true,
            validator: (value) => (value == null || value.isEmpty) ? "Outfit name cannot be blank" : null,
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              // If the form is not valid do nothing
              if (!_formKey.currentState!.validate()) {return;}
              // Otherwise close the current popup and return the text as the "result"
              Navigator.of(context).pop(customController.text.toString());
            },
            elevation: 5.0,
            child: Text("Submit"),
          )
        ],
      );
    });
  }

  // Adds clothing to the outfit
  addClothingToOutfit(index) async {
    // If the name of the clothing is "None" add the ID of -1, otherwise add the id of the clothing
    totalOutfit.add((clothesList[index].name == "None") ? -1 : clothesList[index].id!);
    // If the user has not been asked to add a piece of clothing of every type
    if (totalOutfit.length < clothingTypes.length) {
      // Set the clothing type to the next one in the specified order, refresh clothing and return null
      currentClothingType = clothingTypeOrder[totalOutfit.length];
      await refreshClothes();
      return null;
    }
    else {
      // Get the user to name the outfit
      final String? outfitName = await outfitNameDialog(context);
      // If the name was null show "Cancelled" and return null
      if (outfitName == null) {showSnackBar("Cancelled"); return null;}
      // Create an outfit object with all of the clothes IDs from the list
      final outfit = Outfits(
        name: outfitName,
        clothesIds: {
          "Hats": totalOutfit[4],
          "Jackets": totalOutfit[3],
          "Pants": totalOutfit[1],
          "Shirts": totalOutfit[0],
          "Shoes": totalOutfit[2]
        },
      );
      // Add that outfit to the database and return the name
      await ClothesDatabase.instance.createOutfits(outfit);
      return outfitName;
    }
  }

  // The stuff that is actually shown
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create an Outfit: ${clothingTypes[currentClothingType].title}"),
      ),
      body: GridView.builder(
        itemCount: clothesList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) => ClothingCard(
          clothes: clothesList[index],
          onCardLongPressed: () {},
          onCardTapped: () async {
            // Get the string returned from adding the piece of clothing
            final String? outfitName = await addClothingToOutfit(index);
            // If all of the clothing has been added
            if (totalOutfit.length >= clothingTypes.length) {
              // Show a message containing the name of the outfit if successful
              final bool success = outfitName != null;
              if (success){
                showSnackBar("Created outfit: $outfitName");
              }
              // Go back to the previous screen, returning whenther or not the outfit creation was successful
              Navigator.pop(context, success);
            }
          }
        )
      )
    );
  }
}