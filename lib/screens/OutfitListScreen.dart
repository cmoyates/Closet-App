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
    print("Loading all clothes");
    List<List<Clothes>> allClothesList = [];
    
    for (var i = 0; i < allOutfits.length; i++) {
        print("Outfit $i");
        List<Clothes> clothesList = [];

        if (allOutfits[i].hatIndex != -1) {
          print("hat");
          Clothes hat = await ClothesDatabase.instance.readClothes("Hats", allOutfits[i].hatIndex);
          clothesList.add(hat);
        }
        print("shirt");
        Clothes shirt = await ClothesDatabase.instance.readClothes("Shirts", allOutfits[i].shirtIndex);
        clothesList.add(shirt);
        if (allOutfits[i].hatIndex != -1) {
          print("jacket");
          Clothes jacket = await ClothesDatabase.instance.readClothes("Jackets", allOutfits[i].jacketIndex);
          clothesList.add(jacket);
        }
        print("pants");
        Clothes pants = await ClothesDatabase.instance.readClothes("Pants", allOutfits[i].pantsIndex);
        clothesList.add(pants);
        print("shoes");
        Clothes shoes = await ClothesDatabase.instance.readClothes("Shoes", allOutfits[i].shoesIndex);
        clothesList.add(shoes);

        allClothesList.add(clothesList);
      }

    setState(() {
      allClothes = allClothesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Outfit List"),
      ),
      body: ListView(
        children: [
          (allClothes.length != 0) ? 
          ExpansionPanelList.radio(
            expandedHeaderPadding: EdgeInsets.zero,
            children: allOutfits.map((outfit) {
              final int index = allOutfits.indexOf(outfit);
              return ExpansionPanelRadio(
                value: index,
                headerBuilder: (context, isExpanded) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    outfit.name,
                    style: TextStyle(
                      fontSize: 22
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
                //isExpanded: (_isOpen.length == 0) ? false : _isOpen[index],
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