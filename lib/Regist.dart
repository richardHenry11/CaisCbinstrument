import 'dart:convert';

import 'package:absence/main.dart';
import 'package:absence/theme.dart';
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

  List<String> _employeeNames = [];
  String? _selectedEmployee;
  bool _isLoadingNames = true;

  List<String> _leaderNames = [];
  String? _selectedLeaders;
  bool _loadingLeader = true;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repassword = TextEditingController();

  File? _frontFace;
  File? _leftFace;
  File? _rightFace;
  bool _uploadingFace = false;

  int _currentStep = 0;

  final steps = [
    'straight face frontfacing camera',
    'rotate ur face lil bit to the left',
    'rotate ur face lil bit to the right',
  ];

  bool get _isPhotoCompleted {
    return _frontFace != null && _leftFace != null && _rightFace != null;
  }

  @override
  void initState() {
    super.initState();
    _loadEmployeesNames();
    _loadLeaders();
  }

  Future<File?> _captureFace() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String> fileToBase64Image(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final resized = img.copyResize(image, width: 720);

    final jpg = img.encodeJpg(resized, quality: 65);
    final base64Str = base64Encode(jpg);
    return 'data:image/jpeg;base64,$base64Str';
  }

  Future<void> _regist() async {
    if (!_formKey.currentState!.validate()) return;

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

    setState(() => _uploadingFace = true);

    try {
      final photos = [
        await fileToBase64Image(_frontFace!),
        await fileToBase64Image(_leftFace!),
        await fileToBase64Image(_rightFace!),
      ];

      final payload = {
        "email": _email.text.trim(),
        "password": _password.text,
        "name": _selectedEmployee,
        "leader": _selectedLeaders,
        "photos": photos,
      };

      final headers = {"Content-Type": "application/json"};

      final responses = await http.post(
        Uri.parse('https://cais.cbinstrument.com/api/user/register'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (responses.statusCode == 200 || responses.statusCode == 201) {
        _showMsg("registration successful");
        _showDialogSuccess();
      } else {
        _showDialogFailed();
      }
    } catch (e) {
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
          backgroundColor: AppTheme.cardBackground(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    "Registration Failed",
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFF2AACEB),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDialogSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    "Registration Successful",
                    style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFF2AACEB),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      setState(() => _loadingLeader = false);
    }
  }

  Future<List<String>> _fetchEmployees() async {
    final url = Uri.parse('https://cais.cbinstrument.com/api/user/registered');
    final headers = {"Content-Type": "application/json"};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['names']);
    } else {
      throw Exception("Failed To get Data");
    }
  }

  Future<List<String>> _fetchLeaders() async {
    final url = Uri.parse('https://cais.cbinstrument.com/api/user/leaders');
    final headers = {"Content-type": "application/json"};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['names']);
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/loginBekgron.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: screenHeight * 0.92,
              width: screenWidth,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 19, 89, 146),
                      width: 1,
                    ),
                  ),
                  color: AppTheme.cardBackground(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Image.asset(
                          'assets/logoBiru.png',
                          width: 200,
                          height: 60,
                        ),
                        SizedBox(
                          width: screenWidth * 0.75,
                          child: Divider(thickness: 1, color: AppTheme.borderColor(context)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            t.translate("registss"),
                            style: const TextStyle(
                              color: Color.fromARGB(83, 42, 171, 235),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _isLoadingNames
                                  ? const CircularProgressIndicator()
                                  : _DropdownField(
                                      value: _selectedEmployee,
                                      label: t.translate("user"),
                                      items: _employeeNames,
                                      onChanged: (v) {
                                        setState(() => _selectedEmployee = v);
                                      },
                                    ),
                              SizedBox(height: screenHeight * 0.012),
                              _loadingLeader
                                  ? const CircularProgressIndicator()
                                  : _DropdownField(
                                      value: _selectedLeaders,
                                      label: t.translate("leader"),
                                      items: _leaderNames,
                                      onChanged: (v) {
                                        setState(() => _selectedLeaders = v);
                                      },
                                    ),
                              SizedBox(height: screenHeight * 0.015),
                              _TextField(
                                controller: _email,
                                hint: t.translate("emailOffice"),
                                prefixIcon: 'assets/sms.png',
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              _TextField(
                                controller: _password,
                                hint: t.translate("pas"),
                                obscure: true,
                                prefixIcon: 'assets/finger-scan.png',
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              _TextField(
                                controller: _repassword,
                                hint: t.translate("repas"),
                                obscure: true,
                                prefixIcon: 'assets/finger-scan.png',
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Container(
                                  height: 1,
                                  color: AppTheme.borderColor(context),
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.7,
                                height: screenHeight * 0.22,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 19, 89, 146),
                                  ),
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
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.camera_alt,
                                                size: 50,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                t.translate(
                                                  _currentStep == 0
                                                      ? 'photo1'
                                                      : _currentStep == 1
                                                          ? 'photo2'
                                                          : 'photo3',
                                                ),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              currentImage,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          );
                                  },
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index <= _currentStep
                                          ? const Color(0xFF2AACEB)
                                          : AppTheme.borderColor(context),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if ((_currentStep == 0 && _frontFace != null) ||
                                      (_currentStep == 1 && _leftFace != null) ||
                                      (_currentStep == 2 && _rightFace != null))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade300,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: retryStep,
                                        child: Text(
                                          t.translate('retake'),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  if (!_isPhotoCompleted)
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                                      label: Text(
                                        t.translate("camreg"),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2AACEB),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _uploadingFace ? null : captureStep,
                                    ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      label: t.translate("backLogin"),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MyHomePage(),
                                          ),
                                        );
                                      },
                                      outlined: true,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _ActionButton(
                                      label: t.translate("okReg"),
                                      disabled: _uploadingFace || !_isPhotoCompleted,
                                      onTap: () => _regist(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            t.translate("beta"),
                            style: TextStyle(
                              color: AppTheme.textSecondary(context),
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final String prefixIcon;

  const _TextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    const borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color.fromARGB(255, 19, 89, 146)),
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 14,
          ),
          enabledBorder: borderStyle,
          focusedBorder: borderStyle,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(prefixIcon, width: 20, height: 20),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color.fromARGB(255, 19, 89, 146)),
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          enabledBorder: borderStyle,
          focusedBorder: borderStyle,
          label: Text(label),
          labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        value: value,
        items: items.map((name) {
          return DropdownMenuItem<String>(
            value: name,
            child: Text(name),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool disabled;
  final bool outlined;

  const _ActionButton({
    required this.label,
    this.onTap,
    this.disabled = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: outlined
            ? null
            : (disabled
                ? null
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF186185),
                      Color(0xFF2598CF),
                      Color(0xFF2AACEB),
                    ],
                  )),
        border: outlined
            ? Border.all(color: const Color(0xFF2AACEB), width: 2)
            : null,
        color: outlined
            ? Colors.transparent
            : (disabled ? Colors.grey.shade300 : null),
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: outlined
                ? const Color(0xFF2AACEB)
                : (disabled ? Colors.grey : Colors.white),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
