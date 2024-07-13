import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("404", style: TextStyle(fontSize: 160, fontWeight: FontWeight.bold ,color: Theme.of(context).primaryColor),),
            Text("Not Found", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,),),
            Text("The page you requested could not be found!", style: TextStyle(fontSize: 20,),),
          ],
        ),
      ),
    );
  }
}
