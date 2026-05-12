// import 'dart:math';

import 'dart:convert';
import 'dart:io';

// import 'package:absence/dashboard.dart';
// import 'package:absence/reportLists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:image_picker/image_picker.dart';

class detailReports extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const detailReports({super.key, required this.reportData,});

  @override
  State<detailReports> createState() => _detailReportsState();
}

class _detailReportsState extends State<detailReports> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _date = TextEditingController();
  TextEditingController _startTime = TextEditingController();
  TextEditingController _endTime = TextEditingController();
  // TextEditingController _progressBar = TextEditingController();
  // TextEditingController _interuption = TextEditingController();
  // TextEditingController _solution = TextEditingController();
  TextEditingController _planning = TextEditingController();

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<String> imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  // File? _photo;

  int percentage = 0;

  List<String> _items = ["Pilih Lokasi Kerja", "TKI", "KIP", "WFH"];
  List<String> _itemsJob = [
    "Visit",
    "Correspondence",
    "Development",
    "Installation",
    "Documentation",
    "Maintenance",
    "Troubleshooting",
    "Training",
  ];
  String? _selectedItemJob;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime? Date;
  String? _selectedItem;

  String? _savedName;

  // final ImagePicker _picker = ImagePicker();

  // File? _photo;

  List<Map<String, dynamic>> tasks = [];

  // form validation
  bool _isActivated = false;

  //================================== Functions ==================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _nameController.text = widget.reportData['nama'] ?? "";

  _selectedItem = widget.reportData['lokasi_kerja'];

  // _date.text = widget.reportData['tanggal'] ?? "";

  _startTime.text = widget.reportData['jam_mulai'] ?? "";

  _endTime.text = widget.reportData['jam_selesai'] ?? "";

  _loadTasks();

  _validateSubmit();
  print("Name: ${_nameController.text}");
  }

  void _loadTasks() {
    try {

      final pekerjaanRaw = widget.reportData['pekerjaan_list'];

      // print("RAW PEKERJAAN:");
      // print(pekerjaanRaw);

      final List pekerjaanList = jsonDecode(pekerjaanRaw);

      setState(() {

        tasks = pekerjaanList.map<Map<String, dynamic>>((job) {

          return {

            "project": TextEditingController(
              text: job['project_name'] ?? "",
            ),

            "job": job['job_type'],

            "title": TextEditingController(
              text: job['job_title'] ?? "",
            ),

            "desc": TextEditingController(
              text: job['description'] ?? "",
            ),

            "kendala": TextEditingController(
              text: job['kendala'] ?? "",
            ),

            "solusi": TextEditingController(
              text: job['solusi'] ?? "",
            ),

            "progress": TextEditingController(
              text: (job['progress'] ?? 0).toString(),
            ),

            "percentage": double.tryParse(
              (job['progress'] ?? 0).toString(),
            ) ?? 0.0,

            "file_kendala": null,
            "file_solusi": null,
            "file_doc1": null,
            "file_doc2": null,
            "file_doc3": null,
          };

        }).toList();

      });

      print("TOTAL TASKS: ${tasks.length}");

    } catch (e) {
      print("ERROR LOAD TASK: $e");
    }
  }

  @override
  void dispose() {

    for (var task in tasks) {
      task["project"]?.dispose();
      task["title"]?.dispose();
      task["kendala"]?.dispose();
      task["solusi"]?.dispose();
      task["desc"]?.dispose();
      task["progress"]?.dispose();
    }

    _nameController.dispose();
    _date.dispose();
    _startTime.dispose();
    _endTime.dispose();

    super.dispose();
  }

  void _validateSubmit() {
  bool isValid = true;

  // validasi dropdown lokasi kerja
  if (_selectedItem == null || _selectedItem!.isEmpty) {
    isValid = false;
  }

  // validasi dropdown lokasi kerja
  if (_date.text.trim().isEmpty) {
    isValid = false;
  }

  // validasi planning
  if (_planning.text.trim().isEmpty) {
    isValid = false;
  }

  // validasi semua task
  for (var task in tasks) {
    if (task["project"].text.trim().isEmpty ||
        task["title"].text.trim().isEmpty ||
        task["desc"].text.trim().isEmpty ||
        task["kendala"].text.trim().isEmpty ||
        task["solusi"].text.trim().isEmpty ||
        task["job"] == null) {
      isValid = false;
      break;
    }
  }

  if (_isActivated != isValid) {
    setState(() {
      _isActivated = isValid;
    });
  }
}

  // Future<void> _takePhotoInterruptions(int index) async {
  //   final granted = await requestCameraPermission();
  //   if (!granted) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
  //     return;
  //   }
  //   final XFile? image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //     imageQuality: 75,
  //   );
  //   if (image != null) {
  //     setState(() {
  //       tasks[index]["file_kendala"] = File(image.path);
  //       print("photo taken: ${tasks[index]["file_kendala"]}");
  //     });

  //     // debugPrint("Photo Taken: ${image.path}");

  //     // // Continue Absence
  //     // _submitAbsence();
  //   }
  // }

  // Future<void> _filePickerInterruptions(int index) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     setState(() {
  //       tasks[index]["file_kendala"] = File(result.files.single.path!);
  //     });

  //     print("File Selected: ${result.files.single.name}");
  //   } else {
  //     print("cancel picking file");
  //   }
  // }

  // Future<void> _takePhotoSolutions(int index) async {
  //   final granted = await requestCameraPermission();
  //   if (!granted) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
  //     return;
  //   }
  //   final XFile? image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //     imageQuality: 75,
  //   );
  //   if (image != null) {
  //     setState(() {
  //       tasks[index]["file_solusi"] = File(image.path);
  //       print("photo taken: ${tasks[index]["file_solusi"]}");
  //     });

  //     // debugPrint("Photo Taken: ${image.path}");

  //     // // Continue Absence
  //     // _submitAbsence();
  //   }
  // }

  // Future<void> _filePickerSolutions(int index) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     setState(() {
  //       tasks[index]["file_solusi"] = File(result.files.single.path!);
  //     });

  //     print("File Selected: ${result.files.single.name}");
  //   } else {
  //     print("cancel picking file");
  //   }
  // }

  // Future<void> _takePhotoDoc1(int index) async {
  //   final granted = await requestCameraPermission();
  //   if (!granted) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
  //     return;
  //   }
  //   final XFile? image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //     imageQuality: 75,
  //   );
  //   if (image != null) {
  //     setState(() {
  //       tasks[index]["file_doc1"] = File(image.path);
  //       print("photo taken: ${tasks[index]["file_doc1"]}");
  //     });

  //     // debugPrint("Photo Taken: ${image.path}");

  //     // // Continue Absence
  //     // _submitAbsence();
  //   }
  // }

  // Future<void> _filePickerDoc1(int index) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     setState(() {
  //       tasks[index]["file_doc1"] = File(result.files.single.path!);
  //     });

  //     print("File Selected: ${result.files.single.name}");
  //   } else {
  //     print("cancel picking file");
  //   }
  // }

  // Future<void> _takePhotoDoc2(int index) async {
  //   final granted = await requestCameraPermission();
  //   if (!granted) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
  //     return;
  //   }
  //   final XFile? image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //     imageQuality: 75,
  //   );
  //   if (image != null) {
  //     setState(() {
  //       tasks[index]["file_doc2"] = File(image.path);
  //       print("photo taken: ${tasks[index]["file_doc1"]}");
  //     });

  //     // debugPrint("Photo Taken: ${image.path}");

  //     // // Continue Absence
  //     // _submitAbsence();
  //   }
  // }

  // Future<void> _filePickerDoc2(int index) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     setState(() {
  //       tasks[index]["file_doc2"] = File(result.files.single.path!);
  //     });

  //     print("File Selected: ${result.files.single.name}");
  //   } else {
  //     print("cancel picking file");
  //   }
  // }

  // Future<void> _takePhotoDoc3(int index) async {
  //   final granted = await requestCameraPermission();
  //   if (!granted) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
  //     return;
  //   }
  //   final XFile? image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //     imageQuality: 75,
  //   );
  //   if (image != null) {
  //     setState(() {
  //       tasks[index]["file_doc3"] = File(image.path);
  //       print("photo taken: ${tasks[index]["file_doc1"]}");
  //     });

  //     // debugPrint("Photo Taken: ${image.path}");

  //     // // Continue Absence
  //     // _submitAbsence();
  //   }
  // }

  // Future<void> _filePickerDoc3(int index) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     setState(() {
  //       tasks[index]["file_doc3"] = File(result.files.single.path!);
  //     });

  //     print("File Selected: ${result.files.single.name}");
  //   } else {
  //     print("cancel picking file");
  //   }
  // }

  // void _deleteFileAtIndex(int index) {
  //   setState(() {
  //     tasks[index]["file_kendala"] = null;
  //     tasks[index]["file_solusi"] = null;
  //     tasks[index]["file_doc1"] = null;
  //     tasks[index]["file_doc2"] = null;
  //     tasks[index]["file_doc3"] = null;
  //   });
  // }

  // Future<void> _nameGetter() async {
  //   SharedPreferences _fetcher = await SharedPreferences.getInstance();
  //   _savedName = _fetcher.getString('name');

  //   print("name dailyReport: $_savedName");

  //   setState(() {
  //     _nameController.text = _savedName ?? '';
  //   });
  // }

  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  Future<void> _timePicker(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay? pickTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickTime != null) {
      final hour = pickTime.hour.toString().padLeft(2, '0');
      final minute = pickTime.minute.toString().padLeft(2, '0');

      setState(() {
        controller.text = "$hour:$minute";
      });
    }
  }

  Future<Map<String, dynamic>?> fileToJson(File? file) async {
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);

    final fileName = file.path.split('/').last;

    return {
      "name": fileName,
      "type": "image/png",
      "size": bytes.length,
      "data": "data:image/png;base64,$base64"
    };
  }

  // Future<void> _systemCallback() async {
  //   // final interuptions = _interuption.text;
  //   // final solutions = _solution.text;
  //   final planning = _planning.text;

  //   for (int i = 0; i < tasks.length; i++) {
  //     print("TASK $i => ${tasks[i].keys}");
  //   }

  //   final pekerjaanList = [];

  //   for (var task in tasks) {
  //     final kendalaDoc = await fileToJson(task["file_kendala"]);
  //     final solusiDoc = await fileToJson(task["file_solusi"]);
  //     final doc1 = await fileToJson(task["file_doc1"]);
  //     final doc2 = await fileToJson(task["file_doc2"]);
  //     final doc3 = await fileToJson(task["file_doc3"]);

  //     pekerjaanList.add({
  //       "project_name": task["project"].text,
  //       "job_type": task["job"],
  //       "job_title": task["title"].text,
  //       "description": task["desc"].text,
  //       "progress": task["percentage"].toInt(),
  //       "kendala": task["kendala"]?.text ?? "",
  //       "solusi": task["solusi"]?.text ?? "",
  //       "kendala_doc": kendalaDoc,
  //       "solusi_doc": solusiDoc,
  //       "save_document_1": doc1,
  //       "save_document_2": doc2,
  //       "save_document_3": doc3,
  //     });
  //   }

  //   final pekerjaanListString = jsonEncode(pekerjaanList);

  //   final createdAt = DateTime.now().toUtc().toIso8601String();

  //   final body = {
  //     "nama": _nameController.text,
  //     "lokasi_kerja": _selectedItem.toString(),
  //     "tanggal": _date.text,
  //     "jam_mulai": _startTime.text,
  //     "jam_selesai": _endTime.text,
  //     "pekerjaan_list": pekerjaanListString,
  //     "rencana_besok": planning,
  //     "created_at": createdAt,
  //   };

  //   print("Payload FINAL:\n$body");

  //   _successNotif();

  //   final response = await http.post(
  //     Uri.parse("https://cais.cbinstrument.com/auth/absensi/daily-report"),
  //     headers: {
  //       "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiI3ZTMyYzU3Ny1lODY0LTQwM2UtYTI5MS1lMzZkNWRiMGIwNjIiLCJlbWFpbCI6InJpY2hhcmRAY2JpbnN0cnVtZW50LmNvbSIsImV4cCI6MjA2MzkzMzI1NywiaWF0IjoxNzczMTEwODU3fQ.8mQIOadBQbWhetUXIRsqhtUADGbfR5Pfz7PIYYie9Qw",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode(body),
  //   );

  //   if (response.statusCode == 200) {
  //     final bodi = jsonDecode(response.body);
  //     print(bodi);
  //     _successNotif();
  //   } else {
  //     final bodi = jsonDecode(response.body);
  //     print("error: $bodi");

  //   }
  // }

  // Future<void> _confirmShowDialog() async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Column(
  //           children: [
  //             // Text("Data Inventori berhasil di edit", style: TextStyle(color: Colors.green)),
  //             Icon(
  //               MaterialCommunityIcons.alert_box,
  //               color: const Color.fromARGB(255, 139, 129, 36),
  //               size: 80,
  //             ),
  //             Divider(),
  //           ],
  //         ),
  //         content: Text("Apakah Anda Yakin??!!??"),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               SizedBox(
  //                 width: MediaQuery.sizeOf(context).width * 0.25,
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadiusGeometry.circular(10),
  //                     ),
  //                     backgroundColor: Colors.grey,
  //                   ),
  //                   onPressed: () {
  //                     // button Funct
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text(
  //                     "Cancel",
  //                     style: TextStyle(
  //                       color: const Color.fromARGB(255, 92, 92, 92),
  //                     ),
  //                   ),
  //                 ),
  //               ),

  //               SizedBox(
  //                 width: MediaQuery.sizeOf(context).width * 0.25,
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadiusGeometry.circular(10),
  //                     ),
  //                     backgroundColor: Colors.green,
  //                   ),
  //                   onPressed: () {
  //                     // button Funct
  //                     Navigator.of(context).pop();
  //                     // final id = _apiTresholder[index]["id"];
  //                     _systemCallback();
  //                   },
  //                   child: Text("OK", style: TextStyle(color: Colors.white)),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> _successNotif() async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Column(
  //           children: [
  //             Icon(MaterialCommunityIcons.check_circle, color: Colors.green, size: 80,),
  //             Divider(),
  //           ],
  //         ),
  //         content: Text("Laporan Berhasil Terkirim", style: TextStyle(color: Colors.green)),
  //         actions: [
  //           SizedBox(
  //             width: MediaQuery.sizeOf(context).width * 1,
  //             child: ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadiusGeometry.circular(10),
  //                 ),
  //                 backgroundColor: Colors.green,
  //               ),
  //               onPressed: () {
  //                 // button Funct
  //                 Navigator.of(context).pop();

  //                 Navigator.pushReplacement(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => Dashboard()),
  //                 );
  //               },
  //               child: Text("OK", style: TextStyle(color: Colors.white)),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF182234),
      appBar: AppBar(
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 20.0),
        //     child: Container(
        //       // decoration: BoxDecoration(
        //       //   borderRadius: BorderRadius.circular(10),
        //       //   border: Border.all(
        //       //     color: Color.fromRGBO(37, 99, 235, 0.2)
        //       //   )
        //       // ),
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Color.fromRGBO(37, 99, 235, 0.5),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(10)
        //           ),
        //         ),
        //         onPressed: (){
        //           // Button funct here later!!
        //           Navigator.push(context, 
        //           MaterialPageRoute(builder: (context) => reportList())
        //           );
        //         }, 
        //         child: 
        //         Row(
        //           children: [
        //             Icon(Icons.folder, color: Color.fromRGBO(147, 197, 253, 1)),
        //             Padding(
        //               padding: const EdgeInsets.only(left: 5.0),
        //               child: Text("List Laporan Saya", style: TextStyle(color: Color.fromRGBO(147, 197, 253, 1)),),
        //             ),
        //           ],
        //         )
        //       ),
        //     ),
        //   )
        // ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Details",
          style: TextStyle(
            // fontSize: 15,
            // fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
        backgroundColor: Color(0xFF1e293b),
      ),

      body: 
      SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child: Column(
                children: [
                  Container(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(width: 2, color: Color(0xFF1f2937)),
                      ),
                      color: Color(0xFF131927),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Container(
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: Colors.white),
                              //   // borderRadius: BorderRadius.circular()
                              // ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          MaterialCommunityIcons.account,
                                          color: Color(0xFF64748B),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          child: Text(
                                            "Nama",
                                            style: TextStyle(
                                              color: Color(0xffe5e7eb),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  //======================== Name ===========================
                                  SizedBox(
                                    width: 350,
                                    // height:
                                    //     MediaQuery.sizeOf(context).height *
                                    //     0.06,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Color(0xff475569),
                                          width: 2,
                                        ),
                                      ),
                                      child: TextFormField(
                                        enabled: false,
                                        style: TextStyle(color: Colors.white),
                                        controller: _nameController,
                                        // onChanged: (_) => _validateSubmit(),
                                        decoration: InputDecoration(
                                          hintText: "$_savedName",
                                          hintStyle: TextStyle(
                                            color: const Color.fromARGB(
                                              255,
                                              145,
                                              145,
                                              145,
                                            ),
                                            fontSize: 14,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: const Color(0xff475569),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: const Color(0xff475569),
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Color(0xff334155),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  //============================== Working Station ======================
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          MaterialCommunityIcons.map_marker,
                                          color: Color(0xFF64748B),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          child: Text(
                                            "Lokasi Kerja",
                                            style: TextStyle(
                                              color: Color(0xffe5e7eb),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Dropdown input
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.9,
                                    // height: MediaQuery.sizeOf(context).height * 0.06,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        fillColor: Color(0xFF1f2937),
                                        filled: true,
                                        // labelText: "Pilih Lokasi Kerja",
                                        labelStyle: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            157,
                                            157,
                                            157,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2d4a7c),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2d4a7c),
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          157,
                                          157,
                                          157,
                                        ),
                                      ),
                                      value: _selectedItem,
                                      items: _items.map((kategori) {
                                        return DropdownMenuItem<String>(
                                          value: kategori,
                                          child: Text(kategori),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedItem = value;
                                        });
                                        _validateSubmit();
                                      },
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Date Picker
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          MaterialCommunityIcons.calendar,
                                          color: Color(0xFF64748B),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          child: Text(
                                            "Tanggal",
                                            style: TextStyle(
                                              color: Color(0xffe5e7eb),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Date
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.9,
                                    child: TextField(
                                      controller: _date,
                                      readOnly: true,
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          157,
                                          157,
                                          157,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        fillColor: Color(0xFF1f2937),
                                        filled: true,
                                        label: Text("pilih tanggal"),
                                        labelStyle: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            157,
                                            157,
                                            157,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2d4a7c),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2d4a7c),
                                          ),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.calendar_today_rounded,
                                          color: const Color.fromARGB(
                                            255,
                                            180,
                                            180,
                                            180,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        final _datePicked = await _pickDate(
                                          context,
                                        );
                                        if (_datePicked != null) {
                                          setState(() {
                                            Date = _datePicked;
                                            _date.text = formatter.format(
                                              _datePicked,
                                            );
                                          });
                                        }
                                      },
                                    ),
                                  ),

                                  Text(
                                    "Tanggal otomatis mengikuti hari ini.",
                                    style: TextStyle(
                                      color: Color.fromRGBO(100, 116, 139, 1),
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height *
                                        0.02,
                                  ),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Start Time
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 10.0,
                                                  ),
                                                  child: Icon(
                                                    MaterialCommunityIcons
                                                        .clock,
                                                    size: 17,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                                Text(
                                                  "Jam Masuk",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Start Time
                                          SizedBox(
                                            width:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width *
                                                0.38,
                                            child: TextField(
                                              controller: _startTime,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                  255,
                                                  157,
                                                  157,
                                                  157,
                                                ),
                                              ),
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Color(
                                                          0xFF2d4a7c,
                                                        ),
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Color(
                                                          0xFF2d4a7c,
                                                        ),
                                                      ),
                                                    ),
                                                filled: true,
                                                fillColor: Color(0xFF1f2937),
                                                suffixIcon: Icon(
                                                  MaterialCommunityIcons.clock,
                                                  color: Color.fromARGB(
                                                    255,
                                                    157,
                                                    157,
                                                    157,
                                                  ),
                                                ),
                                              ),
                                              readOnly: true,

                                              onTap: () {
                                                _timePicker(
                                                  context,
                                                  _startTime,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                      // End Time
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 10.0,
                                                  ),
                                                  child: Icon(
                                                    MaterialCommunityIcons
                                                        .clock,
                                                    size: 17,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                                Text(
                                                  "Jam Keluar",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width *
                                                0.38,
                                            child: TextField(
                                              controller: _endTime,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                  255,
                                                  157,
                                                  157,
                                                  157,
                                                ),
                                              ),
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Color(
                                                          0xFF2d4a7c,
                                                        ),
                                                      ),
                                                    ),
                                                filled: true,
                                                fillColor: Color(0xFF1f2937),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Color(
                                                          0xFF2d4a7c,
                                                        ),
                                                      ),
                                                    ),
                                                suffixIcon: Icon(
                                                  MaterialCommunityIcons.clock,
                                                  color: Color.fromARGB(
                                                    255,
                                                    157,
                                                    157,
                                                    157,
                                                  ),
                                                ),
                                              ),
                                              readOnly: true,
                                              onTap: () {
                                                _timePicker(context, _endTime);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ============================================ Content Task ================================================
                          Divider(),
                          // SizedBox(
                          //   height: MediaQuery.sizeOf(context).height * 0.00,
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 24.0,
                              top: 12,
                            ),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1,
                              child: Container(
                                // decoration: BoxDecoration(
                                //   border: Border.all(color: Colors.white),
                                // ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Card(
                                          color: Color.fromRGBO(
                                            5,
                                            150,
                                            105,
                                            0.2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              MaterialCommunityIcons
                                                  .clipboard_check,
                                              color: Color.fromRGBO(
                                                52,
                                                211,
                                                153,
                                                0.8,
                                              ),
                                              size: 17,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Text(
                                            "Pekerjaan Hari Ini",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    Column(
                                      children: List.generate(tasks.length, (
                                        index,
                                      ) {
                                        var task = tasks[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 25.0,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color.fromRGBO(
                                                  51,
                                                  65,
                                                  85,
                                                  1,
                                                ),
                                              ),
                                              color: Color(0xFF1f2937),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child:
                                                // ========================================== Card Tasks ==========================================
                                                Card(
                                                  color: Colors.transparent,
                                                  elevation: 0,
                                                  // color: Color(0xFF1f2937),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Container(
                                                      // decoration: BoxDecoration(
                                                      //   border: Border.all(
                                                      //     color: Colors.white,
                                                      //   ),
                                                      // ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Card(
                                                                color:
                                                                    Color.fromRGBO(
                                                                      84,
                                                                      93,
                                                                      105,
                                                                      1,
                                                                    ),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                            3.0,
                                                                          ),
                                                                      child: Icon(
                                                                        MaterialCommunityIcons
                                                                            .clipboard_check,
                                                                        color: Color.fromRGBO(
                                                                          220,
                                                                          220,
                                                                          220,
                                                                          1,
                                                                        ),
                                                                        size:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsGeometry.only(
                                                                        left: 8,
                                                                        right:
                                                                            8,
                                                                      ),
                                                                      child: Text(
                                                                        "Pekerjaan #${index + 1}",
                                                                        style: TextStyle(
                                                                          color: Color.fromRGBO(
                                                                            220,
                                                                            220,
                                                                            220,
                                                                            1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),

                                                              // ================ Delete Button for task ================
                                                              // ElevatedButton(
                                                              //   style: ElevatedButton.styleFrom(
                                                              //     backgroundColor:
                                                              //         Color.fromRGBO(
                                                              //           84,
                                                              //           93,
                                                              //           105,
                                                              //           1,
                                                              //         ),
                                                              //     shape: RoundedRectangleBorder(
                                                              //       borderRadius:
                                                              //           BorderRadius.circular(
                                                              //             10,
                                                              //           ),
                                                              //     ),
                                                              //   ),
                                                              //   onPressed: () {
                                                              //     // Button Funtion here!!
                                                              //     setState(() {
                                                              //       tasks
                                                              //           .removeAt(
                                                              //             index,
                                                              //           );
                                                              //     });
                                                              //   },
                                                              //   child: Icon(
                                                              //     Icons.close,
                                                              //     color:
                                                              //         Color.fromRGBO(
                                                              //           220,
                                                              //           220,
                                                              //           220,
                                                              //           1,
                                                              //         ),
                                                              //   ),
                                                              // ),
                                                            ],
                                                          ),

                                                          // ========================= Project =======================
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          Text(
                                                            "Project",
                                                            style: TextStyle(
                                                              color:
                                                                  const Color.fromARGB(
                                                                    255,
                                                                    163,
                                                                    163,
                                                                    163,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          TextField(
                                                            enabled: false,
                                                            onChanged: (_) => _validateSubmit(),
                                                            controller:
                                                                task["project"],
                                                            style: TextStyle(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    157,
                                                                    157,
                                                                    157,
                                                                  ),
                                                            ),
                                                            // maxLines: 4,
                                                            decoration: InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            51,
                                                                            65,
                                                                            85,
                                                                            1,
                                                                          ),
                                                                    ),
                                                              ),
                                                              hintText:
                                                                  "Contoh: Kalibrasi Sensor",
                                                              filled: true,
                                                              fillColor: Color(
                                                                0xFF1f2937,
                                                              ),
                                                              disabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            51,
                                                                            65,
                                                                            85,
                                                                            1,
                                                                          ),
                                                                    ),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: Color(
                                                                        0xFF2d4a7c,
                                                                      ),
                                                                    ),
                                                              ),
                                                            ),
                                                          ),

                                                          // ========================= Dropdown job ====================
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          Text(
                                                            "Jenis Pekerjaan",
                                                            style: TextStyle(
                                                              color:
                                                                  const Color.fromARGB(
                                                                    255,
                                                                    163,
                                                                    163,
                                                                    163,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).width *
                                                                0.9,
                                                            // height: MediaQuery.sizeOf(context).height * 0.06,
                                                            child: DropdownButtonFormField<String>(
                                                              disabledHint: Text(
                                                                task["job"],
                                                                style: TextStyle(
                                                                  color: Color.fromARGB(255, 157, 157, 157),
                                                                ),
                                                              ),
                                                              decoration: InputDecoration(
                                                                border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                                fillColor: Color(
                                                                  0xFF1f2937,
                                                                ),
                                                                filled: true,
                                                                
                                                                // labelText: "Pilih Lokasi Kerja",
                                                                labelStyle:
                                                                    TextStyle(
                                                                      color:
                                                                          Color.fromARGB(
                                                                            255,
                                                                            157,
                                                                            157,
                                                                            157,
                                                                          ),
                                                                    ),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  borderSide: BorderSide(
                                                                    color: Color(
                                                                      0xFF2d4a7c,
                                                                    ),
                                                                  ),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  borderSide: BorderSide(
                                                                    color: Color(
                                                                      0xFF2d4a7c,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              style: TextStyle(
                                                                color:
                                                                    Color.fromARGB(
                                                                      255,
                                                                      157,
                                                                      157,
                                                                      157,
                                                                    ),
                                                              ),
                                                              value:
                                                                  task["job"],
                                                              items: _itemsJob.map((kategori) {
                                                                return DropdownMenuItem<String>(
                                                                  value:
                                                                      kategori,
                                                                  child: Text(
                                                                    kategori,
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              onChanged: 
                                                              null
                                                              // (value) {
                                                              //   setState(() {
                                                              //     task["job"] = value;
                                                              //     print(_selectedItemJob);
                                                              //   });
                                                              //   (_) => _validateSubmit();
                                                              // },
                                                            ),
                                                          ),

                                                          // ========================= Job Title =======================
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          Text(
                                                            "Judul Pekerjaan",
                                                            style: TextStyle(
                                                              color:
                                                                  const Color.fromARGB(
                                                                    255,
                                                                    163,
                                                                    163,
                                                                    163,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          TextField(
                                                            enabled: false,
                                                            onChanged: (_) => _validateSubmit(),
                                                            controller:
                                                                task["title"],
                                                            style: TextStyle(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    157,
                                                                    157,
                                                                    157,
                                                                  ),
                                                            ),
                                                            // maxLines: 4,
                                                            decoration: InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            51,
                                                                            65,
                                                                            85,
                                                                            1,
                                                                          ),
                                                                    ),
                                                              ),
                                                              hintText:
                                                                  "Contoh: Kalibrasi Sensor",
                                                              filled: true,
                                                              fillColor: Color(
                                                                0xFF1f2937,
                                                              ),
                                                              disabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            51,
                                                                            65,
                                                                            85,
                                                                            1,
                                                                          ),
                                                                    ),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: Color(
                                                                        0xFF2d4a7c,
                                                                      ),
                                                                    ),
                                                              ),
                                                            ),
                                                          ),

                                                          // ========================= Job Description =======================
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          Text(
                                                            "Deskripsi Pekerjaan",
                                                            style: TextStyle(
                                                              color:
                                                                  const Color.fromARGB(
                                                                    255,
                                                                    163,
                                                                    163,
                                                                    163,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          TextField(
                                                            enabled: false,
                                                            onChanged: (_) => _validateSubmit(),
                                                            controller:
                                                                task["desc"],
                                                            style: TextStyle(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    157,
                                                                    157,
                                                                    157,
                                                                  ),
                                                            ),
                                                            maxLines: 4,
                                                            decoration: InputDecoration(
                                                              disabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            51,
                                                                            65,
                                                                            85,
                                                                            1,
                                                                          ),
                                                                    ),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            51,
                                                                            65,
                                                                            85,
                                                                            1,
                                                                          ),
                                                                    ),
                                                              ),
                                                              hintText:
                                                                  "Contoh: Maintenance AQMS, Instalasi alat baru DLL",
                                                              filled: true,
                                                              fillColor: Color(
                                                                0xFF1f2937,
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: Color(
                                                                        0xFF2d4a7c,
                                                                      ),
                                                                    ),
                                                              ),
                                                            ),
                                                          ),

                                                          // ============= Progress =================
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  top: 8,
                                                                  bottom: 8,
                                                                ),
                                                            child: Text(
                                                              "Progress",
                                                              style: TextStyle(
                                                                color:
                                                                    const Color.fromARGB(
                                                                      255,
                                                                      163,
                                                                      163,
                                                                      163,
                                                                    ),
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.02,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: 
                                                                SliderTheme(
                                                                  data: SliderTheme.of(context).copyWith(
                                                                    disabledActiveTrackColor: Colors.blue,
                                                                    disabledInactiveTrackColor: Colors.grey.shade700,
                                                                    disabledThumbColor: Colors.blue,
                                                                    overlayShape: SliderComponentShape.noOverlay,
                                                                  ),
                                                                  child: Slider(
                                                                    value:
                                                                        task["percentage"],
                                                                    min: 0,
                                                                    max: 100,
                                                                    divisions:
                                                                        100,
                                                                    activeColor:
                                                                        Colors
                                                                            .blue,
                                                                    inactiveColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade700,
                                                                    onChanged: null,
                                                                  ),
                                                                ),
                                                              ),

                                                              // ========================== TextField percentage =========================
                                                              Container(
                                                                width: 60,
                                                                height: 40,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                  color: Color(
                                                                    0xFF0f172a,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  border: Border.all(
                                                                    color: Color(
                                                                      0xFF2d4a7c,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: TextField(
                                                                  enabled: false,
                                                                  controller:
                                                                      task["progress"],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  style: TextStyle(
                                                                    color:
                                                                        Color.fromARGB(
                                                                          255,
                                                                          163,
                                                                          163,
                                                                          163,
                                                                        ),
                                                                  ),
                                                                  decoration: InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    isDense:
                                                                        true,
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                  ),
                                                                  onChanged: (value) {
                                                                    final intValue =
                                                                        int.tryParse(
                                                                          value,
                                                                        );

                                                                    if (intValue !=
                                                                            null &&
                                                                        intValue >=
                                                                            0 &&
                                                                        intValue <=
                                                                            100) {
                                                                      setState(() {
                                                                        task["percentage"] =
                                                                            intValue;
                                                                      });
                                                                      _validateSubmit();
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      left: 5.0,
                                                                    ),
                                                                child: Text(
                                                                  "%",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Color.fromRGBO(
                                                                          220,
                                                                          220,
                                                                          220,
                                                                          1,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          // ========================= Interruptions =======================
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(MaterialCommunityIcons.alert, color: Color.fromRGBO(248, 113, 113, 1),),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                                        child: Text(
                                                                        "Kendala",
                                                                        style: TextStyle(
                                                                          color:
                                                                        Color.fromRGBO(248, 113, 113, 1),
                                                                                                                                    ),
                                                                                                                                  ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.sizeOf(context).width * 0.33,
                                                            child: 
                                                            // Container(
                                                            //   decoration: BoxDecoration(
                                                            //     color: Colors.red
                                                            //   ),
                                                            //   child: 
                                                              TextField(
                                                                enabled: false,
                                                                onChanged: (_) => _validateSubmit(),
                                                                controller:
                                                                    task["kendala"],
                                                                style: TextStyle(
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        157,
                                                                        157,
                                                                        157,
                                                                      ),
                                                                ),
                                                                maxLines: 4,
                                                                decoration: InputDecoration(
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                          color:
                                                                          Color.fromRGBO(127, 29, 29, 1)
                                                                        ),
                                                                  ),
                                                                  hintText:
                                                                      "Contoh: Sensor Tidak Responsif, belum update system",
                                                                  filled: true,
                                                                  fillColor: Color.fromRGBO(127, 29, 29, 0.1),
                                                                  disabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  borderSide: BorderSide(
                                                                    color: Color.fromRGBO(127, 29, 29, 0.3),
                                                                    width: 1.5,
                                                                  ),
                                                                ),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                          color: Color.fromRGBO(127, 29, 29, 1)
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            // ),
                                                          ),
                                                                ],
                                                              ),

                                                          // ========================= Solutions =======================
                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),
                                                          Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(MaterialCommunityIcons.check_bold, color: Color.fromRGBO(52, 211, 153, 1)),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                                    child: Text(
                                                                      "Solusi",
                                                                      style: TextStyle(
                                                                        color:
                                                                            Color.fromRGBO(52, 211, 153, 1)
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.sizeOf(context).width * 0.33, 
                                                            child: TextField(
                                                              enabled: false,
                                                              onChanged: (_) => _validateSubmit(),
                                                              controller:
                                                                  task["solusi"],
                                                              style: TextStyle(
                                                                color:
                                                                    Color.fromARGB(
                                                                      255,
                                                                      157,
                                                                      157,
                                                                      157,
                                                                    ),
                                                              ),
                                                              maxLines: 4,
                                                              decoration: InputDecoration(
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  borderSide:
                                                                      BorderSide(
                                                                        color:
                                                                            Color.fromRGBO(
                                                                              51,
                                                                              65,
                                                                              85,
                                                                              1,
                                                                            ),
                                                                      ),
                                                                ),
                                                                hintText:
                                                                    "Contoh: Maintenance AQMS, Instalasi alat baru DLL",
                                                                filled: true,
                                                                fillColor: Color.fromRGBO(6, 78, 59, 0.1),
                                                                disabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  borderSide: BorderSide(
                                                                    color: Color.fromRGBO(6, 78, 59, 0.3),
                                                                    width: 1.5,
                                                                  ),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  borderSide:
                                                                      BorderSide(
                                                                        color: Color.fromRGBO(127, 29, 29, 1)
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                            ],
                                                          ),

                                                            ],
                                                          ),
                                                          
                                                          // ========================= file Documents ==========================
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.01,
                                                          ),

                                                          Text(
                                                            "Opsional",
                                                            style: TextStyle(
                                                              color:
                                                                  const Color.fromARGB(
                                                                    255,
                                                                    163,
                                                                    163,
                                                                    163,
                                                                  ),
                                                              fontSize: 15,
                                                            ),
                                                          ),

                                                          SizedBox(
                                                            height:
                                                                MediaQuery.sizeOf(
                                                                  context,
                                                                ).height *
                                                                0.015,
                                                          ),

                                                          // // ======================== Interuption File =====================
                                                          // Text(
                                                          //   "File kendala",
                                                          //   style: TextStyle(
                                                          //     color:
                                                          //         Colors.white,
                                                          //   ),
                                                          // ),

                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),
                                                          // Container(
                                                          //   decoration: BoxDecoration(
                                                          //     borderRadius:
                                                          //         BorderRadius.circular(
                                                          //           10,
                                                          //         ),
                                                          //     border: Border.all(
                                                          //       color:
                                                          //           Color.fromRGBO(
                                                          //             51,
                                                          //             65,
                                                          //             85,
                                                          //             1,
                                                          //           ),
                                                          //     ),
                                                          //   ),
                                                          //   child: Row(
                                                          //     mainAxisAlignment:
                                                          //         MainAxisAlignment
                                                          //             .spaceBetween,
                                                          //     children: [
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   8.0,
                                                          //               top:
                                                          //                   3.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //             backgroundColor:
                                                          //                 const Color.fromARGB(
                                                          //                   255,
                                                          //                   213,
                                                          //                   213,
                                                          //                   213,
                                                          //                 ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // Button Funct Here!!...
                                                          //             _filePickerInterruptions(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Text(
                                                          //             "File",
                                                          //             style: TextStyle(
                                                          //               color: Colors
                                                          //                   .black,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       ),

                                                          //       // ======== Nama File ==========
                                                          //       if (task["file_kendala"] !=
                                                          //           null)
                                                          //         Expanded(
                                                          //           child: Padding(
                                                          //             padding: const EdgeInsets.only(
                                                          //               left:
                                                          //                   16.0,
                                                          //             ),
                                                          //             child: Text(
                                                          //               task["file_kendala"]
                                                          //                   .path
                                                          //                   .split(
                                                          //                     '/',
                                                          //                   )
                                                          //                   .last,
                                                          //               style: TextStyle(
                                                          //                 color: Color.fromARGB(
                                                          //                   255,
                                                          //                   163,
                                                          //                   163,
                                                          //                   163,
                                                          //                 ),
                                                          //               ),
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   5.0,
                                                          //               right:
                                                          //                   8.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             backgroundColor:
                                                          //                 Color.fromRGBO(
                                                          //                   37,
                                                          //                   99,
                                                          //                   235,
                                                          //                   1,
                                                          //                 ),
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // cam button funct
                                                          //             _takePhotoInterruptions(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Icon(
                                                          //             Icons
                                                          //                 .camera_alt,
                                                          //             color: Colors
                                                          //                 .white,
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),

                                                          // // =================================================== Solutions =======================================
                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),

                                                          // Text(
                                                          //   "File Solusi",
                                                          //   style: TextStyle(
                                                          //     color:
                                                          //         Colors.white,
                                                          //   ),
                                                          // ),

                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),
                                                          // Container(
                                                          //   decoration: BoxDecoration(
                                                          //     borderRadius:
                                                          //         BorderRadius.circular(
                                                          //           10,
                                                          //         ),
                                                          //     border: Border.all(
                                                          //       color:
                                                          //           Color.fromRGBO(
                                                          //             51,
                                                          //             65,
                                                          //             85,
                                                          //             1,
                                                          //           ),
                                                          //     ),
                                                          //   ),
                                                          //   child: Row(
                                                          //     mainAxisAlignment:
                                                          //         MainAxisAlignment
                                                          //             .spaceBetween,
                                                          //     children: [
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   8.0,
                                                          //               top:
                                                          //                   3.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //             backgroundColor:
                                                          //                 const Color.fromARGB(
                                                          //                   255,
                                                          //                   213,
                                                          //                   213,
                                                          //                   213,
                                                          //                 ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // Button Funct Here!!...
                                                          //             _filePickerSolutions(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Text(
                                                          //             "File",
                                                          //             style: TextStyle(
                                                          //               color: Colors
                                                          //                   .black,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       ),

                                                          //       // ======== Nama File ==========
                                                          //       if (task["file_solusi"] !=
                                                          //           null)
                                                          //         Expanded(
                                                          //           child: Padding(
                                                          //             padding: const EdgeInsets.only(
                                                          //               left:
                                                          //                   16.0,
                                                          //             ),
                                                          //             child: Text(
                                                          //               task["file_solusi"]
                                                          //                   .path
                                                          //                   .split(
                                                          //                     '/',
                                                          //                   )
                                                          //                   .last,
                                                          //               style: TextStyle(
                                                          //                 color: Color.fromARGB(
                                                          //                   255,
                                                          //                   163,
                                                          //                   163,
                                                          //                   163,
                                                          //                 ),
                                                          //               ),
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   3.0,
                                                          //               right:
                                                          //                   8.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             backgroundColor:
                                                          //                 Color.fromRGBO(
                                                          //                   37,
                                                          //                   99,
                                                          //                   235,
                                                          //                   1,
                                                          //                 ),
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // cam button funct
                                                          //             _takePhotoSolutions(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Icon(
                                                          //             Icons
                                                          //                 .camera_alt,
                                                          //             color: Colors
                                                          //                 .white,
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),

                                                          // // =================================================== save doc1 =======================================
                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),

                                                          // Text(
                                                          //   "Save Document 1",
                                                          //   style: TextStyle(
                                                          //     color:
                                                          //         Colors.white,
                                                          //   ),
                                                          // ),

                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),
                                                          // Container(
                                                          //   decoration: BoxDecoration(
                                                          //     borderRadius:
                                                          //         BorderRadius.circular(
                                                          //           10,
                                                          //         ),
                                                          //     border: Border.all(
                                                          //       color:
                                                          //           Color.fromRGBO(
                                                          //             51,
                                                          //             65,
                                                          //             85,
                                                          //             1,
                                                          //           ),
                                                          //     ),
                                                          //   ),
                                                          //   child: Row(
                                                          //     mainAxisAlignment:
                                                          //         MainAxisAlignment
                                                          //             .spaceBetween,
                                                          //     children: [
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   8.0,
                                                          //               top:
                                                          //                   3.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //             backgroundColor:
                                                          //                 const Color.fromARGB(
                                                          //                   255,
                                                          //                   213,
                                                          //                   213,
                                                          //                   213,
                                                          //                 ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // Button Funct Here!!...
                                                          //             _filePickerDoc1(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Text(
                                                          //             "File",
                                                          //             style: TextStyle(
                                                          //               color: Colors
                                                          //                   .black,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       ),

                                                          //       // ======== Nama File ==========
                                                          //       if (task["file_doc1"] !=
                                                          //           null)
                                                          //         Expanded(
                                                          //           child: Padding(
                                                          //             padding: const EdgeInsets.only(
                                                          //               left:
                                                          //                   16.0,
                                                          //             ),
                                                          //             child: Text(
                                                          //               task["file_doc1"]
                                                          //                   .path
                                                          //                   .split(
                                                          //                     '/',
                                                          //                   )
                                                          //                   .last,
                                                          //               style: TextStyle(
                                                          //                 color: Color.fromARGB(
                                                          //                   255,
                                                          //                   163,
                                                          //                   163,
                                                          //                   163,
                                                          //                 ),
                                                          //               ),
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   3.0,
                                                          //               right:
                                                          //                   8.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             backgroundColor:
                                                          //                 Color.fromRGBO(
                                                          //                   37,
                                                          //                   99,
                                                          //                   235,
                                                          //                   1,
                                                          //                 ),
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // cam button funct
                                                          //             _takePhotoDoc1(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Icon(
                                                          //             Icons
                                                          //                 .camera_alt,
                                                          //             color: Colors
                                                          //                 .white,
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),

                                                          // // =================================================== save doc2 =======================================
                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),

                                                          // Text(
                                                          //   "Save Document 2",
                                                          //   style: TextStyle(
                                                          //     color:
                                                          //         Colors.white,
                                                          //   ),
                                                          // ),

                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),
                                                          // Container(
                                                          //   decoration: BoxDecoration(
                                                          //     borderRadius:
                                                          //         BorderRadius.circular(
                                                          //           10,
                                                          //         ),
                                                          //     border: Border.all(
                                                          //       color:
                                                          //           Color.fromRGBO(
                                                          //             51,
                                                          //             65,
                                                          //             85,
                                                          //             1,
                                                          //           ),
                                                          //     ),
                                                          //   ),
                                                          //   child: Row(
                                                          //     mainAxisAlignment:
                                                          //         MainAxisAlignment
                                                          //             .spaceBetween,
                                                          //     children: [
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   8.0,
                                                          //               top:
                                                          //                   3.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //             backgroundColor:
                                                          //                 const Color.fromARGB(
                                                          //                   255,
                                                          //                   213,
                                                          //                   213,
                                                          //                   213,
                                                          //                 ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // Button Funct Here!!...
                                                          //             _filePickerDoc2(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Text(
                                                          //             "File",
                                                          //             style: TextStyle(
                                                          //               color: Colors
                                                          //                   .black,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       ),

                                                          //       // ======== Nama File ==========
                                                          //       if (task["file_doc2"] !=
                                                          //           null)
                                                          //         Expanded(
                                                          //           child: Padding(
                                                          //             padding: const EdgeInsets.only(
                                                          //               left:
                                                          //                   16.0,
                                                          //             ),
                                                          //             child: Text(
                                                          //               task["file_doc2"]
                                                          //                   .path
                                                          //                   .split(
                                                          //                     '/',
                                                          //                   )
                                                          //                   .last,
                                                          //               style: TextStyle(
                                                          //                 color: Color.fromARGB(
                                                          //                   255,
                                                          //                   163,
                                                          //                   163,
                                                          //                   163,
                                                          //                 ),
                                                          //               ),
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   3.0,
                                                          //               right:
                                                          //                   8.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             backgroundColor:
                                                          //                 Color.fromRGBO(
                                                          //                   37,
                                                          //                   99,
                                                          //                   235,
                                                          //                   1,
                                                          //                 ),
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // cam button funct
                                                          //             _takePhotoDoc2(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Icon(
                                                          //             Icons
                                                          //                 .camera_alt,
                                                          //             color: Colors
                                                          //                 .white,
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),

                                                          // // =================================================== save doc3 =======================================
                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),

                                                          // Text(
                                                          //   "Save Document 3",
                                                          //   style: TextStyle(
                                                          //     color:
                                                          //         Colors.white,
                                                          //   ),
                                                          // ),

                                                          // SizedBox(
                                                          //   height:
                                                          //       MediaQuery.sizeOf(
                                                          //         context,
                                                          //       ).height *
                                                          //       0.01,
                                                          // ),
                                                          // Container(
                                                          //   decoration: BoxDecoration(
                                                          //     borderRadius:
                                                          //         BorderRadius.circular(
                                                          //           10,
                                                          //         ),
                                                          //     border: Border.all(
                                                          //       color:
                                                          //           Color.fromRGBO(
                                                          //             51,
                                                          //             65,
                                                          //             85,
                                                          //             1,
                                                          //           ),
                                                          //     ),
                                                          //   ),
                                                          //   child: Row(
                                                          //     mainAxisAlignment:
                                                          //         MainAxisAlignment
                                                          //             .spaceBetween,
                                                          //     children: [
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   8.0,
                                                          //               top:
                                                          //                   3.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //             backgroundColor:
                                                          //                 const Color.fromARGB(
                                                          //                   255,
                                                          //                   213,
                                                          //                   213,
                                                          //                   213,
                                                          //                 ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // Button Funct Here!!...
                                                          //             _filePickerDoc3(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Text(
                                                          //             "File",
                                                          //             style: TextStyle(
                                                          //               color: Colors
                                                          //                   .black,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       ),

                                                          //       // ======== Nama File ==========
                                                          //       if (task["file_doc3"] !=
                                                          //           null)
                                                          //         Expanded(
                                                          //           child: Padding(
                                                          //             padding: const EdgeInsets.only(
                                                          //               left:
                                                          //                   16.0,
                                                          //             ),
                                                          //             child: Text(
                                                          //               task["file_doc3"]
                                                          //                   .path
                                                          //                   .split(
                                                          //                     '/',
                                                          //                   )
                                                          //                   .last,
                                                          //               style: TextStyle(
                                                          //                 color: Color.fromARGB(
                                                          //                   255,
                                                          //                   163,
                                                          //                   163,
                                                          //                   163,
                                                          //                 ),
                                                          //               ),
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       Padding(
                                                          //         padding:
                                                          //             const EdgeInsets.only(
                                                          //               left:
                                                          //                   3.0,
                                                          //               right:
                                                          //                   8.0,
                                                          //               bottom:
                                                          //                   3.0,
                                                          //             ),
                                                          //         child: ElevatedButton(
                                                          //           style: ElevatedButton.styleFrom(
                                                          //             backgroundColor:
                                                          //                 Color.fromRGBO(
                                                          //                   37,
                                                          //                   99,
                                                          //                   235,
                                                          //                   1,
                                                          //                 ),
                                                          //             shape: RoundedRectangleBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.circular(
                                                          //                     10,
                                                          //                   ),
                                                          //             ),
                                                          //           ),
                                                          //           onPressed: () {
                                                          //             // cam button funct
                                                          //             _takePhotoDoc3(
                                                          //               index,
                                                          //             );
                                                          //           },
                                                          //           child: Icon(
                                                          //             Icons
                                                          //                 .camera_alt,
                                                          //             color: Colors
                                                          //                 .white,
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),

                                                          // // ================================ Delete All Optional ==========================
                                                          // Padding(
                                                          //   padding:
                                                          //       const EdgeInsets.only(
                                                          //         top: 16.0,
                                                          //       ),
                                                          //   child: SizedBox(
                                                          //     width:
                                                          //         MediaQuery.sizeOf(
                                                          //           context,
                                                          //         ).width *
                                                          //         0.9,
                                                          //     child: ElevatedButton(
                                                          //       style: ElevatedButton.styleFrom(
                                                          //         backgroundColor:
                                                          //             const Color.fromARGB(
                                                          //               255,
                                                          //               188,
                                                          //               71,
                                                          //               63,
                                                          //             ),
                                                          //         shape: RoundedRectangleBorder(
                                                          //           borderRadius:
                                                          //               BorderRadius.circular(
                                                          //                 10,
                                                          //               ),
                                                          //         ),
                                                          //       ),
                                                          //       onPressed: () {
                                                          //         // button funt here!!
                                                          //         _deleteFileAtIndex(
                                                          //           index,
                                                          //         );
                                                          //       },
                                                          //       child: Text(
                                                          //         "Reset Optionals",
                                                          //         style: TextStyle(
                                                          //           color: Colors
                                                          //               .white,
                                                          //         ),
                                                          //       ),
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        );
                                      }),
                                    ),

                                    // ======================================= Add Task Button =======================================
                                    // Padding(
                                    //   padding: const EdgeInsets.only(
                                    //     top: 16.0,
                                    //     bottom: 16.0,
                                    //   ),
                                    //   child: SizedBox(
                                    //     width:
                                    //         MediaQuery.sizeOf(context).width *
                                    //         1,
                                    //     child: ElevatedButton(
                                    //       style: ElevatedButton.styleFrom(
                                    //         backgroundColor: Color.fromRGBO(
                                    //           73,
                                    //           130,
                                    //           253,
                                    //           1,
                                    //         ),
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(10),
                                    //         ),
                                    //       ),
                                    //       onPressed: () {
                                    //         // Butto funct here!!
                                    //         setState(() {
                                    //           tasks.add({
                                    //             "project":
                                    //                 TextEditingController(),
                                    //             "title":
                                    //                 TextEditingController(),
                                    //             "job": null,
                                    //             "desc": TextEditingController(),
                                    //             "kendala": TextEditingController(),
                                    //             "solusi": TextEditingController(),
                                    //             "file_kendala": null,
                                    //             "file_solusi": null,
                                    //             "file_doc1": null,
                                    //             "file_doc2": null,
                                    //             "file_doc3": null,
                                    //             "progress":
                                    //                 TextEditingController(
                                    //                   text: "0",
                                    //                 ),
                                    //             "percentage": 0.0,
                                    //           });
                                    //         });
                                    //       },
                                    //       child: Text(
                                    //         "Tambah Pekerjaan",
                                    //         style: TextStyle(
                                    //           color: Colors.white,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // =========================================== Tomorrow's Plans =========================================
                          Divider(),

                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //     left: 24.0,
                          //     right: 24.0,
                          //     top: 15.0,
                          //     bottom: 24.0,
                          //   ),
                          //   child: Container(
                          //     // decoration: BoxDecoration(
                          //     //   border: Border.all(color: Colors.white),
                          //     // ),
                          //     child: Column(
                          //       children: [
                          //         Row(
                          //           children: [
                          //             Card(
                          //               color: Color.fromRGBO(8, 145, 178, 0.2),
                          //               shape: RoundedRectangleBorder(
                          //                 borderRadius: BorderRadius.circular(
                          //                   5,
                          //                 ),
                          //               ),
                          //               child: Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Icon(
                          //                   MaterialCommunityIcons.trending_up,
                          //                   color: Color.fromRGBO(
                          //                     34,
                          //                     211,
                          //                     238,
                          //                     0.8,
                          //                   ),
                          //                   size: 17,
                          //                 ),
                          //               ),
                          //             ),
                          //             Padding(
                          //               padding: const EdgeInsets.only(
                          //                 left: 8.0,
                          //               ),
                          //               child: Text(
                          //                 "Rencana Pekerjaan besok",
                          //                 style: TextStyle(
                          //                   color: Colors.white,
                          //                   fontSize: 17,
                          //                   fontWeight: FontWeight.bold,
                          //                 ),
                          //               ),
                          //             ),
                          //           ],
                          //         ),

                          //         // ============================================ Tomorrow's Desc ================================
                          //         SizedBox(
                          //           height:
                          //               MediaQuery.sizeOf(context).height *
                          //               0.005,
                          //         ),
                          //         SizedBox(
                          //           height:
                          //               MediaQuery.sizeOf(context).height *
                          //               0.01,
                          //         ),
                          //         TextField(
                          //           onChanged: (_) => _validateSubmit(),
                          //           controller: _planning,
                          //           style: TextStyle(
                          //             color: Color.fromARGB(255, 157, 157, 157),
                          //           ),
                          //           maxLines: 4,
                          //           decoration: InputDecoration(
                          //             enabledBorder: OutlineInputBorder(
                          //               borderRadius: BorderRadius.circular(10),
                          //               borderSide: BorderSide(
                          //                 color: Color.fromRGBO(51, 65, 85, 1),
                          //               ),
                          //             ),
                          //             hintText:
                          //                 "Contoh: Melanjutkan Kalibrasi, Rewiring, pengecekan data ke server DLL...",
                          //             filled: true,
                          //             fillColor: Color(0xFF1f2937),
                          //             focusedBorder: OutlineInputBorder(
                          //               borderRadius: BorderRadius.circular(10),
                          //               borderSide: BorderSide(
                          //                 color: Color(0xFF2d4a7c),
                          //               ),
                          //             ),
                          //           ),
                          //         ),

                          //         if(!_isActivated)
                          //          Padding(
                          //           padding: EdgeInsets.only(top: 8),
                          //           child: Text(
                          //             "Silahkan Lengkapi laporan diatas...!!",
                          //             style: TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold),
                          //           ),
                          //         ),
                          //         // ============================================ submit button and back button ==========================================
                          //         SizedBox(
                          //           height:
                          //               MediaQuery.sizeOf(context).height *
                          //               0.01,
                          //         ),
                          //         Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceBetween,
                          //           children: [
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.sizeOf(context).width *
                          //                   0.38,
                          //               child: ElevatedButton(
                          //                 style: ElevatedButton.styleFrom(
                          //                   shape: RoundedRectangleBorder(
                          //                     borderRadius:
                          //                         BorderRadius.circular(10),
                          //                   ),
                          //                   backgroundColor: Colors.grey,
                          //                 ),
                          //                 onPressed: () {
                          //                   // Button Funct here!!
                          //                 },
                          //                 child: Text(
                          //                   "back Button",
                          //                   style: TextStyle(
                          //                     color: Colors.white,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.sizeOf(context).width *
                          //                   0.38,
                          //               child: ElevatedButton(
                          //                 style: ElevatedButton.styleFrom(
                          //                   backgroundColor: Color.fromRGBO(
                          //                     73,
                          //                     130,
                          //                     253,
                          //                     1,
                          //                   ),
                          //                   shape: RoundedRectangleBorder(
                          //                     borderRadius:
                          //                         BorderRadius.circular(10),
                          //                   ),
                          //                 ),
                          //                 onPressed: _isActivated ? _confirmShowDialog: null,
                          //                 child: Text(
                          //                   "Kirim",
                          //                   style: TextStyle(
                          //                     color: Colors.white,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),


                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
