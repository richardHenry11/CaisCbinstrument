import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyReport extends StatefulWidget {
  const DailyReport({super.key});

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _date = TextEditingController();
  TextEditingController _startTime = TextEditingController();
  TextEditingController _endTime = TextEditingController();
  List<String> _items = ["Pilih Lokasi Kerja", "TKI", "KIP", "WFH"];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime? Date;
  String? _selectedItem;

  String? _savedName;

  //================================== Functions ==================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameGetter();

    // default date now
    final now = DateTime.now();
    _date.text = formatter.format(now);
    _startTime.text = "08:00";
    _endTime.text = "17:00";
  }

  Future<void> _nameGetter() async {
    SharedPreferences _fetcher = await SharedPreferences.getInstance();
    _savedName = _fetcher.getString('name');

    print("name dailyReport: $_savedName");
  }

  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  Future<void> _timePicker(BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickTime = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now()
    );

    if (pickTime != null){
      final hour = pickTime.hour.toString().padLeft(2, '0');
    final minute = pickTime.minute.toString().padLeft(2, '0');

    setState(() {
      controller.text = "$hour:$minute";
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF182234),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Daily Report",
          style: TextStyle(
            // fontSize: 15,
            // fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
        backgroundColor: Color(0xFF1e293b),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child: Container(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(width: 2, color: Color(0xFF1f2937)),
                  ),
                  color: Color(0xFF131927),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            // borderRadius: BorderRadius.circular()
                          ),
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
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: const Color(0xff475569),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
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
                                width: MediaQuery.sizeOf(context).width * 0.9,
                                // height: MediaQuery.sizeOf(context).height * 0.06,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    fillColor: Color(0xFF1f2937),
                                    filled: true,
                                    // labelText: "Pilih Lokasi Kerja",
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
                                  ),
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 157, 157, 157),
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
                                width: MediaQuery.sizeOf(context).width * 0.9,
                                child: TextField(
                                  controller: _date,
                                  readOnly: true,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 157, 157, 157),
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: Color(0xFF1f2937),
                                    filled: true,
                                    label: Text("pilih tanggal"),
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
                                         Date= _datePicked;
                                        _date.text = formatter.format(
                                          _datePicked,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              Text("Tanggal otomatis mengikuti hari ini.", style: TextStyle(color: Color.fromRGBO(100, 116, 139, 1)),),
                              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Start Time
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: 
                                          Row(
                                            children: [
                                              Padding(padding: EdgeInsets.only(right: 10.0),
                                              child: Icon(MaterialCommunityIcons.clock, size: 17, color: Color(0xFF64748B),)
                                              ),
                                              Text("Jam Masuk", style: TextStyle(color: Colors.white),),
                                            ],
                                          ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.sizeOf(context).width * 0.38,
                                        child: TextField(
                                          controller: _startTime,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 157, 157, 157),
                                          ),
                                          decoration: InputDecoration(
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
                                          suffixIcon: Icon(MaterialCommunityIcons.clock, color: Color.fromARGB(255, 157, 157, 157))
                                          ),
                                          readOnly: true,
                                          
                                          onTap: (){
                                            _timePicker(context, _startTime);
                                          }
                                        ),
                                      ),
                                    ],
                                  ),

                                  // End Time
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: 
                                          Row(
                                            children: [
                                              Padding(padding: EdgeInsets.only(right: 10.0),
                                              child: Icon(MaterialCommunityIcons.clock, size: 17, color: Color(0xFF64748B),)
                                              ),
                                              Text("Jam Keluar", style: TextStyle(color: Colors.white),),
                                            ],
                                          ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.sizeOf(context).width * 0.38,
                                        child: TextField(
                                          controller: _endTime,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 157, 157, 157),
                                          ),
                                          decoration: InputDecoration(
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
                                          suffixIcon: Icon(MaterialCommunityIcons.clock, color: Color.fromARGB(255, 157, 157, 157))
                                          ),
                                          readOnly: true,
                                          onTap: (){
                                            _timePicker(context, _endTime);
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
