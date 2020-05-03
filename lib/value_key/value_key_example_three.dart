


import 'package:flutter/material.dart';

class ValueKeyExampleThree extends StatefulWidget {
  @override
  _ValueKeyExampleThreeState createState() => _ValueKeyExampleThreeState();
}

class _ValueKeyExampleThreeState extends State<ValueKeyExampleThree> {


  final items = List<String>.generate(20, (i) => "Item ${i}");


  @override
  Widget build(BuildContext context) {
    print("Build Content");
    return Scaffold(
      appBar: AppBar(),
      body:ListView.builder(
          itemCount: items.length,
          itemBuilder: (context,index){
            final item = items[index];
            return Dismissible(

              background: Container(color: Colors.red),
              child: ListTile(title: Text('$item')),
              key: ValueKey(item),
              onDismissed: (direction){
                print("Index:${index}");
                setState(() {
                  items.removeAt(index);
                });
                // Then show a snackbar.
                Scaffold.of(context).showSnackBar(SnackBar(content: Text("$item dismissed")));
              },
            );
          }) ,
    );
  }
}
