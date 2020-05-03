import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterkey/main.dart';
import 'package:flutterkey/value_key/value_key_example_one.dart';
import 'package:flutterkey/value_key/value_key_example_three.dart';
import 'package:flutterkey/value_key/value_key_example_two.dart';


class ValueKeyExamples extends StatefulWidget {
  @override
  _ValueKeyExamplesState createState() => _ValueKeyExamplesState();
}

class _ValueKeyExamplesState extends State<ValueKeyExamples> {
  List<TileItem> list = [
    TileItem("Value key example one", 1),
    TileItem("Value key example two", 2),
    TileItem("Value key example three", 3),
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
                      builder: (context) => ValueKeyExampleOne()));
                } else if (list[index].clickedId == 2) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ValueKeyExampleTwo()));
                } else if (list[index].clickedId == 3) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ValueKeyExampleThree()));
                }
              },
              leading: Icon(Icons.touch_app),
              title: new Text(list[index].title),
            );
          }),
    );
  }
}
