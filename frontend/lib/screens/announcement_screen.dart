import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:student_support_system/models/announcement_model.dart';
import 'package:student_support_system/services/announcement_service.dart';

import 'package:intl/intl.dart';

class AnnouncementScreen extends StatefulWidget {
  final String? aid;
  const AnnouncementScreen({super.key, this.aid});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {

  late AnnouncementModel announcement;
  AnnouncementService announcementService = AnnouncementService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("no");
    print("aid = ${widget.aid}");
    getAnnouncementData(widget.aid.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600
        ? webView()
        : mobileView();
  }

  Widget webView() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              context.go("/");
            }),
        flexibleSpace: Container(
          height: 60,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              width: 1200,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logos/curtin_colombo.jpg',
                    height: 36,
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: isLoading
                  ? Container(
                      child: const CircularProgressIndicator(),
                    )
                  : Container(
                width: 1200,
                padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 60,
                          ),
                          Text(
                            announcement.title ?? "",
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 40,),
                          Center(
                            child: Image(
                              width: double.infinity,
                              height: 560,
                              image: NetworkImage(
                                  "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${announcement.imageId}"),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          const SizedBox(height: 20,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "By ${announcement.createBy}",
                                style: const TextStyle(fontSize: 20, color: Colors.black54),
                              ),
                              Text(
                                DateFormat("EEE, MMM d, yyyy")
                                    .format(announcement.updateDate!),
                                style: const TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              controller: QuillController(
                                document: Document.fromJson(
                                    announcement.description),
                                selection: const TextSelection.collapsed(
                                  offset: 0,
                                ),
                              ),
                              readOnly: true,
                              showCursor: false,
                            ),
                          ),
                          const SizedBox(height: 60,)
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mobileView() {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Announcements"),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              GoRouter.of(context).go("/");
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: isLoading
                    ? Container(child: const CircularProgressIndicator(),)
                    : Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height:40,),
                            Text(
                              announcement.title ?? "",
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20,),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image(
                                  height: 240,
                                  width: double.infinity,
                                  image: NetworkImage(
                                      "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${announcement.imageId}"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "By ${announcement.createBy}",
                                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                                Text(
                                    DateFormat("EEE, MMM d, yyyy")
                                        .format(announcement.updateDate!),
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16,),
                            QuillEditor.basic(
                              configurations: QuillEditorConfigurations(
                                controller: QuillController(
                                  document: Document.fromJson(
                                      announcement.description),
                                  selection: const TextSelection.collapsed(
                                    offset: 0,
                                  ),
                                ),
                                readOnly: true,
                                showCursor: false,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getAnnouncementData(String announcementId) async {
    print(announcementId);
    isLoading = true;
    announcement = await announcementService.getAnnouncement(context, announcementId);
    isLoading = false;
    setState(() {

    });
  }
}
