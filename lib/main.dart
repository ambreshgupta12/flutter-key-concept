import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterkey/unique_key/unique_key_examples.dart';
import 'package:flutterkey/value_key/value_key_examples.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage());
  }
}

class TileItem {
  String title;
  int clickedId;

  TileItem(this.title, this.clickedId);
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TileItem> list = [
    TileItem("Unique key examples", 1),
    TileItem("Value key examples", 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Flutter Key Example"),
      ),
      body: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) => ListTile(
                onTap: () {
                  if (list[index].clickedId == 1) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UniqueKeyExamples()));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ValueKeyExamples()));
                  }
                },
                title: new Text(
                  list[index].title,
                ),
            trailing: Icon(Icons.local_library),
              )
      ),
    );
  }
}
