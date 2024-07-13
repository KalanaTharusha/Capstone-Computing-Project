import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:student_support_system/screens/announcement_screen.dart';
import 'package:universal_html/html.dart' as html;

class AnnouncementTile extends StatelessWidget {
  final String id;
  final String title;
  final String summery;
  final String category;
  final String image;
  final bool grid;
  final DateTime today = DateTime.now();
  static DateFormat tFormatter =  DateFormat('h:mm a');

  AnnouncementTile({
    super.key,
    required this.id,
    required this.title,
    required this.summery,
    required this.category,
    required this.image,
    required this.grid,
  });

  @override
  Widget build(BuildContext context) {
    print('aid: $id');

    return grid
        ? gridTile(context)
        : kIsWeb
        ? webAnnouncementTile(context)
        : mobileAnnouncementTile(context);
  }

  Widget webAnnouncementTile(BuildContext ctx) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        child: Container(
          height: 120,
          decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(0.3))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    Image(
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      image: NetworkImage(image),
                    ),
                    Visibility(
                      visible: category.toLowerCase() == "important",
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            height: 40,
                            width: 30,
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ]),
                            child: const Center(
                              child: Icon(Icons.info_outline, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: category.toLowerCase() == "alert",
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            height: 40,
                            width: 30,
                            decoration: BoxDecoration(
                                color: Colors.indigo,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ]),
                            child: const Center(
                              child: Icon(Icons.announcement_outlined, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 8,),
              Expanded(
                  flex: 8,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(height: 12,),
                            Container(
                              child: Text(summery,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(tFormatter.format(today), style: TextStyle(fontSize: 12),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
        onTap: () {
          _handleClick(ctx, id);
        },
      ),

    );
  }

  Widget mobileAnnouncementTile(BuildContext ctx) {
    return Card(
      // surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: InkWell(
        child: Container(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    Image(
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      image: NetworkImage(image),
                    ),
                    Visibility(
                      visible: category.toLowerCase() == "important",
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            height: 40,
                            width: 30,
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ]),
                            child: const Center(
                              child: Icon(Icons.info_outline, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: category.toLowerCase() == "alert",
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            height: 40,
                            width: 30,
                            decoration: BoxDecoration(
                                color: Colors.indigo,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ]),
                            child: const Center(
                              child: Icon(Icons.announcement_outlined, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 8,),
              Expanded(
                  flex: 8,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          child: Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(tFormatter.format(today), style: TextStyle(fontSize: 12),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
        onTap: (){
          _handleClick(ctx, id);
        },
      ),
    );
  }

  Widget gridTile(BuildContext ctx) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        child: Container(
          height: 350,
          width: 250,
          decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(0.3))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Image(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      image: NetworkImage(image),
                    ),
                    Visibility(
                      visible: category.toLowerCase() == "important",
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 32,
                          width: 120,
                          decoration: BoxDecoration(color: Colors.redAccent, boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                          child: const Center(
                            child: Text('IMPORTANT', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: category.toLowerCase() == "alert",
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 32,
                          width: 120,
                          decoration: BoxDecoration(color: Colors.indigo, boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                          child: const Center(
                            child: Text('ALERT', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(height: 18,),
                      Container(
                        child: Text(summery,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // child: Center(
          //   child: Text("Item"),
          // ),
        ),
        onTap: (){
          _handleClick(ctx, id);
        },
      ),
    );
  }

  void _handleClick(BuildContext context, String aid) {

    kIsWeb
        // ? html.window.open('/#/announcement/$aid',"_blank")
        ? context.go("/announcement/$aid")
        : GoRouter.of(context).go("/announcement/$aid");
  }
}
