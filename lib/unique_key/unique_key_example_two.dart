import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class UniqueKeyExampleTwo extends StatefulWidget {
  @override
  _UniqueKeyExampleTwoState createState() => _UniqueKeyExampleTwoState();
}

class _UniqueKeyExampleTwoState extends State<UniqueKeyExampleTwo> {


  List<Widget> list;

  @override
  void initState() {

    super.initState();
    list=[
      StatefulColorfulTile(key:UniqueKey()),
      StatefulColorfulTile(key:UniqueKey())
    ];
  }



  swapTile(){
    setState(() {
      list.insert(1, list.removeAt(0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: swapTile,child: Icon(Icons.sentiment_very_dissatisfied)),
      appBar: AppBar(),
      body: Row(children: list,),

    );
  }
}

class StatefulColorfulTile extends StatefulWidget {


  StatefulColorfulTile({Key key}):super(key:key);
  @override
  _StatefulColorfulTileState createState() => _StatefulColorfulTileState();
}

class _StatefulColorfulTileState extends State<StatefulColorfulTile> {


  Color _myColor;



  @override
  void initState() {
    super.initState();
    _myColor=getColor();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        height: 80,
        color:_myColor
    );
  }


  Color getColor(){
    return RandomColor().randomMaterialColor();
  }
}

