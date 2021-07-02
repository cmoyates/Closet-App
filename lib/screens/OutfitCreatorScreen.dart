import 'dart:io';
import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/models/Clothes.dart';
import 'package:flutter/material.dart';
import 'package:closetapp/models/ClothingTypes.dart';
import 'package:closetapp/models/Outfits.dart';
import 'package:flutter/services.dart';

class OutfitCreatorScreen extends StatefulWidget {
  OutfitCreatorScreen({Key? key}) : super(key: key);

  static const valueKey = ValueKey("OutfitCreatorScreen");

  @override
  _OutfitCreatorScreenState createState() => _OutfitCreatorScreenState();
}

class _OutfitCreatorScreenState extends State<OutfitCreatorScreen> {

  late List<Clothes> clothesList = [];
  List<int> totalOutfit = [];

  int clothingTypeCount = 0;
  int currentClothingType = 3;
  List<int> clothingTypeOrder = [3, 2, 4, 1, 0];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshClothes();
  }

  Future refreshClothes() async {
    setState(() => isLoading = true);

    this.clothesList = await ClothesDatabase.instance.readAllClothes(clothingTypes[currentClothingType].title);
    if (clothingTypeCount > 2)
      this.clothesList.insert(0, Clothes.noneClothes);

    setState(() => isLoading = false);
  }

  showSnackBar(stringToShow) {
    SnackBar sb = SnackBar(content: Text(stringToShow));
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }

  createAlertDialog(BuildContext context) async {

    TextEditingController customController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

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
              if (!_formKey.currentState!.validate()) {return;}
              Navigator.of(context).pop(customController.text.toString());
            },
            elevation: 5.0,
            child: Text("Submit"),
          )
        ],
      );
    });
  }

  addClothingToOutfit(index) async {
    totalOutfit.add((clothesList[index].name == "None") ? -1 : clothesList[index].id!);
    clothingTypeCount++;
    if (clothingTypeCount < clothingTypes.length) {
      currentClothingType = clothingTypeOrder[clothingTypeCount];
      await refreshClothes();
      return null;
    }
    else {
      final String? outfitName = await createAlertDialog(context);
      if (outfitName == null) {showSnackBar("Cancelled"); return null;}
      final outfit = Outfits(
        name: outfitName,
        hatIndex: totalOutfit[4],
        jacketIndex: totalOutfit[3],
        pantsIndex: totalOutfit[1],
        shirtIndex: totalOutfit[0],
        shoesIndex: totalOutfit[2]
      );
      await ClothesDatabase.instance.createOutfits(outfit);
      return outfitName;
    }
  }

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
        itemBuilder: (context, index) => GestureDetector(
          child: Card(
            child: Stack(
              children: [
                (clothesList[index].name == "None") ? 
                Image.asset(clothesList[index].image,
                  fit: BoxFit.cover,
                  width: 420,
                  height: 420,
                ) : Image.file(File(clothesList[index].image),
                  fit: BoxFit.cover,
                  width: 420,
                  height: 420,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(clothesList[index].name),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          onTap: () async {
            final String? outfitName = await addClothingToOutfit(index);
            if (clothingTypeCount >= clothingTypes.length) {
              final bool success = outfitName != null;
              if (success){
                showSnackBar("Created outfit: $outfitName");
              }
              Navigator.pop(context, success);
            }
          },
        )
      )
    );
  }
}