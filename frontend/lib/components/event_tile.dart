import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventTile extends StatelessWidget {
  final String id;
  final String title;
  final DateTime date;

  const EventTile({
    super.key,
    required this.id,
    required this.title,
    required this.date
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("${date.day}", style: TextStyle(fontSize: 35,),),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('EEEE').format(date), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                          Text("${date.month}, ${date.year}",style: TextStyle(fontSize: 10,),),
                        ],
                      ),
                    ],),
                  SizedBox(width: 20,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        Text("Starts at ${DateFormat.jm().format(date)}", style: TextStyle(fontSize: 12,),),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      // Center(child: Text(dummyItems[index])),
    );
  }
}
