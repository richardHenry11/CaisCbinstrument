import 'dart:convert';

import 'package:absence/lateness.dart';
import 'package:absence/lemur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:absence/l10n/app_localizations.dart';

const String baseImageUrl = "https://cais.cbinstrument.com/";

bool isLate(String? checkIn) {
  if (checkIn == null || checkIn.isEmpty) return false;

  final parts = checkIn.split(':');
  if (parts.length != 2) return false;

  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;

  // telat jika lewat jam 09:00
  return hour > 8 && minute > 30 || (hour == 8 && minute > 30);
}

void showPhotoPreview(BuildContext context, String imagePath) {
  final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.network(
                  "$baseImageUrl$imagePath",
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Center(child: Text(t.translate("failedPict"), style: TextStyle(color: Colors.white))),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          ),
        );
      },
    );
  }

Future<void> saveLatenessToPrefs(Map<String, dynamic> item) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'lateness_data',
    jsonEncode(item),
  );
}

String dateFormat(String? date) {
  if (date == null || date.isEmpty) return '-';

  try {
    final parsedDate = DateTime.parse(date);
    final formatter = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    return formatter.format(parsedDate);
    
  } catch (e) {
    return date;
  }
}

Future<void> saveSelectedDate(String date) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('selected_absence_date', date);
}

Future<Map<String, dynamic>?> getLatenessFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('lateness_data');
  final name = prefs.getString('name');

  if (raw == null) return null;

  final data = jsonDecode(raw) as Map<String, dynamic>;
  data['name'] = name;

  return data;
  
}

Widget _absenceCard(BuildContext context, Map<String, dynamic> item) {
  final t = AppLocalizations.of(context)!;
  return Column(
    children: [
      // =================== DATE ===================
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    MaterialCommunityIcons.calendar,
                    color: Colors.grey,
                    size: 15,
                  ),
                  SizedBox(width: 8),
                  Text(
                    t.translate("dateRackup"),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                dateFormat(item['date']),
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),

          // STATUS (T1, T2, dll)
          SizedBox(
            width: 60,
            height: 30,
            child: Card(
              color: item['status'] == 'Kantor' || item['status'] == 'T1' || item['status'] == 'T2' || item['status'] == 'T3' ? Colors.green 
                      : item['status'] == 'sick' ? Colors.purpleAccent 
                      : item['status'] == 'wfh' ? Colors.blue : Colors.yellow,
              child: Center(
                child: Text(
                  item['status'] ?? '-',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),

      Divider(color: Colors.grey),

      // =================== TIME ===================
      Row(
        children: [
          _timeColumn(context, t.translate("in"), item['check_in']),
          _timeColumn(context, t.translate("out"), item['check_out']),
        ],
      ),

      Divider(color: Colors.grey),

      // =================== PHOTO ===================
      Column(
        children: [
          Row(
            children: [
              _photoButton(context, t.translate('in'), item['has_photo_in'], item['photo_check_in'],),
              SizedBox(width: 8),
              _photoButton(context, t.translate("out"), item['has_photo_out'], item['photo_check_out']),
              SizedBox(width: 8),
              _photoButton(context, t.translate("prove"), item['proof_photo'] != "", item['proof_photo']),
            ],
          ),
          SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.9,
        child: 
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            backgroundColor: const Color.fromARGB(255, 169, 137, 255)
          ),
          onPressed: () async {
            // button funct here!
            await saveSelectedDate(item['date']);
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => Lemur())
            );
          }, 
          child: 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MaterialCommunityIcons.alarm, color: Colors.red,),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(t.translate("confirmOT"), style: TextStyle(color: Colors.white),),
              ),
            ],
          )
        ),
      )
        ],
      ),

      Divider(color: Colors.grey),

      // =================== STATUS ===================
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_box, color: Colors.green, size: 15),
              SizedBox(width: 8),
              Text(
                t.translate("confirmation"),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 6),
          Card(
            color: item['supervisor_status'] == 'pending' ? Colors.amber 
                    : item['supervisor_status'] == 'approved' ? Colors.green : Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: Text(
                item['supervisor_status'] ?? '-',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      Divider(color: Colors.grey),

      // =================== Deductions ===============
      Column(
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.white, size: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(t.translate("deduction"), style: TextStyle(color: Colors.grey),),
              )
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Row(
              children: [
                Text("Rp.", style: TextStyle(color: Colors.white),),
                Text(item['deduction'] ?? '0', style: TextStyle(
                  color: item['deduction'] == '0' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold
                  ),
                ),
                Text(".-", style: TextStyle(color: Colors.white),)
              ],
            ),
          )
        ],
      ),

      Divider(color: Colors.grey),

      // =================== reasoning =================
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(MaterialCommunityIcons.file_document_edit, color: Colors.white, size: 15,),
              Padding(
                padding: EdgeInsetsGeometry.only(left: 8.0),
                child: Text(t.translate("reason"), style: TextStyle(color: Colors.grey),),
              )
            ],
          ),

          TextField(
            enabled: false,
            readOnly: true,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "",
              hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
            ),
          ),

          // Lateness Button
          if (isLate(item['check_in']))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await saveLatenessToPrefs(item);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.translate("latenessSaved")),
                    ),
                  );

                  await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => Lateness())
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      t.translate("lateConfirm"),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // // Lateness preferences checker button
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.deepPurple,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          //   onPressed: () async {
          //     final data = await getLatenessFromPrefs();

          //     if (data == null) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text("Belum ada data lateness tersimpan"),
          //         ),
          //       );
          //       return;
          //     }

          //     showDialog(
          //       context: context,
          //       builder: (_) => AlertDialog(
          //         title: const Text("Lateness Data"),
          //         content: SingleChildScrollView(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text("Tanggal : ${data['date']}"),
          //               Text("Check In : ${data['check_in']}"),
          //               Text("Status   : ${data['status']}"),
          //               Text("ID       : ${data['id']}"),
          //               Text("Name     : ${data['name']}")
          //             ],
          //           ),
          //         ),
          //         actions: [
          //           TextButton(
          //             onPressed: () => Navigator.pop(context),
          //             child: const Text("Tutup"),
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          //   child: const Text(
          //     "Cek Preferences",
          //     style: TextStyle(color: Colors.white),
          //   ),
          // )
        ],
      )
    ],
  );
}

  Widget _timeColumn(
    BuildContext context,
    String title,
    String? value,
  ) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 4),
          Text(
            value == null || value.isEmpty ? "-" : value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

Widget _photoButton(BuildContext context, String label, bool available, String imagePath) {
  return SizedBox(
    width: MediaQuery.sizeOf(context).width * 0.28,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: available ? Colors.green : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: available ? () {
        // Button Funct
        showPhotoPreview(context, imagePath);
      } : null,
      child: Row(
        children: [
          Icon(MaterialCommunityIcons.camera, size: 16),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}


class RackupAbsence extends StatefulWidget {
  const RackupAbsence({super.key});

  @override
  State<RackupAbsence> createState() => _RackupAbsenceState();
}

class _RackupAbsenceState extends State<RackupAbsence> {

  // TextEditingController
    final TextEditingController _startDate = TextEditingController();
    final TextEditingController _endDate = TextEditingController();


    // Save Date Time Picker
    DateTime? startDate;
    DateTime? endDate;

    // Getter Date Time prefs
    String? _startDatepref;
    String? _endDatepref;
    String? _namePref;
    String? _token;

    // tresholder API Response
    List<Map<String, dynamic>> absences = [];

    // dateTime picker formatter
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    // loader circular
    bool isLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initFunct();
  }

  Future<void> _initFunct() async {
    await _getPrefs();
    _loadApi();
  }
  
  Future<void> _saveToPrefs() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('startDate', formatter.format(startDate!));
    await _prefs.setString('endDate', formatter.format(endDate!));
  }

  Future<void> _loadApi() async {
    if (_token == null) return;

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // date formatter
    final dateFrom = formatter.format(startDate!);
    final dateTo = formatter.format(endDate!);


    final url =
      "https://cais.cbinstrument.com/auth/absensi/karyawan"
      "?nama=$_namePref"
      "&dateFrom=$dateFrom"
      "&dateTo=$dateTo";
    final headers = {
    "Authorization" : "Bearer $_token"
    };

    try {
      final responses = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (responses.statusCode == 200) {
        final body = jsonDecode(responses.body);

        setState(() {
          absences = body.cast<Map<String, dynamic>>();
        });
      }
    } finally {
      // 🔄 matikan loader
      setState(() {
        isLoading = false;
      });
    }
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

  void _setDefaultDateRange() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    startDate = sevenDaysAgo;
    endDate = now;

    _startDate.text = formatter.format(sevenDaysAgo);
    _endDate.text = formatter.format(now);
  }

  Future<void> _getPrefs() async {
    final SharedPreferences _p = await SharedPreferences.getInstance();

    _startDatepref = _p.getString('startDate');
    _endDatepref = _p.getString('endDate');
    _token = _p.getString('token');
    final name = _p.getString('name');

    _namePref = name?.replaceAll(' ', '+');

    // date checker
    if (_startDatepref == null || _endDatepref == null) {
      _setDefaultDateRange(); // default 7 hari kebelakang
    } else {
      startDate = DateTime.parse(_startDatepref!);
      endDate = DateTime.parse(_endDatepref!);

      _startDate.text = _startDatepref!;
      _endDate.text = _endDatepref!;
    }

    print("name: $_namePref");
    print("token: $_token");
    print("start Date: ${_startDate.text}");
    print("end Date: ${_endDate.text}");
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
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 23, 58),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 189, 189),
        title: Text(t.translate("rackup")),
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
                            labelText: t.translate("startDate"),
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
                            labelText: t.translate("endDate"),
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
                        onPressed: (!getValidRangeTime() || isLoading) ? null : () async {
                          // button Funct
                          await _saveToPrefs(); 
                          await _loadApi();
                        }, 
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: const Color.fromARGB(255, 88, 88, 88)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(t.translate("filter"), style: TextStyle(color: Colors.white)),
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

            // ===================== ABSENCE CARD ======================
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: isLoading
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(t.translate("loadingDat"),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ) : absences.isEmpty
                  ? Center(
                      child: Text(
                        t.translate("noData"),
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: absences.length,
                      itemBuilder: (context, index) {
                        final item = absences[index];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: const Color.fromARGB(255, 66, 91, 130),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _absenceCard(context, item),
                          ),
                        );
                      },
                    ),
            )

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