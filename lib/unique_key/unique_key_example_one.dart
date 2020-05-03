
import 'package:flutter/material.dart';



//As the name suggests a UniqueKey is unique every-time on rebuild.

class UniqueKeyExampleOne extends StatefulWidget {
  @override
  _UniqueKeyExampleOneState createState() => _UniqueKeyExampleOneState();
}

class _UniqueKeyExampleOneState extends State<UniqueKeyExampleOne> {

/*Here you can see even the filled text has been erased. This is because
the entire states of both the widgets are lost and are newly created on rebuilding.
Hence unique keys must be used only in stateless widgets where the widgets aren’t
depended on internal data change.*/
  bool showFirst=true;

  @override
  Widget build(BuildContext context) {
    print("Main BuildContext ");

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        setState(() {
          showFirst=false;
        });
      }),
      appBar: AppBar(title: new Text('Enter the Data both TextFiled'),),
      body: Column(
        children: <Widget>[
          /*Here you can see even the filled text has been erased.
           This is because the entire states of both the widgets are lost and are
           newly created on rebuilding.
Hence unique keys must be used only in stateless widgets where the widgets
 aren’t depended on internal data change.*/
          if(showFirst)MyTextField(key:UniqueKey()),
          MyTextField(key:UniqueKey())

        ],
      ),
    );
  }
}


class MyTextField extends StatefulWidget {

  MyTextField({Key key}):super(key:key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {

  final controller=TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("MyTextField context");
    return TextFormField(
      decoration: InputDecoration(
      ),
      controller: controller,

    );
  }
}