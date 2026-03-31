import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DateHelper {
  static DateTime get dateFrom {
    final year = DateTime.now().year;
    return DateTime(year, 1, 1);
  }

  static DateTime get dateTo {
    final year = DateTime.now().year;
    return DateTime(year, 12, 31);
  }
}

class DashboardDua extends StatefulWidget {
  const DashboardDua({super.key});

  @override
  State<DashboardDua> createState() => _DashboardDuaState();
}

class _DashboardDuaState extends State<DashboardDua> {
  //========================== Global Var Declaration here!! ===============
   String? _savedToken;
   String? _encodedName;

   String formatDate(DateTime date) {
      return "${date.year.toString().padLeft(4, '0')}-"
            "${date.month.toString().padLeft(2, '0')}-"
            "${date.day.toString().padLeft(2, '0')}";
    }

    String? _savedHadir;
    String? _savedCuti;
    String? _savedWFH;
    String? _savedHalfCuti;
    String? _fieldDuty;
    String? _sick;
    String? _fieldCuti;

    String? _status;
    String? _timeCheckin;
    String? location;


  //========================== Functions here!!! ===========================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialization();
  }

  Future<void> _initialization() async {
    await _getPrefs();
    await _httpGet();
    _latestAbsence();
  }

  // Shared Prefs Catcher
  Future<void> _getPrefs() async {
    SharedPreferences _getter = await SharedPreferences.getInstance();
    _savedToken = _getter.getString('token') ?? "There's no token here go away!!";
    String _savedName = _getter.getString('name') ?? "no name";
    _encodedName = Uri.encodeComponent(_savedName);

    print("token: $_savedToken\nname: $_encodedName");
  }

  // Http Comm last absence
  Future<void> _latestAbsence() async {
    try {
      final token = _savedToken;
      final name = _encodedName;
      final url = "https://cais.cbinstrument.com/auth/absensi/saya?nama=$name";
      final headers = {"Authorization" : "Bearer $token"};
      final fetch = await http.get(
        Uri.parse(url),
        headers: headers
      );

      if(!mounted) return;
      if (fetch.statusCode == 200) {
        final awak = jsonDecode(fetch.body);
        print("awak last absence: $awak");
        setState(() {
          _status = awak['status'];
          _timeCheckin = awak['waktu_checkin'];
          location = awak['lokasi'];
        });
      } else {
        final bodi = jsonDecode(fetch.body);
        print("error occured latest Absence: $bodi");
      }
    } catch (e) {
      print("error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Terjadi kesalahan koneksi / server",
          style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  } 

  // Http Comm current leave, sick, 1/2Leave, absence
  Future<void> _httpGet() async {
    try {
      final name = _encodedName;
      final from = formatDate(DateHelper.dateFrom);
      final to = formatDate(DateHelper.dateTo);
      final url = "https://cais.cbinstrument.com/auth/absensi/rekap-karyawan?nama=$name&dateFrom=$from&dateTo=$to";
      final token = _savedToken;
      final headers = {"Authorization" : "Bearer $token"};

      print("token: $_savedToken\nheaders: $headers");

      final fetchData = await http.get(
        Uri.parse(url),
        headers: headers
      ).timeout(const Duration(seconds: 10));

      if(!mounted) return;
      if (fetchData.statusCode == 200) {
        final awak = jsonDecode(fetchData.body);
        print("bodi: $awak");
        setState(() {
          _savedHadir = awak['hadir'].toString();
          _savedWFH = awak['wfh'].toString();
          _savedCuti = awak['cuti_tahunan'].toString();
          _savedHalfCuti = awak['cuti_1_2'].toString();
          _fieldDuty = awak['dinas_lapangan'].toString();
          _sick = awak['sakit'].toString();
          _fieldCuti = awak['cuti_lapangan'].toString();
          print(_savedHalfCuti);
        });
      } else {
        final bodi = jsonDecode(fetchData.body);
        print("Failed to Fetch Data $bodi");
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Gagal Menerima respon server ${fetchData.statusCode}",
            style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      print("error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Terjadi kesalahan koneksi / server",
          style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }


  //========================== UI Builder here!! ===========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF182234),

      //============================= App Bar ==============================
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Dashboard", style: TextStyle(
                // fontSize: 15,
                // fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
        backgroundColor: Color(0xFF1e293b)
      ),
      
      //============================= Body =================================
      body: 
      SingleChildScrollView(
        child: 
        Center(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: 
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(34, 211, 238, 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1e3a8a),
                        Color(0xFF1e293b),
                      ],
                    ),
                  ),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: 
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Colors.white),
                        // ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(MaterialCommunityIcons.signal, color: Colors.cyanAccent, size: 30,),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: 
                                    Text("Rekapitulasi Absensi Tahun Ini", style: TextStyle(color: Colors.white, fontSize: 18)),
                                  ),
                                )
                              ],
                            ),
                            GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              crossAxisCount: 2, // 2 row
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color.fromRGBO(71, 85, 105, 0.4)
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(15, 23, 42, 0.8),
                                      Color.fromRGBO(30, 41, 59, 0.6),
                                    ],
                                  ),
                                  ),
                                  child: Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: 
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(MaterialCommunityIcons.check_circle, color: Color(0xFF22d3ee)),
                                        ),
                                        Text("$_savedHadir", style: TextStyle(color: Colors.white, fontSize:30, fontWeight: FontWeight.bold)),
                                        Text("Hadir", style: TextStyle(color: Color(0xff94a3b8), fontSize: 15,),)
                                      ],
                                    ),
                                  )
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color.fromRGBO(71, 85, 105, 0.4)
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(15, 23, 42, 0.8),
                                      Color.fromRGBO(30, 41, 59, 0.6),
                                    ],
                                  ),
                                  ),
                                  child: Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: 
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(MaterialCommunityIcons.check_circle, color: Color(0xFF22d3ee)),
                                        ),
                                        Text("$_savedWFH", style: TextStyle(color: Colors.white, fontSize:30, fontWeight: FontWeight.bold)),
                                        Text("WFH", style: TextStyle(color: Color(0xff94a3b8), fontSize: 15,),)
                                      ],
                                    ),
                                  )
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color.fromRGBO(71, 85, 105, 0.4)
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(15, 23, 42, 0.8),
                                      Color.fromRGBO(30, 41, 59, 0.6),
                                    ],
                                  ),
                                  ),
                                  child: Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: 
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(MaterialCommunityIcons.check_circle, color: Color(0xFF22d3ee)),
                                        ),
                                        Text("$_savedCuti", style: TextStyle(color: Colors.white, fontSize:30, fontWeight: FontWeight.bold)),
                                        Text("Cuti", style: TextStyle(color: Color(0xff94a3b8), fontSize: 15,),)
                                      ],
                                    ),
                                  )
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color.fromRGBO(71, 85, 105, 0.4)
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(15, 23, 42, 0.8),
                                      Color.fromRGBO(30, 41, 59, 0.6),
                                    ],
                                  ),
                                  ),
                                  child: Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: 
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(MaterialCommunityIcons.check_circle, color: Color(0xFF22d3ee)),
                                        ),
                                        Text("$_fieldDuty", style: TextStyle(color: Colors.white, fontSize:30, fontWeight: FontWeight.bold)),
                                        Text("Dinas Lapangan", style: TextStyle(color: Color(0xff94a3b8), fontSize: 15,),)
                                      ],
                                    ),
                                  )
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color.fromRGBO(71, 85, 105, 0.4)
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(15, 23, 42, 0.8),
                                      Color.fromRGBO(30, 41, 59, 0.6),
                                    ],
                                  ),
                                  ),
                                  child: Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: 
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(MaterialCommunityIcons.check_circle, color: Color(0xFF22d3ee)),
                                        ),
                                        Text("$_sick", style: TextStyle(color: Colors.white, fontSize:30, fontWeight: FontWeight.bold)),
                                        Text("Sakit", style: TextStyle(color: Color(0xff94a3b8), fontSize: 15,),)
                                      ],
                                    ),
                                  )
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color.fromRGBO(71, 85, 105, 0.4)
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(15, 23, 42, 0.8),
                                      Color.fromRGBO(30, 41, 59, 0.6),
                                    ],
                                  ),
                                  ),
                                  child: Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: 
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(MaterialCommunityIcons.check_circle, color: Color(0xFF22d3ee)),
                                        ),
                                        Text("$_fieldCuti", style: TextStyle(color: Colors.white, fontSize:30, fontWeight: FontWeight.bold)),
                                        Text("Cuti Lapangan", style: TextStyle(color: Color(0xff94a3b8), fontSize: 15,),)
                                      ],
                                    ),
                                  )
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //=============================================== Latest Absence ==================================================
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: 
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(34, 211, 238, 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff1e3a8a),
                        Color(0xFF1e40af),
                      ],
                    ),
                  ),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: 
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //     color: Colors.white,
                              //     width: 1
                              //   )
                              // ),
                              child: 
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color.fromRGBO(34, 211, 238, 0.4),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color.fromRGBO(34, 211, 238, 0.25),
                                            Color.fromRGBO(14, 165, 233, 0.15),
                                          ],
                                        ), 
                                      ),
                                      child: Card(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        child: 
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Icon(MaterialCommunityIcons.check_circle, color: Color(0xff22d3ee)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("$_status", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                      Text("Status Hari ini", style: TextStyle(color: Color(0xff94a3b8)),)
                                    ],
                                  )
                                ],
                              )
                            ),
                            Container(
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //     color: Colors.white,
                              //     width: 1
                              //   )
                              // ),
                              child: 
                              Padding(
                                padding: EdgeInsetsGeometry.only(right: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xff22d3ee),
                                        Color(0xFF0ea5e9),
                                      ],
                                    ), 
                                  ),
                                  child: 
                                  Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: 
                                    Padding(
                                      padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 7, bottom: 7),
                                      child: Text("$_status", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                        SizedBox(width: MediaQuery.sizeOf(context).width * 0.75, child: Divider()),
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),

                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.75,
                          child: 
                          Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: Colors.white),
                            // ),
                            child: 
                            Card(
                              color: Color.fromRGBO(15, 23, 42, 0.4),
                              child: 
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(MaterialCommunityIcons.clock, color: Color(0xff60a5fa),),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text("$_timeCheckin", style: TextStyle(color: Colors.white),),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),

                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.75,
                          child: 
                          Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: Colors.white),
                            // ),
                            child: 
                            Card(
                              color: Color.fromRGBO(15, 23, 42, 0.4),
                              child: 
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(MaterialCommunityIcons.map_marker, color: Color(0xff60a5fa),),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text("$location", style: TextStyle(color: Colors.white),),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}