import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/providers/appointment_provider.dart';
import 'package:student_support_system/providers/channel_provider.dart';
import 'package:student_support_system/providers/ticket_provider.dart';
import 'package:student_support_system/services/appointment_service.dart';
import 'package:student_support_system/services/ticket_service.dart';
import 'package:student_support_system/services/user_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../providers/user_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  late List<ChartData> _pieChartData;
  late List<ChartData> _barChartData;
  late List<ChartData> _barChartData2;
  late Map<String, dynamic> _userStats;
  late Map<String, dynamic> _ticketStats;
  late Map<String, dynamic> _appointmentStats;

  UserService userService = UserService();
  TicketService ticketService = TicketService();
  AppointmentService appointmentService = AppointmentService();
  bool isLoading = false;

  final List<Color> customColors = [
    const Color(0xFFD6AB1D),
    const Color(0xFFF2C93F),
    const Color(0xFFFFD95A),
    const Color(0xFFFFE48A),
    const Color(0xFFFFF5D2),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).getStats(context);
    Provider.of<ChannelProvider>(context, listen: false).getAllChannels();
    Provider.of<AppointmentProvider>(context, listen: false).getAppointmentStats(context);
    Provider.of<TicketProvider>(context, listen: false).getStats(context);
    loadStats();
  }

  @override
  Widget build(BuildContext context) {

    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    final AppointmentProvider appointmentProvider = Provider.of<AppointmentProvider>(context);
    final TicketProvider ticketProvider = Provider.of<TicketProvider>(context);

    return Expanded(
        child: Container(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dashboard",
                  style:
                  TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20,),
                Container(
                  child: GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    childAspectRatio: 2 / 1,
                    children: <Widget>[
                      Card(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        child: Container(
                          height: 100,
                          width: 200,
                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/card_bg.png'), fit: BoxFit.fill, alignment: Alignment.topCenter)),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userProvider.isLoading ? 'Loading...' : userProvider.userStats['total'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                              const Text("Total Users", style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis,)
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        child: Container(
                          height: 100,
                          width: 200,
                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/card_bg.png'), fit: BoxFit.fill, alignment: Alignment.topCenter)),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(channelProvider.isLoading ? 'Loading...' : channelProvider.allChannels.length.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                              const Text("Total Channels", style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis,)
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        child: Container(
                          height: 100,
                          width: 200,
                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/card_bg.png'), fit: BoxFit.fill, alignment: Alignment.topCenter)),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appointmentProvider.isLoading ? 'Loading...' : appointmentProvider.stats['totalPending'].toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                              const Text("Pending Appointments", style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis,)
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        child: Container(
                          height: 100,
                          width: 200,
                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/card_bg.png'), fit: BoxFit.fill, alignment: Alignment.topCenter)),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ticketProvider.isLoading ? 'Loading...' : ticketProvider.stats['pending'].toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                              const Text("Open Tickets", style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis,)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40,),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(),)
                            : SizedBox(
                          height: 360,
                          child: SfCartesianChart(
                            title: const ChartTitle(text: 'Ticket Stats'),
                            primaryXAxis: CategoryAxis(),
                            isTransposed: true,
                            series: <ColumnSeries<ChartData, String>>[
                              ColumnSeries<ChartData, String>(
                                dataSource: _barChartData,
                                xValueMapper: (ChartData data, _) => data.key,
                                yValueMapper: (ChartData data, _) => data.value,
                                color: customColors[0],
                              ),
                            ],
                          ),
                        )
                    ),
                    Expanded(
                        flex: 2,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(),)
                            : SizedBox(
                          height: 360,
                          child: SfCartesianChart(
                            title: const ChartTitle(text: 'Appointment Stats'),
                            primaryXAxis: CategoryAxis(),
                            isTransposed: true,
                            series: <ColumnSeries<ChartData, String>>[
                              ColumnSeries<ChartData, String>(
                                dataSource: _barChartData2,
                                xValueMapper: (ChartData data, _) => data.key.replaceAll(RegExp('thisMonth'), ''),
                                yValueMapper: (ChartData data, _) =>
                                data.value,
                                color: customColors[1],
                              ),
                            ],
                          ),
                        )
                    ),
                    Expanded(
                      flex: 2,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(),)
                            : SizedBox(
                              height: 360,
                              child: SfCircularChart(
                                  title: const ChartTitle(text: 'Active Users'),
                                  legend: Legend(isVisible: true, position: LegendPosition.bottom),
                                  series: <CircularSeries>[
                                    PieSeries<ChartData, String>(
                                      dataSource: _pieChartData,
                                      xValueMapper: (ChartData data, _) => data.key,
                                      yValueMapper: (ChartData data, _) => data.value,
                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                      radius: '120',
                                    ),
                                  ],
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    ));
  }

  loadStats() async {

    setState(() {
      isLoading = true;
    });
    _userStats = (await userService.getStats())['stats'];

    _pieChartData = (_userStats..remove('total')).entries
        .map((entry) => ChartData(entry.key, double.parse(entry.value)))
        .toList();

    _ticketStats = await ticketService.getTicketStats();
    _barChartData = (_ticketStats..remove('total')).entries.map((e) => ChartData(e.key, e.value)).toList();

    _appointmentStats = await appointmentService.getAppointmentStats();
    _barChartData2 = ((_appointmentStats..removeWhere((key, value) => key.contains('total')))..remove('thisMonth')).entries.map((e) => ChartData(e.key, e.value)).toList();

    setState(() {
      isLoading = false;
    });
  }
}

class ChartData {
  ChartData(this.key, this.value);
  final String key;
  final double value;
}
