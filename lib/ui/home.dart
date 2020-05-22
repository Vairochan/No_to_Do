import 'package:flutter/material.dart';
import 'package:no_to_do_app/ui/notodoscreen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("No to Do"),
          backgroundColor: Colors.black54,
        ),
        body: NotoDoScreen(),
      ),
    );
  }
}
