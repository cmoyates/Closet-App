import 'package:closetapp/models/Outfits.dart';
import 'package:closetapp/screens/OutfitListScreen.dart';
import 'package:closetapp/widgets/ClothingTypeCard.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'models/ClothingTypes.dart';
import 'screens/ClothingTypeScreen.dart';
import 'package:closetapp/db/ClothingDatabase.dart';
import 'package:closetapp/screens/OutfitCreatorScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int _selectedClothingType = -1;
  bool _creatingAnOutfit = false;
  bool _showingOutfits = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark
      ),
      themeMode: ThemeMode.dark,
      home: Navigator(
        pages: [
          MaterialPage(child: MyHomePage(
            title: 'Closet App',
            didSelectClothingType: (value) {
              setState(() => {
                _selectedClothingType = value
              });
            },
            didStartCreatingOutfit: (value) {
              setState(() {
                _creatingAnOutfit = value;
              });
            },
            isShowingOutfits: (value) {
              setState(() {
                _showingOutfits = value;
              });
            },
            key: MyHomePage.valueKey,
          )),

          if (_selectedClothingType != -1)
            MaterialPage(
              child: ClothingTypeScreen(
                clothingType: clothingTypes[_selectedClothingType],
              ),
              key: ClothingTypeScreen.valueKey
            ),
          
          if (_creatingAnOutfit)
            MaterialPage(
              child: OutfitCreatorScreen(
              ),
              key: OutfitCreatorScreen.valueKey,
            ),

          if (_showingOutfits)
            MaterialPage(
              child: OutfitListScreen(
              ),
              key: OutfitListScreen.valueKey,
          )
        ],
        onPopPage: (route, result) {

          final page = route.settings as MaterialPage;

          if (page.key == ClothingTypeScreen.valueKey) {
            setState(() {
              _selectedClothingType = -1;
            });
          }
          else if (page.key == OutfitCreatorScreen.valueKey) {
            setState(() {
              _creatingAnOutfit = false;
              if (result) {
                _showingOutfits = true;
              }
            });
          }
          else if (page.key == OutfitListScreen.valueKey) {
            setState(() {
              _showingOutfits = false;
            });
          }

          return route.didPop(result);
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.didSelectClothingType, required this.didStartCreatingOutfit, required this.isShowingOutfits}) : super(key: key);

  static const valueKey = ValueKey("MyHomePage");

  final String title;
  final ValueChanged<int> didSelectClothingType;
  final ValueChanged<bool> didStartCreatingOutfit;
  final ValueChanged<bool> isShowingOutfits;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ClothingType> allButtons = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      for (var i = 0; i < clothingTypes.length; i++) {
        this.allButtons.add(clothingTypes[i]);
      }
      allButtons.add(outfitsClothingType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent
              ),
              onPressed: () async {
                ClothesDatabase.instance.resetAll();
                final dir = await getApplicationDocumentsDirectory();
                dir.deleteSync(recursive: true);
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
            if (index == 5) {
              widget.isShowingOutfits(true)
            } else {
              widget.didSelectClothingType(index)
            }
          },
        )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.didStartCreatingOutfit(true);
        },
        child: Icon(Icons.checkroom),
      ),
    );
  }
}