// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:path/path.dart' as p;

// class Camera extends StatefulWidget {
//   const Camera({super.key});

//   @override
//   State<Camera> createState() => _CameraState();
// }

// class _CameraState extends State<Camera> {
//   final ImagePicker _picker = ImagePicker();

//   Future<String> imageToBase64(File imageFile) async {
//     final bytes = await imageFile.readAsBytes();
//     return base64Encode(bytes);
//   }

//   // var SharedPrefs
//   String? _savedUser;
//   String? _savedToken;
//   // String? _isLoggedIn;
//   String? _savedName;
//   // String? _savedType;
//   String? _savedStatus;
//   String? _savedAttType;
//   String? _savedShiftType;

//   File? _photo;
//   bool _isSubmitting = false;

//   Future<bool> requestCameraPermission() async {
//   final status = await Permission.camera.request();
//   return status.isGranted;
// }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _prefsCatcher();
//   }

//   Future<void> _takePhoto() async {
//     final granted = await requestCameraPermission();
//     if(!granted){
//         ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Camera permission denied")),
//       );
//       return;
//     }
//     final XFile? image = await _picker.pickImage(
//                                                 source:ImageSource.camera,
//                                                 preferredCameraDevice: CameraDevice.front,
//                                                 imageQuality: 75
//                                                 );
//     if (image != null) {
//       setState(() {
//         _photo = File(image.path);
//       });

//       debugPrint("Photo Taken: ${image.path}");

//       // // Continue Absence
//       // _submitAbsence();
//     }
//   }

//   Future<void> _prefsCatcher() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _savedUser = prefs.getString('user') ?? "Who is there?";
//       _savedToken = prefs.getString('token') ?? "this is token";
//       _savedName = prefs.getString('name') ?? "who is this?";
//       _savedStatus = prefs.getString('status') ?? "which type r u?";
//       _savedAttType = prefs.getString('attendance_type') ?? "what att type r u?";
//       _savedShiftType = prefs.getString('shift_type') ?? "what ShiftType is this?";

//       // _isLoggedIn = prefs.getBool('isLoggedIn');
//       print("savedUser: $_savedUser");
//       print("savedToken: $_savedToken");
//       print("savedName: $_savedName");
//       print("Attendance type: $_savedAttType");
//       print("Status: $_savedStatus");
//       print("Shift Status: $_savedShiftType");
//     });
//   }

//   Future<void> _submitAbsence() async {
//     // if (_nameController.text.isEmpty || _photo == null) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(content: Text("Please Fill the Blanks...")),
//     //   );
//     //   return;
//     // }

//     // final bytes = await _photo!.readAsBytes();
//     // final base64image = base64Encode(bytes);
//     // final ext = _photo!.path.split('.').last;
//     // final mime = ext == 'png' ? 'image/png' : 'image/jpeg';

//     final base64Image = await imageToBase64(_photo!);
//     final photoData = "data:image/jpeg;base64,$base64Image";

//     debugPrint("PHOTO LENGTH: ${photoData.length}");
//     debugPrint("PHOTO PREFIX: ${photoData.substring(0, 30)}");
//     debugPrint("full photo: ${photoData}");

//     String utcNow() {
//       return DateTime.now()
//           .toUtc()
//           .toIso8601String()
//           .split('.')
//           .first + 'Z';
//     }

//     String localDateTime() {
//       final now = DateTime.now();
//       return "${now.year.toString().padLeft(4, '0')}-"
//             "${now.month.toString().padLeft(2, '0')}-"
//             "${now.day.toString().padLeft(2, '0')} "
//             "${now.hour.toString().padLeft(2, '0')}:"
//             "${now.minute.toString().padLeft(2, '0')}:"
//             "${now.second.toString().padLeft(2, '0')}";
//     }

//     final header = "Bearer $_savedToken";

//     final body = {
//       "name": _savedName,
//       "attendance_type": _savedAttType,
//       "timestamp": utcNow(),
//       // "gps_latitude": -6.951720770791366,
//       // "gps_longitude": 107.53339375994186,
//       "location_name": "Margaasih, KIP",
//       "start_date": localDateTime(),
//       "end_date": localDateTime(),
//       "duration_days": 1,
//       "document_photo": photoData,
//       "status": _savedStatus,
//       "shift_type": _savedShiftType,
//     };

//     final responses = await http.post(
//       Uri.parse("https://cais.cbinstrument.com/auth/input/absensi"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": header},
//       body: jsonEncode(body)
//     );

//     if(responses.statusCode == 200) {
//         final resBody = jsonDecode(responses.body);
//         print(resBody);
//       print("Absence Fuccessful");
//     } else {
//       print("Absence Failed");
//     }
//   }

//   Future<void> _confirmSubmitAbsence() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false, 
//       builder: (context) {
//         return AlertDialog(
//           title: 
//             Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Confirmation", style: TextStyle(color: const Color.fromARGB(255, 219, 197, 0))),
//                     Icon(Icons.warning_rounded, color: const Color.fromARGB(255, 219, 197, 0)),
//                   ],
//                 ),
//                 Divider()
//               ],
//             ),
//           content: 
//           Text("R U Sureee????!!!!???", style: TextStyle(color: const Color.fromARGB(255, 61, 61, 61)),),
//           actions: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
//                 backgroundColor: Colors.red
//               ),
//               onPressed: (){
//                 // button Funct
//                  Navigator.of(context).pop();
//               }, 
//               child: Text("Cancel", style: TextStyle(color: Colors.white),)
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
//                 backgroundColor: Colors.green
//               ),
//               onPressed: (){
//                 // button Funct
//                 _submitAbsence();
//                 Navigator.of(context).pop();
//                 _thxForAbsence();
//               }, 
//               child: Text("Sure", style: TextStyle(color: Colors.white),)
//             )
//           ],
//         );
//       }
//     );
//   }

//   Future<void> _thxForAbsence() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false, 
//       builder: (context) {
//         return AlertDialog(
//           title: 
//             Column(
//               children: [
//                 Text("Thank You.. ^_^", style: TextStyle(color: Colors.green)),
//                 Divider()
//               ],
//             ),
//           actions: [
//             SizedBox(
//               width: MediaQuery.sizeOf(context).width * 1,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
//                   backgroundColor: Colors.green
//                 ),
//                 onPressed: (){
//                   // button Funct
//                   Navigator.of(context).pop();
//                 }, 
//                 child: Text("OK", style: TextStyle(color: Colors.white),)
//               ),
//             )
//           ],
//         );
//       }
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: Text("Take Picture..", style: TextStyle(color: Colors.white)),
//       ),
//       body:
//         Padding(
//           padding: const EdgeInsets.all(8),
//           child:
//           Column(
//             children: [
//                 Expanded(
//                   child: _photo == null 
//                   ? Center(child: Text("No Photo yet...", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w800),))
//                   : 
//                   ClipRRect(
//                     borderRadius: BorderRadiusGeometry.circular(20),
//                     child: 
//                       Image.file(_photo!, fit: BoxFit.cover,
//                     )
//                   )
//                 ),
//               SizedBox(height: 5),
//               ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 82, 177, 255),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
//                 ),
//                 onPressed: _takePhoto,
//                 icon: const Icon(Icons.camera_alt_rounded, color: Colors.white,),
//                 label: const Text("Take Photo", style: TextStyle(color: Colors.white),),
//               ),
//               SizedBox(height: 8),
//               // ElevatedButton(
//               //   onPressed: () {
//               //     if (_photo == null) {
//               //       debugPrint("Belum ada foto");
//               //       return;
//               //     }

//               //     final fileName = p.basename(_photo!.path);
//               //     final extension = p.extension(_photo!.path);
//               //     final fileSize = _photo!.lengthSync();

//               //     debugPrint("📸 File name : $fileName");
//               //     debugPrint("📂 Extension : $extension");
//               //     debugPrint("📦 Size      : ${fileSize ~/ 1024} KB");
//               //     debugPrint("📍 Full path : ${_photo!.path}");
//               //   },
//               //   child: const Text("check file Photo"),
//               // ),
//               // SizedBox(height: 8),
//               // TextField(
//               //   controller: _nameController,
//               //   decoration: const InputDecoration(
//               //     labelText: "Name",
//               //     border: OutlineInputBorder()
//               //   ),
//               // ),
//               // SizedBox(height: 8),
//               // DropdownButtonFormField(
//               //   value: _status,
//               //   items: const [
//               //     DropdownMenuItem(value: "Masuk", child: Text("Masuk")),
//               //     DropdownMenuItem(value: "Tidak Masuk", child: Text("Tidak Masuk")),
//               //   ], 
//               //   onChanged: (val) => setState(() => _status = val!),
//               //   decoration: const InputDecoration(
//               //     border: OutlineInputBorder(),
//               //   labelText: "Status",
//               //   ),
//               // ),
//               SizedBox(
//                 width: MediaQuery.sizeOf(context).width * 1,
//                 height: MediaQuery.sizeOf(context).height * 0.08,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _isSubmitting ? const Color.fromARGB(255, 211, 211, 211) : const Color.fromARGB(255, 87, 201, 91),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
//                   ),
//                   onPressed: _photo != null && !_isSubmitting
//                   ? _confirmSubmitAbsence : null,
//                   child: Text(_isSubmitting ? "Submitting..." : "Submit Absent", 
//                     style: TextStyle(color: _isSubmitting ? const Color.fromARGB(255, 74, 74, 74) : Colors.white, 
//                     fontSize: 15, 
//                     fontWeight: FontWeight.w900)
//                   )
//                 ),
//               )
//             ],
//           )
//         )
//     );
//   }
// }