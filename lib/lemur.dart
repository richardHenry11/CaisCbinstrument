import 'dart:convert';

import 'package:absence/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:absence/l10n/app_localizations.dart';

class LemburCounter extends StatelessWidget {
  final String title;
  final int value;
  final int max;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final TextEditingController controller;

  const LemburCounter({
    super.key,
    required this.title,
    required this.value,
    required this.max,
    required this.onIncrement,
    required this.onDecrement,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.85,
        child: Card(
          color: const Color.fromARGB(255, 94, 129, 186),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.36,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Text(title, style: const TextStyle(color: Colors.white)),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            "Max. ${max}Hours",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 198, 198, 198),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.4,
                child: Row(
                  children: [
                    _btn(
                      context,
                      icon: MaterialCommunityIcons.pan_left,
                      onPressed: value > 0 ? onDecrement : null,
                    ),

                    _display(context),

                    _btn(
                      context,
                      icon: MaterialCommunityIcons.pan_right,
                      onPressed: value < max ? onIncrement : null,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(BuildContext context,
      {required IconData icon, VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.1,
        height: MediaQuery.sizeOf(context).height * 0.045,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: const Color.fromARGB(255, 82, 177, 255),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _display(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.1,
      height: MediaQuery.sizeOf(context).height * 0.045,
      child: TextField(
        controller: controller,
        enabled: false,
        readOnly: true,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: const Color.fromARGB(255, 3, 23, 58),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 219, 219, 219),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 219, 219, 219),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

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
           "${time.year} ";
          //  "${time.hour.toString().padLeft(2, '0')}."
          //  "${time.minute.toString().padLeft(2, '0')}."
          //  "${time.second.toString().padLeft(2, '0')}";
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return months[month - 1];
  }
}

class Lemur extends StatefulWidget {
  const Lemur({super.key});

  @override
  State<Lemur> createState() => _LemurState();
}

class _LemurState extends State<Lemur> {
  // Base64image controller
    Future<String> imageToBase64(File imageFile) async {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    }

    // Controller TextEditing
    TextEditingController _date = TextEditingController();

    // Var form
    DateTime? date;
    String? _token;
    String? _name;

    // state Weekdays
    int lemburW1 = 0;
    int lemburW2 = 0;

    // state Weekends
    int lemburWE1 = 0;
    int lemburWE2 = 0;
    int lemburWE3 = 0;

    // controller lemur wikdey
    final w1Ctrl = TextEditingController(text: "0");
    final w2Ctrl = TextEditingController(text: "0");

    // controller lemur wiken
    final we1Ctrl = TextEditingController(text: "0");
    final we2Ctrl = TextEditingController(text: "0");
    final we3Ctrl = TextEditingController(text: "0");

    // Workinglists state
    final TextEditingController workingListCtrl = TextEditingController();

    // dateTime picker formatter
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    // image picker
    final ImagePicker _picker = ImagePicker();
    File? _photo;

    // working prove photo
    File? _workingPhoto;

    // submit button state
    bool _isActivated = false;

    // error treshold
    String? error;

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDateFromPrefs();
    workingListCtrl.addListener(_validateSubmit);
  }

    Future<void> _loadDateFromPrefs() async {
      final prefs = await SharedPreferences.getInstance();
      final storedDate = prefs.getString('selected_absence_date');
      final token = prefs.getString('token');
      final name = prefs.getString('name');

      if (storedDate != null && storedDate.isNotEmpty) {
        setState(() {
          date = DateTime.parse(storedDate);
          _date.text = storedDate;           
          _token = token;
          _name = name;

          print(date);
          print(_token);
          print(_name);
        });
      }
    }

    void _validateSubmit() {
      final isValid =
          _photo != null &&
          _workingPhoto != null &&
          _date.text.isNotEmpty &&
          workingListCtrl.text.isNotEmpty;

      if (_isActivated != isValid) {
        setState(() {
          _isActivated = isValid;
        });
      }
    }

    Future<void> _submitApi() async {
      if(_token == null){
        _logout();
        return;
      }

      if (_photo == null || _workingPhoto == null) return;

      // To base6eimage
      final base64Image1 = await imageToBase64(_photo!);
      final photoDataApproval = "data:image/jpeg;base64,$base64Image1";
      final base64Image2 = await imageToBase64(_workingPhoto!);
      final photoDataWorking = "data:image/jpeg;base64,$base64Image2";

      debugPrint("PHOTO LENGTH approval: ${photoDataApproval.length}");
      debugPrint("PHOTO PREFIX approval: ${photoDataApproval.substring(0, 30)}");
      debugPrint("full photo approval: ${photoDataApproval}");
      debugPrint("PHOTO LENGTH Working: ${photoDataWorking.length}");
      debugPrint("PHOTO PREFIX Working: ${photoDataWorking.substring(0, 30)}");
      debugPrint("full photo Working: ${photoDataWorking}");


      final url = "https://cais.cbinstrument.com/auth/absensi/input-lembur";
      final headers = {
        "Authorization":"Bearer $_token",
        "Content-Type":"application/json"
        };
      final body = jsonEncode(
       {
        "nama": _name,
        "tanggal_lembur": _date.text,
        "lembur_weekday_1": lemburW1,
        "lembur_weekday_2": lemburW2,

        "lembur_weekend_1": lemburWE1,
        "lembur_weekend_2": lemburWE2,
        "lembur_weekend_3": lemburWE3,

        "daftar_pekerjaan": workingListCtrl.text,
        "bukti_persetujuan_atasan": photoDataApproval,
        "bukti_pekerjaan": [photoDataWorking]
       }  
      );

      final postResponse = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body
      );

      if (postResponse.statusCode == 200) {
        final resBody = jsonDecode(postResponse.body);
        print(resBody);
        print("Absence Fuccessful");
        _thxForAbsence();
      } else {
        final body = jsonDecode(postResponse.body);
        _thxForAbsenceFailed();
        error = body['error'];
        print("Absence Failed");
        print("$error");
      }
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

  Future<void> _thxForAbsence() async {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: 
            Column(
              children: [
                // Text("", style: TextStyle(color: Colors.green)),
                Icon(MaterialCommunityIcons.check_decagram, color: Colors.green, size: 80,),
                // Divider()
              ],
            ),
          content: 
            Text("Report Has been Sent, and will be checked by HR :)", style: TextStyle(color: Colors.green, fontSize: 15),),
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

    void incW1() => setState(() {
      lemburW1++;
      w1Ctrl.text = lemburW1.toString();
    });

    void decW1() => setState(() {
      lemburW1--;
      w1Ctrl.text = lemburW1.toString();
    });

    void incW2() => setState(() {
      lemburW2++;
      w2Ctrl.text = lemburW2.toString();
    });

    void decW2() => setState(() {
      lemburW2--;
      w2Ctrl.text = lemburW2.toString();
    });


    // Weekend
    void incWE1() => setState(() {
      lemburWE1++;
      we1Ctrl.text = lemburWE1.toString();
    });

    void decWE1() => setState(() {
      lemburWE1--;
      we1Ctrl.text = lemburWE1.toString();
    });
    void incWE2() => setState(() {
      lemburWE2++;
      we2Ctrl.text = lemburWE2.toString();
    });

    void decWE2() => setState(() {
      lemburWE2--;
      we2Ctrl.text = lemburWE2.toString();
    });

    void incWE3() => setState(() {
      lemburWE3++;
      we3Ctrl.text = lemburWE3.toString();
    });

    void decWE3() => setState(() {
      lemburWE3--;
      we3Ctrl.text = lemburWE3.toString();
    });

    // cam Permission
    Future<bool> requestCameraPermission() async {
      final status = await Permission.camera.request();
      return status.isGranted;
    }

    Future<void> _setTimeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final formatted = formatter.format(date!);

    await prefs.setString(
      'date',
      formatted,
    );

    debugPrint(
      "Date: $formatted"
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    /// PICK DATE
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date == null) {
      return null;
    }

    // // Pick Time
    // final TimeOfDay? time = await showTimePicker(
    //   context: context, 
    //   initialTime: TimeOfDay.now());

    // if (time == null) {
    //   return null;
    // }

    return DateTime(
      date.year,
      date.month,
      date.day,
    );
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
    final jpg = img.encodeJpg(resized, quality: 90);

    final newFile = File(
      '${file.parent.path}/normalized_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await newFile.writeAsBytes(jpg);
    return newFile;
  }

  Future<void> _takePhoto() async {
    final granted = await requestCameraPermission();

    if(!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 75
    );

    if (image != null) {
      setState(() {
        _photo = File(image.path);
      });

      final fixedImage = await _normalizeImage(_photo!);
      setState(() {
        _photo = fixedImage;
      });
      _validateSubmit();
    }
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

  // =================================== Working Photo Prove Function =====================================
  Future<void> _takeWorkingPhoto() async {
    final granted = await requestCameraPermission();

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _workingPhoto = File(image.path);
      });
      _validateSubmit();
    }
  }

  Future<void> _pickWorkingPhotoFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _workingPhoto = File(image.path);
      });
      _validateSubmit();
    }
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
  void dispose() {
    workingListCtrl.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 23, 58),
      body:
      SingleChildScrollView(
        child: Column(
          children: [
          // DateTime Picker
          SizedBox(height:MediaQuery.sizeOf(context).height * 0.05),
            Center(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: Card(
                  color: const Color.fromARGB(255, 66, 91, 130),
                  child: 
                  Column(
                    children: [
                      TextField(
                        controller: _date,
                          readOnly: true,
                            style: TextStyle(color: const Color.fromARGB(255, 218, 218, 218)),
                            decoration: InputDecoration(
                            labelText: t.translate('dateOvertime'),
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 154, 154, 154)),
                            prefixIcon: Icon(Icons.calendar_today_rounded, color: const Color.fromARGB(255, 180, 180, 180),)
                            ),
                          onTap: () async {
                            final picked = await _pickDateTime(context);
                              if (picked != null) {
                                setState(() {
                                  date = picked;
                                   _date.text = formatter.format(picked);
                                });
                              }
                            },
                          ),
                        ElevatedButton(onPressed: (){ _setTimeToPrefs(); }, child: Text(t.translate('setToPrefs')))
                      // )
                    ],
                  )
                ),
              ),
            ),
        
            // ====================== Bukti Persetujuan ========================
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Card(
                color: const Color.fromARGB(255, 66, 91, 130),
                child: 
                Column(
                  children: [
                    Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Row(
                      children: [
                          Icon(MaterialCommunityIcons.check_circle, color: Colors.green, size: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(t. translate("leaderApproval"), style: TextStyle(color: Colors.white)),
                          )
                        ],
                      )
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: 
                      Row(
                        children: [
                          Icon(MaterialCommunityIcons.alert, color: Colors.yellow, size: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(t.translate("mustBeFilled"), style: TextStyle(color: Colors.yellow, fontSize: 10)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10), 
                      child:
                        _photo == null ?
                        Center(child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.1, child: Text("photoDesk", style: TextStyle(color: Colors.redAccent)))) 
                        : SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          child: 
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: 
                            Image.file(_photo!, fit: BoxFit.contain)
                          ),
                        ),
                      ),  
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // =========== Take photo ===========
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              ),
                              backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                            ),
                            onPressed:(){
                              _takePhoto();
                            },
                            child: Text(t.translate("takePicture"), style: TextStyle(color: Colors.white),)
                          ),
                              
                          // =========== photo from gallery ===========
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              ),
                              backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                            ),
                            onPressed:() async {
                              final file = await _takePhotoFromGallery();
                              
                              if (file != null) {
                                setState(() {
                                  _photo = file;
                                });
                                _validateSubmit();
                              }
                            },
                            child: Text(t.translate("gallery"), style: TextStyle(color: Colors.white),)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Overtime Duration
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Card(
                color: Color.fromARGB(255, 66, 91, 130),
                child:
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(MaterialCommunityIcons.clock, size: 20, color: Colors.purpleAccent,),
                            ),
                            Text(t.translate("OverDur"), style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Card(
                            color: const Color.fromARGB(255, 94, 129, 186),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(t.translate("weekday"), style: TextStyle(color: Colors.lightBlueAccent, fontSize: 10, fontWeight: FontWeight.bold),),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================ Lembur Weekday 1 =====================
                    LemburCounter(
                      title: t.translate("over1"),
                      value: lemburW1,
                      max: 3,
                      controller: w1Ctrl,
                      onIncrement: incW1,
                      onDecrement: decW1,
                    ),

                    // ================ Lembur Weekday 2 =====================
                    LemburCounter(
                      title: t.translate("over2"),
                      value: lemburW2,
                      max: 4,
                      controller: w2Ctrl,
                      onIncrement: incW2,
                      onDecrement: decW2,
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Card(
                            color: const Color.fromARGB(69, 255, 234, 76),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text("WEEKEND", style: TextStyle(color: Colors.yellowAccent, fontSize: 10, fontWeight: FontWeight.bold),),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================ Lembur Weekend 1 =====================
                    LemburCounter(
                      title: t.translate("overEnd1"),
                      value: lemburWE1,
                      max: 3,
                      controller: we1Ctrl,
                      onIncrement: incWE1,
                      onDecrement: decWE1,
                    ),

                    // ================ Lembur Weekend 2 =====================
                    LemburCounter(
                      title: t.translate("overEnd2"),
                      value: lemburWE2,
                      max: 4,
                      controller: we2Ctrl,
                      onIncrement: incWE2,
                      onDecrement: decWE2,
                    ),

                    // ================ Lembur Weekend 2 =====================
                    LemburCounter(
                      title: t.translate("overEnd3"),
                      value: lemburWE3,
                      max: 4,
                      controller: we3Ctrl,
                      onIncrement: incWE3,
                      onDecrement: decWE3,
                    ),
                  ],
                ),
              ),
            ),

            // ============================ Working Lists ==============================
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Card(
                color:const Color.fromARGB(255, 66, 91, 130),
                child:
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(MaterialCommunityIcons.file_document, color: Colors.blue,),
                          ),
                          Text(t.translate("overWorkingList"), style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        children: [
                          Text(t.translate("must"), style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),

                    // Working List TextBox
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.85,
                        child: 
                        TextField(
                          controller: workingListCtrl,
                          maxLines: 4,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: t.translate("whatWork"),
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180),
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 94, 129, 186) ,
                            contentPadding: const EdgeInsets.all(12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 219, 219, 219),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 82, 177, 255),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),                    
                  ],
                )
              ),
            ),

            // Working Photo prove
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Card(
                color: const Color.fromARGB(255, 66, 91, 130),
                child:
                Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top:10.0),
                          child: Icon(MaterialCommunityIcons.image_album, color: const Color.fromARGB(255, 255, 115, 105)),
                        ),
                        Text(t.translate("workPhoto"), style: TextStyle(color: Colors.white),)
                      ],
                    ),

                    // preview Photo
                    Padding(
                    padding: const EdgeInsets.all(10),
                    child: _workingPhoto == null
                        ? Center(
                            child: SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.12,
                              child: Text(t.translate("noPhotoWorking"),
                                style: TextStyle(color: Colors.orangeAccent),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.8,
                            height: MediaQuery.sizeOf(context).height * 0.35,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _workingPhoto!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      
                      // Button
                      Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _takeWorkingPhoto,
                            child: Text(t.translate("takePhoto")),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _pickWorkingPhotoFromGallery,
                            child: Text(t.translate("gallery")),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ),
            ),

            if (!_isActivated)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            t.translate("fillData"),
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                          ),
                        ),

            // Button Submit
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context). height * 0.07,
              child: ElevatedButton(
              onPressed: _isActivated ? _submitApi : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isActivated ? Colors.green : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                t.translate("submitOver"),
                style: TextStyle(color: Colors.white),
              ),
            )
            )
          ]
        ),
      )
    );
  }
}