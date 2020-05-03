
import 'package:flutter/material.dart';




class ValueKeyExampleOne extends StatefulWidget {
  @override
  _ValueKeyExampleOneState createState() => _ValueKeyExampleOneState();
}

class _ValueKeyExampleOneState extends State<ValueKeyExampleOne> {
  /*Here we can see ValueKey takes a parameter which we have set to an integer 1, 2.
   We are free to choose anything as parameter just it shouldn’t change on rebuilding.*/
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
          /*Remember not to pass same parameter again to
              some other widget. Flutter will throw exception ‘Duplicate Keys Found’.*/
          if(showFirst)MyTextField(key:ValueKey(1)),
          MyTextField(key:ValueKey(2))

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