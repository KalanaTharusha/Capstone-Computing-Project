import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final String subject;
  final DateTime date;
  final String summery;
  final String status;

  const TicketCard(
      {super.key,
      required this.subject,
      required this.date,
      required this.summery,
      required this.status});

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
                    subject,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(DateFormat.yMMMd().add_jm().format(date)),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    summery,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
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
    switch (status) {
      case "PENDING":
        return Colors.red;
      case "REPLIED":
        return Colors.orange;
      case "CLOSED":
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}
