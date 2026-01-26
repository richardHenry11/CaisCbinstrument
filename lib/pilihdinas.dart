import 'package:absence/cuti.dart';
import 'package:absence/cutiLapangan.dart';
import 'package:absence/dashboard.dart';
import 'package:absence/drawer.dart';
import 'package:absence/fieldDuty.dart';
import 'package:absence/main.dart';
import 'package:absence/officeAbsence.dart';
import 'package:absence/sick.dart';
import 'package:absence/lateness.dart';
import 'package:absence/wfh.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final Att_type = "Dinas Luar";
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
        content: Text("goodbye :(", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        Center(child: Text("Absence", style: TextStyle(color: const Color.fromARGB(255, 122, 122, 122),),)),
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
            case "chart":
             Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => Lateness())
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue
            ),
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: Card(
                    color: const Color.fromARGB(255, 67, 57, 158),
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
                            child: Text("CBI Automation & Integrated System CAIS", 
                                          style: TextStyle(color: const Color.fromARGB(255, 202, 202, 202), 
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900
                                          ),
                                        ),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
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
                              child: Text("Dinas Kantor", style: TextStyle(color: Colors.white),)
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
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
                              child: Text("Dinas Lapangan", style: TextStyle(color: Colors.white))
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
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
                              child: Text("WFH", style: TextStyle(color: Colors.white))
                            ),
                          ),
                        SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
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
                              child: Text("Cuti", style: TextStyle(color: Colors.white))
                            ),
                          ),
                        SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
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
                              child: Text("Cuti Lapangan", style: TextStyle(color: Colors.white))
                            ),
                          ),
                        SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
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
                              child: Text("Sakit", style: TextStyle(color: Colors.white))
                            ),
                          ),
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02)
                      ],
                    )
                  ),
                ),
                // ElevatedButton(onPressed: (){
                //   _prefsCatcher();
                // }, child: Text("test prefs"))
              ],
            )
          ),
        )
    );
  }
}