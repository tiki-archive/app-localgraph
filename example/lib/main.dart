import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'localgraph Example',
    theme: ThemeData(),
    home: Scaffold(
      body: Center(child: Text('localgraph')),
    ),
  ));
}
