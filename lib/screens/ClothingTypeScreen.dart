import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/models/Clothes.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:closetapp/models/ClothingTypes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:closetapp/models/Outfits.dart';

class ClothingTypeScreen extends StatefulWidget {
  const ClothingTypeScreen({Key? key, required this.clothingType}) : super(key: key);

  final ClothingType clothingType;
  static const valueKey = ValueKey("ClothingTypeScreen");

  @override
  _ClothingTypeScreenState createState() => _ClothingTypeScreenState();
}

class _ClothingTypeScreenState extends State<ClothingTypeScreen> {

  late List<Clothes> clothesList = [];
  bool isLoading = false;
  
  String? _image;
  String? _name;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    refreshClothes();
  }

  Future refreshClothes() async {
    setState(() => isLoading = true);

    this.clothesList = await ClothesDatabase.instance.readAllClothes(widget.clothingType.title);

    setState(() => isLoading = false);
  }
  
  showSnackBar(stringToShow) {
    SnackBar sb = SnackBar(content: Text(stringToShow));
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }

  addClothes() async {
    final File? pickedImageFile = await chooseImage();
    if (pickedImageFile == null) {showSnackBar("Cancelled"); return false;}
    String? description = "";
    description = await createAlertDialog(context);
    if (description == null) {showSnackBar("Cancelled"); return false;}
    setState(() {
      _name = description;
    });
    await saveImageToFile(pickedImageFile);
    final item = Clothes(name: _name.toString(), image: _image.toString());
    await ClothesDatabase.instance.createClothes(widget.clothingType.title, item);
    List<Clothes> all = await ClothesDatabase.instance.readAllClothes(widget.clothingType.title);
    for (var i = 0; i < all.length; i++) {
      if (all[i].name == item.name) {print("Added ${widget.clothingType.singular}, ID: ${all[i].id}");}
    }
    return true;
  }

  chooseImage() async {
    final PickedFile? imagePickedFile = await picker.getImage(source: ImageSource.camera, maxWidth: 420);
    if (imagePickedFile == null) {return null;}
    final File image = File(imagePickedFile.path);
    return image;
  }

  saveImageToFile(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final String imgType = image.path.split(".").last;
    final String path = "${directory.path}/${DateTime.now()}.$imgType";
    await image.copy(path);
    setState(() {
      _image = path;
    });
  }

  createAlertDialog(BuildContext context) async {

    TextEditingController customController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

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

  showContextMenu(BuildContext context, int index) async {
    return await showDialog(context: context, builder: (context) { return AlertDialog(
      title: Center(child: Text(clothesList[index].name)),
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      actions: [
        MaterialButton(
          child: Text("Change Description"),
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
            if (!_formKey.currentState!.validate()) {return;}
            
            Clothes tempClothes = Clothes(
              id: clothesList[index].id,
              name: customController.text.toString(),
              image: clothesList[index].image
            );

            await ClothesDatabase.instance.updateClothes(widget.clothingType.title, tempClothes);

            await refreshClothes();

            Navigator.pop(context);
          }
        )
      ],
    );});
  }

  showDeleteConfimation(context, index) async {
    return await showDialog(context: context, builder: (context) {return AlertDialog(
      title: Text("Are you sure you want to delete ${clothesList[index].name}?"),
      actions: [
        MaterialButton(
          child: Text("Yes"),
          onPressed: () async {
            
            List<Outfits> outfits = await ClothesDatabase.instance.readAllOutfits();
            for (var i = 0; i < outfits.length; i++) {
              if (outfits[i].clothesIds[widget.clothingType.title] == clothesList[index].id) {
                showSnackBar("Also had to delete outfit: ${outfits[i].name}");
                await ClothesDatabase.instance.deleteOutfits(outfits[i].id!);
              }
            }

            await ClothesDatabase.instance.deleteClothes(widget.clothingType.title, clothesList[index].id!);

            await refreshClothes();

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
        title: Text(widget.clothingType.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool additionSuccessful = await addClothes();
          if (additionSuccessful) {
            await refreshClothes();
            showSnackBar("Added: $_name");
          }
        },
        child: Icon(Icons.add),
      ),
      body: GridView.builder(
        itemCount: clothesList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) => GestureDetector(
          onLongPress: () async {
            print("Menu");
            showContextMenu(context, index);
          },
          child: Card(
            child: Stack(
              children: [
                Image.file(File(clothesList[index].image),
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
        )
      )
    );
  }
}