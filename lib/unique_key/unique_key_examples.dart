import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterkey/main.dart';
import 'package:flutterkey/unique_key/unique_key_example_one.dart';
import 'package:flutterkey/unique_key/unique_key_example_three.dart';
import 'package:flutterkey/unique_key/unique_key_example_two.dart';

class UniqueKeyExamples extends StatefulWidget {
  @override
  _UniqueKeyExamplesState createState() => _UniqueKeyExamplesState();
}

class _UniqueKeyExamplesState extends State<UniqueKeyExamples> {
  List<TileItem> list = [
    TileItem("Unique key example one", 1),
    TileItem("Unique key example two", 2),
    TileItem("Unique key example three", 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                if (list[index].clickedId == 1) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UniqueKeyExampleOne()));
                } else if (list[index].clickedId == 2) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UniqueKeyExampleTwo()));
                } else if (list[index].clickedId == 3) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UniqueKeyExampleThree()));
                }
              },
              leading: Icon(Icons.touch_app),
              title: new Text(list[index].title),
            );
          }),
    );
  }
}
