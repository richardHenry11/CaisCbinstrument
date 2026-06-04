import 'package:absence/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:absence/cuti.dart';
import 'package:absence/cutiLapangan.dart';
import 'package:absence/cutiSetengah.dart';
import 'package:absence/dashboard.dart';
import 'package:absence/drawer.dart';
import 'package:absence/fieldDuty.dart';
import 'package:absence/l10n/app_localizations.dart';
import 'package:absence/lateness.dart';
import 'package:absence/main.dart';
import 'package:absence/officeAbsence.dart';
import 'package:absence/settings.dart';
import 'package:absence/sick.dart';
import 'package:absence/wfh.dart';

class dateTimePicker extends StatelessWidget {
  const dateTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final time = snapshot.data!;
        return Text(
          _formatDateTime(time),
          style: const TextStyle(
            color: Color.fromARGB(255, 111, 255, 116),
            fontSize: 10,
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime time) {
    return "${time.day.toString().padLeft(2, '0')} "
        "${_monthName(time.month)} "
        "${time.year} "
        "${time.hour.toString().padLeft(2, '0')}."
        "${time.minute.toString().padLeft(2, '0')}."
        "${time.second.toString().padLeft(2, '0')}";
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des",
    ];
    return months[month - 1];
  }
}

class PilihDinas extends StatefulWidget {
  const PilihDinas({super.key});

  @override
  State<PilihDinas> createState() => _PilihDinasState();
}

class _PilihDinasState extends State<PilihDinas> {
  String? _userPref;
  String? _tokenPrefs;
  String? _namePrefs;
  String? _idPrefs;
  bool? _isLoggedInPrefs;

  @override
  void initState() {
    super.initState();
    _prefsCatcher();
  }

  Future<void> _prefsCatcher() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _userPref = _prefs.getString('user') ?? 'who are you?';
    _tokenPrefs = _prefs.getString('token') ?? 'there is no token here, go away';
    _namePrefs = _prefs.getString('name') ?? 'who are you again?';
    _idPrefs = _prefs.getString('id') ?? 'un ID fied :D';
    _isLoggedInPrefs = _prefs.getBool('isLoggedIn');
    
    // print save prefs state
    print("user: $_userPref");
    print("token: $_tokenPrefs");
    print("name: $_namePrefs");
    print("id: $_idPrefs");
    print("isLoggedIn: $_isLoggedInPrefs");
  }

  void _dinasKantor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', "kantor");
    await prefs.setString('status', "Hadir");
  }

  void _dinasLuar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', "dinas_lapangan");
    await prefs.setString('status', "dinas luar");
  }

  void _WFH() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', "wfh");
    await prefs.setString('status', "wfh");
  }

  void _cuti() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', "cuti");
    await prefs.setString('status', "Cuti");
  }

  void _cutiLapangan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', "cuti_lapangan");
    await prefs.setString('status', "Cuti Lapangan");
  }

  void _sakit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', "sakit");
    await prefs.setString('status', "Sakit");
  }

  void _cutiSetengah() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_type', "cuti1/2");
    await prefs.setString('status', "Cuti1/2");
  }

  Future<void> _logout() async {
    final t = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('name');
    await prefs.remove('id');
    await prefs.remove('employeesId');

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
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("titlePilihDinas")),
      ),
      drawer: AppSidebar(
        onMenuTap: (route) async {
          Navigator.pop(context);
          switch (route) {
            case "dashboard":
              Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Dashboard()),
              );
            case "lateness":
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => Lateness()),
              );
            case "settings":
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            case "logout":
              _logout();
          }
        },
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.cardBackground(context),
              AppTheme.cardGradientEnd(context),
              AppTheme.cardBackground(context),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                _buildMainCard(t, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.03),
                _buildInfoCard(t, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.03),
                _buildFooter(t),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(AppLocalizations t, double sw, double sh) {
    return Container(
      width: sw * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.borderColor(context)),
        ),
        color: AppTheme.cardBackground(context),
        elevation: 0,
        child: Column(
          children: [
            SizedBox(height: sh * 0.02),
            Text(
              t.translate("pilihAbsen"),
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: sh * 0.02),
            _buildButtonRow(sw, [
              _AttButtonData(
                icon: MaterialCommunityIcons.office_building,
                label: t.translate("office"),
                accentColor: const Color(0xFF38BDF8),
                onTap: () {
                  _dinasKantor();
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OfficeAbsence()),
                  );
                },
              ),
              _AttButtonData(
                icon: MaterialCommunityIcons.map_marker,
                label: t.translate("field"),
                accentColor: const Color(0xFF2DD4BF),
                onTap: () {
                  _dinasLuar();
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => FieldDuty()),
                  );
                },
              ),
            ]),
            _buildButtonRow(sw, [
              _AttButtonData(
                icon: MaterialCommunityIcons.home,
                label: t.translate("wfh"),
                accentColor: const Color(0xFFA78BFA),
                onTap: () {
                  _WFH();
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => WFH()),
                  );
                },
              ),
              _AttButtonData(
                icon: MaterialCommunityIcons.calendar,
                label: t.translate("cuti"),
                accentColor: const Color(0xFFFB923C),
                onTap: () {
                  _cuti();
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Cuti()),
                  );
                },
              ),
            ]),
            _buildButtonRow(sw, [
              _AttButtonData(
                icon: MaterialCommunityIcons.earth,
                label: t.translate("cutLap"),
                accentColor: const Color(0xFF4ADE80),
                onTap: () {
                  _cutiLapangan();
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => CutiLapangan()),
                  );
                },
              ),
              _AttButtonData(
                icon: MaterialCommunityIcons.file_document,
                label: t.translate("sick"),
                accentColor: const Color(0xFFF87171),
                onTap: () {
                  _sakit();
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Sick()),
                  );
                },
              ),
            ]),
            SizedBox(height: sh * 0.01),
            _buildFullButton(
              icon: MaterialCommunityIcons.calendar_clock,
              label: t.translate("Cuti1/2"),
              accentColor: const Color(0xFFFBBF24),
              width: sw * 0.71,
              onTap: () {
                _cutiSetengah();
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CutiSetengah()),
                );
              },
            ),
            SizedBox(height: sh * 0.01),
            _buildFullButton(
              icon: Icons.home_rounded,
              label: t.translate("beranda"),
              accentColor: const Color(0xFF38BDF8),
              width: sw * 0.71,
              filled: true,
              onTap: () {
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Dashboard()),
                );
              },
            ),
            SizedBox(height: sh * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(double sw, List<_AttButtonData> buttons) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: sw * 0.71,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: buttons.map((b) {
            return SizedBox(
              width: sw * 0.325,
              child: _AttButton(data: b),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFullButton({
    required IconData icon,
    required String label,
    required Color accentColor,
    required double width,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: width,
        child: _ModernButton(
          label: label,
          icon: icon,
          accentColor: accentColor,
          filled: filled,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations t, double sw, double sh) {
    return Container(
      width: sw * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.borderColor(context)),
        ),
        color: AppTheme.cardBackground(context),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: const Color(0xFF38BDF8), size: 16),
                  SizedBox(width: 8),
                  Text(
                    t.translate("keamanandanverif"),
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.02),
              _infoRow(MaterialCommunityIcons.office_building, t.translate("office"),
                  t.translate("gpsharusoffice"), " 50m ", t.translate("fromoffice"),
                  const Color(0xFF38BDF8)),
              SizedBox(height: 6),
              _infoRow(MaterialCommunityIcons.map_marker, t.translate("field"),
                  t.translate("gpsharusflex"), t.translate("flexduty"), null,
                  const Color(0xFF2DD4BF)),
              SizedBox(height: 6),
              _infoRow(MaterialCommunityIcons.home, t.translate("wfh"),
                  t.translate("GPS"), t.translate("gpsinfo"), null,
                  const Color(0xFFA78BFA)),
              SizedBox(height: 6),
              _infoRow(MaterialCommunityIcons.calendar, t.translate("cuti"),
                  t.translate("noneedgps"), t.translate("norphoto"), null,
                  const Color(0xFFFB923C)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String text1, String highlight,
      String? text2, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Icon(icon, color: color, size: 14),
        ),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11),
              children: [
                TextSpan(text: "$title: ",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: text1),
                TextSpan(text: highlight,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                if (text2 != null) TextSpan(text: text2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations t) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
        color: AppTheme.cardBackground(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  color: const Color(0xFF38BDF8).withOpacity(0.9), size: 18),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("HR Compliance",
                      style: TextStyle(
                          color: AppTheme.textSecondary(context), fontSize: 10, fontWeight: FontWeight.w600)),
                  Text("Sistem terintegrasi",
                      style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 8)),
                ],
              ),
            ],
          ),
          Container(width: 1, height: 28, color: AppTheme.borderColor(context)),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  color: const Color.fromARGB(255, 111, 255, 116).withOpacity(0.8), size: 25),
              SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Server Time",
                      style: TextStyle(
                          color: Color.fromARGB(255, 111, 255, 116), fontSize: 9)),
                  const dateTimePicker(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttButtonData {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _AttButtonData({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });
}

class _AttButton extends StatefulWidget {
  final _AttButtonData data;
  const _AttButton({required this.data});

  @override
  State<_AttButton> createState() => _AttButtonState();
}

class _AttButtonState extends State<_AttButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnim.value, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              d.accentColor.withOpacity(0.12),
              d.accentColor.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: d.accentColor.withOpacity(0.25)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: d.accentColor.withOpacity(0.08),
            highlightColor: Colors.transparent,
            onTapDown: (_) => _animController.forward(),
            onTapUp: (_) {
              _animController.reverse();
              d.onTap();
            },
            onTapCancel: () => _animController.reverse(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(d.icon, color: d.accentColor, size: 18),
                  SizedBox(width: 8),
                  Text(d.label,
                      style: TextStyle(
                          color: AppTheme.textPrimary(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool filled;
  final VoidCallback onTap;

  const _ModernButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.filled = false,
  });

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnim.value, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: w.filled
              ? LinearGradient(colors: [
                  w.accentColor.withOpacity(0.3),
                  w.accentColor.withOpacity(0.1),
                ])
              : LinearGradient(colors: [
                  w.accentColor.withOpacity(0.10),
                  w.accentColor.withOpacity(0.03),
                ]),
          border: Border.all(
            color: w.filled
                ? w.accentColor.withOpacity(0.4)
                : w.accentColor.withOpacity(0.2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: w.accentColor.withOpacity(0.08),
            highlightColor: Colors.transparent,
            onTapDown: (_) => _animController.forward(),
            onTapUp: (_) {
              _animController.reverse();
              w.onTap();
            },
            onTapCancel: () => _animController.reverse(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(w.icon, color: w.accentColor, size: 18),
                  SizedBox(width: 10),
                  Text(w.label,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
