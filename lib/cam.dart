import 'dart:convert';

import 'package:absence/l10n/app_localizations.dart';
import 'package:absence/main.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';


class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
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

  // state validator
  bool _faceValid = false;
  // String? _detectedName;
  String _faceMessage = "";
  double? _similarity;

  File? _photo;
  bool _isSubmitting = false;

  // error treshold
  String? error;

  // Location Treshold
  double? _lat;
  double? _lng;
  String? _address;

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _getLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location Permission denied");
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _lat = pos.latitude;
    _lng = pos.longitude;

    final placemarks = await placemarkFromCoordinates(
      _lat!,
      _lng!,
    );

    final mark = placemarks.first;

    _address =
        "${mark.subLocality ?? ''}, ${mark.locality ?? ''}, ${mark.administrativeArea ?? ''}";
}

  Future<File> _drawGpsOverlay(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final now = DateTime.now();

    final text = """
    ${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}
    ${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}
    $_address
    """;

    img.drawString(
      image,
      text,
      font: img.arial24,
      x: 21,
      y: image.height - 139,
      color: img.ColorRgb8(0, 0, 0),
    );

    img.drawString(
      image,
      text,
      font: img.arial24,
      x: 20,
      y: image.height - 140,
      color: img.ColorRgb8(255, 255, 255),
    );

    final outFile = File(
      '${file.parent.path}/gps_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await outFile.writeAsBytes(img.encodeJpg(image, quality: 85));
    return outFile;
  }
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prefsCatcher();
  }

  Future<File> _normalizeImage(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception("Failed to decode image");
    }

    // Resize optimal untuk face recognition
    final resized = img.copyResize(decoded, width: 800);

    // Encode ulang ke JPEG (buang format aneh kamera)
    final jpg = img.encodeJpg(resized, quality: 75);

    final newFile = File(
      '${file.parent.path}/normalized_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await newFile.writeAsBytes(jpg);
    return newFile;
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
      await _getLocation();
      setState(() {
        _photo = File(image.path);
        _faceValid = false;
      });

      final normalized = await _normalizeImage(_photo!);
      final stamped = await _drawGpsOverlay(normalized);

      setState(() {
        _photo = stamped;
      });

      await recognizeFace(stamped);

      // final image = await _controller.takePicture();
      // debugPrint("Photo Taken: ${image.path}");

      // await _sendToCompreFace(image.path);
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

      // _isLoggedIn = prefs.getBool('isLoggedIn');
      print("savedUser: $_savedUser");
      print("savedToken: $_savedToken");
      print("savedName: $_savedName");
      print("Attendance type: $_savedAttType");
      print("Status: $_savedStatus");
      print("Shift Status: $_savedShiftType");
    });
  }

  Future<void> _updateStatusByTime() async {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    String status;
    // String attType;

    if (hour < 8 || (hour == 8 && minute <= 10)) {
      status = "Hadir";
      // attType = "Hadir";
    } else if (hour == 8 && minute >= 10 && minute <= 15) {
      status = "Terlambat";
      // attType = "Terlambat";
    } else if (hour == 8 && minute > 15 && minute <= 30) {
      status = "Terlambat";
      // attType = "Terlambat";
    } else if (hour == 8 && minute > 30 && minute <= 59) {
      status = "Terlambat";
      // attType = "Terlambat";
    } else {
      status = "Alpha";
      // attType = "Alpha";
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('status', status);

    setState(() {
      _savedStatus = status;
    });

    debugPrint("⏰ Status updated by time: $status");
  }

  Future<void> recognizeFace(File imageFile) async {
  setState(() {
    _faceValid = false;
    _similarity = null;
    _faceMessage = "Checking...";
  });

  final request = http.MultipartRequest(
    'POST',
    Uri.parse("https://cais-ai.cbinstrument.com/api/v1/recognition/recognize"),
  )
    ..headers['x-api-key'] = '23e225bf-8f28-4493-a870-39019954fdae'
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path, contentType: MediaType('image', 'jpeg')));

  final response = await request.send();
  final body = await response.stream.bytesToString();

  if (response.statusCode != 200) {
    setState(() {
      _faceMessage = "Failed to face verifying";
      _faceValid = false;
    });
    return;
  }

  final data = jsonDecode(body);
  final faces = data['result'];

  if (faces == null || faces.isEmpty) {
    setState(() {
      _faceMessage = "No face detected";
      _faceValid = false;
    });
    return;
  }

  if (faces.length != 1) {
    setState(() {
      _faceMessage = "Make sure only one face is visible";
      _faceValid = false;
    });
    return;
  }

  final result = data['result'][0];
  // final subjects = result['subjects'] as List?;
  final subjects = result['subjects'];

    if (subjects == null || subjects.isEmpty) {
      setState(() {
        _faceMessage = "Face Unknown";
        _faceValid = false;
      });
      return;
    }

    Map<String, dynamic>? matched;

    for (final s in subjects) {
      if (s['subject'] == _savedName) {
        matched = s;
        break;
      }
    }

  // if (subjects == null || subjects.isEmpty) {
  //   setState(() {
  //     _faceMessage = "Face Unknown";
  //     _faceValid = false;
  //   });
  //   return;
  // }

  // final matched = subjects.firstWhere(
  //   (s) => s['subject'] == _savedName,
  //   orElse: () => null,
  // );

  if (matched == null) {
    setState(() {
      _faceMessage = "Face is not Verified";
      _faceValid = false;
    });
    return;
  }

  final sim = matched['similarity'];

  setState(() {
    _similarity = sim;
    _faceValid = sim >= 0.95;
    _faceMessage = _faceValid
        ? "Face Verified"
        : "Face Unknown";
  });

  print("similarities : $_similarity");
  print("face valid : $_faceValid");
  print("face Message : $_faceMessage");
}

  Future<void> _submitAbsence() async {
    await _updateStatusByTime();

    if(_photo == null) return;
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

    String localDateTime() {
      final now = DateTime.now();
      return "${now.year.toString().padLeft(4, '0')}-"
            "${now.month.toString().padLeft(2, '0')}-"
            "${now.day.toString().padLeft(2, '0')} "
            "${now.hour.toString().padLeft(2, '0')}:"
            "${now.minute.toString().padLeft(2, '0')}:"
            "${now.second.toString().padLeft(2, '0')}";
    }

    final header = "Bearer $_savedToken";

    final body = {
      "name": _savedName,
      "attendance_type": _savedAttType,
      "timestamp": utcNow(),
      // "gps_latitude": -6.951720770791366,
      // "gps_longitude": 107.53339375994186,
      "location_name": "Margaasih",
      "start_date": localDateTime(),
      "end_date": localDateTime(),
      "duration_days": 1,
      "document_photo_masuk": photoData,
      "status": _savedStatus,
      "shift_type": _savedShiftType,
    };

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
      print("Absence Fuccessful");
      _thxForAbsence();
    } else {
      final body = jsonDecode(responses.body);
      _thxForAbsenceFailed();
      error = body['error'];
      print("Absence Failed");
    }
  }

  // Future<bool> _recognitionWithHombre(File imageFile) async {
    
  // }

  Future<void> _confirmSubmitAbsence() async {
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
                    Text("Confirmation", style: TextStyle(color: const Color.fromARGB(255, 219, 197, 0))),
                    Icon(Icons.warning_rounded, color: const Color.fromARGB(255, 219, 197, 0)),
                  ],
                ),
                Divider()
              ],
            ),
          content: 
          Text("R U Sureee????!!!!???", style: TextStyle(color: const Color.fromARGB(255, 61, 61, 61)),),
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
              child: Text("Cancel", style: TextStyle(color: Colors.white),)
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
              child: Text("Sure", style: TextStyle(color: Colors.white),)
            )
          ],
        );
      }
    );
  }

  Future<void> _thxForAbsenceFailed() async {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: 
            Column(
              children: [
                Text("Absence Failed", style: TextStyle(color: Colors.red)),
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
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: 
            Column(
              children: [
                Text("Thank You.. ^_^", style: TextStyle(color: Colors.green)),
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
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(t.translate("takePicture"), style: TextStyle(color: Colors.white)),
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
                ),
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white,),
                label: const Text("Take Photo", style: TextStyle(color: Colors.white),),
              ),
              SizedBox(height: 8),
              if (_faceMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _faceValid ? Icons.verified : Icons.error,
                        color: _faceValid ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _faceMessage,
                        style: TextStyle(
                          color: _faceValid ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // ElevatedButton(onPressed: (){ _prefsCatcher(); }, child: Text("Test Prefs"))
                    ],
                  ),
                ),
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
                  onPressed: _photo != null && _faceValid && !_isSubmitting
                  ? _confirmSubmitAbsence : null,
                  child: Text(_isSubmitting ? "Submitting..." : "Submit Absent", 
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