import 'dart:convert';
import 'dart:io';

import 'package:absence/drawer.dart';
import 'package:absence/lateness.dart';
import 'package:absence/settings.dart';
import 'package:absence/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as ktp;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:absence/dailyReport.dart';
import 'package:absence/dashboardDua.dart';
import 'package:absence/invention.dart';
import 'package:absence/l10n/app_localizations.dart';
import 'package:absence/main.dart';
import 'package:absence/fieldDuty.dart';
import 'package:absence/officeAbsence.dart';
import 'package:absence/pilihdinas.dart';
import 'package:absence/rackupAbsence.dart';
import 'package:absence/wfh.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  late final AnimationController _flyController;
  late final Animation<double> _flyAnimation;

  String? _userPref;
  String? _tokenPrefs;
  String? _namePrefs;
  String? _idPrefs;
  bool? _isLoggedInPrefs;
  int? _employeesId;

  String? _photoProfile;
  String? _position;
  String? _name;
  String? _role;

  Future<ktp.Response?> safeGet(String url, Map<String, String> headers) async {
    try {
      return await ktp.get(Uri.parse(url), headers: headers);
    } on HandshakeException catch (_) {
      debugPrint("SSL Handshake Error → Auto logout");
      await _logoutExpired();
      return null;
    } on SocketException catch (_) {
      debugPrint("No Internet Connection");
      return null;
    } catch (e) {
      debugPrint("Unknown error: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _flyAnimation = CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _flyController.forward();
    });
    _initApp();
  }

  @override
  void dispose() {
    _flyController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    await _dateDestroyer();
    await _prefsCatcher();
    await _loadPhoto();
  }

  Future<void> _dateDestroyer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('startDate');
    await prefs.remove('endDate');
  }

  Future<void> _prefsCatcher() async {
    final prefs = await SharedPreferences.getInstance();
    _userPref = prefs.getString('user') ?? 'who are you?';
    _tokenPrefs = prefs.getString('token') ?? 'there is no token here, go away';
    _namePrefs = prefs.getString('name') ?? 'who are you again?';
    _idPrefs = prefs.getString('id') ?? 'unIDfied :D';
    _isLoggedInPrefs = prefs.getBool('isLoggedIn');
    _employeesId = prefs.getInt('employeesId') ?? 0;

    debugPrint("user: $_userPref");
    debugPrint("token: $_tokenPrefs");
    debugPrint("name: $_namePrefs");
    debugPrint("id: $_idPrefs");
    debugPrint("isLoggedIn: $_isLoggedInPrefs");
    debugPrint("employees ID: $_employeesId");
  }

  Future<void> _loadPhoto() async {
    final url =
        "https://cais.cbinstrument.com/auth/user/profile/?userID=$_idPrefs";
    final headers = {"Authorization": "Bearer $_tokenPrefs"};

    final responses = await safeGet(url, headers);

    if (responses == null) return;

    if (responses.statusCode == 401) {
      debugPrint("Token expired → auto logout");
      await _logoutExpired();
      return;
    }

    if (!responses.body.trim().startsWith('{')) {
      debugPrint("Response is not JSON → it is probably a redirect/login page");
      await _logoutExpired();
      return;
    }

    if (responses.statusCode != 200) {
      debugPrint("Request gagal, kemungkinan token invalid / expired");
      return;
    }

    final body = jsonDecode(responses.body);
    final photoList = jsonDecode(body['photo'] ?? '[]') as List<dynamic>;
    final firstPhoto = photoList.isNotEmpty ? photoList[0] as String : '';

    if (!mounted) return;
    setState(() {
      _photoProfile = firstPhoto.isNotEmpty
          ? 'https://cais.cbinstrument.com/$firstPhoto'
          : null;
      _name = body['name'];
      _position = body['position'];
      _role = body['role'];
    });

    debugPrint("Photo: $_photoProfile");
    debugPrint("Name: $_name");
    debugPrint("Position: $_position");
    debugPrint("Role: $_role");
  }

  Future<void> _logout() async {
    final t = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

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

  Future<void> _logoutExpired() async {
    final t = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MyHomePage()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          t.translate("expired"),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showPhotoPreview() {
    if (_photoProfile == null) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                _photoProfile!,
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.55,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    color: AppTheme.cardBackground(context),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  color: AppTheme.cardBackground(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: AppTheme.textSecondary(context).withValues(alpha: 0.5),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Gagal memuat foto",
                        style: TextStyle(
                          color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _name ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_position != null) ...[
              const SizedBox(height: 4),
              Text(
                _position!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Text(
                  "Tutup",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    int index,
    IconData icon,
    String title,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final delays = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5];
    return AnimatedBuilder(
      animation: _flyAnimation,
      builder: (context, child) {
        final progress = ((_flyAnimation.value - delays[index]) / (1 - delays[index])).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 120 * (1 - progress)),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashColor: iconColor.withValues(alpha: 0.2),
        highlightColor: iconColor.withValues(alpha: 0.05),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cardGradientStart(context),
                AppTheme.cardGradientEnd(context),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.borderColor(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: iconColor.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withValues(alpha: 0.03),
                  ),
                ),
              ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            iconColor.withValues(alpha: 0.2),
                            iconColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, size: 28, color: iconColor),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _dinasKantor() {
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString('attendance_type', "kantor");
      await prefs.setString('status', "Hadir");
      if (!mounted) return;
      Navigator.push(
        context, MaterialPageRoute(builder: (_) => const OfficeAbsence()),
      );
    });
  }

  void _dinasLuar() {
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString('attendance_type', "dinas_lapangan");
      await prefs.setString('status', "dinas luar");
      if (!mounted) return;
      Navigator.push(
        context, MaterialPageRoute(builder: (_) => const FieldDuty()),
      );
    });
  }

  void _wfh() {
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString('attendance_type', "wfh");
      await prefs.setString('status', "wfh");
      if (!mounted) return;
      Navigator.push(
        context, MaterialPageRoute(builder: (_) => const WFH()),
      );
    });
  }

  Widget _buildBottomNav(AppLocalizations t) {
    return SizedBox(
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 28,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NavItem(
                    icon: Icons.explore_outlined,
                    label: t.translate("field"),
                    onTap: _dinasLuar,
                  ),
                  const SizedBox(width: 80),
                  _NavItem(
                    icon: Icons.home_outlined,
                    label: t.translate("wfh"),
                    onTap: _wfh,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            // bottom: 100,
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground(context),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(200)),
                ),
              ),
            ),
          ),
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _dinasKantor,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 2.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.business, color: Colors.white, size: 26),
                      const SizedBox(height: 2),
                      Text(
                        t.translate("office"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 76,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: 
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logoBiru.png",
                width: screenWidth * 0.42,
                height: 34,
              ),
              const SizedBox(height: 2),
              Text(
                "Automation & Integrated System",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 74, 74, 74).withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
        //     child: GestureDetector(
        //       onTap: _showPhotoPreview,
        //       child: Container(
        //         padding: const EdgeInsets.all(2),
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           gradient: LinearGradient(
        //             colors: [
        //               Colors.cyanAccent.withValues(alpha: 0.6),
        //               Colors.lightBlue.withValues(alpha: 0.6),
        //             ],
        //           ),
        //           boxShadow: [
        //             BoxShadow(
        //               color: Colors.cyanAccent.withValues(alpha: 0.2),
        //               blurRadius: 8,
        //               spreadRadius: 1,
        //             ),
        //           ],
        //         ),
        //         child: CircleAvatar(
        //           radius: 22,
        //           backgroundColor: AppTheme.cardBackground(context),
        //           backgroundImage: _photoProfile != null
        //               ? NetworkImage(_photoProfile!)
        //               : null,
        //           child: _photoProfile == null
        //               ? Icon(
        //                   Icons.person,
        //                   color: Colors.white.withValues(alpha: 0.7),
        //                 )
        //               : null,
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
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
      bottomNavigationBar: _buildBottomNav(t),
      body: Column(
        children: [
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
              color: AppTheme.cardBackground(context),
              border: Border(
                bottom: BorderSide(color: AppTheme.borderColor(context)),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 12,
                  left: 24,
                  right: 24,
                  bottom: 20,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showPhotoPreview,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyanAccent.withValues(alpha: 0.15),
                              Colors.lightBlue.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.transparent,
                          backgroundImage: _photoProfile != null
                              ? NetworkImage(_photoProfile!)
                              : null,
                          child: _photoProfile == null
                              ? Icon(
                                  Icons.person,
                                  color: AppTheme.textSecondary(context),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name ?? '...',
                            style: TextStyle(
                              color: AppTheme.textPrimary(context),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.8,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _position ?? '...',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildMenuCard(
                  0,
                  Icons.dashboard_rounded,
                  t.translate("dabor"),
                  const Color(0xFF22d3ee),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardDua()),
                    );
                  },
                ),
                _buildMenuCard(
                  1,
                  Icons.how_to_reg_rounded,
                  t.translate("absentDashboard"),
                  const Color(0xFF34d399),
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PilihDinas()),
                    );
                  },
                ),
                _buildMenuCard(
                  2,
                  Icons.access_time_rounded,
                  t.translate("rackupAbsent"),
                  const Color(0xFFa78bfa),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RackupAbsence()),
                    );
                  },
                ),
                _buildMenuCard(
                  3,
                  Icons.assignment_rounded,
                  t.translate("dailyReport"),
                  const Color(0xFFfbbf24),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DailyReport()),
                    );
                  },
                ),
                _buildMenuCard(
                  4,
                  Icons.inventory_2_rounded,
                  t.translate("inputGoods"),
                  const Color(0xFFf472b6),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Invention()),
                    );
                  },
                ),
                _buildMenuCard(
                  5,
                  Icons.logout_rounded,
                  t.translate("logout"),
                  const Color(0xFFf87171),
                  () async {
                    await _logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.textSecondary(context), size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
