
import 'dart:async';


import 'package:absence/camCutie.dart';
import 'package:absence/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:absence/l10n/app_localizations.dart';


class dateTimePicker extends StatelessWidget {
  const dateTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) =>DateTime.now(),
      ),

      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final time = snapshot.data!;

        return Text(
          _formatDateTime(time),
          style: const TextStyle(
            color: Color.fromARGB(255, 111, 255, 116),
            fontSize: 10,
          )
        );
      },
    );
  }
  String _formatDateTime(DateTime time){
    return "${time.day.toString().padLeft(2, '0')} "
           "${_monthName(time.month)} "
           "${time.year} ";
          //  "${time.hour.toString().padLeft(2, '0')}."
          //  "${time.minute.toString().padLeft(2, '0')}."
          //  "${time.second.toString().padLeft(2, '0')}";
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return months[month - 1];
  }
}

class Cuti extends StatefulWidget {
  const Cuti({super.key});

  @override
  State<Cuti> createState() => _CutiState();
}

class _CutiState extends State<Cuti> {
  String? _savedUser;
  String? _savedToken;
  // String? _isLoggedIn;
  String? _savedName;
  String? _savedStatus;
  String? _savedAttType;
  String? _savedShiftType;
  String? _startDatepref;
  String? _endDatePref;

  LatLng? currentLocation;
  double? distance;

  // stream location
  StreamSubscription<Position>? positionStream;
  
  // Text Editing Controller
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();

  // saved var dateTime picker
  DateTime? startDateTime;
  DateTime? endDateTime;

  // dateTime picker formatter
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    // this is prefsCatcher
    _prefsCatcher();
    _clearDurationPrefs();
  }

  Future<void> _clearDurationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('duration_days');
  }

  Future<void> _prefsCatcher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUser = prefs.getString('user') ?? "Who is there?";
      _savedToken = prefs.getString('token') ?? "this is token";
      _savedName = prefs.getString('name') ?? "who is this?";
      _savedStatus = prefs.getString('status') ?? "which type r u?";
      _savedAttType = prefs.getString('attendance_type') ?? "what att type r u?";
      _savedShiftType = prefs.getString('shift_type');
      _startDatepref = prefs.getString('start_date');
      _endDatePref = prefs.getString('end_date');

      // _isLoggedIn = prefs.getBool('isLoggedIn');
      print("savedUser: $_savedUser");
      print("savedToken: $_savedToken");
      print("savedName: $_savedName");
      print("Attendance type: $_savedAttType");
      print("Status: $_savedStatus");
      print("Shift Status: $_savedShiftType");
      print("start_date: $_startDatepref");
      print("end_date: $_endDatePref");
    });
  }

  Future<void> _setTimeToPrefs() async {
    if (!getValidRangeTime()) return;

    final prefs = await SharedPreferences.getInstance();

    final int durationDays =
      calculateDurationDays(startDateTime!, endDateTime!);

    await prefs.setString(
      'start_date',
      formatter.format(startDateTime!),
    );
    await prefs.setString(
      'end_date',
      formatter.format(endDateTime!),
    );

    await prefs.setInt(
      'duration_days',
      durationDays,
    );

    debugPrint(
      "Start Date: $startDateTime"
    );
    debugPrint(
      "End Date: $endDateTime"
    );
  }

  int calculateDurationDays(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  // Future<DateTime?> _pickDateTime(BuildContext context) async {
  //   /// PICK DATE
  //   final DateTime? date = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );

  //   if (date == null) {
  //     return null;
  //   }

  //   // Pick Time
  //   final TimeOfDay? time = await showTimePicker(
  //     context: context, 
  //     initialTime: TimeOfDay.now());

  //   if (time == null) {
  //     return null;
  //   }

  //   return DateTime(
  //     date.year,
  //     date.month,
  //     date.day,
  //     // time.hour,
  //     // time.minute,
  //   );
  // }

  bool getValidRangeTime() {
    if (startDateTime == null || endDateTime == null) return false;

    // end must be after or equal to Start
    if (endDateTime!.isBefore(startDateTime!)) return false;

    // count diff days
    final int diffDays =
        endDateTime!.difference(startDateTime!).inDays;

    // max up to 30 days only!
    return diffDays <= 30;
  }

  Future<void> _logout() async {
    final t = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (_) => MyHomePage()),
      (route) => false, 
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(t.translate("dadah"), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void dispose(){
    positionStream?.cancel();
    positionStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return
    Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 23, 58),
      body: 
      Column(
            children: [
              Container(
                color: const Color.fromARGB(255, 184, 184, 184),
                child: 
                Column(
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // ElevatedButton(
                        //   onPressed: (){
                        //     _prefsCatcher();
                        //   }, 
                        //   child: Text("Test SharedPrefs")
                        // ),
                        Image.asset('assets/logoBiru.png', width: 220, height: 65),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: const Color.fromARGB(255, 67, 57, 158),
                          ),
                          onPressed:
                          (){
                            // button funct
                            _logout();
                          }, 
                          child: Icon(Icons.logout_rounded, color: Colors.white,)),
                      ],
                    ),
                  ],
                )
              ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  child: Card(
                    color: const Color.fromARGB(255, 67, 57, 158),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.008,),
                        Text(t.translate("period"), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),),
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),

                        // DateTime Picker
                        TextField(
                          controller: _startDate,
                          readOnly: true,
                          style: TextStyle(color: const Color.fromARGB(255, 207, 207, 207)),
                          decoration: InputDecoration(
                            labelText: t.translate("startDate"),
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 154, 154, 154)),
                            prefixIcon: Icon(Icons.calendar_today_rounded, color: const Color.fromARGB(255, 180, 180, 180),)
                          ),
                          onTap: () async {
                            final picked = await _pickDate(context);
                            if (picked != null){
                              setState(() {
                                startDateTime = picked;
                                _startDate.text =formatter.format(picked);
                              });
                            }
                          },
                        ),
                        TextField(
                          controller: _endDate,
                          readOnly: true,
                          style: TextStyle(color: const Color.fromARGB(255, 207, 207, 207)),
                          decoration: InputDecoration(
                            labelText: t.translate("endDate"),
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 154, 154, 154)),
                            prefixIcon: Icon(Icons.calendar_today_rounded, color: const Color.fromARGB(255, 180, 180, 180),)
                          ),
                          onTap: () async {
                            final picked = await _pickDate(context);
                            if (picked != null){
                              setState(() {
                                endDateTime = picked;
                                _endDate.text =formatter.format(picked);
                              });
                            }
                          },
                        ),
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.72,
                          height: MediaQuery.sizeOf(context).height * 0.07,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20))
                            ),
                            onPressed: getValidRangeTime()
                              ? () async {
                                  await _setTimeToPrefs();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => CamAndFile()),
                                  );
                                }
                              : null,
                            child: Text( getValidRangeTime() ? 
                              t.translate("absent") : t.translate("fillDate"),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,)
                      ],
                    )
                  ),
                ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.8,
                child:
                Card(
                  color: const Color.fromARGB(255, 67, 57, 158),
                  child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: MediaQuery.sizeOf(context).width * 0.01,),
                        Icon(Icons.shield_outlined, color: Colors.lightBlueAccent,),
                        Column(
                          children: [
                            Text("HR Compliance Verified", style: TextStyle(color: Colors.white, fontSize: 12),),
                            Text("Sistem terintegrasi dengan audit trail", style: TextStyle(color: Colors.white, fontSize: 8))
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width *0.01, 
                                                    right: MediaQuery.sizeOf(context).width *0.01, 
                                                    top: MediaQuery.sizeOf(context).width *0.01, 
                                                    bottom: MediaQuery.sizeOf(context).width *0.01
                                                  ),
                          child: Container(
                            width: 2,
                            height: MediaQuery.sizeOf(context).height * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                        Column(
                          children: [
                            Text("Server Time", style: TextStyle(color: Color.fromARGB(255, 111, 255, 116), fontSize: 10),),
                            // Text("18 Des 2025, 14.16.18", style: TextStyle(color: Color.fromARGB(255, 111, 255, 116), fontSize: 10))
                            dateTimePicker(),
                          ],
                        ),
                      ],
                    )
                )
              )
            ],
      ),
    );
  }
}