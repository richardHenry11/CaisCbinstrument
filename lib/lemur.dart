import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
        readOnly: true,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: const Color.fromARGB(255, 3, 23, 58),
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
  // Controller TextEditing
    TextEditingController _date = TextEditingController();
    // Var form
    DateTime? date;

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
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    // image picker
    final ImagePicker _picker = ImagePicker();
    File? _photo;

    // working prove photo
    File? _workingPhoto;

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

    await prefs.setString(
      'date',
      formatter.format(date!),
    );

    debugPrint(
      "Date: $date"
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    // PILIH TANGGAL
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return null;

    // PILIH JAM & MENIT
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
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
    }
  } 
  
  @override
  Widget build(BuildContext context) {
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
                            labelText: 'Date Overtime',
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
                      //   ElevatedButton(onPressed: (){ _setTimeToPrefs(); }, child: Text("Set to prefs")
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
                            child: Text("Leader Approval", style: TextStyle(color: Colors.white)),
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
                            child: Text("must be filled as an approve from leader", style: TextStyle(color: Colors.yellow, fontSize: 10)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10), 
                      child:
                        _photo == null ?
                        Center(child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.1, child: Text("No Photo detected", style: TextStyle(color: Colors.redAccent)))) 
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
                            child: Text("Take Photo", style: TextStyle(color: Colors.white),)
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
                              
                              if (_photo != null || _photo == null) {
                                setState(() {
                                  _photo = file;
                                });
                              }
                            },
                            child: Text("Open File", style: TextStyle(color: Colors.white),)
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
                color: const Color.fromARGB(255, 66, 91, 130),
                child:
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(MaterialCommunityIcons.clock, size: 20, color: Colors.purpleAccent,),
                            ),
                            Text("Overtime Duration", style: TextStyle(color: Colors.white),),
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
                              child: Text("WEEKDAY", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 10, fontWeight: FontWeight.bold),),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================ Lembur Weekday 1 =====================
                    LemburCounter(
                      title: "Overtime Weekday 1",
                      value: lemburW1,
                      max: 3,
                      controller: w1Ctrl,
                      onIncrement: incW1,
                      onDecrement: decW1,
                    ),

                    // ================ Lembur Weekday 2 =====================
                    LemburCounter(
                      title: "Overtime Weekday 2",
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
                      title: "Overtime Weekend 1",
                      value: lemburWE1,
                      max: 3,
                      controller: we1Ctrl,
                      onIncrement: incWE1,
                      onDecrement: decWE1,
                    ),

                    // ================ Lembur Weekend 2 =====================
                    LemburCounter(
                      title: "Overtime Weekend 2",
                      value: lemburWE2,
                      max: 4,
                      controller: we2Ctrl,
                      onIncrement: incWE2,
                      onDecrement: decWE2,
                    ),

                    // ================ Lembur Weekend 2 =====================
                    LemburCounter(
                      title: "Overtime Weekend 3",
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
                          Text("Working List", style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        children: [
                          Text("* wajib", style: TextStyle(color: Colors.red)),
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
                            hintText: "what are u working...",
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
                        Text("Working Photo Proof", style: TextStyle(color: Colors.white),)
                      ],
                    ),

                    // preview Photo
                    Padding(
                    padding: const EdgeInsets.all(10),
                    child: _workingPhoto == null
                        ? Center(
                            child: SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.12,
                              child: const Text(
                                "No working photo selected",
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
                            child: const Text("Take Photo"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _pickWorkingPhotoFromGallery,
                            child: const Text("Open File"),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ),
            ),

            // Button Submit
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: MediaQuery.sizeOf(context). height * 0.07,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green
                ),
                onPressed: (){
              
                }, 
                child: Text("Submit Report", style: TextStyle(color: Colors.white),)
              ),
            )
          ]
        ),
      )
    );
  }
}