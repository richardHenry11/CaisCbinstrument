import 'dart:convert';

import 'package:absence/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absence/l10n/app_localizations.dart';
// import 'package:path/path.dart' as p;

class CamAndFile extends StatefulWidget {
  const CamAndFile({super.key});

  @override
  State<CamAndFile> createState() => _CamAndFileState();
}

class _CamAndFileState extends State<CamAndFile> {
  final ImagePicker _picker = ImagePicker();

  Future<String> imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  // var SharedPrefs
  String? _savedUser;
  String? _savedToken;
  // String? _isLoggedIn;
  String? _savedName;
  // String? _savedType;
  String? _savedStatus;
  String? _savedAttType;
  String? _savedShiftType;
  String? _savedStartTime;
  String? _savedEndTime;
  int? _savedDayDuration;

  File? _photo;
  bool _isSubmitting = false;

  // error treshold
  String? error;

  Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prefsCatcher();
  }

  Future<File?> _takePhotoFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75
    );

    if (image == null) {
      return null;
    }
    return File(image.path);
  }

  Future<void> _takePhoto() async {
    final granted = await requestCameraPermission();
    if(!granted){
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
      return;
    }
    final XFile? image = await _picker.pickImage(
                                                source:ImageSource.camera,
                                                preferredCameraDevice: CameraDevice.front,
                                                imageQuality: 75
                                                );
    if (image != null) {
      setState(() {
        _photo = File(image.path);
      });

      debugPrint("Photo Taken: ${image.path}");

      // // Continue Absence
      // _submitAbsence();
    }
  }

  Future<void> _prefsCatcher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUser = prefs.getString('user') ?? "Who is there?";
      _savedToken = prefs.getString('token') ?? "this is token";
      _savedName = prefs.getString('name') ?? "who is this?";
      _savedStatus = prefs.getString('status') ?? "which type r u?";
      _savedAttType = prefs.getString('attendance_type') ?? "what att type r u?";
      _savedShiftType = prefs.getString('shift_type') ?? "what ShiftType is this?";
      _savedStartTime = prefs.getString('start_date') ?? "what date?";
      _savedEndTime = prefs.getString('end_date') ?? "what time?";
      _savedDayDuration = prefs.getInt('duration_days') ?? 0;

      // _isLoggedIn = prefs.getBool('isLoggedIn');
      print("savedUser: $_savedUser");
      print("savedToken: $_savedToken");
      print("savedName: $_savedName");
      print("Attendance type: $_savedAttType");
      print("Status: $_savedStatus");
      print("Shift Status: $_savedShiftType");
      print("start Time: $_savedStartTime");
      print("end Time: $_savedEndTime");
      print("day duration: $_savedDayDuration");
    });
  }

  Future<void> _submitAbsence() async {
    // if (_nameController.text.isEmpty || _photo == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please Fill the Blanks...")),
    //   );
    //   return;
    // }

    // final bytes = await _photo!.readAsBytes();
    // final base64image = base64Encode(bytes);
    // final ext = _photo!.path.split('.').last;
    // final mime = ext == 'png' ? 'image/png' : 'image/jpeg';

    final base64Image = await imageToBase64(_photo!);
    final photoData = "data:image/jpeg;base64,$base64Image";

    debugPrint("PHOTO LENGTH: ${photoData.length}");
    debugPrint("PHOTO PREFIX: ${photoData.substring(0, 30)}");
    debugPrint("full photo: ${photoData}");

    String utcNow() {
      return DateTime.now()
          .toUtc()
          .toIso8601String()
          .split('.')
          .first + 'Z';
    }

    // String localDateTime() {
    //   final now = DateTime.now();
    //   return "${now.year.toString().padLeft(4, '0')}-"
    //         "${now.month.toString().padLeft(2, '0')}-"
    //         "${now.day.toString().padLeft(2, '0')} "
    //         "${now.hour.toString().padLeft(2, '0')}:"
    //         "${now.minute.toString().padLeft(2, '0')}:"
    //         "${now.second.toString().padLeft(2, '0')}";
    // }

    final header = "Bearer $_savedToken";

    final body = {
      "name": _savedName,
      "attendance_type": _savedAttType,
      "timestamp": utcNow(),
      // "gps_latitude": -6.951720770791366,
      // "gps_longitude": 107.53339375994186,
      "location_name": "Margaasih, KIP",
      "start_date": _savedStartTime,
      "end_date": _savedEndTime,
      "duration_days": _savedDayDuration,
      "document_photo_bukti1": photoData,
      "status": _savedStatus,
      "shift_type": "masuk",
    };

    print("Bodi: $body");

    final responses = await http.post(
      Uri.parse("https://cais.cbinstrument.com/auth/input/absensi"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": header},
      body: jsonEncode(body)
    );

    if(responses.statusCode == 200) {
        final resBody = jsonDecode(responses.body);
        print(resBody);
      print("Absence FUCKcessful");
      _thxForAbsence();
    } else {
      final bodi = jsonDecode(responses.body);

      error = bodi['error'];
      print("Absence Failed");
      _thxForAbsenceFailed();
    }
  }

  Future<void> _confirmSubmitAbsence() async {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: 
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.translate("confirm"), style: TextStyle(color: const Color.fromARGB(255, 219, 197, 0))),
                    Icon(Icons.warning_rounded, color: const Color.fromARGB(255, 219, 197, 0)),
                  ],
                ),
                Divider()
              ],
            ),
          content: 
          Text(t.translate("rusure"), style: TextStyle(color: const Color.fromARGB(255, 61, 61, 61)),),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
                backgroundColor: Colors.red
              ),
              onPressed: (){
                // button Funct
                 Navigator.of(context).pop();
              }, 
              child: Text(t.translate("cancel"), style: TextStyle(color: Colors.white),)
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
                backgroundColor: Colors.green
              ),
              onPressed: (){
                // button Funct
                _submitAbsence();
                Navigator.of(context).pop();
              }, 
              child: Text(t.translate("sure"), style: TextStyle(color: Colors.white),)
            )
          ],
        );
      }
    );
  }

  Future<void> _thxForAbsenceFailed() async {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: 
            Column(
              children: [
                Text(t.translate("failed"), style: TextStyle(color: Colors.red)),
                Divider()
              ],
            ),
          content: Text("$error", style: TextStyle(color: Colors.black),),
          actions: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
                  backgroundColor: Colors.green
                ),
                onPressed: (){ error == 'Token tidak valid' ?
                  // button Funct
                   _logout() : Navigator.of(context).pop();
                }, 
                child: Text("OK", style: TextStyle(color: Colors.white),)
              ),
            )
          ],
        );
      }
    );
  }

  Future<void> _thxForAbsence() async {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: 
            Column(
              children: [
                Text(t.translate("thx"), style: TextStyle(color: Colors.green)),
                Divider()
              ],
            ),
          actions: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
                  backgroundColor: Colors.green
                ),
                onPressed: (){
                  // button Funct
                  Navigator.of(context).pop();
                }, 
                child: Text("OK", style: TextStyle(color: Colors.white),)
              ),
            )
          ],
        );
      }
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final t = AppLocalizations.of(context)!;
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (_) => MyHomePage()),
      (route) => false, 
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: 
        Text(t.translate("dadah"), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(t.translate("takePhoto"), style: TextStyle(color: Colors.white)),
      ),
      body:
        Padding(
          padding: const EdgeInsets.all(8),
          child:
          Column(
            children: [
                Expanded(
                  child: _photo == null 
                  ? Center(child: Text(t.translate("photoDesk"), style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w800),))
                  : 
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(20),
                    child: 
                      Image.file(_photo!, fit: BoxFit.cover,
                    )
                  )
                ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
                    ),
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt_rounded, color: Colors.white,),
                    label: Text(t.translate("takePicture"), style: TextStyle(color: Colors.white),),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
                    ),
                    onPressed: () async {
                      final file = await _takePhotoFromGallery();

                      if (file != null || file == null) {
                        setState(() {
                          _photo = file;
                        });
                      }
                    },
                    icon: const Icon(Icons.folder, color: Colors.white,),
                    label: Text(t.translate("gallery"), style: TextStyle(color: Colors.white),),
                  ),
                  // ElevatedButton(onPressed: (){ _prefsCatcher(); }, child: Text("test"))
                ],
              ),
              SizedBox(height: 8),
              // ElevatedButton(
              //   onPressed: () {
              //     if (_photo == null) {
              //       debugPrint("Belum ada foto");
              //       return;
              //     }

              //     final fileName = p.basename(_photo!.path);
              //     final extension = p.extension(_photo!.path);
              //     final fileSize = _photo!.lengthSync();

              //     debugPrint("📸 File name : $fileName");
              //     debugPrint("📂 Extension : $extension");
              //     debugPrint("📦 Size      : ${fileSize ~/ 1024} KB");
              //     debugPrint("📍 Full path : ${_photo!.path}");
              //   },
              //   child: const Text("check file Photo"),
              // ),
              // SizedBox(height: 8),
              // TextField(
              //   controller: _nameController,
              //   decoration: const InputDecoration(
              //     labelText: "Name",
              //     border: OutlineInputBorder()
              //   ),
              // ),
              // SizedBox(height: 8),
              // DropdownButtonFormField(
              //   value: _status,
              //   items: const [
              //     DropdownMenuItem(value: "Masuk", child: Text("Masuk")),
              //     DropdownMenuItem(value: "Tidak Masuk", child: Text("Tidak Masuk")),
              //   ], 
              //   onChanged: (val) => setState(() => _status = val!),
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //   labelText: "Status",
              //   ),
              // ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 1,
                height: MediaQuery.sizeOf(context).height * 0.08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting ? const Color.fromARGB(255, 211, 211, 211) : const Color.fromARGB(255, 87, 201, 91),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
                  ),
                  onPressed: _photo != null && !_isSubmitting
                  ? _confirmSubmitAbsence : null,
                  child: Text(_isSubmitting ? t.translate("isSubmit") : t.translate("Submit"), 
                    style: TextStyle(color: _isSubmitting ? const Color.fromARGB(255, 74, 74, 74) : Colors.white, 
                    fontSize: 15, 
                    fontWeight: FontWeight.w900)
                  )
                ),
              )
            ],
          )
        )
    );
  }
}