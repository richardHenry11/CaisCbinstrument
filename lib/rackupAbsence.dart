import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class rackupAbsence extends StatefulWidget {
  const rackupAbsence({super.key});

  @override
  State<rackupAbsence> createState() => _rackupAbsenceState();
}

class _rackupAbsenceState extends State<rackupAbsence> {

  // TextEditingController
    final TextEditingController _startDate = TextEditingController();
    final TextEditingController _endDate = TextEditingController();


    // Save Date Time Picker
    DateTime? startDate;
    DateTime? endDate;

    // Getter Date Time prefs
    String? _startDatepref;
    String? _endDatepref;

    // dateTime picker formatter
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
  
  Future<void> _saveToPrefs() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('startDate', formatter.format(startDate!));
    await _prefs.setString('endDate', formatter.format(endDate!));
  }

  bool getValidRangeTime() {
    if(startDate == null || endDate == null) return false;
    return endDate!.isAfter(startDate!);
  }

  String? getRangeErrorMessage() {
  if (startDate == null || endDate == null) {
    return "Tanggal belum lengkap";
  }

  if (endDate!.isBefore(startDate!)) {
    return "Tanggal akhir harus setelah tanggal awal";
  }

  if (endDate!
          .difference(startDate!)
          .inDays >
      31) {
    return "Rentang tanggal maksimal 30 hari";
  }

  return null;
}

  void _getPrefs() async {
    final SharedPreferences _p = await SharedPreferences.getInstance();

    _startDatepref = _p.getString('startDate');
    _endDatepref = _p.getString('endDate');

    print("start Date: $_startDatepref");
    print("end Date: $_endDatepref");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 23, 58),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 189, 189),
        title: Text("Rackup Absence"),
      ),
      body: 
      SingleChildScrollView(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1, 
              height: MediaQuery.sizeOf(context).height * 0.25,
            child: 
              Container(
                color: const Color.fromARGB(255, 66, 91, 130),
                child: Column(
                  children: [

                    //  ================================== Start Date =======================
                    TextField(
                      controller: _startDate,
                      style: TextStyle(color: const Color.fromARGB(255, 227, 227, 227)),
                      decoration: InputDecoration(
                            labelText: 'Start Date & Time',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 154, 154, 154)),
                            prefixIcon: Icon(Icons.calendar_today_rounded, color: const Color.fromARGB(255, 180, 180, 180),)
                          ),
                          onTap: () async {
                            final picked = await _pickDateTime(context);
                            if (picked != null){
                              setState(() {
                                 startDate= picked;
                                _startDate.text =formatter.format(picked);
                              });
                            }
                          },
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),

                    // ===================== End Date ======================
                    TextField(
                      controller: _endDate,
                      style: TextStyle(color: const Color.fromARGB(255, 218, 218, 218)),
                      decoration: InputDecoration(
                            labelText: 'End Date & Time',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 154, 154, 154)),
                            prefixIcon: Icon(Icons.calendar_today_rounded, color: const Color.fromARGB(255, 180, 180, 180),)
                          ),
                          onTap: () async {
                            final picked = await _pickDateTime(context);
                            if (picked != null){
                              setState(() {
                                 endDate= picked;
                                _endDate.text =formatter.format(picked);
                              });
                            }
                          },
                    ),

                    // submit
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
                        onPressed: getValidRangeTime() ? () async {
                          // button Funct
                          await _saveToPrefs(); 
                        }: null, 
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: const Color.fromARGB(255, 88, 88, 88)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("saved to prefs", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ) 
                      ),
                    ),
                  ],
                ),
              )
            ),

            SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),

            // Card Absences
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child:
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: const Color.fromARGB(255, 66, 91, 130),
                child: 
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // =============== Absence Card Content =============
                    children: [
                      Row(
                        children: [
                          Icon(MaterialCommunityIcons.calendar, color: const Color.fromARGB(255, 203, 203, 203), size: 15,),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("Tanggal", style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 186, 186, 186)),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Row(
                          children: [
                            Text("Kamis, 15 Jan 2026", style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),

                      // Divider
                      Divider(
                        color: const Color.fromARGB(255, 118, 118, 118),
                        indent: MediaQuery.sizeOf(context).width * 0.01,
                        endIndent: MediaQuery.sizeOf(context).width * 0.01,
                      ),

                      // Time
                      Row(
                        children: [

                          // Check In
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(MaterialCommunityIcons.clock, color: const Color.fromARGB(255, 203, 203, 203), size: 15,),
                                Padding(padding: EdgeInsetsGeometry.all(3.0),
                                child:
                                  Text("Check In", style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 183, 183, 183)),)
                                )
                              ],
                            ),
                          ),

                          // Check Out
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.45,
                            child: 
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(MaterialCommunityIcons.clock, color: const Color.fromARGB(255, 203, 203, 203), size: 15,),
                                Padding(padding: EdgeInsetsGeometry.all(3.0),
                                child:
                                  Text("Check Out", style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 174, 174, 174)),)
                                )
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Time
                      Row(
                        children: [

                          // Check In
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsetsGeometry.all(3.0),
                                child:
                                  Text("08:05", style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w900),)
                                )
                              ],
                            ),
                          ),

                          // Check Out
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.45,
                            child: 
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsetsGeometry.all(3.0),
                                child:
                                  Text("17:38", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: const Color.fromARGB(255, 255, 255, 255)),)
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: const Color.fromARGB(255, 118, 118, 118),
                        indent: MediaQuery.sizeOf(context).width * 0.01,
                        endIndent: MediaQuery.sizeOf(context).width * 0.01,
                      ),

                      // Photo
                      Row(
                        children: [

                          // Check In Photo
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.25,
                            child:
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                backgroundColor: const Color.fromARGB(255, 215, 215, 215),
                              ),
                              onPressed: 
                              (){
                                // Button Funct

                              },
                              child:
                              Row(
                                children: [
                                  Icon(MaterialCommunityIcons.camera),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("In"),
                                  )
                                ],
                              ), 
                            )
                          ),

                          // Check Out Photo
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.25,
                              child:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: const Color.fromARGB(255, 215, 215, 215),
                                ),
                                onPressed: 
                                (){
                                  // Button Funct
                                  
                                },
                                child:
                                Row(
                                  children: [
                                    Icon(MaterialCommunityIcons.camera),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text("Out"),
                                    )
                                  ],
                                ), 
                              )
                            ),
                          ),

                          // Prove Photo
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.28,
                              child:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: const Color.fromARGB(255, 215, 215, 215),
                                ),
                                onPressed: 
                                (){
                                  // Button Funct
                                  
                                },
                                child:
                                Row(
                                  children: [
                                    Icon(MaterialCommunityIcons.camera),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text("Prove", style: TextStyle(fontSize: 12),),
                                    )
                                  ],
                                ), 
                              )
                            ),
                          ),                          
                        ],
                      ),
                      Divider(
                        color: const Color.fromARGB(255, 118, 118, 118),
                        indent: MediaQuery.sizeOf(context).width * 0.01,
                        endIndent: MediaQuery.sizeOf(context).width * 0.01,
                      ),

                      Row(
                        children: [
                          Icon(Icons.check_box, color: Colors.green, size: 15),
                          Padding(padding: EdgeInsets.only(left: 8.0),
                            child:
                            Text("Confirmation", style: TextStyle(color: Colors.grey)),
                          )
                        ],
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.005),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            child: 
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orangeAccent,
                              ),
                              child: Center(child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Menunggu"),
                              )),
                            )
                          ),
                        ],
                      ),

                      // Divider
                      Divider(
                        color: const Color.fromARGB(255, 118, 118, 118),
                        indent: MediaQuery.sizeOf(context).width * 0.01,
                        endIndent: MediaQuery.sizeOf(context).width * 0.01,
                      ),

                      // Reason
                      Row(
                        children: [
                          Icon(Icons.edit, color: const Color.fromARGB(255, 199, 199, 199), size: 15),
                          Padding(padding: EdgeInsets.only(left: 8.0),
                            child:
                            Text("Reason", style: TextStyle(color: Colors.grey)),
                          )
                        ],
                      ),

                      // Textfield
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hint: Text("No Reason yet", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                        ),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.lightBlue 
                        ),
                        onPressed: (){
                          // Button Funct

                        }, 
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            Padding(padding: EdgeInsets.only(left: 8.0),
                              child: Text("Fill / Edit Reason", style: TextStyle(color: Colors.white),),
                            )
                          ],
                        )
                      )
                    ],
                  ),
                ),
              )
            ),

            // ElevatedButton(
            //   onPressed: (){
            //     _getPrefs();
            //   }, 
            //   child: Text("Test prefs")
            // )
          ],
        )
      )
    );
  }
}