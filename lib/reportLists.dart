// import 'package:absence/dailyReport.dart';
import 'dart:convert';

import 'package:absence/editdaily.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:data_table_2/data_table_2.dart';

class reportList extends StatefulWidget {
  const reportList({super.key});

  @override
  State<reportList> createState() => _reportListState();
}

class _reportListState extends State<reportList> {
  // ====================================================== Vars Definitions ==============================================================
  // TextEditingControllers
  TextEditingController _dateStart = TextEditingController();
  TextEditingController _dateEnd = TextEditingController();
  TextEditingController _project = TextEditingController();
  TextEditingController _jobKind = TextEditingController();
  TextEditingController _jobTitle = TextEditingController();

  // prefs
  String? _savedName;

  // Datings
  DateTime? Date;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  // Dropdowns
  List<String> _items = ["Pilih Lokasi Kerja", "TKI", "KIP", "WFH"];
  String? _selectedItem;

  // List getData
  List<Map<String, dynamic>> data = [];

  // ====================================================== Functions =====================================================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _nameGetter();
    _getData();
  }

  Future<void> _nameGetter() async {
    final prefs = await SharedPreferences.getInstance();

    _savedName = prefs.getString("name");
    print("_savedName");
  }

  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  // void _applyFilter() {
  //   // final search = _search.text.toLowerCase();
  //   final kategori = _selectedItem;

  //   setState(() {
  //     _filteredData = data.where((item) {
  //       final nama = (item['nama_barang'] ?? "").toLowerCase();
  //       final qr = (item['qr_code'] ?? "").toLowerCase();
  //       final kat = (item['kategori'] ?? "");

  //       // final keywords = search.split(" ");
  //       final date = item['tanggal_jam'];

  //       //============ Date Parse ===============
  //       DateTime? dateTime;
  //       if (date != null) {
  //         try {
  //           dateTime = DateTime.parse(date);
  //         } catch (e) {
  //           dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
  //         }
  //       }

  //       // final matchSearch = search.isEmpty ||
  //       // keywords.every((k) =>
  //       //   nama.contains(k) || qr.contains(k)
  //       // );

  //       final matchKategori = kategori == null || kategori == "Pilih Kategori"
  //           ? true
  //           : kat == kategori;

  //       // final matchDate = (() {
  //       //   if (dateTime == null) return true;

  //       //   DateTime? start;
  //       //   DateTime? end;

  //       //   if (startDateTime != null) {
  //       //     start = DateTime(
  //       //       startDateTime!.year,
  //       //       startDateTime!.month,
  //       //       startDateTime!.day,
  //       //       0,
  //       //       0,
  //       //       0,
  //       //     );
  //       //   }

  //       //   if (endDateTime != null) {
  //       //     end = DateTime(
  //       //       endDateTime!.year,
  //       //       endDateTime!.month,
  //       //       endDateTime!.day,
  //       //       23,
  //       //       59,
  //       //       59,
  //       //     );
  //       //   }

  //       //   if (start != null && dateTime.isBefore(start)) return false;
  //       //   if (end != null && dateTime.isAfter(end)) return false;

  //       //   return true;
  //       // })();

  //       return matchSearch && matchKategori;
  //     }).toList();
  //   });
  // }

  Future<void> _getData() async {
    try {
      final url= "https://cais.cbinstrument.com/auth/absensi/daily-report?page=1&per_page=20&nama=RICHARD%20HENDRIK&role=Operator";
      final token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiI3ZTMyYzU3Ny1lODY0LTQwM2UtYTI5MS1lMzZkNWRiMGIwNjIiLCJlbWFpbCI6InJpY2hhcmRAY2JpbnN0cnVtZW50LmNvbSIsImV4cCI6MjA2MzkzMzI1NywiaWF0IjoxNzczMTEwODU3fQ.8mQIOadBQbWhetUXIRsqhtUADGbfR5Pfz7PIYYie9Qw";
      final header = {
        "Authorization": token,
        "Content-type": "application/json"
      };
      final response = await http.get(
        Uri.parse(url),
        headers: header
      );

      if(response.statusCode == 200){
        final body = jsonDecode(response.body);
        final listBody = body;

        setState(() {
        data = List<Map<String, dynamic>>.from(
          listBody.map((item) {
            // 🔥 convert item dulu
            final mapItem = Map<String, dynamic>.from(item);

            List pekerjaan = [];
            try {
              pekerjaan = jsonDecode(mapItem['pekerjaan_list']);
            } catch (e) {
              pekerjaan = [];
            }

            return {
              ...mapItem,
              "jumlah_pekerjaan": pekerjaan.length
            };
          }),
        );
      });

        print("TOTAL DATA: ${listBody.length}");
        print("STATUS: ${response.statusCode}");
        print("BODY RAW:");
        print(response.body);
      
      } else {
        print("internal server error");
      }
    
    } catch (e) {
      print("error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF182234),
      appBar: AppBar(
        backgroundColor: Color(0xFF1e293b),
        iconTheme: IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "History Report Pekerjaan Harian",
              style: TextStyle(color: Color.fromRGBO(245, 250, 255, 1)),
            ),
            Text(
              "Monitoring aktivitas kerja harian karyawan",
              style: TextStyle(
                color: Color.fromRGBO(107, 140, 186, 1),
                fontSize: 15,
              ),
            ),
          ],
        ),

        // actions: [
        //   ElevatedButton(
        //     onPressed: (){
        //       // Button Funct here!
        //       Navigator.pushReplacement(context,
        //       MaterialPageRoute(builder: (context) => DailyReport())
        //       );
        //     },
        //     child: Text("Kembali")
        //   )
        // ],
      ),

      // ================================================= UI Scaffold here! ===========================================================
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 1,
            child: Container(
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.white),
                color: Color.fromRGBO(13, 26, 45, 1),
              ),
              child:
                  // =========================================================== Filter =================================================
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.sizeOf(context).width * 0.045,
                      right: MediaQuery.sizeOf(context).width * 0.045,
                      top: 20,
                      bottom: 20,
                    ),
                    child: Container(
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.red),
                      // ),
                      child: Column(
                        children: [
                          // ============================= Date ======================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ------------------------- Start Date ----------------------------------
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.4,
                                child: TextField(
                                  controller: _dateStart,
                                  readOnly: true,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 157, 157, 157),
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: Color(0xFF1f2937),
                                    filled: true,
                                    label: Text("Tanggal Mulai"),
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 157, 157, 157),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color(0xFF2d4a7c),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                        _dateStart.text = formatter.format(
                                          _datePicked,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),

                              // ---------------------------- End Date ---------------------------
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.4,
                                child: TextField(
                                  controller: _dateEnd,
                                  readOnly: true,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 157, 157, 157),
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: Color(0xFF1f2937),
                                    filled: true,
                                    label: Text("Tanggal Mulai"),
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 157, 157, 157),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color(0xFF2d4a7c),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                        _dateEnd.text = formatter.format(
                                          _datePicked,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // =============================================== Location ========================================
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 8.0,
                                      top: 8.0,
                                    ),
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
                                        // _validateSubmit();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // ================================================= Project ==============================================
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              // bottom: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          MaterialCommunityIcons.target,
                                          color: Color(0xFF64748B),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          child: Text(
                                            "Project",
                                            style: TextStyle(
                                              color: Color(0xffe5e7eb),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // TextField
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                            0.4,
                                        child: TextField(
                                          controller: _project,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                              255,
                                              163,
                                              163,
                                              163,
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  51,
                                                  65,
                                                  85,
                                                  1,
                                                ),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Color(0xFF1f2937),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Color(0xFF2d4a7c),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // ================================= Job =============================
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          MaterialCommunityIcons.briefcase,
                                          color: Color(0xFF64748B),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          child: Text(
                                            "Jenis Pekerjaan",
                                            style: TextStyle(
                                              color: Color(0xffe5e7eb),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // TextField
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                            0.4,
                                        child: TextField(
                                          controller: _jobKind,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                              255,
                                              163,
                                              163,
                                              163,
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  51,
                                                  65,
                                                  85,
                                                  1,
                                                ),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Color(0xFF1f2937),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Color(0xFF2d4a7c),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ================================================== Job Title =======================================================
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      MaterialCommunityIcons.briefcase,
                                      color: Color(0xFF64748B),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                      ),
                                      child: Text(
                                        "Project",
                                        style: TextStyle(
                                          color: Color(0xffe5e7eb),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // TextField
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.9,
                                    child: TextField(
                                      controller: _jobTitle,
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          163,
                                          163,
                                          163,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color.fromRGBO(
                                              51,
                                              65,
                                              85,
                                              1,
                                            ),
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFF1f2937),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2d4a7c),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //================================================== Buttons =========================================================
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                // ============================================ Find Data's button ============================================
                                SizedBox(
                                  height: 50,
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      backgroundColor: Color.fromRGBO(8, 145, 178, 1)
                                    ),
                                    onPressed: (){
                                      // button Funct Here!!
                            
                                    }, 
                                    child: 
                                    Row(
                                      children: [
                                        Icon(MaterialCommunityIcons.magnify, color: Colors.white,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text("Cari Data", style: TextStyle(color: Colors.white),),
                                        ),
                                      ],
                                    )
                                  ),
                                ),

                                // ============================================ Reset button ============================================
                                SizedBox(
                                  height: 50,
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      backgroundColor: Color.fromRGBO(26, 45, 74, 1)
                                    ),
                                    onPressed: (){
                                      // button Funct Here!!
                            
                                    }, 
                                    child: 
                                    Row(
                                      children: [
                                        Icon(MaterialCommunityIcons.refresh, color: Colors.white,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text("Reset", style: TextStyle(color: Colors.white),),
                                        ),
                                      ],
                                    )
                                  ),
                                )
                              ],
                            ),
                          ) ,

                          // ===================================================== Buttons 2 =================================================
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                // ============================================ Export XLS ============================================
                                SizedBox(
                                  height: 50,
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      backgroundColor: Color.fromRGBO(4, 120, 87, 1)
                                    ),
                                    onPressed: (){
                                      // button Funct Here!!
                            
                                    }, 
                                    child: 
                                    Row(
                                      children: [
                                        Icon(MaterialCommunityIcons.file_document, color: Colors.white,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text("Export XLS", style: TextStyle(color: Colors.white),),
                                        ),
                                      ],
                                    )
                                  ),
                                ),

                                // ============================================ Export PDF ============================================
                                SizedBox(
                                  height: 50,
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      backgroundColor: Color.fromRGBO(185, 28, 28, 1)
                                    ),
                                    onPressed: (){
                                      // button Funct Here!!
                            
                                    }, 
                                    child: 
                                    Row(
                                      children: [
                                        Icon(MaterialCommunityIcons.file_document, color: Colors.white,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text("Export PDF", style: TextStyle(color: Colors.white),),
                                        ),
                                      ],
                                    )
                                  ),
                                )
                              ],
                            ),
                          ) ,
                        ],
                      ),
                    ),
                  ),
            ),
          ),

          // ============================================================ Content and CRUD ===================================================================
          Expanded(
            child: DataTable2(
              // columnSpacing: 2,
              horizontalMargin: 12,
              minWidth: 1300,

              columns: [
                DataColumn(
                  label: Text(
                    'Nama',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Lokasi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tanggal',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Jam Mulai',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Jam Selesai',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Jumlah Pekerjaan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],

              rows: data.map<DataRow>((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        item['nama'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    DataCell(
                      Text(
                        item['lokasi_kerja'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    DataCell(
                      Text(
                        item['tanggal'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    DataCell(
                      Text(
                        item['jam_mulai'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    DataCell(
                      Text(
                        item['jam_selesai'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    DataCell(
                      Text(
                        item['jumlah_pekerjaan'].toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    DataCell(
                      Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.visibility,
                            color: Color.fromRGBO(34, 211, 238, 1),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: IconButton(
                            onPressed: () {
                              // Button Funct here!!
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => EditDaily(reportData: item,)
                                )
                              );
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Color.fromRGBO(250, 204, 21, 1),
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.delete,
                            color: Color.fromRGBO(248, 113, 113, 1),
                          ),
                        ),
                      ],
                    ),
                    ),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
