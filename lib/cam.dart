import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:absence/l10n/app_localizations.dart';
import 'package:absence/main.dart';
import 'package:absence/pilihdinas.dart';
import 'package:absence/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? _controller;
  List<CameraDescription>? cameras;

  Timer? _captureTimer;

  bool _isProcessing = false;

  Future<String> imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  // var SharedPrefs
  String? _savedUser;
  String? _savedToken;
  // String? _isLoggedIn;
  String? _savedName;
  // String? _savedType;
  String? _savedStatus;
  String? _savedAttType;
  String? _savedShiftType;

  // state validator
  bool _faceValid = false;
  // String? _detectedName;
  String _faceMessage = "";
  double? _similarity;

  File? _photo;
  bool _isSubmitting = false;

  // error treshold
  String? error;

  // Location Treshold
  double? _lat;
  double? _lng;
  String? _address;

  // clock timer overlayed
  Timer? _clockTimer;

  // in or out
  String? attendance;
  

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _getLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // throw Exception("Location Permission denied");

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location permission denied")));
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _lat = pos.latitude;
    _lng = pos.longitude;

    final placemarks = await placemarkFromCoordinates(_lat!, _lng!);

    final mark = placemarks.first;

    _address =
        "${mark.subLocality ?? ''}, ${mark.locality ?? ''}, ${mark.administrativeArea ?? ''}";
  }

  Future<File> _drawGpsOverlay(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final now = DateTime.now();

    final text =
        """
    ${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}
    ${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}
    $_address
    $_savedAttType - $_savedShiftType
    """;

    img.drawString(
      image,
      text,
      font: img.arial24,
      x: 21,
      y: image.height - 139,
      color: img.ColorRgb8(0, 0, 0),
    );

    img.drawString(
      image,
      text,
      font: img.arial24,
      x: 20,
      y: image.height - 140,
      color: img.ColorRgb8(255, 255, 255),
    );

    final outFile = File(
      '${file.parent.path}/gps_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await outFile.writeAsBytes(img.encodeJpg(image, quality: 85));
    return outFile;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPage();
    });
    _clockTimer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      if (mounted) {
        setState(() {});
      }
    },
  );
  }

  Future<void> _initPage() async {
    await _prefsCatcher();
    await _initCamera();
    _startRealtimeCapture();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();

    final frontCamera = cameras!.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (!mounted) return;

    setState(() {
      
    });
  }

  void _startRealtimeCapture() {
    _captureTimer?.cancel();

    _captureTimer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        if (_isProcessing) return;

        _isProcessing = true;

        try {
          await _captureAndRecognize();
        } catch (e) {
          debugPrint("Capture Error: $e");
        }

        _isProcessing = false;
      },
    );
  }

  Future<void> _captureAndRecognize() async {
    if (_controller == null) return;

    if (!_controller!.value.isInitialized) return;

    final XFile image = await _controller!.takePicture();

    final file = File(image.path);

    await _getLocation();

    final normalized = await _normalizeImage(file);

    final stamped = await _drawGpsOverlay(normalized);

    if (!mounted) return;

    setState(() {
      _photo = stamped;
    });

    await recognizeFace(stamped);

    if (_faceValid) {
      _captureTimer?.cancel();
    }
  }

  // Future<void> _timeSelector() async {

  // }

  Widget _buildGPSOverlay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.35),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppTheme.cyanAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.access_time_rounded,
                    color: AppTheme.cyanAccent, size: 12),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat("HH:mm:ss", "en_EN").format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat("EEE, dd MMM", "en_EN").format(DateTime.now()),
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.my_location_rounded, color: Colors.greenAccent, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _address ?? "Loading location...",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.pin_drop_rounded, color: Colors.orangeAccent, size: 13),
              const SizedBox(width: 6),
              Text(
                "${_lat?.toStringAsFixed(6) ?? '---'}, ${_lng?.toStringAsFixed(6) ?? '---'}",
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.cyanAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.cyanAccent.withValues(alpha: 0.25)),
                ),
                child: Text(
                  "$_savedAttType - $_savedShiftType",
                  style: const TextStyle(
                    color: AppTheme.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<File> _normalizeImage(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception("Failed to decode image");
    }

    // Resize optimal untuk face recognition
    final resized = img.copyResize(decoded, width: 800);

    // Encode ulang ke JPEG (buang format aneh kamera)
    final jpg = img.encodeJpg(resized, quality: 75);

    final newFile = File(
      '${file.parent.path}/normalized_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await newFile.writeAsBytes(jpg);
    return newFile;
  }

  // Future<void> _takePhoto() async {
  //   final granted = await requestCameraPermission();
  //   if (!granted) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
  //     return;
  //   }
  //   final XFile? image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //     imageQuality: 75,
  //   );
  //   if (image != null) {
  //     await _getLocation();
  //     setState(() {
  //       _photo = File(image.path);
  //       _faceValid = false;
  //     });

  //     final normalized = await _normalizeImage(_photo!);
  //     final stamped = await _drawGpsOverlay(normalized);

  //     setState(() {
  //       _photo = stamped;
  //     });

  //     await recognizeFace(stamped);

  //     // final image = await _controller.takePicture();
  //     // debugPrint("Photo Taken: ${image.path}");

  //     // await _sendToCompreFace(image.path);
  //     // // Continue Absence
  //     // _submitAbsence();
  //   }
  // }

  Future<void> _prefsCatcher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedUser = prefs.getString('user') ?? "Who is there?";
      _savedToken = prefs.getString('token') ?? "this is token";
      _savedName = prefs.getString('name') ?? "who is this?";
      _savedStatus = prefs.getString('status') ?? "which type r u?";
      _savedAttType =
          prefs.getString('attendance_type') ?? "what att type r u?";
      _savedShiftType =
          prefs.getString('shift_type') ?? "what ShiftType is this?";

      // _isLoggedIn = prefs.getBool('isLoggedIn');
      print("savedUser: $_savedUser");
      print("savedToken: $_savedToken");
      print("savedName: $_savedName");
      print("Attendance type: $_savedAttType");
      print("Status: $_savedStatus");
      print("Shift Status: $_savedShiftType");
    });
  }

  Future<void> _updateStatusByTime() async {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    String status;
    // String attType;

    if (hour < 8 || (hour == 8 && minute <= 10)) {
      status = "Hadir";
      // attType = "Hadir";
    } else if (hour == 8 && minute >= 10 && minute <= 15) {
      status = "Terlambat";
      // attType = "Terlambat";
    } else if (hour == 8 && minute > 15 && minute <= 30) {
      status = "Terlambat";
      // attType = "Terlambat";
    } else if (hour == 8 && minute > 30 && minute <= 59) {
      status = "Terlambat";
      // attType = "Terlambat";
    } else {
      status = "Alpha";
      // attType = "Alpha";
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('status', status);

    if (!mounted) return;
    setState(() {
      _savedStatus = status;
    });

    debugPrint("⏰ Status updated by time: $status");
  }

  Future<void> recognizeFace(File imageFile) async {
    if (!mounted) return;
    setState(() {
      final t = AppLocalizations.of(context)!;
      _faceValid = false;
      _similarity = null;
      _faceMessage = t.translate("checking");
    });

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(
              "https://cais-ai.cbinstrument.com/api/v1/recognition/recognize",
            ),
          )
          ..headers['x-api-key'] = '23e225bf-8f28-4493-a870-39019954fdae'
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              imageFile.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    final data = jsonDecode(body);

    debugPrint(body);

    if (response.statusCode != 200) {
      final t = AppLocalizations.of(context)!;

      if (data['message'] == "No face is found in the given image") {

        if (!mounted) return;

        setState(() {
          final t = AppLocalizations.of(context)!;
          _faceMessage = t.translate("noFace");
          _faceValid = false;
        });

        return;
      }

      if (!mounted) return;
      setState(() {
        _faceMessage = t.translate("nor");
        _faceValid = false;
      });
      return;
    }

    final faces = data['result'];

    if (faces.length != 1) {
      if (!mounted) return;
      setState(() {
        final t = AppLocalizations.of(context)!;
        _faceMessage = t.translate("oneFace");
        _faceValid = false;
      });
      return;
    }

    final result = data['result'][0];
    // final subjects = result['subjects'] as List?;
    final subjects = result['subjects'];

    if (subjects == null || subjects.isEmpty) {
      if (!mounted) return;
      setState(() {
        _faceMessage = "Face Unknown";
        _faceValid = false;
      });
      return;
    }

    Map<String, dynamic>? matched;

    for (final s in subjects) {
      if (s['subject'] == _savedName) {
        matched = s;
        break;
      }
    }

    // if (subjects == null || subjects.isEmpty) {
    //   setState(() {
    //     _faceMessage = "Face Unknown";
    //     _faceValid = false;
    //   });
    //   return;
    // }

    // final matched = subjects.firstWhere(
    //   (s) => s['subject'] == _savedName,
    //   orElse: () => null,
    // );

    if (matched == null) {
      setState(() {
        final t = AppLocalizations.of(context)!;
        _faceMessage = t.translate("unrecog");
        _faceValid = false;
      });
      return;
    }

    final sim = matched['similarity'];

    if (!mounted) return;

    final isValid = sim >= 0.95;

    setState(() {
      final t = AppLocalizations.of(context)!;
      _similarity = sim;
      _faceValid = isValid;

      _faceMessage = isValid
          ? t.translate("recoged")
          : t.translate("unfaced");
    });

    if (isValid) {
      // stop realtime capture
      _captureTimer?.cancel();

      _isProcessing = false;

      // turn off realtime capture
      await _controller?.dispose();

      if (!mounted) return;

      setState(() {
        _controller = null;
      });
    }

    print("similarities : $_similarity");
    print("face valid : $_faceValid");
    print("face Message : $_faceMessage");
  }

  Future<void> _submitAbsence() async {
    await _updateStatusByTime();

    if (_photo == null) return;
    // if (_nameController.text.isEmpty || _photo == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please Fill the Blanks...")),
    //   );
    //   return;
    // }

    // final bytes = await _photo!.readAsBytes();
    // final base64image = base64Encode(bytes);
    // final ext = _photo!.path.split('.').last;
    // final mime = ext == 'png' ? 'image/png' : 'image/jpeg';

    final base64Image = await imageToBase64(_photo!);
    final photoData = "data:image/jpeg;base64,$base64Image";

    debugPrint("PHOTO LENGTH: ${photoData.length}");
    debugPrint("PHOTO PREFIX: ${photoData.substring(0, 30)}");
    debugPrint("full photo: ${photoData}");

    String utcNow() {
      return DateTime.now().toUtc().toIso8601String().split('.').first + 'Z';
    }

    String localDateTime() {
      final now = DateTime.now();
      return "${now.year.toString().padLeft(4, '0')}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')} "
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    }

    final header = "Bearer $_savedToken";

    final body = {
      "name": _savedName,
      "attendance_type": _savedAttType,
      "timestamp": utcNow(),
      // "gps_latitude": -6.951720770791366,
      // "gps_longitude": 107.53339375994186,
      "location_name": "Margaasih",
      "start_date": localDateTime(),
      "end_date": localDateTime(),
      "duration_days": 1,
      "document_photo_$_savedShiftType": photoData,
      "status": _savedStatus,
      "shift_type": _savedShiftType,
    };

    setState(() {
      _isSubmitting = false;
    });

    // print("Simulasi Pengiriman");
    // print(body);
    // print("ABSEN BERHASIL :)");

    final responses = await http.post(
      Uri.parse("https://cais.cbinstrument.com/auth/input/absensi"),
      headers: {"Content-Type": "application/json", "Authorization": header},
      body: jsonEncode(body),
    ).timeout(Duration(seconds: 10));

    if (responses.statusCode == 200) {
      final resBody = jsonDecode(responses.body);
      print(resBody);
      print("Absence Fuccessful");
      _thxForAbsence();
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    } else {
      final body = jsonDecode(responses.body);
      _thxForAbsenceFailed();
      error = body['error'];
      print("Absence Failed");
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _thxForAbsenceFailed() async {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(t.translate("failed"), style: TextStyle(color: Colors.red)),
              Divider(),
            ],
          ),
          content: Text("$error", style: TextStyle(color: Colors.black)),
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
                  error == 'Token tidak valid'
                      ?
                        // button Funct
                        _logout()
                      : Navigator.of(context).pop();
                },
                child: Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _thxForAbsence() async {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(t.translate("thx"), style: TextStyle(color: Colors.green)),
              Divider(),
            ],
          ),
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
                  // _isSubmitting = false;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PilihDinas()),
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final t = AppLocalizations.of(context)!;
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MyHomePage()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          t.translate("dadah"),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _controller?.dispose();
    _clockTimer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnActive = _photo != null && _faceValid && !_isSubmitting;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.translate("takePicture"),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ========== Camera Preview Area ==========
          Expanded(
            child: Stack(
              children: [
                // Camera / Photo
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: _photo != null && _faceValid
                      ? Image.file(_photo!, fit: BoxFit.cover)
                      : (_controller == null || !_controller!.value.isInitialized)
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const CircularProgressIndicator(strokeWidth: 3),
                              ),
                            )
                          : CameraPreview(_controller!),
                ),

                // ========== Scan Frame Overlay ==========
                if (_photo == null && _controller != null && _controller!.value.isInitialized)
                  CustomPaint(
                    size: Size.infinite,
                    painter: _ScanFramePainter(
                      color: AppTheme.cyanAccent.withValues(alpha: 0.5),
                    ),
                  ),

                // ========== GPS Bottom Overlay ==========
                if (_photo == null || !_faceValid)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _buildGPSOverlay(),
                      ),
                    ),
                  ),

                // ========== Full error overlay ==========
                if (_photo != null && !_faceValid)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.error_outline_rounded,
                                  color: Colors.redAccent, size: 48),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                _faceMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ========== Valid gradient overlay ==========
                if (_photo != null && _faceValid)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ========== Bottom Panel ==========
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.black).withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ========== Instruction List ==========
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        _instructionItem(
                          icon: Icons.face_rounded,
                          label: t.translate("facingForward"),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        _instructionItem(
                          icon: Icons.group_remove_rounded,
                          label: t.translate("2ormoreevade"),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        _instructionItem(
                          icon: Icons.timer_outlined,
                          label: t.translate("stayStill"),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  // ========== Submit Button ==========
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: btnActive
                            ? LinearGradient(
                                colors: [
                                  AppTheme.cyanAccent,
                                  AppTheme.cyanAccent.withValues(alpha: 0.7),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.withValues(alpha: 0.25),
                                  Colors.grey.withValues(alpha: 0.1),
                                ],
                              ),
                        boxShadow: btnActive
                            ? [
                                BoxShadow(
                                  color: AppTheme.cyanAccent.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: btnActive
                            ? () {
                                setState(() => _isSubmitting = true);
                                if (!mounted) return;
                                _submitAbsence();
                              }
                            : null,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    btnActive
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.lock_outline_rounded,
                                    color: btnActive ? Colors.white : Colors.white38,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t.translate("Submit"),
                                    style: TextStyle(
                                      color: btnActive ? Colors.white : Colors.white38,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionItem({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppTheme.cyanAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.cyanAccent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final Color color;

  _ScanFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final ovalWidth = size.width * 0.7;
    final ovalHeight = size.height * 0.5;
    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    canvas.drawOval(ovalRect, paint);

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final hLine = Offset(center.dx - ovalWidth / 2 - 20, center.dy);
    canvas.drawLine(hLine, Offset(center.dx - ovalWidth / 2 - 4, center.dy), dashPaint);
    canvas.drawLine(
      Offset(center.dx + ovalWidth / 2 + 4, center.dy),
      Offset(center.dx + ovalWidth / 2 + 20, center.dy),
      dashPaint,
    );

    final vLine = Offset(center.dx, center.dy - ovalHeight / 2 - 20);
    canvas.drawLine(vLine, Offset(center.dx, center.dy - ovalHeight / 2 - 4), dashPaint);
    canvas.drawLine(
      Offset(center.dx, center.dy + ovalHeight / 2 + 4),
      Offset(center.dx, center.dy + ovalHeight / 2 + 20),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
