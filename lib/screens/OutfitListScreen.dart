import 'dart:io';

import 'package:flutter/material.dart';
import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/models/Outfits.dart';
import 'package:closetapp/models/Clothes.dart';

class OutfitListScreen extends StatefulWidget {
  const OutfitListScreen({Key? key}) : super(key: key);

  static const valueKey = ValueKey("OutfitListScreen");

  @override
  _OutfitListScreenState createState() => _OutfitListScreenState();
}

class _OutfitListScreenState extends State<OutfitListScreen> {

  late List<Outfits> allOutfits = [];
  bool isLoading = false;
  late List<bool> _isOpen = [];
  late List<List<Clothes>> allClothes = [];

  @override
  void initState() {
    super.initState();

    refreshOutfits();
  }

  Future refreshOutfits() async {
    setState(() => isLoading = true);

    this.allOutfits = await ClothesDatabase.instance.readAllOutfits();

    setState(() {
      for (var i = 0; i < allOutfits.length; i++) {
        _isOpen.add(false);
      }
    });

    await loadClothingItems();

    setState(() => isLoading = false);
  }

  Future loadClothingItems() async {
    List<List<Clothes>> allClothesList = [];
    
    for (var i = 0; i < allOutfits.length; i++) {
      print(i);
        List<Clothes> clothesList = [];

        if (allOutfits[i].clothesIds["Hats"] != -1) {
          print("Hat");
          Clothes hat = await ClothesDatabase.instance.readClothes("Hats", allOutfits[i].clothesIds["Hats"]!);
          clothesList.add(hat);
        }
        print("Shirt");
        Clothes shirt = await ClothesDatabase.instance.readClothes("Shirts", allOutfits[i].clothesIds["Shirts"]!);
        clothesList.add(shirt);
        if (allOutfits[i].clothesIds["Jackets"] != -1) {
          print("Jacket");
          Clothes jacket = await ClothesDatabase.instance.readClothes("Jackets", allOutfits[i].clothesIds["Jackets"]!);
          clothesList.add(jacket);
        }
        print("Pants");
        Clothes pants = await ClothesDatabase.instance.readClothes("Pants", allOutfits[i].clothesIds["Pants"]!);
        clothesList.add(pants);
        print("Shoes");
        Clothes shoes = await ClothesDatabase.instance.readClothes("Shoes", allOutfits[i].clothesIds["Shoes"]!);
        clothesList.add(shoes);

        allClothesList.add(clothesList);
      }

    setState(() {
      allClothes = allClothesList;
    });
  }

  showContextMenu(BuildContext context, int index) async {
    return await showDialog(context: context, builder: (context) { return AlertDialog(
      title: Center(child: Text(allOutfits[index].name)),
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      actions: [
        MaterialButton(
          child: Text("Rename"),
          onPressed: () {
            Navigator.pop(context);
            showRenamePopup(context, index);
          },
        ),
        MaterialButton(
          child: Text("Delete"),
          onPressed: () {
            Navigator.pop(context);
            showDeleteConfimation(context, index);
          },
        ),
      ],
    );});
  }

  showRenamePopup(BuildContext context, int index) async {

    TextEditingController customController = TextEditingController();
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
            if (!_formKey.currentState!.validate()) {return;}
            
            Outfits tempOutfit = allOutfits[index].copy(name: customController.text);

            await ClothesDatabase.instance.updateOutfits(tempOutfit);

            await refreshOutfits();

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
            await ClothesDatabase.instance.deleteOutfits(allOutfits[index].id!);

            await refreshOutfits();

            Navigator.pop(context);
          }
        ),
        MaterialButton(
          child: Text("No"),
          onPressed: () {
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
                  children: allClothes[index].map((item) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "    ${item.name}",
                          style: TextStyle(
                            fontSize: 16
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Image.file(
                          File(item.image),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    ],
                  )).toList(),
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