import 'dart:convert';

import 'package:absence/l10n/app_localizations.dart';
import 'package:absence/lateness.dart';
import 'package:absence/lemur.dart';
import 'package:absence/main.dart';
import 'package:absence/pilihdinas.dart';
import 'package:absence/rackupAbsence.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as ktp;
import 'dart:io';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // SharedPrefs var
  String? _userPref;
  String? _tokenPrefs;
  String? _namePrefs;
  String? _idPrefs;
  bool? _isLoggedInPrefs;
  int? _employeesId;

  // photo profile var
  String? _photoProfile;
  String? _position;
  String? _name;
  String? _role;
  
  Future<ktp.Response?> safeGet(
      String url,
      Map<String, String> headers,
  ) async {
    try {
      return await ktp.get(Uri.parse(url), headers: headers);
    } on HandshakeException catch (_) {
      debugPrint("SSL Handshake Error → Auto logout");
      await _logoutExpired();
      return null;
    } on SocketException catch (_) {
      debugPrint("No Internet Connection");
      return null;
    } catch (e) {
      debugPrint("Unknown error: $e");
      return null;
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _dateDestroyer();
    await _prefsCatcher();
    await _loadPhoto();
  }

  Future<void> _dateDestroyer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('startDate');
    await prefs.remove('endDate');
  }

  Future<void> _prefsCatcher() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _userPref = _prefs.getString('user') ?? 'who are you?';
    _tokenPrefs = _prefs.getString('token') ?? 'there is no token here, go away';
    _namePrefs = _prefs.getString('name') ?? 'who are you again?';
    _idPrefs = _prefs.getString('id') ?? 'unIDfied :D';
    _isLoggedInPrefs = _prefs.getBool('isLoggedIn');
    _employeesId = _prefs.getInt('employeesId') ?? 0;

    // print save prefs state
    print("user: $_userPref");
    print("token: $_tokenPrefs");
    print("name: $_namePrefs");
    print("id: $_idPrefs");
    print("isLoggedIn: $_isLoggedInPrefs");
    print("employees ID: $_employeesId");
  }

  Future<void> _loadPhoto() async {
    final url = "https://cais.cbinstrument.com/auth/user/profile/?userID=$_idPrefs";
    final headers = {
      "Authorization": "Bearer $_tokenPrefs"
    };



    final responses = await safeGet(url, headers);

    if (responses == null) return;

    if (responses.statusCode == 401) {
      debugPrint("Token expired → auto logout");
      await _logoutExpired();
      return;
    }

     // 🔥 Check wether its json or html
    if (!responses.body.trim().startsWith('{')) {
      debugPrint("Rsponse ain't not JSON → it's prolly redirect/login");
      await _logoutExpired();
      return;
    }

    if (responses.statusCode != 200) {
      debugPrint("Request gagal, kemungkinan token invalid / expired");
      return;
    }

    // declared body
      final body = jsonDecode(responses.body);

    if (responses.statusCode == 200) {
      List<dynamic> photoList = jsonDecode(body['photo']);

      // ambil foto pertama
      String firstPhoto = photoList.isNotEmpty ? photoList[0] : '';

      setState(() {
        // merge base url 
        _photoProfile = firstPhoto.isNotEmpty ? 
          'https://cais.cbinstrument.com/$firstPhoto' :
           null;
        _name = body['name'];
        _position = body['position'];
        _role = body['role'];
      });

      debugPrint("Photo: $_photoProfile");
      debugPrint("Name: $_name");
      debugPrint("Position: $_position");
      debugPrint("Role: $_role");
    }
  }

  // Future<void> _loadPhoto() async {
  //   final url = "http://cais-ai.cbinstrument.com/api/v1/recognition/faces?subject=$_namePrefs";
  //   final headers = {
  //     "x-api-key" : "23e225bf-8f28-4493-a870-39019954fdae"
  //   };

  //   final response = await ktp.get(  
  //     Uri.parse(url),
  //     headers: headers
  //   );

  //   final body = jsonDecode(response.body);
  //   print(body);

  //   if (response.statusCode == 200) {
  //     final faces = body['faces'];
  //     if  (faces.isNotEmpty) {
  //       final face = faces.first;
  //       debugPrint("Face ID: ${face['image_id']}");
  //       debugPrint("Image ID: ${face['subject']}");
  //     }
  //   }
  // }

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

  Future<void> _logoutExpired() async {
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
        content: Text(t.translate("expired"), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget menuCard(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.cyanAccent.withOpacity(0.3),
      highlightColor: Colors.cyan.withOpacity(0.1),
      onTap: onTap, // 🔥 anything here!
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 22, 84, 134),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent,
              blurRadius: 5,
              spreadRadius: 3,
            ),
            // BoxShadow(
            //   color: Colors.cyanAccent.withOpacity(0.4),
            //   blurRadius: 28,
            //   spreadRadius: 4,
            // ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.cyanAccent),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 23, 58),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 174, 174, 174),
        title: 
        Center(child: Image.asset("assets/logoBiru.png", width: MediaQuery.sizeOf(context).width * 0.45, height: 80,)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: 
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlue
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    _photoProfile != null ? NetworkImage(_photoProfile!) : null,
                child: _photoProfile == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            )
          )
        ]
      ),
      body: 
      Column(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 1,
            child: 
              Container(
                color: const Color.fromARGB(255, 22, 84, 134),
                child: 
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 24.0, right: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("$_name", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),),
                          Text("$_position", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w300),)
                        ],
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          // border: Border.all(
                          //   color: Colors.white,
                          //   width: 1,
                          // ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ),
          
          // Container
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2, // 2 row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1, // square (adjustable height and width)
              children: [
                // menuCard(Icons.dashboard, "Dashboard",
                //   (){
                //     // Button funct
                //   }
                // ),
                menuCard(Icons.how_to_reg, t.translate("absentDashboard"),
                  (){
                    // Button funct
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => PilihDinas())
                    );
                  }
                ),
                menuCard(Icons.location_on, t.translate("reportLap"),
                  (){
                    // Button funct
                   
                  }
                ),
                menuCard(Icons.nightlight, t.translate("reportLemur"),
                  (){
                    // Button funct
                     Navigator.push(context, MaterialPageRoute(builder: (context) => Lemur()));
                  }
                ),
                menuCard(Icons.bar_chart, t.translate("disiplineGraph"),
                  (){
                    // Button funct
                  }
                ),
                menuCard(Icons.inventory, t.translate("inputGoods"),
                  (){
                    // Button funct
                  }
                ),
                menuCard(Icons.warning, t.translate("lateness"),
                  (){
                    // Button funct
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => Lateness())
                    );
                  }
                ),
                menuCard(Icons.access_time, t.translate("rackupAbsent"), 
                  (){
                    //Button Funct 
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => RackupAbsence())
                    );
                  }
                ),
                menuCard(
                  Icons.logout,
                  t.translate("logout"),
                  () async {
                    await _logout();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}