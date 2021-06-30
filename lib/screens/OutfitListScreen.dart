import 'package:flutter/material.dart';
import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/models/Outfits.dart';

class OutfitListScreen extends StatefulWidget {
  const OutfitListScreen({Key? key}) : super(key: key);

  static const valueKey = ValueKey("OutfitListScreen");

  @override
  _OutfitListScreenState createState() => _OutfitListScreenState();
}

class _OutfitListScreenState extends State<OutfitListScreen> {

  late List<Outfits> allOutfits = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshOutfits();
  }

  Future refreshOutfits() async {
    setState(() => isLoading = true);

    this.allOutfits = await ClothesDatabase.instance.readAllOutfits();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Outfit List (${allOutfits.length})"),
      ),
      body: ListView.builder(
        itemCount: allOutfits.length,
        itemBuilder: (context, index) => GestureDetector(
          child: Card(
            child: Text(allOutfits[index].name),
          ),
          onTap: () {
            SnackBar sb = SnackBar(content: Text("This is where you will be able to see outfit: ${allOutfits[index].name}"));
            ScaffoldMessenger.of(context).showSnackBar(sb);
          },
        )
      )
    );
  }
}