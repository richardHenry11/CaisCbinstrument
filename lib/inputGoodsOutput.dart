import 'dart:convert';

// import 'package:absence/goodInputLists.dart';
import 'package:absence/goodOutputLists.dart';
import 'package:absence/goodsKind.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class InputGoodsOutput extends StatefulWidget {

  final Map<String, dynamic> barang;

  const InputGoodsOutput({super.key,required this.barang});

  @override
  State<InputGoodsOutput> createState() => _InputGoodsOutputState();
}

class _InputGoodsOutputState extends State<InputGoodsOutput> {
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

  // Date state
  DateTime? startDateTime;
  final TextEditingController _startDate = TextEditingController();
  final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm");

  // radio
  String? selectedValue = "Peralatan Kantor";

  // TextFieldController
  final TextEditingController _QRCode = TextEditingController();
  final TextEditingController _namaBarang = TextEditingController();
  final TextEditingController _jumlah = TextEditingController();
  final TextEditingController _keterangan = TextEditingController();



  //=====================  Functions  ===================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _QRCode.text = widget.barang["qr_code"];
    _namaBarang.text = widget.barang["nama_barang"];
    _selectedKategori = widget.barang["kategori"];
    selectedValue = widget.barang["jenis_barang"];
    _jumlah.text = widget.barang["stok_awal"].toString();
    _keterangan.text = widget.barang["keterangan"] ?? "";

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
    final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiI3ZTMyYzU3Ny1lODY0LTQwM2UtYTI5MS1lMzZkNWRiMGIwNjIiLCJlbWFpbCI6InJpY2hhcmRAY2JpbnN0cnVtZW50LmNvbSIsImV4cCI6MjA2MzkzMzI1NywiaWF0IjoxNzczMTEwODU3fQ.8mQIOadBQbWhetUXIRsqhtUADGbfR5Pfz7PIYYie9Qw";
    final url = "https://cais.cbinstrument.com/auth/inventory/barang-keluar";
    final headers = {"Authorization":"Bearer $token", "Content-Type": "application/json"};
    final body = {
      "id": "0",
      "jenis_barang": selectedValue,
      "jumlah": int.parse(_jumlah.text),
      "kategori": _selectedKategori,
      "keterangan": _keterangan.text,
      "nama_barang": _namaBarang.text,
      "qr_code": _QRCode.text,
      "tanggal_jam": _startDate.text
    };

    final sendData = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body)
    );

    if(sendData.statusCode == 200){
      final bodi = jsonDecode(sendData.body);
      print(bodi);
      _thxShowDialog();
    } else {
      print(sendData.statusCode);
      final awak = jsonDecode(sendData.body);
      print(awak);
      _thxShowDialogPailed();
    }
  }

  Future<void> _thxShowDialogPailed() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(MaterialCommunityIcons.close_circle, color: const Color.fromARGB(255, 179, 50, 41), size: 80),
              Divider(),
            ],
          ),
          content: Text("Gagal Menambah Barang Masuk", style: TextStyle(color: const Color.fromARGB(255, 179, 50, 41))),
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
          content: Text("Data Barang berhasil ditambah", style: TextStyle(color: Colors.green)),
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
                    MaterialPageRoute(builder: (context) => GoodOutputLists()),
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
        title: Text("Input Barang Masuk", style: TextStyle(color: Color(0xFF4a9eff)),),
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

              //=========================== Date Input ================================
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
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

              //=================================== Quantity =======================================
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
                        Text("Jumlah", style: TextStyle(color: Color(0xFF8b9cb6))),
                        TextFormField(
                          style: TextStyle(color: Color(0xFF8b9cb6)),
                          controller: _jumlah,
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