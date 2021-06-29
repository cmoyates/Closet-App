import 'dart:convert';
import 'dart:ffi';
import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/models/Clothes.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:closetapp/models/ClothingTypes.dart';
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';

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

  String? _image;
  String? _name;
  final picker = ImagePicker();

  addNewClothes() async {
    await chooseImage();
    await createAlertDialog(context).then((value) async {
      setState(() {
        _name = value;
      });
    });
    await addClothes(_name.toString(), _image.toString());
    await refreshClothes();
    SnackBar sb = SnackBar(content: Text("Added: $_name, now ${clothesList.length} items in \"${widget.clothingType.title}\""));
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }
  Future addClothes(String nameOfTheClothes, String imageOfTheClothes) async {
    final clothes = Clothes(
      name: nameOfTheClothes,
      image: imageOfTheClothes
    );

    await ClothesDatabase.instance.create(widget.clothingType.title, clothes);
  }
  chooseImage() async {
    final PickedFile? imagePickedFile = await picker.getImage(source: ImageSource.camera);
    final File image = File(imagePickedFile!.path);
    final directory = await getApplicationDocumentsDirectory();
    final String imgType = imagePickedFile.path.split(".").last;
    final String path = "${directory.path}/${DateTime.now()}.$imgType";
    await image.copy(path);
    setState(() {
      _image = path;
    });
  }

  createAlertDialog(BuildContext context) async {

    TextEditingController customController = TextEditingController();

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Describe this piece of clothing:"),
        content: TextField(
          controller: customController,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pop(customController.text.toString());
            },
            elevation: 5.0,
            child: Text("Submit"),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clothingType.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addNewClothes();
        },
        child: Icon(Icons.add),
      ),
      body: GridView.builder(
        itemCount: clothesList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) => Card(
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
        )
      )
    );
  }
}