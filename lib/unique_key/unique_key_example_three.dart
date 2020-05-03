import 'package:flutter/material.dart';

class UniqueKeyExampleThree extends StatefulWidget {
  @override
  _UniqueKeyExampleThreeState createState() => _UniqueKeyExampleThreeState();
}

class _UniqueKeyExampleThreeState extends State<UniqueKeyExampleThree> {
  final items = List<String>.generate(20, (i) => "Item ${i}");

  @override
  Widget build(BuildContext context) {
    print("Build Content");
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              background: Container(color: Colors.red),
              child: ListTile(title: Text('$item')),
              key: UniqueKey(),
              onDismissed: (direction) {
                print("Index:${index}");
                setState(() {
                  items.removeAt(index);
                });
                // Then show a snackbar.
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("$item dismissed")));
              },
            );
          }),
    );
  }
}
