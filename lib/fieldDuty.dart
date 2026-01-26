
import 'dart:async';

import 'package:absence/cam.dart';
import 'package:absence/camPulang.dart';
import 'package:absence/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

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
           "${time.year} "
           "${time.hour.toString().padLeft(2, '0')}."
           "${time.minute.toString().padLeft(2, '0')}."
           "${time.second.toString().padLeft(2, '0')}";
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return months[month - 1];
  }
}

class FieldDuty extends StatefulWidget {
  const FieldDuty({super.key});

  @override
  State<FieldDuty> createState() => _FieldDutyState();
}

class _FieldDutyState extends State<FieldDuty> {
  String? _savedUser;
  String? _savedToken;
  // String? _isLoggedIn;
  String? _savedName;
  String? _savedStatus;
  String? _savedAttType;
  String? _savedShiftType;

  // latlong vars
  final LatLng officeLocation =
      LatLng(-6.951720770791366, 107.53339375994186);
  // final double allowedRadius = 200; // meters

  LatLng? currentLocation;
  double? distance;

  // stream location
  StreamSubscription<Position>? positionStream;
  
  // KIP office locations



  // TKI Office Location

  // button State
  // bool _canPressButton = false;
  // bool _isCheckingLocation = false;

  @override
  void initState() {
    super.initState();
    // this is prefsCatcher
    _prefsCatcher();
    _initLocation();
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

      // _isLoggedIn = prefs.getBool('isLoggedIn');
      print("savedUser: $_savedUser");
      print("savedToken: $_savedToken");
      print("savedName: $_savedName");
      print("Attendance type: $_savedAttType");
      print("Status: $_savedStatus");
      print("Shift Status: $_savedShiftType");
    });
  }

  void _masukShiftType() async {
    final masuk = "masuk";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('shift_type', masuk);

    setState(() {
      _savedShiftType = masuk;
    });

    print('shift_type: $masuk');
  }

  void _pulangShiftType() async {
    final pulang = "pulang";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('shift_type', pulang);

    setState(() {
      _savedShiftType = pulang;
    });

    print('shift_type: $pulang');
  }


  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((position) {
      final dist = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLocation.latitude,
        officeLocation.longitude,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        distance = dist;
        // _canPressButton = dist <= allowedRadius;
        // _isCheckingLocation = false;
      });

      // debugPrint("Distance: ${dist.toStringAsFixed(2)} m");
    });
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
  void dispose(){
    positionStream?.cancel();
    positionStream = null;
    super.dispose();
  }

  bool get _isShiftSelected => _savedShiftType == "masuk" || _savedShiftType == "pulang";

  @override
  Widget build(BuildContext context) {
    return
    Scaffold(
      body: 
      SizedBox(
        width: MediaQuery.sizeOf(context).width * 1,
        child: Container(
          color: Colors.blue,
          child: Column(
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
                        // Text("testing wa atuh euy", style: TextStyle(color: Colors.white),),
                        Card(
                          color: const Color.fromARGB(255, 67, 57, 158),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: const Color.fromARGB(255, 89, 71, 252),
                              width: 2,
                            ),
                          ),
                          child:
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, color: Colors.white, size: 12,),
                                  Padding(
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.005),
                                    child: Text("GPS Validator - Office", style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.05,),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                            "GPS Verified - Flexible Area",
                                          style: const TextStyle(color: Colors.white, fontSize: 8),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, top: MediaQuery.of(context).size.height * 0.01),
                                child: Text("PT Cakrawala Bima Instrument, Jelegong, Kec. Kutawaringin, Kabupaten Bandung", style: TextStyle(color: Colors.white, fontSize: 10),),
                              ),
                              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                              Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, right:MediaQuery.of(context).size.width * 0.04 ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Distance to Office: ", style: TextStyle(color: Colors.white, fontSize: 12)),
                                    Text(distance == null ? "calculating..." : "${distance!.toStringAsFixed(2)} Meter", style: TextStyle(color: Colors.white, fontSize: 12),)
                                  ],
                                ),
                              ),
                              SizedBox(
                              height: MediaQuery.sizeOf(context). height * 0.4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: officeLocation,
                                    initialZoom: 15,
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all,
                                    ),
                                  ),
                                  children: [
                                    // MAP TILE
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.absence',
                                    ),

                                    // OFFICE MARKER
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: officeLocation,
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_city,
                                            color: Colors.blue,
                                            size: 36,
                                          ),
                                        ),

                                        // USER MARKER
                                        if (currentLocation != null)
                                          Marker(
                                            point: currentLocation!,
                                            width: 40,
                                            height: 40,
                                            child: const Icon(
                                              Icons.my_location,
                                              color: Colors.lightBlueAccent,
                                              size: 28,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                            ],
                          )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.3,
                              child:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(10)
                                  ),
                                  backgroundColor: _savedShiftType == "masuk" ? Colors.lightBlueAccent : const Color.fromARGB(255, 220, 220, 220) 
                                ),
                                onPressed: (){
                                  // button Funct
                                  _masukShiftType();
                                }, 
                                child: Text("Masuk", style: TextStyle(color: _savedShiftType == "masuk" ? Colors.white : Colors.black))
                              )
                            ),

                            // Pulang
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.3,
                              child:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(10)
                                  ),
                                  backgroundColor: _savedShiftType == "pulang" ? Colors.lightBlueAccent : const Color.fromARGB(255, 220, 220, 220) 
                                ),
                                onPressed: (){
                                  // button Funct
                                  _pulangShiftType();
                                }, 
                                child: Text("Pulang", style: TextStyle(color: _savedShiftType == "pulang" ? Colors.white : Colors.black))
                              )
                            )
                          ],
                        ),
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.72,
                          height: MediaQuery.sizeOf(context).height * 0.07,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.grey;
                                }
                                return Colors.lightBlueAccent;
                              }),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            onPressed: _isShiftSelected
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: _savedShiftType == 'masuk' ? (_) => Camera() : (_) => CamPulang()),
                                    );
                                  }
                                : null,

                            child: Text(
                              !_isShiftSelected
                                  ? "Which one"
                                  : "Tap To Absent",
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
        ),
      ),
    );
  }
}