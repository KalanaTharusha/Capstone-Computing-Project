import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Icon icon;

  const StatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0)
      ),
      elevation: 12,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/card_bg.png'),
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,)
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
              Padding(padding: EdgeInsets.all(4)),
              Text(title, style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis,),
          ],
        ),
        ),
      ),
    );
  }
}
