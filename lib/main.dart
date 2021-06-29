import 'package:closetapp/widgets/ClothingTypeCard.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'models/ClothingTypes.dart';
import 'screens/ClothingTypeScreen.dart';
import 'package:closetapp/db/ClothingDatabase.dart';

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
          )),

          if (_selectedClothingType != -1)
            MaterialPage(
              child: ClothingTypeScreen(
                clothingType: clothingTypes[_selectedClothingType],
              ),
              key: ClothingTypeScreen.valueKey
            )
        ],
        onPopPage: (route, result) {

          final page = route.settings as MaterialPage;

          if (page.key == ClothingTypeScreen.valueKey)
            _selectedClothingType = -1;

          return route.didPop(result);
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title, required this.didSelectClothingType}) : super(key: key);

  final String title;
  final ValueChanged didSelectClothingType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            )
          ],
        )
      ),
      body: GridView.builder(
        itemCount: clothingTypes.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ), 
        itemBuilder: (context, index) => ClothingTypeCard(
          clothingType: clothingTypes[index],
          onPress: () => {
            didSelectClothingType(index)
          },
        )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SnackBar sb = SnackBar(content: Text("\"Creating an outfit\" has not been implemented yet"));
          ScaffoldMessenger.of(context).showSnackBar(sb);
        },
        child: Icon(Icons.checkroom),
      ),
    );
  }
}