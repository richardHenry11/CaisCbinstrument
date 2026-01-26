import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class Lateness extends StatefulWidget {
  const Lateness({super.key});

  @override
  State<Lateness> createState() => _LatenessState();
}

class _LatenessState extends State<Lateness> {
  // image picker
  final ImagePicker _picker = ImagePicker();
  File? _photo;

  // Cam Permit
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Dropdown list
  List<String> _dropdownItem = ["Macet", "Kendaraan Bermasalah", "Urusan Keluarga", "Gangguan Kesehatan", "Lainnya"];
  String? _selectedReason;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 189, 189),
        title: Text("Lateness Confirmation"),
      ),
      backgroundColor: const Color.fromARGB(255, 3, 23, 58),
      body: SingleChildScrollView(
        child: 
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 1,
                child: Card(
                  color: const Color.fromARGB(255, 66, 91, 130),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Icon(MaterialCommunityIcons.alarm, color: Colors.redAccent),
                            ),
                            Text("Absence Data", style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   height: MediaQuery.sizeOf(context).height * 0.02,
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
                        child: 
                            Card(
                              color: const Color.fromARGB(255, 3, 23, 58),
                                child:
                                Column(
                                  children: [
                                    // ======== Row Name =========
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(width: MediaQuery.sizeOf(context).width * 0.4, child: Text("Name", style: TextStyle(color: Colors.white),)),
                                          SizedBox(width: MediaQuery.sizeOf(context).width * 0.3, child: Text("........", style: TextStyle(color: Colors.white))),
                                        ],
                                      ),
                                    ),
                        
                                    // ======== Row Date =========
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(width: MediaQuery.sizeOf(context).width * 0.4, child: Text("Date", style: TextStyle(color: Colors.white))),
                                          SizedBox(width: MediaQuery.sizeOf(context).width * 0.3, child: Text("........", style: TextStyle(color: Colors.white))),
                                        ],
                                      ),
                                    ),
                        
                                    // ======== Row CheckIn =========
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(width: MediaQuery.sizeOf(context).width * 0.4, child: Text("Check In", style: TextStyle(color: Colors.white))),
                                          SizedBox(width: MediaQuery.sizeOf(context).width * 0.3, child: Text("........", style: TextStyle(color: Colors.white))),
                                        ],
                                      ),
                                    ),

                                    // ======== Row Location =========
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(width: MediaQuery.sizeOf(context).width * 0.4, child: Text("Location", style: TextStyle(color: Colors.white))),
                                          SizedBox(width: MediaQuery.sizeOf(context).width * 0.3, child: Text("........", style: TextStyle(color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            ),
                          Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
                          child:
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.05,
                            child: Card(
                              color: Colors.lightGreen,
                              child:
                              Center(child: Text("You're not absent yet"))
                            ),
                          )
                        ),
                    ],
                  )
                ),
              ),




              // ============================= Lateness Reason =========================
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 1,
                child: Card(
                  color: const Color.fromARGB(255, 66, 91, 130),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Icon(MaterialCommunityIcons.file_document_edit, color: Colors.blueAccent),
                            ),
                            Text("Lateness Reason", style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedReason,
                          dropdownColor: const Color.fromARGB(255, 3, 23, 58),
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 3, 23, 58),
                            labelText: "Select Reason",
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: _dropdownItem.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedReason = newValue;
                            });
                          }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== Label =====
                            const Text(
                              "Keterangan Tambahan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ===== Textbox =====
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF0F1B2E),
                                    Color(0xFF0A1426),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white24,
                                ),
                              ),
                              child: TextField(
                                maxLines: 5, // multiline
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  hintText: "Tulis keterangan tambahan...",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  contentPadding: EdgeInsets.all(16),
                                  border: InputBorder.none, // hilangkan border default
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  )
                ),
              ),


              // ============================= Lateness Reason =========================
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 1,
                child: Card(
                  color: const Color.fromARGB(255, 66, 91, 130),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Icon(MaterialCommunityIcons.camera, color: const Color.fromARGB(255, 236, 255, 24)),
                            ),
                            Text("Lateness Reason", style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                             _photo == null 
                              ? Center(child: 
                              SizedBox(height: MediaQuery.sizeOf(context).height * 0.1, child: Text("No Photo yet...", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w800),)))
                              : 
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.8,
                                child: 
                                ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(20),
                                  child: 
                                    Image.file(_photo!, fit: BoxFit.cover,
                                  )
                                ),
                              ),
                          SizedBox(height:10),
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
                            label: const Text("Take Photo", style: TextStyle(color: Colors.white),),
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
                            icon: const Icon(MaterialCommunityIcons.file, color: Colors.white,),
                            label: const Text("Choose File", style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ],
                  )
                ),
              ),




              // =================== Send Confirmation Button ==============
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.95,
                height: MediaQuery.sizeOf(context).height * 0.07,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.lightBlueAccent
                  ),
                  onPressed:(){
                    // Button Funct Here!
                
                  }, 
                  child: Text("Send Lateness Confirmation", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}