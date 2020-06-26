import 'package:flutter/material.dart';
import 'Homepage.dart';
import 'Signin.dart';
import 'Signup.dart';

// void main() => runApp(MyApp());

class AuthenticationClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Homepage(),
      routes: <String,WidgetBuilder>{
        "/Signin": (BuildContext context) => Signin(),
        "/Signup": (BuildContext context) => Signup(),
      },
    );
  }
}