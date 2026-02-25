import 'dart:convert';

import 'package:absence/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:absence/l10n/app_localizations.dart';

class Regist extends StatefulWidget {
  const Regist({super.key});

  @override
  State<Regist> createState() => _RegistState();
}

class _RegistState extends State<Regist> {
  final _formKey = GlobalKey<FormState>();

  // state get employees
  List<String> _employeeNames = [];
  String? _selectedEmployee;
  bool _isLoadingNames = true;

  // state get Leaders
  List<String> _leaderNames = [];
  String? _selectedLeaders;
  bool _loadingLeader = true;

  // TextEditingControllers
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repassword = TextEditingController();

  // state put user in parameter's url

  // File? _selectedImage;
  File? _frontFace;
  File? _leftFace;
  File? _rightFace;
  bool _uploadingFace = false;

  // current step
  int _currentStep = 0;

  // Mapping Steps
  final steps = [
    'straight face frontfacing camera',
    'rotate ur face lil bit to the left',
    'rotate ur face lil bit to the right'
  ];

  // button register state
  bool get _isPhotoCompleted {
  return _frontFace != null &&
         _leftFace != null &&
         _rightFace != null;
}


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadEmployeesNames();
    _loadLeaders();
  }

  Future<File?> _captureFace() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front ,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Future<void> _takeFrontFace() async {
  //   final image = await _captureFace();
  //   if (image != null) {
  //     setState(() {
  //       _frontFace = image;
  //     });
  //   }
  // }

  // Future<void> _takeLeftFace() async {
  //   final image = await _captureFace();
  //   if (image != null) {
  //     setState(() {
  //       _leftFace = image;
  //     });
  //   }
  // }

  // Future<void> _takeRightFace() async {
  //   final image = await _captureFace();
  //   if (image != null) {
  //     setState(() {
  //       _rightFace = image;
  //     });
  //   }
  // }

  // Future<void> _uploadSingleFace(File image) async {
  //   final subject = Uri.encodeComponent(_selectedEmployee!);
  //   final xapikey = '23e225bf-8f28-4493-a870-39019954fdae';

  //   final uri = Uri.parse(
  //     'https://cais-ai.cbinstrument.com/api/v1/recognition/faces?subject=$subject',
  //   );

  //   final request = http.MultipartRequest('POST', uri)
  //         ..headers['x-api-key'] = xapikey
  //         ..files.add(
  //           await http.MultipartFile.fromPath('file', image.path)
  //   );

  //   final response = await request.send();
  //   if (response.statusCode != 200 && response.statusCode != 201) {
  //     throw Exception("Upload Failed (${response.statusCode})");
  //   }
  // }

  // Future<void> _uploadAllFaces() async {
  //   if (_selectedEmployee == null) {
  //     _showMsg('Who are you???');
  //     return;
  //   }

  //   if (_frontFace == null || _leftFace == null || _rightFace == null) {
  //     _showMsg('complete ur take photo');
  //     return;
  //   }

  //   setState(() {
  //     _uploadingFace = true;
  //   });

  //   try {
  //     await _uploadSingleFace(_frontFace!);
  //     await _uploadSingleFace(_leftFace!);
  //     await _uploadSingleFace(_rightFace!);

  //     _showMsg('Photo has been successfully registered');
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     _showMsg('Failed to upload');
  //   } finally {
  //     setState(() {
  //       _uploadingFace = false;
  //     });
  //   }
  // }

  Future<String> fileToBase64Image(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final resized = img.copyResize(
        image,
        width: 720,
      );

    final jpg = img.encodeJpg(
      resized,
      quality: 65
    );
    final base64Str = base64Encode(jpg);
    return 'data:image/jpeg;base64,$base64Str';

  }

  Future<void> _regist() async {
    if(!_formKey.currentState!.validate()) return;

    if (_frontFace == null || _rightFace == null || _leftFace == null) {
      _showMsg('complete the photos');
      return;
    }

    if (_password.text != _repassword.text) {
      _showMsg('password not same');
      return;
    }

    if (_selectedEmployee == null || _selectedLeaders == null) {
      _showMsg('Please select user and leader');
      return;
    }

    setState(() {
      _uploadingFace = true;
    });

    try {
      final photos = [
        await fileToBase64Image(_frontFace!),
        await fileToBase64Image(_leftFace!),
        await fileToBase64Image(_rightFace!)
      ];

      final payload = {
        "email"   : _email.text.trim(),
        "password": _password.text,
        "name"    : _selectedEmployee,
        "leader"  : _selectedLeaders,
        "photos"  : photos
      };

      final headers = {
        "Content-Type": "application/json",
      };

      print(jsonEncode(payload));

      final responses = await http.post(
        Uri.parse('https://cais.cbinstrument.com/api/user/register'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (responses.statusCode == 200 || responses.statusCode == 201) {
        final body = jsonDecode(responses.body);
        print("gebugBody: $body");

        _showMsg("registration successful");
        _showDialogSuccess();
      } else {
        debugPrint(responses.body);
        _showDialogFailed();
      }

    } catch (e) {
      debugPrint(e.toString());
      _showMsg("an internal server problem occur");
    } finally {
      setState(() => _uploadingFace = false);
    }
  }

  void _showDialogFailed() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: 
            Column(
              children: [
                Row(
                  children: [
                    Text("Registration Failed", style: TextStyle(color: const Color.fromARGB(255, 225, 31, 31), fontSize: 16, fontWeight: FontWeight.bold)),
                    Padding(padding: EdgeInsets.all(8), child: Icon(Icons.error),)
                  ],
                ),
                Divider()
              ],
            ),
          actions: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
                  backgroundColor: Colors.green
                ),
                onPressed: (){
                  // button Funct
                  Navigator.of(context).pop();
                }, 
                child: Text("OK", style: TextStyle(color: Colors.white),)
              ),
            )
          ],
        );
      }
    );
  }

  void _showDialogSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: 
            Column(
              children: [
                Row(
                  children: [
                    Text("Registration Successful", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w600)),
                    Padding(padding: EdgeInsets.all(8), child: Icon(Icons.verified, color: Colors.lightGreen,),)
                  ],
                ),
                Divider()
              ],
            ),
          actions: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
                  backgroundColor: Colors.green
                ),
                onPressed: (){
                  // button Funct
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => MyHomePage())
                  );
                }, 
                child: Text("OK", style: TextStyle(color: Colors.white),)
              ),
            )
          ],
        );
      }
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> captureStep() async {
    final image = await _captureFace();

    if (image == null) return;

    setState(() {
      if (_currentStep == 0) _frontFace = image;
      if (_currentStep == 1) _leftFace = image;
      if (_currentStep == 2) _rightFace = image;

      if (_currentStep < 2) {
        _currentStep++;
      }
    });
  }

  void retryStep() {
    setState(() {
      if (_currentStep == 0) _frontFace = null;
      if (_currentStep == 1) {
        _leftFace = null;
        _currentStep = 0;
      }
      if (_currentStep == 2) {
        _rightFace = null;
        _currentStep = 1;
      }
    });
  }

  Future<void> _loadEmployeesNames() async {
    try {
      final names = await _fetchEmployees();
      setState(() {
        _employeeNames = names;
        _selectedEmployee = null;
        _isLoadingNames = false;
      });
    } catch (e) {
      _isLoadingNames = false;
      debugPrint(e.toString());
    }
  }

  Future<void> _loadLeaders() async {
    try {
      final leaders = await _fetchLeaders();
      setState(() {
        _leaderNames = leaders;
        _selectedLeaders = null;
        _loadingLeader = false;
      });
    } catch (e) {
      debugPrint('Leader error: $e');
      setState(() {
        _loadingLeader = false;
      });
    }
  }

  Future<List<String>> _fetchEmployees() async {
    final url = Uri.parse(
      'https://cais.cbinstrument.com/api/user/registered',
    );
    final headers = {"Content-Type": "application/json"};

    final response = await http.get(
      url,
      headers: headers
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['names']);
    } else {
      throw Exception("Failed To get Data");
    }
  }

  Future<List<String>> _fetchLeaders() async {
    final url = Uri.parse(
      'https://cais.cbinstrument.com/api/user/leaders'
    );
    final headers = {"Content-type" : "application/json"};

    final response = await http.get(
      url,
      headers: headers
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("response: $data");

      return List<String>.from(data['names']);
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 84, 134),
      body: 
      SingleChildScrollView(
        // child: SizedBox(
        //   height: MediaQuery.sizeOf(context).height * 1,
          child: 
          Center(
            child: 
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    child: 
                    Container(
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        // outside glowing
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
                      ]
                    ),
                      child: Card(
                        color: const Color.fromARGB(255, 5, 37, 93),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue, 
                            width: 1,
                          ),
                        ),
                        child: 
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Image.asset('assets/logoBiru.png', width: 220, height: 65),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.only(top:10),
                              child: Text(t.translate("registss"), 
                                            style: TextStyle(color: const Color.fromARGB(255, 202, 202, 202), 
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900
                                            ),
                                          ),
                            ),
                      
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.5,
                                child: Container(
                                  height: 3, 
                                  decoration: BoxDecoration(
                                    color: Colors.cyanAccent, // garis inti
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.6),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.3),
                                        blurRadius: 30,
                                        spreadRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Form(
                              key: _formKey,
                              child:
                                Column(
                                  children: [
                              
                                    // ====== employee's lists =======
                                    _isLoadingNames ? const CircularProgressIndicator() :
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width * 0.75,
                                      height: MediaQuery.sizeOf(context).height * 0.06,
                                      child:  
                                      DropdownButtonFormField(
                                        decoration:InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            label: Text(t.translate("user")),
                                        ),
                                        value: _selectedEmployee,
                                        items: _employeeNames.map((name){
                                          return DropdownMenuItem<String>(
                                            value: name,
                                            child: Text(name)
                                          );
                                        }).toList(), 
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedEmployee = value;
                                          });
                                        },
                                      ),
                                    ),
                              
                                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),
                              
                                    // ====== Leader's lists =======
                                    _loadingLeader ? const CircularProgressIndicator() :
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width * 0.75,
                                      height: MediaQuery.sizeOf(context).height * 0.06,
                                      child:  
                                      DropdownButtonFormField(
                                        decoration:InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            label: Text(t.translate("leader"))
                                        ),
                                        value: _selectedLeaders,
                                        items: _leaderNames.map((name){
                                          return DropdownMenuItem<String>(
                                            value: name,
                                            child: Text(name)
                                          );
                                        }).toList(), 
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedLeaders = value;
                                          });
                                        },
                                      ),
                                    ),
                              
                                    // Office Email
                                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width * 0.75,
                                      height: MediaQuery.sizeOf(context).height * 0.06,
                                      child: TextFormField(
                                        controller: _email,
                                        // obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: t.translate("emailOffice"),
                                          hintStyle: TextStyle(color: const Color.fromARGB(
                                                                  255, 195, 195, 195)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none
                                          ),
                                          filled: true,
                                          fillColor: Colors.white
                                        ),
                                      ),
                                    ),
                              
                                    // Password
                                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width * 0.75,
                                      height: MediaQuery.sizeOf(context).height * 0.06,
                                      child: TextFormField(
                                        controller: _password,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: t.translate("pas"),
                                          hintStyle: TextStyle(color: const Color.fromARGB(
                                                                  255, 195, 195, 195)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none
                                          ),
                                          filled: true,
                                          fillColor: Colors.white
                                        ),
                                      ),
                                    ),
                              
                                    // Re-Password
                                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width * 0.75,
                                      height: MediaQuery.sizeOf(context).height * 0.06,
                                      child: TextFormField(
                                        controller: _repassword,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: t.translate("repas"),
                                          hintStyle: TextStyle(color: const Color.fromARGB(
                                                                  255, 195, 195, 195)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none
                                          ),
                                          filled: true,
                                          fillColor: Colors.white
                                        ),
                                      ),
                                    ),
                              
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Divider(thickness: 2, endIndent: MediaQuery.sizeOf(context).width * 0.05, indent: MediaQuery.sizeOf(context).width * 0.05,),
                                    ),
                              
                                    //====== PHOTO TAKING ========
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width * 0.5,
                                        height: MediaQuery.sizeOf(context).height * 0.25,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.blueAccent, style: BorderStyle.solid),
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.black12,
                                        ),
                                        child: Builder(
                                          builder: (_) {
                                            File? currentImage;
                                            if (_currentStep == 0) currentImage = _frontFace;
                                            if (_currentStep == 1) currentImage = _leftFace;
                                            if (_currentStep == 2) currentImage = _rightFace;
                                              
                                            return currentImage == null
                                                ? Icon(Icons.camera_alt, size: 60, color: Colors.white70)
                                                : ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.file(
                                                      currentImage,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    ),
                                                  );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.005,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(3, (index) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: index <= _currentStep
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        );
                                      }),
                                    ),
                              
                                    // cam Button
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // ========= Retry ===========
                                        if ((_currentStep == 0 && _frontFace != null) ||
                                          (_currentStep == 1 && _leftFace != null) ||
                                          (_currentStep == 2 && _rightFace != null))
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red.shade300,
                                              padding: EdgeInsets.symmetric(horizontal:24, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                              )
                                            ),
                                            onPressed: retryStep,
                                            child: Text(t.translate('retake'), style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
                                          ),
                                        ),
                                        // ========== take Photo ==========
                                        if (!_isPhotoCompleted)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12, left: 5),
                                          child: ElevatedButton.icon(
                                            icon: Icon(Icons.camera_alt),
                                            label: Text(t.translate("camreg"), style: TextStyle(color: Colors.white),),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueAccent,
                                              padding: EdgeInsets.symmetric(horizontal:24, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: _uploadingFace ? null : captureStep,
                                          ),
                                        ),
                                      ],
                                    ),
                              
                                    // information Photo text
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: 
                                      SizedBox(
                                        width: MediaQuery.sizeOf(context).width * 0.75,
                                        child: Card(
                                          color: Colors.green.withOpacity(0.5),
                                          child: 
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: 
                                            Text(
                                              t.translate(_currentStep == 0 ? 'photo1' : _currentStep == 1 ? 'photo2' : 'photo3'),
                                              style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                                      child: 
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          // Back To Login
                                          SizedBox(
                                            width: MediaQuery.sizeOf(context).width * 0.3,
                                            height: MediaQuery.sizeOf(context).height * 0.06,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10)
                                                )
                                              ),
                                              onPressed: 
                                              // button submit funct
                                              (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                                              }, 
                                              child: Text(t.translate("backLogin"), style: TextStyle(color: Colors.white),)
                                            ),
                                          ),
                              
                                          // Register
                                          SizedBox(
                                            width: MediaQuery.sizeOf(context).width * 0.3,
                                            height: MediaQuery.sizeOf(context).height * 0.06,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _isPhotoCompleted ? const Color.fromARGB(255, 73, 197, 254) : Colors.grey,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10)
                                                )
                                              ),
                                              onPressed: (_uploadingFace || !_isPhotoCompleted) ? null : 
                                              // button submit funct
                                              () async {
                                                await _regist();
                                              }, 
                                              child: Text(
                                                t.translate("okReg"), 
                                                style: TextStyle(color: Colors.white),
                                              )
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            // Padding(padding: EdgeInsets.all(5.0)),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(t.translate("beta"), style: TextStyle(color: const Color.fromARGB(
                                                                    255, 195, 195, 195), fontSize: 8, fontWeight: FontWeight.w800),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // ),
    );
  }
}