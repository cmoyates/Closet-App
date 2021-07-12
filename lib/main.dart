import 'package:closetapp/screens/OutfitListScreen.dart';
import 'package:flutter/material.dart';
import 'models/ClothingTypes.dart';
import 'screens/ClothingTypeScreen.dart';
import 'package:closetapp/screens/OutfitCreatorScreen.dart';
import 'package:flutter/services.dart';
import 'package:closetapp/screens/HomeScreen.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

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
          MaterialPage(child: HomeScreen(
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
            key: HomeScreen.valueKey,
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
              if (result != null && result) {
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