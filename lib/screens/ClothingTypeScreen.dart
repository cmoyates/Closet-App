// Imports
import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/models/Clothes.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:closetapp/models/ClothingTypes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:closetapp/models/Outfits.dart';
import 'package:closetapp/widgets/ClothingCard.dart';

class ClothingTypeScreen extends StatefulWidget {
  const ClothingTypeScreen({Key? key, required this.clothingType}) : super(key: key);

  // The type of clothing the page is displaying
  final ClothingType clothingType;
  // The key used by the navigator
  static const valueKey = ValueKey("ClothingTypeScreen");

  @override
  _ClothingTypeScreenState createState() => _ClothingTypeScreenState();
}

class _ClothingTypeScreenState extends State<ClothingTypeScreen> {

  // A list of all clothes of the appropriate type
  late List<Clothes> clothesList = [];
  // Loading bool for refreshing the clothes
  bool isLoading = false;
  // The image picker that will be used for getting images of the clothes
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    refreshClothes();
  }

  Future refreshClothes() async {
    setState(() => isLoading = true);

    // Read the list of that type of clothes from the database
    this.clothesList = await ClothesDatabase.instance.readAllClothes(widget.clothingType.title);

    setState(() => isLoading = false);
  }
  
  // This is a utility function that shows messages at the bottom of the app
  showSnackBar(stringToShow) {
    SnackBar sb = SnackBar(content: Text(stringToShow));
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }

  // This function adds new clothing to the database
  addClothes() async {
    // Get an image of the clothes that you want to add
    final File? pickedImageFile = await chooseImage();
    // If the user doesn't take the picture cancel adding the clothing
    if (pickedImageFile == null) {showSnackBar("Cancelled"); return null;}
    // Get a description of the clothing from the user
    String? description = await showDescriptionDialog(context);
    // If the user doesn't give a description cancel adding the clothing
    if (description == null) {showSnackBar("Cancelled"); return null;}
    // Save the image to a file and record the path
    final String imagePath = await saveImageToFile(pickedImageFile);
    // Create an object out of the info gathered and add it to the database
    final item = Clothes(name: description, image: imagePath.toString());
    await ClothesDatabase.instance.createClothes(widget.clothingType.title, item);
    // Return the description
    return description;
  }

  // This function gets the image of the clothing the user is adding
  chooseImage() async {
    // Use the image picker to get have the user take a picture
    final PickedFile? imagePickedFile = await picker.getImage(source: ImageSource.camera, maxWidth: 420);
    // If the user cancels the taking of the picture return null
    if (imagePickedFile == null) {return null;}
    // Convert the "PickedFile" object to a File object and return it
    return File(imagePickedFile.path);
  }

  // This function saves an Image object to a file
  saveImageToFile(File image) async {
    // Get the apps "documents directory"
    final directory = await getApplicationDocumentsDirectory();
    // Get the file type of the image
    final String imgType = image.path.split(".").last;
    // Create the complete path out of those things and the current "DateTime"
    final String path = "${directory.path}/${DateTime.now()}.$imgType";
    // Copy the image file to that path and return it
    await image.copy(path);
    return path;
  }

  // This function brings up the dialog for the user to enter a description of a piece of clothing
  showDescriptionDialog(BuildContext context) async {
    // This is the controller for the text form
    TextEditingController customController = TextEditingController();
    // This is the key used for validating the form
    final _formKey = GlobalKey<FormState>();
    // This is what's actually shown
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Describe this piece of clothing:"),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: customController,
            autofocus: true,
            validator: (value) => (value == null || value.isEmpty) ? "Description cannot be blank" : null,
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              // If the form is not valid (empty) do nothing
              if (!_formKey.currentState!.validate()) {return;}
              // Otherwise close the dialog and return the text from the form
              Navigator.of(context).pop(customController.text.toString());
            },
            elevation: 5.0,
            child: Text("Submit"),
          )
        ],
      );
    });
  }

  // This function brings up the context menu of an article of clothing
  showContextMenu(BuildContext context, int index) async {
    return await showDialog(context: context, builder: (context) { return AlertDialog(
      title: Center(child: Text(clothesList[index].name)),
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      actions: [
        MaterialButton(
          child: Text("Change Description"),
          onPressed: () {
            // Close the current popup
            Navigator.pop(context);
            // Open the rename popup
            showRenamePopup(context, index);
          },
        ),
        MaterialButton(
          child: Text("Delete"),
          onPressed: () {
            // Close the current popup
            Navigator.pop(context);
            // Open the delete confirmation popup
            showDeleteConfimation(context, index);
          },
        ),
      ],
    );});
  }

  // This function brings up the prompt for the user to rename some clothing
  showRenamePopup(BuildContext context, int index) async {
    // This is the controller for the text form
    TextEditingController customController = TextEditingController();
    // This is the key used for validating the form
    final _formKey = GlobalKey<FormState>();
    // This is what's actually shown
    return await showDialog(context: context, builder: (context) {return AlertDialog(
      title: Text("Change ${clothesList[index].name} desctiption:"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: customController,
          autofocus: true,
          validator: (value) => (value == null || value.isEmpty) ? "Description cannot be blank" : null,
        )
      ),
      actions: [
        MaterialButton(
          child: Text("Submit"),
          onPressed: () async {
            // If the form is not valid (empty) do nothing
            if (!_formKey.currentState!.validate()) {return;}
            // Otherwise create a temp clothes object and update the entry in the database
            Clothes tempClothes = Clothes(
              id: clothesList[index].id,
              name: customController.text.toString(),
              image: clothesList[index].image
            );
            await ClothesDatabase.instance.updateClothes(widget.clothingType.title, tempClothes);
            // Refresh the clothes list and close the popup
            await refreshClothes();
            Navigator.pop(context);
          }
        )
      ],
    );});
  }
  
  // This function asks the user if they're sure they want to delete some clothing
  showDeleteConfimation(context, index) async {
    // Show a dialog asking the user if they are sure they want to delete something: yes or no
    return await showDialog(context: context, builder: (context) {return AlertDialog(
      title: Text("Are you sure you want to delete ${clothesList[index].name}?"),
      actions: [
        MaterialButton(
          child: Text("Yes"),
          onPressed: () async {
            List<Outfits> outfits = await ClothesDatabase.instance.readAllOutfits();
            // For every outfit
            for (var i = 0; i < outfits.length; i++) {
              // If it contains this article of clothing
              if (outfits[i].clothesIds[widget.clothingType.title] == clothesList[index].id) {
                // Tell the user the outfit needed to be deleted, and then delete it
                showSnackBar("Also had to delete outfit: ${outfits[i].name}");
                await ClothesDatabase.instance.deleteOutfits(outfits[i].id!);
              }
            }
            // Delete the image file and then remove the clothing from the database
            await File(clothesList[index].image).delete();
            await ClothesDatabase.instance.deleteClothes(widget.clothingType.title, clothesList[index].id!);
            // Refresh the clothes being shown
            await refreshClothes();
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

  // This is the actual content shown on the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clothingType.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? name = await addClothes();
          if (name != null) {
            await refreshClothes();
            showSnackBar("Added: $name");
          }
        },
        child: Icon(Icons.add),
      ),
      body: (clothesList.isEmpty) ? Center(
        child: Text(
          "You haven't added any ${widget.clothingType.title.toLowerCase()} yet!",
          style: TextStyle(
            fontSize: 20
          ),
        ),
      ) : 
      GridView.builder(
        itemCount: clothesList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) => ClothingCard(
          clothes: clothesList[index],
          onCardTapped: () {},
          onCardLongPressed: () => showContextMenu(context, index),
        )
      )
    );
  }
}