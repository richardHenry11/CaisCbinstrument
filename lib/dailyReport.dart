// import 'dart:math';

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
  TextEditingController _progressBar = TextEditingController();
  double percentage = 53;
  List<String> _items = ["Pilih Lokasi Kerja", "TKI", "KIP", "WFH"];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime? Date;
  String? _selectedItem;

  String? _savedName;

  List<Map<String, dynamic>> tasks = [];

  //================================== Functions ==================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();

    tasks.add({
      "desc": TextEditingController(),
      "progress": TextEditingController(text: "0"),
      "percentage": 0.0,
    });
  }

  Future<void> _initialize() async {
    await _nameGetter();
    // default date now
    final now = DateTime.now();
    _date.text = formatter.format(now);
    _startTime.text = "08:00";
    _endTime.text = "17:00";

    // progress controller
    _progressBar.text = percentage.toInt().toString();
  }

  Future<void> _nameGetter() async {
    SharedPreferences _fetcher = await SharedPreferences.getInstance();
    _savedName = _fetcher.getString('name');

    print("name dailyReport: $_savedName");

    setState(() {
      _nameController.text = _savedName ?? '';
    });
  }

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
                                    MediaQuery.sizeOf(context).height * 0.02,
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                MaterialCommunityIcons.clock,
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
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width *
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
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Color(0xFF2d4a7c),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Color(0xFF2d4a7c),
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
                                            _timePicker(context, _startTime);
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
                                                MaterialCommunityIcons.clock,
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
                                            MediaQuery.sizeOf(context).width *
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
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Color(0xFF2d4a7c),
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
                                      color: Color.fromRGBO(5, 150, 105, 0.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                                      padding: const EdgeInsets.only(left: 8.0),
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
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromRGBO(51, 65, 85, 1),
                                    ),
                                    color: Color(0xFF1f2937),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child:
                                      // ========================================== Card Tasks ==========================================
                                      Column(
                                        children: List.generate(tasks.length, (
                                          index,
                                        ) {
                                          var task = tasks[index];

                                          return Card(
                                            color: Colors.transparent,
                                            elevation: 0,
                                            // color: Color(0xFF1f2937),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Card(
                                                          color: Color.fromRGBO(
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
                                                                  color:
                                                                      Color.fromRGBO(
                                                                        220,
                                                                        220,
                                                                        220,
                                                                        1,
                                                                      ),
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsGeometry.only(
                                                                      left: 8,
                                                                      right: 8,
                                                                    ),
                                                                child: Text(
                                                                  "Pekerjaan #${index + 1}",
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
                                                        ),

                                                        // ================ Delete Button for task ================
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Color.fromRGBO(
                                                                  84,
                                                                  93,
                                                                  105,
                                                                  1,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            // Button Funtion here!!
                                                            setState(() {
                                                              tasks.removeAt(
                                                                index,
                                                              );
                                                            });
                                                          },
                                                          child: Icon(
                                                            Icons.close,
                                                            color:
                                                                Color.fromRGBO(
                                                                  220,
                                                                  220,
                                                                  220,
                                                                  1,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
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
                                                      controller: task["desc"],
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
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
                                                          borderSide: BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                  51,
                                                                  65,
                                                                  85,
                                                                  1,
                                                                ),
                                                          ),
                                                        ),
                                                        filled: true,
                                                        fillColor: Color(
                                                          0xFF1f2937,
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
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
                                                      padding: EdgeInsets.only(
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
                                                          child: Slider(
                                                            value:
                                                                task["percentage"],
                                                            min: 0,
                                                            max: 100,
                                                            divisions: 100,
                                                            activeColor:
                                                                Colors.blue,
                                                            inactiveColor:
                                                                Colors
                                                                    .grey
                                                                    .shade700,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                task["percentage"] =
                                                                    value;
                                                                task["progress"]
                                                                    .text = value
                                                                    .toInt()
                                                                    .toString();
                                                              });
                                                            },
                                                          ),
                                                        ),

                                                        // ========================== TextField percentage =========================
                                                        Container(
                                                          width: 60,
                                                          height: 40,
                                                          alignment:
                                                              Alignment.center,
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
                                                            controller:
                                                                task["progress"],
                                                            textAlign: TextAlign
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
                                                            decoration:
                                                                InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  isDense: true,
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
                                                                      intValue
                                                                          .toDouble();
                                                                });
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                ),

                                // ======================================= Add Task Button =======================================
                              
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                                  child: SizedBox(
                                    width: MediaQuery.sizeOf(context).width * 1,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Butto funct here!!
                                        setState(() {
                                          tasks.add({
                                            "desc": TextEditingController(),
                                            "progress": TextEditingController(
                                              text: "0",
                                            ),
                                            "percentage": 0.0,
                                          });
                                        });
                                      },
                                      child: Text("Tambah Pekerjaan"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // =========================================== Interuptions =========================================
                      Divider(),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          top: 15.0,
                          bottom: 24.0
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                            )
                          ),
                          child: Row(
                                      children: [
                                        Card(
                                          color: Color.fromRGBO(217, 119, 6, 0.2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              MaterialCommunityIcons
                                                  .clipboard_check,
                                              color: Color.fromRGBO(
                                                217, 
                                                119,
                                                6,
                                                0.8,
                                              ),
                                              size: 17,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            "Kendala",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
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
