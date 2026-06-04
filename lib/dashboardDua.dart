import 'dart:convert';

import 'package:absence/l10n/app_localizations.dart';
import 'package:absence/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DateHelper {
  static DateTime get dateFrom {
    final year = DateTime.now().year;
    return DateTime(year, 1, 1);
  }

  static DateTime get dateTo {
    final year = DateTime.now().year;
    return DateTime(year, 12, 31);
  }
}

class DashboardDua extends StatefulWidget {
  const DashboardDua({super.key});

  @override
  State<DashboardDua> createState() => _DashboardDuaState();
}

class _DashboardDuaState extends State<DashboardDua>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flyController;
  late final Animation<double> _flyAnimation;

  String? _savedToken;
  String? _encodedName;

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String? _savedHadir;
  String? _savedCuti;
  String? _savedWFH;
  String? _savedHalfCuti;
  String? _fieldDuty;
  String? _sick;
  String? _fieldCuti;

  String? _status;
  String? _timeCheckin;
  String? location;

  @override
  void initState() {
    super.initState();
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _flyAnimation = CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _flyController.forward();
    });
    _initialization();
  }

  @override
  void dispose() {
    _flyController.dispose();
    super.dispose();
  }

  Future<void> _initialization() async {
    await _getPrefs();
    await _httpGet();
    _latestAbsence();
  }

  Future<void> _getPrefs() async {
    SharedPreferences _getter = await SharedPreferences.getInstance();
    _savedToken = _getter.getString('token') ?? "There's no token here go away!!";
    String _savedName = _getter.getString('name') ?? "no name";
    _encodedName = Uri.encodeComponent(_savedName);

    print("token: $_savedToken\nname: $_encodedName");
  }

  Future<void> _latestAbsence() async {
    try {
      final token = _savedToken;
      final name = _encodedName;
      final url = "https://cais.cbinstrument.com/auth/absensi/saya?nama=$name";
      final headers = {"Authorization": "Bearer $token"};
      final fetch = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (!mounted) return;
      if (fetch.statusCode == 200) {
        final awak = jsonDecode(fetch.body);
        print("awak last absence: $awak");
        setState(() {
          _status = awak['status'];
          _timeCheckin = awak['waktu_checkin'];
          location = awak['lokasi'];
        });
      } else {
        final bodi = jsonDecode(fetch.body);
        print("error occured latest Absence: $bodi");
      }
    } catch (e) {
      print("error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Terjadi kesalahan koneksi / server",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _httpGet() async {
    try {
      final name = _encodedName;
      final from = formatDate(DateHelper.dateFrom);
      final to = formatDate(DateHelper.dateTo);
      final url =
          "https://cais.cbinstrument.com/auth/absensi/rekap-karyawan?nama=$name&dateFrom=$from&dateTo=$to";
      final token = _savedToken;
      final headers = {"Authorization": "Bearer $token"};

      print("token: $_savedToken\nheaders: $headers");

      final fetchData = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (fetchData.statusCode == 200) {
        final awak = jsonDecode(fetchData.body);
        print("bodi: $awak");
        setState(() {
          _savedHadir = awak['hadir'].toString();
          _savedWFH = awak['wfh'].toString();
          _savedCuti = awak['cuti_tahunan'].toString();
          _savedHalfCuti = awak['cuti_1_2'].toString();
          _fieldDuty = awak['dinas_lapangan'].toString();
          _sick = awak['sakit'].toString();
          _fieldCuti = awak['cuti_lapangan'].toString();
          print(_savedHalfCuti);
        });
      } else {
        final bodi = jsonDecode(fetchData.body);
        print("Failed to Fetch Data $bodi");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Gagal Menerima respon server ${fetchData.statusCode}",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      print("error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Terjadi kesalahan koneksi / server",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildStatTile(
    int index,
    IconData icon,
    Color iconColor,
    String count,
    String label,
  ) {
    final delays = [0.0, 0.08, 0.16, 0.24, 0.32, 0.4];
    return AnimatedBuilder(
      animation: _flyAnimation,
      builder: (context, child) {
        final progress =
            ((_flyAnimation.value - delays[index]) / (1 - delays[index]))
                .clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 60 * (1 - progress)),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: AppTheme.borderColor(context),
          ),
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardGradientEnd(context),
              AppTheme.cardGradientStart(context),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
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
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final stats = [
      (Icons.check_circle_rounded, const Color(0xFF22d3ee),
          _savedHadir ?? '...', "Hadir"),
      (Icons.home_rounded, const Color(0xFF34d399),
          _savedWFH ?? '...', "WFH"),
      (Icons.beach_access_rounded, const Color(0xFFfbbf24),
          _savedCuti ?? '...', t.translate("cuti")),
      (Icons.map_rounded, const Color(0xFFa78bfa),
          _fieldDuty ?? '...', t.translate("field")),
      (Icons.healing_rounded, const Color(0xFFf472b6),
          _sick ?? '...', t.translate("sick")),
      (Icons.flight_rounded, const Color(0xFFfb923c),
          _fieldCuti ?? '...', t.translate("cutLap")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.translate("beranda"),
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),

            //============================== Recap Section ==============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.cardGradientStart(context),
                      AppTheme.cardGradientEnd(context),
                    ],
                  ),
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
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyanAccent.withValues(alpha: 0.2),
                                  Colors.lightBlue.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.cyanAccent.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              MaterialCommunityIcons.signal,
                              color: Colors.cyanAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            t.translate("rackupAbsen"),
                            style: TextStyle(
                              color: AppTheme.textPrimary(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          final item = stats[index];
                          return _buildStatTile(
                            index,
                            item.$1,
                            item.$2,
                            item.$3,
                            item.$4,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),

            //============================== Latest Absence ==============================
            AnimatedBuilder(
              animation: _flyAnimation,
              builder: (context, child) {
                final progress =
                    ((_flyAnimation.value - 0.5) / (1 - 0.5)).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, 60 * (1 - progress)),
                  child: Opacity(opacity: progress, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.cardGradientStart(context),
                        AppTheme.cardGradientEnd(context),
                      ],
                    ),
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
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.cyanAccent.withValues(alpha: 0.2),
                                        Colors.lightBlue.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: Colors.cyanAccent.withValues(alpha: 0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    MaterialCommunityIcons.check_circle,
                                    color: Color(0xFF22d3ee),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _status ?? '...',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      t.translate("todayState"),
                                      style: TextStyle(
                                        color: AppTheme.textSecondary(context),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF22d3ee),
                                    const Color(0xFF0ea5e9),
                                  ],
                                ),
                              ),
                              child: Text(
                                _status ?? '...',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: AppTheme.borderColor(context),
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.surfaceLow(context),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                MaterialCommunityIcons.clock,
                                color: Colors.lightBlue.withValues(alpha: 0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _timeCheckin ?? '...',
                                style: TextStyle(
                                  color: AppTheme.textPrimary(context),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.surfaceLow(context),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                MaterialCommunityIcons.map_marker,
                                color: Colors.lightBlue.withValues(alpha: 0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  location ?? '...',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
