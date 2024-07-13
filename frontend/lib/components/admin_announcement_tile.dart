import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../screens/announcement_screen.dart';

class AdminAnnouncementTile extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String image;
  final Function editFunction;

  const AdminAnnouncementTile({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.editFunction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        kIsWeb
            ? html.window.open('/#/announcements/$id',"_blank")
            : Navigator.push(context, MaterialPageRoute(builder: (context) => AnnouncementScreen(aid: id,)));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 150,
                    child: Ink.image(
                      image: NetworkImage(
                          'https://images.unsplash.com/photo-1522028067194-85ce8814a419?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1974&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(20),
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          child: Text(
                            title.isEmpty ? "Title should be here" : title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  title.isEmpty ? "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam luctus elit ac magna efficitur tempus. Ut elementum eget arcu sed dictum. Donec id sapien sed purus rhoncus pharetra vel sed odio. Praesent faucibus pretium risus, sit amet rhoncus massa pharetra consequat. Curabitur sit amet bibendum erat. Nam volutpat ornare ante, commodo placerat dui varius nec. Quisque consequat est ac tortor pellentesque, vitae sollicitudin felis lacinia. Pellentesque aliquet, felis sit amet ullamcorper consequat, purus libero accumsan est, vel commodo lorem odio a eros. Maecenas eleifend, magna sed euismod molestie, magna massa euismod augue, ut maximus ante sapien lobortis massa. Aliquam ullamcorper faucibus scelerisque."
                                      : description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(height: 5,),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    onPressed: (){ editFunction(); },
                                    child: Text("Edit"),),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Center(child: Text(dummyItems[index])),
      ),
    );
  }
}
