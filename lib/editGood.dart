import 'dart:convert';
import 'dart:io';

// import 'package:absence/goodInputLists.dart';
// import 'package:absence/goodOutputLists.dart';
import 'package:absence/goodsKind.dart';
import 'package:absence/invention.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class EditGood extends StatefulWidget {

  final Map<String, dynamic> barang;

  const EditGood({super.key,required this.barang});

  @override
  State<EditGood> createState() => _EditGoodState();
}

class _EditGoodState extends State<EditGood> {
  //===================== global funct here!! ===========================
  List<String> _kategoriBarang = [
    "Siap Jual",
    "Consumable",
    "Aset Tetap",
    "Barang Tersedia (Backstock)",
    "Barang dalam Proses (WIP)",
    "Barang Pengembalian / Retur",
    "Spare Parts",
    "Barang Obsolete",
    "Barang Pameran / Demonstrasi",
    "Barang Berteknologi Tinggi",
    "Dokumen",
  ];

  String? _selectedKategori;

  List<String> _units = [
    "Unit",
    "Pcs",
    "Set"
  ];

  String? _selectedUnit;

  // Date state
  DateTime? startDateTime;
  final TextEditingController _startDate = TextEditingController();
  final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");

  // radio
  String? selectedValue = "Peralatan Kantor";

  // TextFieldController
  final TextEditingController _QRCode = TextEditingController();
  final TextEditingController _namaBarang = TextEditingController();
  final TextEditingController _stokAwal = TextEditingController();
  final TextEditingController _keterangan = TextEditingController();
  // final TextEditingController _satuan = TextEditingController();
  final TextEditingController _posisiBarang = TextEditingController();

  // Camera permission and converter
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<String> imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }
  final ImagePicker _picker = ImagePicker();
  File? _photo;

  // Uint8List? _imageBytes;

  String? _imageUrl;


  //=====================  Functions  ===================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _QRCode.text = widget.barang["qr_code"];
    _namaBarang.text = widget.barang["nama_barang"];
    _selectedKategori = widget.barang["kategori"];
    selectedValue = widget.barang["jenis_barang"];
    _stokAwal.text = widget.barang["stok_awal"].toString();
    _keterangan.text = widget.barang["keterangan"] ?? "";
    _selectedUnit = widget.barang['satuan'];
    _posisiBarang.text = widget.barang['posisi'];
    final gambar = widget.barang["gambar"];

    if (gambar != null && gambar.isNotEmpty) {
      _imageUrl = "https://cais.cbinstrument.com/$gambar";
    }


    startDateTime = DateFormat("yyyy-MM-dd HH:mm:ss")
    .parse(widget.barang["created_at"]);
    _startDate.text = formatter.format(startDateTime!);
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

    // Pick Time
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now());

    if (time == null) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _sendAPI() async {
    String? photoData;

    if (_photo != null) {
      final base64Image = await imageToBase64(_photo!);
      photoData = "data:image/jpeg;base64,$base64Image";
    }

    // debugPrint("PHOTO LENGTH: ${photoData.length}");
    // debugPrint("PHOTO PREFIX: ${photoData.substring(0, 30)}");
    // debugPrint("full photo: ${photoData}");

    final id = widget.barang["id"];
    final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiI3ZTMyYzU3Ny1lODY0LTQwM2UtYTI5MS1lMzZkNWRiMGIwNjIiLCJlbWFpbCI6InJpY2hhcmRAY2JpbnN0cnVtZW50LmNvbSIsImV4cCI6MjA2MzkzMzI1NywiaWF0IjoxNzczMTEwODU3fQ.8mQIOadBQbWhetUXIRsqhtUADGbfR5Pfz7PIYYie9Qw";
    final url = "https://cais.cbinstrument.com/auth/inventory/barang/$id";
    final headers = {"Authorization":"Bearer $token", "Content-Type": "application/json"};
    final body = {
      "id": "0",
      "jenis_barang": selectedValue,
      "stok_awal": int.parse(_stokAwal.text),
      "kategori": _selectedKategori,
      "keterangan": _keterangan.text,
      "nama_barang": _namaBarang.text,
      "qr_code": _QRCode.text,
      "created_at": _startDate.text,
      "satuan": _selectedUnit,
      "stok_masuk": 0,
      "stok_akhir": 3,
      "barang_masuk": 0,
      "barang_keluar": 0,
      "harga_beli": 0,
      "harga_masuk": 0,
      // hanya kirim gambar jika ada foto baru
      if (photoData != null) "gambar": photoData,
    };
    // print(id);
    // print(body);

    final sendData = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body)
    );

    if(sendData.statusCode == 200){
      final bodi = jsonDecode(sendData.body);
      print(bodi);
      _thxShowDialog();
    } else {
      final awak = jsonDecode(sendData.body);
      print(awak);
      print(sendData.statusCode);
      _confirmFoto();
    }
  }

  Future<void> _confirmFoto() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(MaterialCommunityIcons.check_circle, color: Colors.green, size: 80,),
              Divider(),
            ],
          ),
          content: 
              Text("Data Inventori berhasil di edit", style: TextStyle(color: Colors.green)),
          actions: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  // button Funct
                  Navigator.of(context).pop();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Invention()),
                  );
                },
                child: Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _thxShowDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(MaterialCommunityIcons.check_circle, color: Colors.green, size: 80,),
              Divider(),
            ],
          ),
          content: 
              Text("Data Inventori berhasil di edit", style: TextStyle(color: Colors.green)),
          actions: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  // button Funct
                  Navigator.of(context).pop();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Invention()),
                  );
                },
                child: Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<File?> _takePhotoFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image == null) {
      return null;
    }
    return File(image.path);
  }

  Future<void> _takePhoto() async {
    final granted = await requestCameraPermission();
    if (!granted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
      return;
    }
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 75,
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

  //===================== UI Scaffold ===================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF182234),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: const Color.fromARGB(255, 201, 201, 201)
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A2332),
                Color(0xFF0F1621),
              ],
            ),
          ),
        ),
        title: Text("Tambah Barang", style: TextStyle(color: Color(0xFF4a9eff)),),
      ),

      // Body
      body: SingleChildScrollView(
        child: 
        Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),

              //=========================== QR Code ==============================
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.02),
                child: 
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: 
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.white
                    //   )
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("QR Code", style: TextStyle(color: Color(0xFF8b9cb6))),
                        TextFormField(
                          style: TextStyle(color: Color(0xFF8b9cb6)),
                          controller: _QRCode,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                filled: true,
                                fillColor: Color(0xFF1f2937),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //=========================== Good's Name ==============================
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.02),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: 
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.white
                    //   )
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nama Barang", style: TextStyle(color: Color(0xFF8b9cb6))),
                        TextFormField(
                          style: TextStyle(color: Color(0xFF8b9cb6)),
                          controller: _namaBarang,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                filled: true,
                                fillColor: Color(0xFF1f2937),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //=========================== Good's Category ==============================
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.02),
                child: 
                SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      // height: MediaQuery.sizeOf(context).height * 0.06,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Color(0xFF1f2937),
                          filled: true,
                          labelText: "Pilih Kategori",
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 157, 157, 157),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                          ),
                        ),
                        style: TextStyle(color: Color.fromARGB(255, 157, 157, 157)),
                        value: _selectedKategori,
                        items: _kategoriBarang.map((kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedKategori = value;
                          });
                        },
                      ),
                    ),
              ),

              //=========================== Good's Kind ==============================
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: 
                GoodsKindRadio(
                  selectedValue: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),

              //======================== Photo Section ======================
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: 
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      width: 1,
                      color: Color(0xFF2d4a7c)
                    )
                  ),
                  color: Color(0xFF1f2937),
                  child: 
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [

                      if (_photo != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _photo!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (_imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            _imageUrl!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Column(
                          children: [
                            Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "Belum ada Foto",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      // : ClipRRect(
                      //   borderRadius: BorderRadiusGeometry.circular(20),
                      //   child: Image.file(_photo!, fit: BoxFit.cover),
                      //             ),
                                SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                      ),
                      onPressed: _takePhoto,
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Ambil Foto",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                                    ),
                                    Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 82, 177, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final file = await _takePhotoFromGallery();
                    
                        if (file != null || file == null) {
                          setState(() {
                            _photo = file;
                          });
                        }
                      },
                      icon: const Icon(Icons.folder, color: Colors.white),
                      label: Text(
                        "Pilih Dari Gallery",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                                    ),
                                    // ElevatedButton(onPressed: (){ _prefsCatcher(); }, child: Text("test"))
                                  ],
                                ),
                      ],
                    ),
                  ),
                ),
              ),

              //=========================== Date Input ================================
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: TextField(
                          controller: _startDate,
                          readOnly: true,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 207, 207, 207),
                          ),
                          decoration: InputDecoration(
                            labelText: "Tanggal dan Jam",
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 154, 154, 154),
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today_rounded,
                              color: const Color.fromARGB(255, 180, 180, 180),
                            ),
                            enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFF1f2937),
                          ),
                          onTap: () async {
                            final picked = await _pickDateTime(context);
                            if (picked != null) {
                              setState(() {
                                startDateTime = picked;
                                _startDate.text = formatter.format(picked);
                              });
                            }
                          },
                        ),
              ),

              //=========================== Good's Units ==============================
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.02),
                child: 
                SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      // height: MediaQuery.sizeOf(context).height * 0.06,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Color(0xFF1f2937),
                          filled: true,
                          labelText: "Unit",
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 157, 157, 157),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                          ),
                        ),
                        style: TextStyle(color: Color.fromARGB(255, 157, 157, 157)),
                        value: _selectedUnit,
                        items: _units.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        },
                      ),
                    ),
              ),

              //=================================== Stok Awal =======================================
              SizedBox(height: MediaQuery.sizeOf(context).width * 0.02,),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.02),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child:
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.white
                    //   )
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Stok Awal", style: TextStyle(color: Color(0xFF8b9cb6))),
                        TextFormField(
                          style: TextStyle(color: Color(0xFF8b9cb6)),
                          controller: _stokAwal,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                filled: true,
                                fillColor: Color(0xFF1f2937),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              
              //=================================== Posisi Barang =======================================
              SizedBox(height: MediaQuery.sizeOf(context).width * 0.02,),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.02),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child:
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.white
                    //   )
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Posisi Barang", style: TextStyle(color: Color(0xFF8b9cb6))),
                        TextFormField(
                          style: TextStyle(color: Color(0xFF8b9cb6)),
                          controller: _posisiBarang,
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                filled: true,
                                fillColor: Color(0xFF1f2937),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //=================================== Description ==================================
              SizedBox(height: MediaQuery.sizeOf(context).width * 0.02,),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.02),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: 
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.white
                    //   )
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Keterangan", style: TextStyle(color: Color(0xFF8b9cb6))),
                        TextFormField(
                          style: TextStyle(color: Color(0xFF8b9cb6)),
                          controller: _keterangan,
                          maxLines: 5,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                filled: true,
                                fillColor: Color(0xFF1f2937),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: Divider(),
              ),
              
              // Button Submit
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Color(0xFF2563eb)
                  ),
                  onPressed:() {
                    // Button Funct here !!
                    _sendAPI();
                  },
                  child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("💾"),
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                      Text("Simpan", style: TextStyle(color: Colors.white)),
                    ],
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}