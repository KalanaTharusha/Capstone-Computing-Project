import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final String reason;
  final DateTime date;
  final TimeOfDay time;
  final String lecturer;
  final String location;
  final String status;

  const AppointmentCard({
    super.key,
    required this.reason,
    required this.date,
    required this.time,
    required this.lecturer,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    reason,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Text(DateFormat.yMMMd().format(date)),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(time.format(context))
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage:
                      AssetImage('assets/images/ProfilePic.jpg'),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lecturer,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Location: $location'),
                      ],
                    )
                  ],
                )
              ],
            ),
            Flexible(
              child: Chip(
                color: MaterialStatePropertyAll(getChipColor(status)),
                label: Container(
                  width: 60,
                  child: Center(
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getChipColor(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.green;
      case "declined":
        return Colors.red;
      case "rejected":
        return Colors.red;
      case "pending":
        return Colors.orange;
      default:
        return Colors.white;
    }
  }
}
