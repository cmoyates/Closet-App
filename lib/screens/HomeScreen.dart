import 'package:flutter/material.dart';
import 'package:closetapp/models/ClothingTypes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/widgets/ClothingTypeCard.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.didSelectClothingType, required this.didStartCreatingOutfit, required this.isShowingOutfits}) : super(key: key);

  // The key used by the navigator
  static const valueKey = ValueKey("MyHomePage");
  // Some value changed callbacks that detect what the user does
  final ValueChanged<int> didSelectClothingType;
  final ValueChanged<bool> didStartCreatingOutfit;
  final ValueChanged<bool> isShowingOutfits;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ClothingType> allButtons = [];

  // When the screen loads
  @override
  void initState() {
    super.initState();

    setState(() {
      // Add buttons for each of the clothing types
      for (var i = 0; i < clothingTypes.length; i++) {
        this.allButtons.add(clothingTypes[i]);
      }
      // Add a button to view outfits
      allButtons.add(outfitsClothingType);
    });
  }

  // Shows the reset confirmation dialog
  showResetConfimation(context) async {
    return await showDialog(context: context, builder: (context) {return AlertDialog(
      title: Text("Are you sure you want to reset EVERYTHING?"),
      actions: [
        MaterialButton(
          child: Text("Yes"),
          onPressed: () async {
            // Reset everything in the database
            ClothesDatabase.instance.resetAll();
            // Delete everything in the application documents directory
            final dir = await getApplicationDocumentsDirectory();
            dir.deleteSync(recursive: true);
            // Close the popup
            Navigator.pop(context);
          }
        ),
        MaterialButton(
          child: Text("No"),
          onPressed: () {
            // Close the popup
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
        title: Text('Closet App'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent
              ),
              onPressed: () async {
                // Show the reset confirmation popup
                await showResetConfimation(context);
                // Close the drawer
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Reset",
                  style: TextStyle(
                    fontSize: 75
                  ),
                ),
              ),
            ),
          ],
        )
      ),
      body: GridView.builder(
        itemCount: allButtons.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ), 
        itemBuilder: (context, index) => ClothingTypeCard(
          clothingType: allButtons[index],
          onPress: () => {
            // If the user taps the last button show the outfits
            if (index == clothingTypes.length) {
              widget.isShowingOutfits(true)
            } 
            // Otherwise show the selected clothing type
            else {
              widget.didSelectClothingType(index)
            }
          },
        )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Get lists of the pants shirts and shoes in the database
          final pants = await ClothesDatabase.instance.readAllClothes("Pants");
          final shirts = await ClothesDatabase.instance.readAllClothes("Shirts");
          final shoes = await ClothesDatabase.instance.readAllClothes("Shoes");
          // If any of these lists are empty
          if (pants.isEmpty || shirts.isEmpty || shoes.isEmpty) {
            // Tell the user that they need at least one of each
            SnackBar sb = SnackBar(content: Text("You need at least 1 shirt, 1 pair of pants, and 1 pair of shoes to make an outfit!"));
            ScaffoldMessenger.of(context).showSnackBar(sb);
            return;
          }
          // Start creating an outfit
          widget.didStartCreatingOutfit(true);
        },
        child: Icon(Icons.checkroom),
      ),
    );
  }
}