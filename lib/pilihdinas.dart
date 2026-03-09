import 'package:absence/cuti.dart';
import 'package:absence/cutiLapangan.dart';
import 'package:absence/dashboard.dart';
import 'package:absence/drawer.dart';
import 'package:absence/fieldDuty.dart';
import 'package:absence/main.dart';
import 'package:absence/officeAbsence.dart';
import 'package:absence/settings.dart';
import 'package:absence/sick.dart';
import 'package:absence/lateness.dart';
import 'package:absence/wfh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absence/l10n/app_localizations.dart';

class dateTimePicker extends StatelessWidget {
  const dateTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),

      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final time = snapshot.data!;

        return Text(
          _formatDateTime(time),
          style: const TextStyle(
            color: Color.fromARGB(255, 111, 255, 116),
            fontSize: 10,
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime time) {
    return "${time.day.toString().padLeft(2, '0')} "
        "${_monthName(time.month)} "
        "${time.year} "
        "${time.hour.toString().padLeft(2, '0')}."
        "${time.minute.toString().padLeft(2, '0')}."
        "${time.second.toString().padLeft(2, '0')}";
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return months[month - 1];
  }
}

class PilihDinas extends StatefulWidget {
  const PilihDinas({super.key});

  @override
  State<PilihDinas> createState() => _PilihDinasState();
}

class _PilihDinasState extends State<PilihDinas> {
  // await prefs.setString('user', user);
  //       await prefs.setString('token', token);
  //       await prefs.setString('name', name);
  //       await prefs.setBool('isLoggedIn', true);

  // get Login Prefs
  String? _userPref;
  String? _tokenPrefs;
  String? _namePrefs;
  String? _idPrefs;
  bool? _isLoggedInPrefs;

  // button state
  bool isOfficeSelected = false;
  bool isFieldSelected = false;
  bool isWfhSelected = false;
  bool isCutiSelected = false;
  bool isCutlapSelected = false;
  bool isSickSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prefsCatcher();
  }

  Future<void> _prefsCatcher() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _userPref = _prefs.getString('user') ?? 'who are you?';
    _tokenPrefs =
        _prefs.getString('token') ?? 'there is no token here, go away';
    _namePrefs = _prefs.getString('name') ?? 'who are you again?';
    _idPrefs = _prefs.getString('id') ?? 'un ID fied :D';
    _isLoggedInPrefs = _prefs.getBool('isLoggedIn');

    // print save prefs state
    print("user: $_userPref");
    print("token: $_tokenPrefs");
    print("name: $_namePrefs");
    print("id: $_idPrefs");
    print("isLoggedIn: $_isLoggedInPrefs");
  }

  void _dinasKantor() async {
    final Att_type = "kantor";
    final status = "Hadir";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void _dinasLuar() async {
    final Att_type = "dinas_lapangan";
    final status = "dinas luar";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void _WFH() async {
    final Att_type = "wfh";
    final status = "wfh";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void _cuti() async {
    final Att_type = "cuti";
    final status = "Cuti";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void _cutiLapangan() async {
    final Att_type = "cuti_lapangan";
    final status = "Cuti Lapangan";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void _sakit() async {
    final Att_type = "sakit";
    final status = "Sakit";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  Future<void> _logout() async {
    final t = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    // clear all only selected prefs
    await prefs.remove('isLoggedIn');
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('name');
    await prefs.remove('id');
    await prefs.remove('employeesId');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MyHomePage()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          t.translate("dadah"),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF182234),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 219, 219, 219), // warna icon burger
        ),
        backgroundColor: const Color.fromRGBO(2, 6, 23, 1),
        // shadowColor: Colors.cyanAccent.withOpacity(0.2),
        title: Text(
          t.translate("titlePilihDinas"),
          style: TextStyle(color: const Color.fromARGB(255, 224, 224, 224)),
        ),
      ),
      drawer: AppSidebar(
        onMenuTap: (route) async {
          Navigator.pop(context);

          switch (route) {
            case "dashboard":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
              break;
            case "lateness":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Lateness()),
              );
              break;
            case "settings":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
              break;
            case "alarm":
              break;
            case "logout":
              _logout();
              break;
          }
        },
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 1,
          height: MediaQuery.sizeOf(context).height * 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: Container(
                  // decoration: BoxDecoration(
                  //   boxShadow: [
                  //     // outside glowing
                  //     BoxShadow(
                  //       color: Colors.cyanAccent.withOpacity(0.4),
                  //       blurRadius: 15,
                  //       spreadRadius: 2,
                  //     ),
                  //     BoxShadow(
                  //       color: Colors.cyanAccent.withOpacity(0.2),
                  //       blurRadius: 30,
                  //       spreadRadius: 6,
                  //     ),
                  //   ]
                  // ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 67, 150, 217),
                        width: 1,
                      ),
                    ),
                    color: Color(0xFF334155),
                    child: Column(
                      children: [
                        // Padding(
                        //     padding: const EdgeInsets.only(top: 8.0),
                        //     child: Image.asset('assets/logoBiru.png', width: 220, height: 65),
                        //   ),
                        // SizedBox(
                        //   width: MediaQuery.sizeOf(context).width * 0.6,
                        //   child:
                        //   Divider(
                        //     thickness: 1,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 10.0),
                        //   child: SizedBox(
                        //     height: MediaQuery.sizeOf(context).height * 0.02,
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(bottom: 20.0),
                        //       child: Text(t.translate("pilihAbsen"),
                        //                     style: TextStyle(color: const Color.fromARGB(255, 202, 202, 202),
                        //                     fontSize: 14,
                        //                     fontWeight: FontWeight.w900
                        //                     ),
                        //                   ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10.0,
                          ),
                          child: Text(
                            t.translate("pilihAbsen"),
                            style: TextStyle(
                              color: const Color.fromARGB(255, 215, 215, 215),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.71,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.325,
                                  // height: MediaQuery.sizeOf(context).width * 0.1,
                                  child:
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //     boxShadow: [
                                      //       BoxShadow(
                                      //         color: Colors.cyanAccent.withOpacity(0.3),
                                      //         blurRadius: 15,
                                      //         spreadRadius: 2,
                                      //       ),
                                      //       BoxShadow(
                                      //         color: Colors.cyanAccent.withOpacity(0.1),
                                      //         blurRadius: 30,
                                      //         spreadRadius: 6,
                                      //       )
                                      //     ]
                                      //   ),
                                      //   child:
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith((
                                                states,
                                              ) {
                                                if (states.contains(
                                                  MaterialState.pressed,
                                                )) {
                                                  return Colors
                                                      .lightBlue; // warna saat ditekan
                                                }
                                                return const Color.fromRGBO(
                                                  30,
                                                  41,
                                                  59,
                                                  1,
                                                ); // warna normal
                                              }),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          _dinasKantor();

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OfficeAbsence(),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: 5.0,
                                              ),
                                              child: Icon(
                                                MaterialCommunityIcons
                                                    .office_building,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              t.translate("office"),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                ),
                              ),

                              // ),

                              // SizedBox(width: MediaQuery.sizeOf(context).width * 0.001),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10.0,
                                  left: 20.0,
                                ),
                                child: SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.325,
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.3),
                                    //       blurRadius: 15,
                                    //       spreadRadius: 2,
                                    //     ),
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.1),
                                    //       blurRadius: 30,
                                    //       spreadRadius: 6,
                                    //     )
                                    //   ]
                                    // ),
                                    child: ElevatedButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                MaterialState.pressed,
                                              )) {
                                                return Colors.lightBlue;
                                              }
                                              return const Color.fromRGBO(
                                                30,
                                                41,
                                                59,
                                                1,
                                              );
                                            }),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        _dinasLuar();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FieldDuty(),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        MaterialCommunityIcons.map_marker,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        t.translate("field"),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.71,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.325,
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.3),
                                    //       blurRadius: 15,
                                    //       spreadRadius: 2,
                                    //     ),
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.1),
                                    //       blurRadius: 30,
                                    //       spreadRadius: 6,
                                    //     )
                                    //   ]
                                    // ),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                MaterialState.pressed,
                                              )) {
                                                return Colors.lightBlue;
                                              }
                                              return const Color.fromRGBO(
                                                30,
                                                41,
                                                59,
                                                1,
                                              );
                                            }),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        _WFH();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WFH(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Icon(
                                              MaterialCommunityIcons.home,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            t.translate("wfh"),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // SizedBox(width:  MediaQuery.sizeOf(context).width * 0.001,),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10.0,
                                  left: 20.0,
                                ),
                                child: SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.325,
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.3),
                                    //       blurRadius: 15,
                                    //       spreadRadius: 2,
                                    //     ),
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.1),
                                    //       blurRadius: 30,
                                    //       spreadRadius: 6,
                                    //     )
                                    //   ]
                                    // ),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                MaterialState.pressed,
                                              )) {
                                                return Colors.lightBlue;
                                              }
                                              return const Color.fromRGBO(
                                                30,
                                                41,
                                                59,
                                                1,
                                              );
                                            }),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        _cuti();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Cuti(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Icon(
                                              MaterialCommunityIcons.calendar,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            t.translate("cuti"),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.71,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.325,
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.3),
                                    //       blurRadius: 15,
                                    //       spreadRadius: 2,
                                    //     ),
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.1),
                                    //       blurRadius: 30,
                                    //       spreadRadius: 6,
                                    //     )
                                    //   ]
                                    // ),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                MaterialState.pressed,
                                              )) {
                                                return Colors.lightBlue;
                                              }
                                              return const Color.fromRGBO(
                                                30,
                                                41,
                                                59,
                                                1,
                                              );
                                            }),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        _cutiLapangan();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CutiLapangan(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 3.0,
                                            ),
                                            child: Icon(
                                              MaterialCommunityIcons.earth,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            t.translate("cutLap"),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(width: MediaQuery.sizeOf(context).width * 0.0),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10.0,
                                  left: 20.0,
                                ),
                                child: SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.325,
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.3),
                                    //       blurRadius: 15,
                                    //       spreadRadius: 2,
                                    //     ),
                                    //     BoxShadow(
                                    //       color: Colors.cyanAccent.withOpacity(0.1),
                                    //       blurRadius: 30,
                                    //       spreadRadius: 6,
                                    //     )
                                    //   ]
                                    // ),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                MaterialState.pressed,
                                              )) {
                                                return Colors.lightBlue;
                                              }
                                              return const Color.fromRGBO(
                                                30,
                                                41,
                                                59,
                                                1,
                                              );
                                            }),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        _sakit();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Sick(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Icon(
                                              MaterialCommunityIcons
                                                  .file_document,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            t.translate("sick"),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            child: Container(
                              // decoration: BoxDecoration(
                              //   boxShadow: [
                              //     BoxShadow(
                              //       color: Colors.cyanAccent.withOpacity(0.3),
                              //       blurRadius: 15,
                              //       spreadRadius: 2,
                              //     ),
                              //     BoxShadow(
                              //       color: Colors.cyanAccent.withOpacity(0.1),
                              //       blurRadius: 30,
                              //       spreadRadius: 6,
                              //     )
                              //   ]
                              // ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    73,
                                    197,
                                    254,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () {
                                  // _logout();
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => Sick()));
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Dashboard(),
                                    ),
                                  );
                                },
                                child: Text(
                                  t.translate("beranda"),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),

              // Describer Card
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                // height: MediaQuery.sizeOf(context).height * 0.1,
                child: Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 67, 150, 217),
                        width: 1,
                      ),
                    ),
                    color: Color(0xFF334155),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.1,
                            ),
                            Icon(
                              Icons.shield_outlined,
                              color: Colors.lightBlueAccent,
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.03,
                            ),
                            Text(
                              t.translate("keamanandanverif"),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02,
                        ),

                        // Office Describer
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          child: Container(
                            child: Card(
                              color: const Color.fromRGBO(30, 41, 59, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: const Color.fromARGB(255, 77, 83, 93),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).width *
                                          0.1,
                                      child: Icon(
                                        MaterialCommunityIcons.office_building,
                                        color: Colors.lightGreen,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                              0.52,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t.translate("office"),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    t.translate(
                                                      "gpsharusoffice",
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    " 50m ",
                                                    style: TextStyle(
                                                      color: Colors.lightGreen,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    t.translate("fromoffice"),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                t.translate("fotowajib"),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Duty Field Describer
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          child: Container(
                            child: Card(
                              color: const Color.fromRGBO(30, 41, 59, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: const Color.fromARGB(255, 77, 83, 93),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).width *
                                          0.1,
                                      child: Icon(
                                        MaterialCommunityIcons.map_marker,
                                        color: Colors.lightBlue,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                              0.52,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t.translate("field"),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    t.translate("gpsharusflex"),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    t.translate("flexduty"),
                                                    style: TextStyle(
                                                      color: Colors.lightBlue,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  // Text(t.translate("fromoffice"), style: TextStyle(color: Colors.white, fontSize: 10))
                                                ],
                                              ),
                                              Text(
                                                t.translate("fotowajib"),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // WFH Describer
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          child: Container(
                            child: Card(
                              color: const Color.fromRGBO(30, 41, 59, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: const Color.fromARGB(255, 77, 83, 93),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).width *
                                          0.1,
                                      child: Icon(
                                        MaterialCommunityIcons.home,
                                        color: Color.fromRGBO(192, 132, 252, 1),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                              0.52,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t.translate("wfh"),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    t.translate("GPS"),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    t.translate("gpsinfo"),
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(
                                                        192,
                                                        132,
                                                        252,
                                                        1,
                                                      ),
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  // Text(t.translate("fromoffice"), style: TextStyle(color: Colors.white, fontSize: 10))
                                                ],
                                              ),
                                              Text(
                                                t.translate("fotowajib"),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Annual Leave Describer
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          child: Container(
                            child: Card(
                              color: const Color.fromRGBO(30, 41, 59, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: const Color.fromARGB(255, 77, 83, 93),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).width *
                                          0.1,
                                      child: Icon(
                                        MaterialCommunityIcons.calendar,
                                        color: Color.fromRGBO(251, 146, 60, 1),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                              0.52,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t.translate("cuti"),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    t.translate("noneedgps"),
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(
                                                        251,
                                                        146,
                                                        60,
                                                        1,
                                                      ),
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    t.translate("norphoto"),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  // Text(t.translate("fromoffice"), style: TextStyle(color: Colors.white, fontSize: 10))
                                                ],
                                              ),
                                              Text(
                                                t.translate("dokumenwajib"),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.04,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),

              // HR Qualified
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: Container(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color.fromARGB(255, 67, 150, 217),
                          width: 1,
                        ),
                      ),
                      color: Color(0xFF334155),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // SizedBox(width: MediaQuery.sizeOf(context).width * 0.01,),
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.lightBlueAccent,
                          ),
                          Column(
                            children: [
                              Text(
                                "HR Compliance Verified",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "Sistem terintegrasi dengan audit trail",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.sizeOf(context).width * 0.01,
                              right: MediaQuery.sizeOf(context).width * 0.01,
                              top: MediaQuery.sizeOf(context).width * 0.01,
                              bottom: MediaQuery.sizeOf(context).width * 0.01,
                            ),
                            child: Container(
                              width: 2,
                              height: MediaQuery.sizeOf(context).height * 0.04,
                              color: Colors.grey,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "Server Time",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 111, 255, 116),
                                  fontSize: 10,
                                ),
                              ),
                              // Text("18 Des 2025, 14.16.18", style: TextStyle(color: Color.fromARGB(255, 111, 255, 116), fontSize: 10))
                              dateTimePicker(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // ElevatedButton(onPressed: (){
              //   _prefsCatcher();
              // }, child: Text("test prefs"))
            ],
          ),
        ),
      ),
      // )
    );
  }
}
