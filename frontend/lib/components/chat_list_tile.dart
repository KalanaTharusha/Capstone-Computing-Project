import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatListTile extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  bool unread = false;

  ChatListTile({
    Key? key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.unread,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7D4),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFD95A),
          child: Icon(Icons.groups),
        ),
        title: Container(
          constraints: BoxConstraints(maxWidth: 200),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: unread
            ? Container(
                width: 50,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD95A),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "New",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            : null,
        onTap: () {
          GoRouter.of(context).go('/chat/$id');
        },
      ),
    );
  }
}
