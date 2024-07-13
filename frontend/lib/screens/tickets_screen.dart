import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/main.dart';
import 'package:student_support_system/models/ticket_model.dart';
import 'package:student_support_system/providers/ticket_provider.dart';
import 'package:student_support_system/services/ticket_service.dart';
import 'package:student_support_system/utils/validation_utils.dart';

import '../components/ticket_card.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  //new ticket creation
  String? subject = '';
  String? summary = '';
  String? pickedCategory;

  List<String> categoryOptions = [];

  //ticket creation form
  TextEditingController subjectController = TextEditingController();
  TextEditingController summaryController = TextEditingController();

  final GlobalKey<FormState> _ticketFormKey = GlobalKey<FormState>();

  bool showTicketList = true;
  final ValueNotifier<bool> isButtonDisabled = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    Provider.of<TicketProvider>(context, listen: false).getForUserTickets();
    loadCategories();
  }

  loadCategories() async {
    List<String> categories = await TicketService().getTicketCategories();
    print(categories);
    setState(() {
      categoryOptions = categories;
      pickedCategory = categoryOptions[0];
    });
  }

  //builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MediaQuery.of(context).size.width >= 600
          ? webLayout()
          : mobileLayout(),
    );
  }

  Widget webLayout() {
    final provider = Provider.of<TicketProvider>(context);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 1200,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 26,
                        ),
                        const Text(
                          "My Tickets",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        provider.tickets.length > 0
                            ? SingleChildScrollView(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height - 240,
                                  padding: const EdgeInsets.all(12),
                                  child: ListView.separated(
                                    itemBuilder: (context, index) => InkWell(
                                      child: TicketCard(
                                        date: provider
                                            .tickets[index].dateCreated!,
                                        subject: provider.tickets[index].title!,
                                        summery: provider
                                            .tickets[index].description!,
                                        status: provider.tickets[index].status!,
                                      ),
                                      onTap: () {
                                        showTicketDetails(
                                            provider.tickets[index]);
                                      },
                                    ),
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(
                                      height: 4,
                                    ),
                                    itemCount: provider.tickets.length,
                                  ),
                                ),
                              )
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height - 300,
                                child: const Center(
                                  child: Text("No tickets found"),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Submit a ticket",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Form(
                            key: _ticketFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Category"),
                                const SizedBox(
                                  height: 8,
                                ),
                                DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  value: pickedCategory,
                                  items: categoryOptions.map((String lecturer) {
                                    return DropdownMenuItem<String>(
                                      value: lecturer,
                                      child: Text(lecturer),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      pickedCategory = newValue!;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text("Subject"),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: subjectController,
                                  onSaved: (newValue) => subject = newValue,
                                  validator:
                                      ValidationUtils.validateTicketTitle,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text("Summary"),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: summaryController,
                                  onSaved: (newValue) => summary = newValue,
                                  validator: ValidationUtils.validateTicketBody,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 8,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: isButtonDisabled,
                                      builder: (context, isDisabled, child) {
                                        return FilledButton(
                                          onPressed: () {
                                            isDisabled
                                                ? null
                                                : createNewTicket();
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Theme.of(context)
                                                          .primaryColor),
                                              shape:
                                                  const MaterialStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .zero))),
                                          child: Text(
                                            isDisabled
                                                ? "Submitting..."
                                                : "Submit",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileLayout() {
    final provider = Provider.of<TicketProvider>(context);
    return showTicketList
        ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Tickets",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showTicketList = false;
                            });
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  provider.tickets.length > 0
                      ? ShaderMask(
                          shaderCallback: (Rect rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.purple,
                                Colors.transparent,
                                Colors.transparent,
                                Colors.purple
                              ],
                              stops: [
                                0.0,
                                0.1,
                                0.9,
                                1.0
                              ], // 10% purple, 80% transparent, 10% purple
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstOut,
                          child: SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height - 220,
                              child: ListView.separated(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                itemBuilder: (context, index) => InkWell(
                                  child: TicketCard(
                                    date: provider.tickets[index].dateCreated!,
                                    subject: provider.tickets[index].title!,
                                    summery:
                                        provider.tickets[index].description!,
                                    status: provider.tickets[index].status!,
                                  ),
                                  onTap: () {
                                    showTicketDetails(provider.tickets[index]);
                                  },
                                ),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: 4,
                                ),
                                itemCount: provider.tickets.length,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height - 300,
                          child: const Center(
                            child: Text("No tickets found"),
                          ),
                        ),
                ],
              ),
            ),
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showTicketList = true;
                          });
                        },
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Submit Ticket",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Form(
                      key: _ticketFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Category"),
                          const SizedBox(
                            height: 8,
                          ),
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            value: pickedCategory,
                            items: categoryOptions.map((String lecturer) {
                              return DropdownMenuItem<String>(
                                value: lecturer,
                                child: Text(lecturer),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                pickedCategory = newValue!;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text("Subject"),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: subjectController,
                            onSaved: (newValue) => subject = newValue,
                            validator: ValidationUtils.validateTicketTitle,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text("Summary"),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: summaryController,
                            onSaved: (newValue) => summary = newValue,
                            validator: ValidationUtils.validateTicketBody,
                            keyboardType: TextInputType.multiline,
                            maxLines: 8,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ValueListenableBuilder(
                                  valueListenable: isButtonDisabled,
                                  builder: (context, isDisabled, child) {
                                    return FilledButton(
                                      onPressed: () {
                                        isDisabled ? null : createNewTicket();
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Theme.of(context)
                                                      .primaryColor),
                                          shape: const MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.zero))),
                                      child: Text(
                                        isDisabled ? "Submitting" : "Submit",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void showTicketDetails(TicketModel ticketModel) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ticket No: ${ticketModel.id}"),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close))
              ],
            ),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            content: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                width: 600,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Category: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(ticketModel.category ?? ''),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Subject: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(ticketModel.title ?? ''),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Raised on: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(DateFormat.yMMMd()
                            .add_jm()
                            .format(ticketModel.dateCreated!)),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Raised by: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(ticketModel.createdUser!.firstName ?? ''),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "Summary: ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    RichText(
                      text: TextSpan(
                        text: '${ticketModel.description}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ticketModel.status!.toLowerCase() != 'closed'
                  ? FilledButton(
                      onPressed: () {
                        closeTicket(ticketModel.id!);
                        Navigator.pop(context);
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero))),
                      child: const Text(
                        "Close Ticket",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  : const Center(
                      child: Text(
                      "This ticket has been closed",
                      style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.red),
                    ))
            ],
          );
        });
  }

  closeTicket(String id) async {
    TicketModel ticket = await TicketService().closeTicket(id);
    if (ticket.status == 'CLOSED') {
      AwesomeDialog(
              context: context,
              width: 500,
              padding: const EdgeInsets.all(12),
              showCloseIcon: true,
              dialogType: DialogType.success,
              animType: AnimType.topSlide,
              title: 'Ticket Closed',
              desc: 'Your ticket has been closed successfully',
              btnOkOnPress: () {},
              dismissOnTouchOutside: false)
          .show();
      Provider.of<TicketProvider>(context, listen: false).getForUserTickets();
    }
  }

  createNewTicket() async {
    String? userId = await storage.read(key: 'userId');
    final form = _ticketFormKey.currentState;

    if (form != null && form.validate()) {
      form.save();

      isButtonDisabled.value = true;

      print("text: ${subjectController.text}");

      TicketModel ticket = await TicketService().createTicket({
        'title': subjectController.text,
        'description': summaryController.text,
        'category': pickedCategory,
        'createdUserId': userId,
      });

      isButtonDisabled.value = false;

      if (ticket.id != null && mounted) {
        AwesomeDialog(
                context: context,
                width: 500,
                padding: const EdgeInsets.all(12),
                showCloseIcon: true,
                dialogType: DialogType.success,
                animType: AnimType.topSlide,
                title: 'Ticket Created',
                desc: 'Your ticket has been created successfully',
                btnOkOnPress: () {},
                dismissOnTouchOutside: false)
            .show();

        Provider.of<TicketProvider>(context, listen: false).addTicket(ticket);
        form.reset();
      }
    }
  }
}
