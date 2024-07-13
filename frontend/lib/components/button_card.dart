import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  final String buttonText;
  final String subtitle;
  final Icon icon;
  final Function callback;

  const ButtonCard({
    super.key,
    required this.buttonText,
    required this.subtitle,
    required this.icon,
    required this.callback
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
                child: icon),
            Container(
              width: 20,
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                      onPressed: (){callback();},
                      child: Text(buttonText),
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).primaryColor),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              )
                          ))),
                  Padding(padding: EdgeInsets.all(8)),
                  Text(subtitle, overflow: TextOverflow.ellipsis,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
