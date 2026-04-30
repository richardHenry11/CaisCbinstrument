// import 'package:absence/dailyReport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  // prefs
  String? _savedName;

  // Datings
  DateTime? Date;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  // Dropdowns
  List<String> _items = ["Pilih Lokasi Kerja", "TKI", "KIP", "WFH"];
  String? _selectedItem;

  // ====================================================== Functions =====================================================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameGetter();
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
                border: Border.all(color: Colors.white),
              ),
              child:
              // =========================================================== Filter =================================================
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.045, right: MediaQuery.sizeOf(context).width * 0.045,
                    top: 20, bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red
                        )
                      ),
                      child: 
                      Column(
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
                                    if (_datePicked != null) {
                                      setState(() {
                                        Date = _datePicked;
                                        _dateStart.text = formatter.format(_datePicked);
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
                                    if (_datePicked != null) {
                                      setState(() {
                                        Date = _datePicked;
                                        _dateEnd.text = formatter.format(_datePicked);
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
                                    padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
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
                                        MediaQuery.sizeOf(context).width * 0.4,
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
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
