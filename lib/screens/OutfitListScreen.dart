import 'package:closetapp/widgets/OutfitListClothing.dart';
import 'package:flutter/material.dart';
import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/models/Outfits.dart';
import 'package:closetapp/models/Clothes.dart';

class OutfitListScreen extends StatefulWidget {
  const OutfitListScreen({Key? key}) : super(key: key);
  // The key used by the navigator
  static const valueKey = ValueKey("OutfitListScreen");

  @override
  _OutfitListScreenState createState() => _OutfitListScreenState();
}

class _OutfitListScreenState extends State<OutfitListScreen> {

  // Lists of outfits, clothes for the outfits, and whether any given outfits panel is expanded
  late List<Outfits> allOutfits = [];
  late List<List<Clothes>> allClothes = [];
  late List<bool> _isOpen = [];
  // Loading bool for refreshing the outfits
  bool isLoading = false;

  // Refresh the outfits when the screen loads
  @override
  void initState() {
    super.initState();

    refreshOutfits();
  }

  // Refresh the outfits
  Future refreshOutfits() async {
    setState(() => isLoading = true);

    // Load in all outfits
    this.allOutfits = await ClothesDatabase.instance.readAllOutfits();

    // Set all bools in the open list to false (closing all expanding panels)
    // It is done like this to account for the fact that the length of the open list could change
    setState(() {
      _isOpen = [];
      for (var i = 0; i < allOutfits.length; i++) {
        _isOpen.add(false);
      }
    });

    // Load in all of the clothing items from all of the outfits
    await loadClothingItems();

    setState(() => isLoading = false);
  }

  Future loadClothingItems() async {
    // An empty list of lists of clothes
    List<List<Clothes>> allClothesList = [];
    
    for (var i = 0; i < allOutfits.length; i++) {
        // Make an empty list of clothes 
        List<Clothes> clothesList = [];
        // Load in the hat for the outfit if there is one
        if (allOutfits[i].clothesIds["Hats"] != -1) {
          Clothes hat = await ClothesDatabase.instance.readClothes("Hats", allOutfits[i].clothesIds["Hats"]!);
          clothesList.add(hat);
        }
        // Load in the shirt
        Clothes shirt = await ClothesDatabase.instance.readClothes("Shirts", allOutfits[i].clothesIds["Shirts"]!);
        clothesList.add(shirt);
        // Load in the jacket if there is one
        if (allOutfits[i].clothesIds["Jackets"] != -1) {
          Clothes jacket = await ClothesDatabase.instance.readClothes("Jackets", allOutfits[i].clothesIds["Jackets"]!);
          clothesList.add(jacket);
        }
        // Load in the pants and shoes
        Clothes pants = await ClothesDatabase.instance.readClothes("Pants", allOutfits[i].clothesIds["Pants"]!);
        clothesList.add(pants);
        Clothes shoes = await ClothesDatabase.instance.readClothes("Shoes", allOutfits[i].clothesIds["Shoes"]!);
        clothesList.add(shoes);

        // Add the list to the list of lists
        allClothesList.add(clothesList);
      }

    // Set the list of lists in the state
    setState(() {
      allClothes = allClothesList;
    });
  }

  // Show the "context menu"
  showContextMenu(BuildContext context, int index) async {
    return await showDialog(context: context, builder: (context) { return AlertDialog(
      title: Center(child: Text(allOutfits[index].name)),
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      actions: [
        MaterialButton(
          child: Text("Rename"),
          onPressed: () {
            // Close the current popup and open the rename popup
            Navigator.pop(context);
            showRenamePopup(context, index);
          },
        ),
        MaterialButton(
          child: Text("Delete"),
          onPressed: () {
            // Close the current popup and open the delete confirmation popup
            Navigator.pop(context);
            showDeleteConfimation(context, index);
          },
        ),
      ],
    );});
  }

  showRenamePopup(BuildContext context, int index) async {
    // This is the controller for the text form
    TextEditingController customController = TextEditingController();
    // This is the key used for validating the form
    final _formKey = GlobalKey<FormState>();
    
    return await showDialog(context: context, builder: (context) {return AlertDialog(
      title: Text("Rename ${allOutfits[index].name}:"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: customController,
          autofocus: true,
          validator: (value) => (value == null || value.isEmpty) ? "Name cannot be blank" : null,
        )
      ),
      actions: [
        MaterialButton(
          child: Text("Submit"),
          onPressed: () async {
            // If the form text is not valid do nothing
            if (!_formKey.currentState!.validate()) {return;}
            // Create a copy of the outfit you're renaming and give it the new name
            Outfits tempOutfit = allOutfits[index].copy(name: customController.text);
            // Update the entry in the database and refresh the outfits shown
            await ClothesDatabase.instance.updateOutfits(tempOutfit);
            await refreshOutfits();
            // Close current popup
            Navigator.pop(context);
          }
        )
      ],
    );});
  }

  showDeleteConfimation(context, index) async {
    return await showDialog(context: context, builder: (context) {return AlertDialog(
      title: Text("Are you sure you want to delete ${allOutfits[index].name}?"),
      actions: [
        MaterialButton(
          child: Text("Yes"),
          onPressed: () async {
            // Delete the outfit from the database
            await ClothesDatabase.instance.deleteOutfits(allOutfits[index].id!);
            // Refresh the outfits being shown and close the current popup
            await refreshOutfits();
            Navigator.pop(context);
          }
        ),
        MaterialButton(
          child: Text("No"),
          onPressed: () {
            // Close the current popup
            Navigator.pop(context);
          }
        ),
      ],
    );});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Outfit List"),
      ),
      body: (allOutfits.isEmpty) ? Center(
        child: Text(
          "You haven't added any outfits yet!",
          style: TextStyle(
            fontSize: 20
          ),
        ),
      ): 
      ListView(
        children: [
          (allClothes.length != 0) ? 
          ExpansionPanelList.radio(
            expandedHeaderPadding: EdgeInsets.zero,
            children: allOutfits.map((outfit) {
              final int index = allOutfits.indexOf(outfit);
              return ExpansionPanelRadio(
                value: index,
                headerBuilder: (context, isExpanded) => GestureDetector(
                  onLongPress: () async {
                    await showContextMenu(context, index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      outfit.name,
                      style: TextStyle(
                        fontSize: 22
                      ),
                    ),
                  ),
                ),
                body: Column(
                  children: allClothes[index].map((item) => OutfitListClothing(item: item)).toList(),
                ),
                canTapOnHeader: true,
              );
            }).toList(),
            expansionCallback: (index, isOpen) => setState(() => _isOpen[index] = !isOpen),
          ) : 
          Container()
        ],
      )
    );
  }
}