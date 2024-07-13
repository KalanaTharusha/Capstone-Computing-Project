import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/components/box_text_button.dart';
import 'package:student_support_system/models/announcement_model.dart';
import 'package:student_support_system/providers/user_provider.dart';
import 'package:student_support_system/services/announcement_service.dart';
import 'package:student_support_system/utils/validation_utils.dart';

import '../../components/button_card.dart';
import '../../components/stat_card.dart';
import '../../providers/announcement_provider.dart';
import 'package:intl/intl.dart';

class AdminAnnouncements extends StatefulWidget {
  const AdminAnnouncements({super.key});

  @override
  State<AdminAnnouncements> createState() => _AdminAnnouncementsState();
}

class _AdminAnnouncementsState extends State<AdminAnnouncements> {
  static var _categories = ["Select Category",];
  String _selectedCategory = _categories.first;
  bool isEditMode = false;
  bool isImgUploaded = false;
  bool isNewAnnouncementMode = false;
  bool isListMode = true;

  TextEditingController _caTitle = TextEditingController();
  TextEditingController _eaTitle = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String imageId = "";

  PlatformFile? pickedFile = null;

  QuillController cQuillController = QuillController.basic();
  QuillController edQuillController = QuillController.basic();

  AnnouncementModel selectedAnnouncement = AnnouncementModel();

  AnnouncementService announcementService = AnnouncementService();

  DateTimeRange? selectedRange = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 6)), end: DateTime.now());

  final GlobalKey<FormState> _newAnnouncementFormKey = GlobalKey<FormState>();
  String? _newAnnouncementTitle;

  final GlobalKey<FormState> _editAnnouncementFormKey = GlobalKey<FormState>();
  String? _editAnnouncementTitle;

  @override
  void initState() {
    super.initState();
    Provider.of<AnnouncementProvider>(context, listen: false).getSearchResults(context, "by_date", startDate: selectedRange!.start, endDate: selectedRange!.end);
    Provider.of<UserProvider>(context, listen: false).getCurrUser(context);
    setCategories();
  }

  static final _filterBy = [
    "None",
    "Important",
    "Academic",
    "Sport",
    "Alert"
  ];


  String _selectedFilter = _filterBy.first;

  @override
  Widget build(BuildContext context) {

    final announcementProvider = Provider.of<AnnouncementProvider>(context, listen: true);

    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(40),
      child: Container(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Row(
                children: [
                  Text(
                    "Announcements",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Visibility(
                visible: isListMode,
                child: announcementTable(announcementProvider),
              ),
              Visibility(
                visible: isNewAnnouncementMode,
                child: createAnnouncement(announcementProvider),
              ),
              Visibility(
                visible: isEditMode,
                child: editAnnouncement(announcementProvider),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget announcementTable(AnnouncementProvider announcementProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40,),
        Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 400,
                  height: 36,
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: "search by title",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
                    ),
                  ),
                ),
                Container(
                  width: 12,
                ),
                Container(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _selectedFilter = _filterBy.first;
                      });
                      announcementProvider.getSearchResults(context, "by_term", term: searchController.text);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),),
                        )
                    ),
                    child: const Icon(Icons.search,),
                  ),
                ),
                Container(
                  width: 26,
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal:12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(DateFormat("MMM d, yyyy - ").format(selectedRange!.start)),
                          Text(DateFormat("MMM d, yyyy").format(selectedRange!.end)),
                          VerticalDivider(),
                          IconButton(onPressed: () async{
                            DateTimeRange? tempRange = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                                initialDateRange: selectedRange,
                                builder: (context, child) {
                                  return Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth: 600,
                                          maxHeight: 600
                                      ),
                                      child: child,
                                    ),
                                  );
                                });

                            if (tempRange == null) return;
                            setState(() {
                              selectedRange = tempRange;
                            });
                            announcementProvider.getSearchResults(context, "by_date", startDate: selectedRange!.start, endDate: selectedRange!.end);
                          }, icon: Icon(Icons.calendar_month, size: 24,), padding: EdgeInsets.zero,)
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: 26,
                ),
                const Text("Filter by", style: TextStyle(fontSize: 16),),
                Container(
                  width: 12,
                ),
                Container(
                  height: 36,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: _selectedFilter,
                      isDense: true,
                      focusColor: Colors.transparent,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedFilter = newValue!;
                        });
                        announcementProvider.filterSearchResults(context, newValue!);
                      },
                      items: _filterBy.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Container(
                  width: 26,
                ),
                ElevatedButton(
                    onPressed: (){
                      setState(() {
                        isListMode = false;
                        isEditMode = false;
                        isNewAnnouncementMode = true;
                      });
                    },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).primaryColor),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            )
                        )),
                    child: const Text("Create")),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20,),
        Container(
          width: double.infinity,
          child: announcementProvider.isLoading ? const CircularProgressIndicator() : Table(
            border: TableBorder.all(color: Colors.black.withOpacity(0.15)),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(2),
              5: FlexColumnWidth(2),
              6: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                  children: const [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Published Date"),
                      ),),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Title"),
                      ),),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Category"),
                      ),),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Published by"),
                      ),),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Last Update"),
                      ),),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Actions"),
                      ),),
                  ]
              ),
              ...List.generate(announcementProvider.searchResults.length, (index) =>
                  TableRow(
                  decoration: BoxDecoration(color: index.isEven ? Colors.black.withOpacity(0.005) : Colors.white),
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(DateFormat().format(announcementProvider.searchResults[index].createDate ?? DateTime.now())),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(announcementProvider.searchResults[index].title ?? "", maxLines: 1, overflow: TextOverflow.ellipsis,),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(announcementProvider.searchResults[index].category ?? ""),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(announcementProvider.searchResults[index].createBy ?? "No User"),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(DateFormat().format(announcementProvider.searchResults[index].updateDate ?? DateTime.now())),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Tooltip(
                              message: "Edit",
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      )
                                  ),
                                  backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).primaryColor),
                                ),
                                child: const Icon(Icons.edit, size: 18,),
                                onPressed: () {
                                  setState(() {
                                    selectedAnnouncement = announcementProvider.searchResults[index];
                                    edQuillController = QuillController(document: Document.fromJson(selectedAnnouncement.description), selection: const TextSelection.collapsed(offset: 10),);
                                    isListMode = false;
                                    isNewAnnouncementMode = false;
                                    isEditMode = true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 20,),
                            Tooltip(
                              message: "Delete",
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      )
                                  ),
                                  backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.error),
                                ),
                                child: const Icon(Icons.delete, size: 18, color: Colors.white,),
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    width: 500,
                                    padding: const EdgeInsets.all(12),
                                    dialogType: DialogType.error,
                                    animType: AnimType.topSlide,
                                    showCloseIcon: true,
                                    title: "Are you sure?",
                                    desc: "Are you sure want to delete this announcement? This action cannot be undone.",
                                    btnCancelColor: Colors.grey,
                                    btnOkColor: Colors.red,
                                    btnCancelOnPress: (){},
                                    btnOkOnPress: (){
                                      _deleteAnnouncement(announcementProvider, announcementProvider.searchResults[index].id);
                                      },
                                  ).show();
                                  },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createAnnouncement(AnnouncementProvider announcementProvider) {

    return Form(
      key: _newAnnouncementFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40,),
          Row(
            children: [
              InkWell(
                child: const Icon(Icons.arrow_back_rounded),
                onTap: (){
                  setState(() {
                    isNewAnnouncementMode = false;
                    isEditMode = false;
                    isListMode = true;
                  });
                },
              ),
              const SizedBox(width: 20,),
              const Text("New Announcement", style: TextStyle(fontSize: 24,)),
            ],
          ),
          const SizedBox(height: 40,),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex:3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Category"),
                      const SizedBox(height: 12,),
                      SizedBox(
                        width: 200,
                        child: FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                              isEmpty: _selectedCategory == _categories.first,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  isDense: true,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedCategory = newValue!;
                                    });
                                  },
                                  items: _categories.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20,),
                      const Text("Title"),
                      const SizedBox(height: 12,),
                      TextFormField(
                        controller: _caTitle,
                        validator: ValidationUtils.validateAnnouncementTitle,
                        onSaved: (value) => _newAnnouncementTitle = value,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  flex:2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Image"),
                      const SizedBox(height: 12,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 160,
                              child: pickedFile == null
                                  ? Image(image: NetworkImage("${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/cc_dummy_image.jpg"), fit: BoxFit.cover,)
                                  : Image(image: MemoryImage(pickedFile!.bytes!), fit: BoxFit.cover,),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    BoxTextButton(title: "Upload", btnColor: Theme.of(context).primaryColor, onTap: _handleImageUpload, txtColor: Colors.black),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: QuillSimpleToolbar(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: cQuillController,
                ),
              ),
            ),
          ),
          Container(
            height: 500,
            color: Colors.black12.withOpacity(0.05),
            padding: const EdgeInsets.all(20),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                  controller: cQuillController,
                  readOnly: false),
            ),
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 200,
                child: BoxTextButton(
                  btnColor: Colors.black12.withOpacity(0.05),
                  title: "Cancel",
                  onTap: () {
                    setState(() {
                      isNewAnnouncementMode = false;
                      isEditMode = false;
                      isListMode = true;
                    });
                  },
                  txtColor: Colors.black,
                ),
              ),
              SizedBox(
                width: 200,
                child: BoxTextButton(
                  btnColor: Theme.of(context).primaryColor,
                  title: "Publish",
                  onTap: (){_createNewAnnouncement(announcementProvider);},
                  txtColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget editAnnouncement(AnnouncementProvider announcementProvider) { // ToDo: null value with _categories array

    _eaTitle.text = selectedAnnouncement.title ?? "";

    return Form(
      key: _editAnnouncementFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40,),
          Row(
            children: [
              InkWell(
                child: const Icon(Icons.arrow_back_rounded),
                onTap: (){
                  setState(() {
                    isNewAnnouncementMode = false;
                    isEditMode = false;
                    isListMode = true;
                  });
                },
              ),
              const SizedBox(width: 20,),
              const Text("Edit Announcement", style: TextStyle(fontSize: 24,)),
            ],
          ),
          const SizedBox(height: 40,),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex:3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Category"),
                      const SizedBox(height: 12,),
                      SizedBox(
                        width: 200,
                        child: FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                              isEmpty: _selectedCategory == _categories.first,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedAnnouncement.category,
                                  isDense: true,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedAnnouncement.category = newValue!;
                                    });
                                  },
                                  items: _categories.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20,),
                      const Text("Title"),
                      const SizedBox(height: 12,),
                      TextFormField(
                        controller: _eaTitle,
                        validator: ValidationUtils.validateAnnouncementTitle,
                        onSaved: (value) => _editAnnouncementTitle = value,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20,),
                Expanded(
                    flex:2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Image"),
                        const SizedBox(height: 12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 160,
                                child: selectedAnnouncement.imageId == null && pickedFile == null // ToDo: Check this logic again
                                    ? Image(image: NetworkImage("${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/cc_dummy_image.jpg"), fit: BoxFit.cover,)
                                    : selectedAnnouncement.imageId != null && pickedFile != null
                                    ? Image(image: MemoryImage(pickedFile!.bytes!), fit: BoxFit.cover,)
                                    : Image(image: NetworkImage("${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${selectedAnnouncement.imageId}"), fit: BoxFit.cover,)
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: SizedBox(
                                  child: Column(
                                    children: [
                                      BoxTextButton(title: "Change", btnColor: Theme.of(context).primaryColor, onTap: _handleImageUpload, txtColor: Colors.black),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: QuillSimpleToolbar(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: edQuillController,
                ),
              ),
            ),
          ),
          Container(
            height: 500,
            color: Colors.black12.withOpacity(0.05),
            padding: const EdgeInsets.all(20),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                  controller: edQuillController,
                  readOnly: false),
            ),
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 200,
                child: BoxTextButton(
                  btnColor: Colors.black12.withOpacity(0.05),
                  title: "Cancel",
                  onTap: () {
                    setState(() {
                      isNewAnnouncementMode = false;
                      isEditMode = false;
                      isListMode = true;
                    });
                  },
                  txtColor: Colors.black,
                ),
              ),
              SizedBox(
                width: 200,
                child: BoxTextButton(
                  btnColor: Theme.of(context).primaryColor,
                  title: "Update",
                  onTap: () {
                    _updateAnnouncement(announcementProvider);
                  },
                  txtColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleImageUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      pickedFile = result.files.first;
      String? fileType = pickedFile!.extension;

      AnnouncementService announcementService = AnnouncementService();

      Map<String, dynamic> response = await announcementService.uploadImage(pickedFile!);
      bool status = response['status'];

      if(status) {
        var message = jsonDecode(response['message']);
        imageId = message['fileName'];
        if(isEditMode) {selectedAnnouncement.imageId = imageId;}
        setState(() {
          // ToDo
        });
      }
    }
  }

  void _createNewAnnouncement(AnnouncementProvider announcementProvider) async {

    final form = _newAnnouncementFormKey.currentState;

    if(form != null && form.validate()) {

      if(cQuillController.document.isEmpty()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Cannot publish an empty announcement"),
          backgroundColor: Colors.red ,
        ));
        return;
      }

      if(_selectedCategory == _categories.first) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Please select announcement category"),
          backgroundColor: Colors.red ,
        ));
        return;
      }

      form.save();

      var json = jsonEncode(cQuillController.document.toDelta().toJson());
      print(json);

      AnnouncementModel announcement = AnnouncementModel();
      announcement.title = _newAnnouncementTitle;
      announcement.description = json;
      announcement.imageId = imageId.isEmpty ? "cc_dummy_image.jpg" : imageId;
      announcement.category = _selectedCategory;

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

      try{
        announcementProvider.createAnnouncement(context, userProvider.currUser.userId, announcement);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Announcement created successfully'),
          backgroundColor: Colors.green,
        ));

        _caTitle.text = "";
        cQuillController = QuillController.basic();
        _selectedCategory = _categories.first;
        pickedFile = null;

        isNewAnnouncementMode = false;
        isEditMode = false;
        isListMode = true;

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Something went wrong."),
          backgroundColor: Colors.red ,
        ));
        print(e.toString());
      }
    }
  }

  void _updateAnnouncement(AnnouncementProvider announcementProvider) async {

    final form = _editAnnouncementFormKey.currentState;

    if(form != null && form.validate()) {
      if(edQuillController.document.isEmpty()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Cannot publish an empty announcement"),
          backgroundColor: Colors.red ,
        ));
        return;
      }

      if(selectedAnnouncement.category == _categories.first) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Please select announcement category"),
          backgroundColor: Colors.red ,
        ));
        return;
      }

      form.save();

      var json = jsonEncode(edQuillController.document.toDelta().toJson());
      print(json);

      AnnouncementModel announcement = selectedAnnouncement;
      announcement.title = _eaTitle.text;
      announcement.description = json;
      announcement.imageId = selectedAnnouncement.imageId;
      announcement.category = selectedAnnouncement.category;

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

      try{
        announcementProvider.updateAnnouncement(context, userProvider.currUser.userId, selectedAnnouncement.id, announcement);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Announcement updated successfully'),
          backgroundColor: Colors.green,
        ));

        _eaTitle.text = "";
        edQuillController = QuillController.basic();
        _selectedCategory = _categories.first;
        pickedFile = null;

        isNewAnnouncementMode = false;
        isEditMode = false;
        isListMode = true;

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Something went wrong."),
          backgroundColor: Colors.red ,
        ));
        print(e.toString());
      }
    }

  }

  void _deleteAnnouncement(AnnouncementProvider announcementProvider, id) async {

    try{

      announcementProvider.deleteAnnouncement(context, id);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Announcement deleted successfully."),
        backgroundColor: Colors.green ,
      ));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Something went wrong."),
        backgroundColor: Colors.red ,
      ));
      print(e.toString());
    }

  }

  Future<void> setCategories() async {
    AnnouncementService announcementService = AnnouncementService();

    List<String> cat = await announcementService.getAnnouncementCategories();
    cat.forEach((element) {
      print(element);
    });

    if(_categories.length == 1) {
      _categories.addAll(cat);
    }
  }
}
