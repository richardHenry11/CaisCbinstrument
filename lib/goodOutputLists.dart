import 'dart:convert';

// import 'package:absence/addGoodInput.dart';
import 'package:absence/addGoodOutput.dart';
// import 'package:absence/editGoodInput.dart';
import 'package:absence/editGoodOutput.dart';
import 'package:absence/goodInputLists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class GoodOutputLists extends StatefulWidget {
  const GoodOutputLists({super.key});

  @override
  State<GoodOutputLists> createState() => _GoodOutputListsState();
}

class _GoodOutputListsState extends State<GoodOutputLists> {
  // dropdown Items
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

  TextEditingController _startDate = TextEditingController();
  TextEditingController _endDate = TextEditingController();

  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  // saved datetime
  DateTime? startDateTime;
  DateTime? endDateTime;

  // pages
  final _page = 1;
  final _perPage = 20;

  // list map API result tresholder
  List<Map<String, dynamic>> _apiTresholder  = [];




  //===================================== Functions and logics =================================

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadAPI();
  }

  Widget _itemLists(BuildContext context, Map<String, dynamic> item, int index) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.025),
              child: 
              // Image.asset("assets/gedeBox.png", width: MediaQuery.sizeOf(context).width * 0.05,),
              Text("📥")
            ), 
            Expanded(child: Text(item['nama_barang'], style: TextStyle(color: Color(0xFF4a9eff), fontWeight: FontWeight.w900),)),            
          ],
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),
        Row(
          children: [
            Text("QR Code: ", style: TextStyle(color: Color(0xFF8b9cb6), fontSize: 15),),
            Text(item['qr_code'], style: TextStyle(color: Colors.green, fontSize: 15),)
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.01, bottom: MediaQuery.sizeOf(context).height * 0.01),
          child: Divider(
            color: Color(0xFF1f2937),
          ),
        ),

        //========================== Category ========================
        SizedBox(
          height: 
          // 16,
          20,
          child: 
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.white
            //   )
            // ),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.25,
                  child: Text("Kategori", style: TextStyle(color: Color(0xFF6b7785), fontSize: 15),)
                ),
                Padding(
                  padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.01),
                  child: Text(": ", style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),),
                ),
                Expanded(child: Text(item['kategori'], style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),))
              ],
            ),
          ),
        ),

        //========================== Kind ========================
        SizedBox(
         height: 20,
          child: 
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.white
            //   )
            // ),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.25,
                  child: Text("Jenis", style: TextStyle(color: Color(0xFF6b7785), fontSize: 15),)
                ),
                Padding(
                  padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.01),
                  child: Text(": ", style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),),
                ),
                Expanded(child: Text(item['jenis_barang'], style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),))
              ],
            ),
          ),
        ),

        //========================== Units ========================
        // SizedBox(
        //  height: 20,
        //   child: 
        //   Container(
        //     // decoration: BoxDecoration(
        //     //   border: Border.all(
        //     //     color: Colors.white
        //     //   )
        //     // ),
        //     child: Row(
        //       children: [
        //         SizedBox(
        //           width: MediaQuery.sizeOf(context).width * 0.25,
        //           child: Text("Satuan", style: TextStyle(color: Color(0xFF6b7785), fontSize: 15),)
        //         ),
        //         Padding(
        //           padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.01),
        //           child: Text(": ", style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),),
        //         ),
        //         Expanded(child: Text(item['satuan'], style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),))
        //       ],
        //     ),
        //   ),
        // ),

        //========================== Stocks ========================
        // SizedBox(
        //  height: 20,
        //   child: 
        //   Container(
        //     // decoration: BoxDecoration(
        //     //   border: Border.all(
        //     //     color: Colors.white
        //     //   )
        //     // ),
        //     child: Row(
        //       children: [
        //         SizedBox(
        //           width: MediaQuery.sizeOf(context).width * 0.25,
        //           child: Text("Stok", style: TextStyle(color: Color(0xFF6b7785), fontSize: 15),)
        //         ),
        //         Padding(
        //           padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.01),
        //           child: Text(": ", style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),),
        //         ),
        //         Expanded(child: Text(item['stok_awal'].toString(), style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),))
        //       ],
        //     ),
        //   ),
        // ),

        //========================== Position ========================
        // SizedBox(
        //  height: 20,
        //   child: 
        //   Container(
        //     // decoration: BoxDecoration(
        //     //   border: Border.all(
        //     //     color: Colors.white
        //     //   )
        //     // ),
        //     child: Row(
        //       children: [
        //         SizedBox(
        //           width: MediaQuery.sizeOf(context).width * 0.25,
        //           child: Text("Posisi", style: TextStyle(color: Color(0xFF6b7785), fontSize: 15),)
        //         ),
        //         Padding(
        //           padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.01),
        //           child: Text(": ", style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),),
        //         ),
        //         Expanded(child: Text(item['posisi'], style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),))
        //       ],
        //     ),
        //   ),
        // ),

        //========================== Description ========================
        SizedBox(
         height: 20,
          child: 
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.white
            //   )
            // ),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.25,
                  child: Text("Tanggal", style: TextStyle(color: Color(0xFF6b7785), fontSize: 15),)
                ),
                Padding(
                  padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.01),
                  child: Text(": ", style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),),
                ),
                Expanded(child: Text(item['tanggal_jam'] == "" ? "-" : item['tanggal_jam'], style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),))
              ],
            ),
          ),
        ),

         //========================== Position ========================
        SizedBox(
         height: 20,
          child: 
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.white
            //   )
            // ),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.25,
                  child: Text("Jumlah Masuk", style: TextStyle(color: Color(0xFF6b7785), fontSize: 15),)
                ),
                Padding(
                  padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.01),
                  child: Text(": ", style: TextStyle(color: Color(0xFFe1e7f5), fontSize: 15),),
                ),
                Text("+", style: TextStyle(color: Color(0xFF6ee7b7)),),
                Expanded(child: Text(item['jumlah'].toString(), style: TextStyle(color: Color(0xFF6ee7b7), fontSize: 15),))
              ],
            ),
          ),
        ),

        // //============================= Good's Photo Preview ===============================
        // SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),

        // if (item['gambar'] != null && item['gambar'] != "")
        // ClipRRect(
        //   borderRadius: BorderRadius.circular(10),
        //   child: Image.network("https://cais.cbinstrument.com/${item['gambar']}",
        //     // height: MediaQuery.sizeOf(context).height * 0.4,
        //     // width: double.infinity,
        //     fit: BoxFit.cover,
        //     errorBuilder: (context, error, stackTrace) {
        //     return Container(
        //       height: 150,
        //       color: Colors.black12,
        //       child: Center(
        //         child: Icon(Icons.broken_image, color: Colors.grey),
        //       ),
        //     );
        //   },
        //   ),
        // ),

        //===================== Input Button In and Out ========================
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        // Input
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     SizedBox(
        //       width: MediaQuery.sizeOf(context).width * 0.4,
        //       height: MediaQuery.sizeOf(context).height * 0.08,
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(10),
        //           ),
        //           backgroundColor: Color(0xFF065f46),
        //           side: BorderSide(
        //             width: 1,
        //             color: Color(0xFF047857)
        //           )
        //         ),
        //         onPressed: (){
        //           // button funct here!!!
            
        //         }, 
        //         child: Row(
        //           children: [
        //             Padding(
        //               padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.015),
        //               child: Text("📥"),
        //             ),
        //             Expanded(child: Text("Input Barang Masuk", style: TextStyle(color: Color(0xFF6ee7b7)),))
        //           ],
        //         )
        //       ),
        //     ),

        //     // Output
        //     SizedBox(
        //       width: MediaQuery.sizeOf(context).width * 0.4,
        //       height: MediaQuery.sizeOf(context).height * 0.08,
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(10),
        //           ),
        //           backgroundColor: Color(0xFF7f1d1d),
        //           side: BorderSide(
        //             width: 1,
        //             color: Color(0xFF991b1b)
        //           )
        //         ),
        //         onPressed: (){
        //           // button funct here!!!

        //         }, 
        //         child: Row(
        //           children: [
        //             Padding(
        //               padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.015),
        //               child: Text("📥"),
        //             ),
        //             Expanded(child: Text("Input Barang Masuk", style: TextStyle(color: Color(0xFFfca5a5)),))
        //           ],
        //         )
        //       ),
        //     )
        //   ],
        // ),

        //------------------------------------- CRUD Button ------------------------------------
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
        // Input
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.4,
              height: MediaQuery.sizeOf(context).height * 0.08,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF2d4a7c),
                  side: BorderSide(
                    width: 1,
                    color: Color.fromARGB(255, 79, 161, 255)
                  )
                ),
                onPressed: (){
                  // button funct here!!!
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => EditGoodOutput(
                      barang: _apiTresholder[index],
                    ))
                  );
                }, 
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.015),
                      child: Text("✏️"),
                    ),
                    Expanded(child: Text("Ubah", style: TextStyle(color: Color(0xFF4a9eff)),))
                  ],
                )
              ),
            ),

            // Output
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.4,
              height: MediaQuery.sizeOf(context).height * 0.08,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF7f1d1d),
                  side: BorderSide(
                    width: 1,
                    color: Color(0xFF991b1b)
                  )
                ),
                onPressed: (){
                  // button funct here!!!
                  _confirmShowDialog(item["id"]);
                }, 
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.015),
                      child: Text("🗑️"),
                    ),
                    Expanded(child: Text("Hapus", style: TextStyle(color: Color(0xFFfca5a5)),))
                  ],
                )
              ),
            )
          ],
        ),
      ]
    );
  }

  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  Future<void> _loadAPI() async {
    final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiI3ZTMyYzU3Ny1lODY0LTQwM2UtYTI5MS1lMzZkNWRiMGIwNjIiLCJlbWFpbCI6InJpY2hhcmRAY2JpbnN0cnVtZW50LmNvbSIsImV4cCI6MjA2MzkzMzI1NywiaWF0IjoxNzczMTEwODU3fQ.8mQIOadBQbWhetUXIRsqhtUADGbfR5Pfz7PIYYie9Qw";
    final url = "https://cais.cbinstrument.com/auth/inventory/barang-keluar?page=$_page&per_page=$_perPage";
    final headers = {
      "Authorization" : "Bearer $token"
    };

    final responseAPI = await http.get(
      Uri.parse(url),
      headers: headers
    );

    if(responseAPI.statusCode == 200) {
      final bodi= jsonDecode(responseAPI.body);

      setState(() {
        _apiTresholder = List<Map<String, dynamic>>.from(bodi["data"]);
      });
      print("hasil API: $_apiTresholder");
    }
  }

  Future<void> _delete(String id) async {
    final token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiI3ZTMyYzU3Ny1lODY0LTQwM2UtYTI5MS1lMzZkNWRiMGIwNjIiLCJlbWFpbCI6InJpY2hhcmRAY2JpbnN0cnVtZW50LmNvbSIsImV4cCI6MjA2MzkzMzI1NywiaWF0IjoxNzczMTEwODU3fQ.8mQIOadBQbWhetUXIRsqhtUADGbfR5Pfz7PIYYie9Qw";
    final url = "https://cais.cbinstrument.com/auth/inventory/barang-keluar/$id";
    final headers = {"Authorization" : token};

    final responseAPI = await http.delete(
      Uri.parse(url),
      headers: headers
    );

    if(responseAPI.statusCode == 200){
      setState(() {
        _apiTresholder.removeWhere((item) => item["id"] == id);
      });
      _thxShowDialog();      
    } else {
      _thxShowDialogFailed();
    }
  }

  Future<void> _confirmShowDialog(String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              // Text("Data Inventori berhasil di edit", style: TextStyle(color: Colors.green)),
              Icon(MaterialCommunityIcons.alert_box, color: const Color.fromARGB(255, 139, 129, 36), size: 80),
              Divider(),
            ],
          ),
          content: Text("Apakah Anda Yakin??!!??"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      // button Funct
                      Navigator.of(context).pop();                      
                    },
                    child: Text("Cancel", style: TextStyle(color: const Color.fromARGB(255, 92, 92, 92))),
                  ),
                ),

                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.25,
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
                      // final id = _apiTresholder[index]["id"];
                      _delete(id);
                    },
                    child: Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
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
              // Text("Data Inventori berhasil di edit", style: TextStyle(color: Colors.green)),
              Icon(MaterialCommunityIcons.check_circle, color: Colors.green, size: 80),
              Divider(),
            ],
          ),
          content: Text("Data berhasil di hapus"),
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
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Row(
                        children: [
                          Text("Barang berhasil dihapus"),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Icon(MaterialCommunityIcons.check_circle, color: Colors.white,),
                          )
                        ],
                      )),
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

  Future<void> _thxShowDialogFailed() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              // Text("Data Inventori berhasil di edit", style: TextStyle(color: Colors.green)),
              Icon(MaterialCommunityIcons.close_circle, color: Color(0xFF7f1d1d), size: 80),
              Divider(),
            ],
          ),
          content: Text("Data berhasil di hapus"),
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
                    MaterialPageRoute(builder: (context) => GoodInputList()),
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menghapus barang")),
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



  // Scaffold body / context builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF182234),
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.1,
              child: 
              // Image.asset(
              //   "assets/gedeBox.png",
              //   width: MediaQuery.sizeOf(context).width * 0.04,
              //   height: MediaQuery.sizeOf(context).height * 0.04,
              // ),
              Text("📥")
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: [
                  Text(
                    "Barang Keluar",
                    style: TextStyle(color: Color(0xFFfca5a5)),
                  ),
                  Text(
                    "Management Stok & peminjaman",
                    style: TextStyle(fontSize: 10, color: Color(0xFF8b9cb6)),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF182234),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Color(0xFF2d4a7c), // warna border
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 219, 219, 219), // warna icon burger
        ),
      ),

      body: SingleChildScrollView(
        child: 
        // Container(
        //   decoration: BoxDecoration(
        //     border: Border.all(
        //       width: 1,
        //       color: Colors.white
        //     )
        //   ),
        //   child: 
    
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF131927),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xff1f2937),
                        width: 1
                      )
                    )
                  ),
                  child: 
                  Container(
                    child: 
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.05, right: MediaQuery.sizeOf(context).width * 0.05, bottom: MediaQuery.sizeOf(context).height * 0.03),
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        child: 
                        TextFormField(
                          decoration: InputDecoration(
                            hint: Row(
                              children: [
                                Text("🔍"),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    "Cari Nama Barang / QR Code",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 157, 157, 157),
                                    ),
                                  ),
                                ),
                              ],
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
                        ),
                      ),
                                  
                                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                                  
                                      // Dropdown input
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
                                  
                                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                                  
                                      //=================== date filters =======================
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //     border: Border.all(
                                      //       width: 1,
                                      //       color: Colors.white
                                      //     )
                                      //   ),
                                      //   child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // =============== Start Date =========================
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.44,
                            child: TextField(
                              controller: _startDate,
                              readOnly: true,
                              style: TextStyle(color: Color.fromARGB(255, 157, 157, 157)),
                              decoration: InputDecoration(
                                fillColor: Color(0xFF1f2937),
                                filled: true,
                                label: Text("Start Date"),
                                labelStyle: TextStyle(color: Color.fromARGB(255, 157, 157, 157)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                suffixIcon: Icon(
                                  Icons.calendar_today_rounded,
                                  color: const Color.fromARGB(255, 180, 180, 180),
                                ), 
                              ),
                              onTap: () async {
                                final _datePicked = await _pickDate(context);
                                if(_datePicked != null) {
                                  setState(() {
                                    startDateTime = _datePicked;
                                    _startDate.text = formatter.format(_datePicked);
                                  });
                                }
                              },
                            ),
                          ),
                      
                          //==================== End Date ===================
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.44,
                            child: TextField(
                              controller: _endDate,
                              readOnly: true,
                              style: TextStyle(color: Color.fromARGB(255, 157, 157, 157)),
                              decoration: InputDecoration(
                                fillColor: Color(0xFF1f2937),
                                filled: true,
                                label: Text("End Date"),
                                labelStyle: TextStyle(color: Color.fromARGB(255, 157, 157, 157)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2d4a7c)),
                                ),
                                suffixIcon: Icon(
                                  Icons.calendar_today_rounded,
                                  color: const Color.fromARGB(255, 180, 180, 180),
                                ), 
                              ),
                              onTap: () async {
                                final _datePicked = await _pickDate(context);
                                if(_datePicked != null) {
                                  setState(() {
                                    startDateTime = _datePicked;
                                    _startDate.text = formatter.format(_datePicked);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                                      // ),
                      
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                      // Button Tambah Barang
                      SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      // height: MediaQuery.sizeOf(context).height * 0.08,
                      child:
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7f1d1d),
                          shape: RoundedRectangleBorder(  
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
                        onPressed: (){
                          // Button Funct here!!
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => Addgoodoutput())
                          );
                        }, 
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(MaterialCommunityIcons.plus_circle, color: Color.fromARGB(255, 189, 189, 189), size: MediaQuery.sizeOf(context).height * 0.03,),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Tambah Barang Keluar", style: TextStyle(color: Colors.white),),
                            ),
                      
                          ],
                        )
                      ),
                      ),
                      
                      //================== goods input and output ==============
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                      SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      child: Container(
                        // decoration: BoxDecoration(
                        //   border: Border.all(
                        //     width: 1,
                        //     color: Colors.white
                        //   )
                        // ),
                        child: 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //================ good's input ===================
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.43,
                              // height: MediaQuery.sizeOf(context).height * 0.06,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Color(0xFF065f46)
                                ),
                                onPressed: (){
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => GoodInputList())
                                  );
                                }, 
                                child: 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("📥"),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text("List Barang Masuk", style: TextStyle(color: Colors.white, fontSize: 10),),
                                    )
                                  ],
                                )
                              ),
                            ),
                      
                            //================ good's output ===================
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.43,
                              // height: MediaQuery.sizeOf(context).height * 0.06,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Color(0xFF7f1d1d)
                                ),
                                onPressed: (){
                              
                                }, 
                                child: 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("📥"),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text("List Barang Keluar", style: TextStyle(color: Colors.white, fontSize: 10),),
                                    )
                                  ],
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                                      ),
                        ],
                      ),
                    ),
                  ),
              ),

                //=============================== Content Inventory ==================================
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
                Center(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.red
                      ),
                      child: 
                      _apiTresholder.isEmpty ?
                      Center(child: Text("No Data", style: TextStyle(color: Colors.white),)) :
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _apiTresholder.length,
                        itemBuilder: (context, index) {
                          final items = _apiTresholder[index];
                  
                          return 
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                width: 2,
                                color: Color(0xFF7f1d1d)
                              )
                            ),
                            color: Color(0xFF131927),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _itemLists(context, items, index),
                            ),
                          );
                        }
                      )
                    ),
                  ),
                )
              ],
            ),
          ),
      // ),
    );
  }
}
