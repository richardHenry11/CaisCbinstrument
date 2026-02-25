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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absence/l10n/app_localizations.dart';

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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prefsCatcher();
  }

  Future<void> _prefsCatcher() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _userPref = _prefs.getString('user') ?? 'who are you?';
    _tokenPrefs = _prefs.getString('token') ?? 'there is no token here, go away';
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

  void  _dinasLuar() async {
    final Att_type = "dinas_lapangan";
    final status = "dinas luar";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void  _WFH() async {
    final Att_type = "wfh";
    final status = "wfh";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void  _cuti() async {
    final Att_type = "cuti";
    final status = "Cuti";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void  _cutiLapangan() async {
    final Att_type = "cuti_lapangan";
    final status = "Cuti Lapangan";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', Att_type);
    await prefs.setString('status', status);
    print("attendance type: $Att_type");
    print("shift type: $status");
  }

  void  _sakit() async {
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
        content: Text(t.translate("dadah"), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 23, 58),
      appBar: 
      AppBar(
        backgroundColor: const Color.fromARGB(255, 73, 197, 254),
        shadowColor: Colors.cyanAccent.withOpacity(0.2),
        title: 
        Center(child: Text(t.translate("titlePilihDinas"), style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255),),)),
      ),
      drawer: AppSidebar(
        onMenuTap: (route) async {
          Navigator.pop(context);

          switch (route) {
            case "dashboard":
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard())
            );
            break;
            case "lateness":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Lateness())
            );
            break;
            case "settings":
             Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => SettingsPage())
            );
            break;
            case "alarm":
            break;
            case "logout":
            _logout();
            break;
          } 
        }
      ),
      body: 
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 1,
          height: MediaQuery.sizeOf(context).height * 1,
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: 
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        // outside glowing
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ]
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.blue, 
                          width: 1,
                        ),
                      ),
                      color: const Color.fromARGB(255, 22, 84, 134),
                      child:
                      Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Image.asset('assets/logoBiru.png', width: 220, height: 65),
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.6,
                              child: 
                              Divider(
                                thickness: 1, 
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                              child: Text(t.translate("pilihAbsen"), 
                                            style: TextStyle(color: const Color.fromARGB(255, 202, 202, 202), 
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900
                                            ),
                                          ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                height: MediaQuery.sizeOf(context).width * 0.1,
                                child: 
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.1),
                                        blurRadius: 30,
                                        spreadRadius: 6,
                                      )
                                    ]
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      )
                                    ),
                                    onPressed: (){
                                      _dinasKantor();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => OfficeAbsence()));
                                    }, 
                                    child: Text(t.translate("office"), style: TextStyle(color: Colors.white),)
                                  ),
                                ),
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                child: 
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.1),
                                        blurRadius: 30,
                                        spreadRadius: 6,
                                      )
                                    ]
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      )
                                    ),
                                    onPressed: (){
                                      _dinasLuar();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FieldDuty()));
                                    }, 
                                    child: Text(t.translate("field"), style: TextStyle(color: Colors.white))
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                child: 
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.1),
                                        blurRadius: 30,
                                        spreadRadius: 6,
                                      )
                                    ]
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      )
                                    ),
                                    onPressed: (){
                                      _WFH();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => WFH()));
                                    }, 
                                    child: Text(t.translate("wfh"), style: TextStyle(color: Colors.white))
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                child: 
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.1),
                                        blurRadius: 30,
                                        spreadRadius: 6,
                                      )
                                    ]
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      )
                                    ),
                                    onPressed: (){
                                      _cuti();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Cuti()));
                                    }, 
                                    child: Text(t.translate("cuti"), style: TextStyle(color: Colors.white))
                                  ),
                                ),
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                child: 
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.1),
                                        blurRadius: 30,
                                        spreadRadius: 6,
                                      )
                                    ]
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      )
                                    ),
                                    onPressed: (){
                                      _cutiLapangan();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => CutiLapangan()));
                                    }, 
                                    child: Text(t.translate("cutLap"), style: TextStyle(color: Colors.white))
                                  ),
                                ),
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                child: 
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.1),
                                        blurRadius: 30,
                                        spreadRadius: 6,
                                      )
                                    ]
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      )
                                    ),
                                    onPressed: (){
                                      _sakit();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Sick()));
                                    }, 
                                    child: Text(t.translate("sick"), style: TextStyle(color: Colors.white))
                                  ),
                                ),
                              ),
                          ),
                          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02)
                        ],
                      )
                    ),
                  ),
                ),
                // ElevatedButton(onPressed: (){
                //   _prefsCatcher();
                // }, child: Text("test prefs"))
              ],
            )
          ),
        // )
    );
  }
}