import 'dart:convert';

import 'package:absence/lateness.dart';
import 'package:absence/lemur.dart';
import 'package:absence/lemurRevise.dart';
import 'package:absence/theme.dart';
import 'package:flutter/material.dart';
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
  return hour > 8 && minute > 30 || (hour == 8 && minute > 30);
}

void showPhotoPreview(BuildContext context, String imagePath) {
  final t = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                child: Image.network(
                  "$baseImageUrl$imagePath",
                  fit: BoxFit.contain,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 300,
                      color: AppTheme.cardBackground(context),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.cyanAccent,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    color: AppTheme.cardBackground(context),
                    child: Center(
                      child: Text(
                        t.translate("failedPict"),
                        style: TextStyle(color: AppTheme.textSecondary(context)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> saveLatenessToPrefs(Map<String, dynamic> item) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lateness_data', jsonEncode(item));
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

Color _statusColor(String? status) {
  switch (status) {
    case 'Kantor': case 'T1': case 'T2': case 'T3':
      return const Color(0xFF22c55e);
    case 'sick':
      return const Color(0xFFa855f7);
    case 'wfh':
      return const Color(0xFF3b82f6);
    case 'leave':
      return const Color(0xFFf59e0b);
    default:
      return const Color(0xFF94a3b8);
  }
}

IconData _statusIcon(String? status) {
  switch (status) {
    case 'Kantor': case 'T1': case 'T2': case 'T3':
      return Icons.business_center;
    case 'sick':
      return Icons.local_hospital;
    case 'wfh':
      return Icons.home;
    default:
      return Icons.calendar_today;
  }
}

String _statusLabel(String? status, AppLocalizations t) {
  if (status == "leave") return t.translate("cuti");
  if (status == "sick") return t.translate("sick");
  if (status != null && status.isNotEmpty) return status;
  return "-";
}

Color _supervisorBadgeColor(String? status) {
  switch (status) {
    case 'approved':
      return const Color(0xFF22c55e);
    case 'pending':
      return const Color(0xFFf59e0b);
    default:
      return const Color(0xFFef4444);
  }
}

IconData _supervisorBadgeIcon(String? status) {
  switch (status) {
    case 'approved':
      return Icons.check_circle;
    case 'pending':
      return Icons.access_time;
    default:
      return Icons.cancel;
  }
}

Widget _absenceCard(BuildContext context, Map<String, dynamic> item) {
  final t = AppLocalizations.of(context)!;
  final status = item['status'] as String?;
  final sc = _statusColor(status);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ────────────── Date + Status ──────────────
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 14, color: AppTheme.textSecondary(context)),
                    const SizedBox(width: 6),
                    Text(
                      t.translate("dateRackup"),
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat(item['date']),
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [sc.withAlpha(200), sc.withAlpha(100)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon(status), size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  _statusLabel(status, t),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      // ────────────── Time ──────────────
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: _timeDisplay(context, Icons.login_rounded, t.translate("in"), item['check_in'])),
            Container(width: 1, height: 32, color: AppTheme.borderColor(context)),
            Expanded(child: _timeDisplay(context, Icons.logout_rounded, t.translate("out"), item['check_out'])),
          ],
        ),
      ),

      const SizedBox(height: 12),

      // ────────────── Photo Buttons ──────────────
      Row(
        children: [
          Expanded(child: _photoButton(context, t.translate('in'), item['has_photo_in'], item['photo_check_in'], Icons.camera_alt_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _photoButton(context, t.translate("out"), item['has_photo_out'], item['photo_check_out'], Icons.camera_alt_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _photoButton(context, t.translate("prove"), item['proof_photo'] != "", item['proof_photo'], Icons.description_rounded)),
        ],
      ),

      const SizedBox(height: 12),

      // ────────────── Overtime Button ──────────────
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF8b5cf6),
            elevation: 0,
          ),
          onPressed: () async {
            await saveSelectedDate(item['date']);
            Navigator.push(
              context,
              item['overtime_approval'] == "revise"
                  ? MaterialPageRoute(builder: (context) => LemurRevise())
                  : MaterialPageRoute(builder: (context) => Lemur()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: Colors.white.withAlpha(200), size: 18),
              const SizedBox(width: 8),
              Text(
                t.translate("confirmOT"),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 16),

      // ────────────── Status Supervisor ──────────────
      Row(
        children: [
          Expanded(
            child: _statusPill(
              context,
              icon: Icons.checklist_rounded,
              label: t.translate("confirmation"),
              value: item['supervisor_status'] == 'pending' ? '-' : item['supervisor_status'],
              status: item['supervisor_status'],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statusPill(
              context,
              icon: Icons.timer_outlined,
              label: t.translate("lemurConfirmation"),
              value: item['overtime_approval'] == '' ? t.translate('noreport') : item['overtime_approval'],
              status: item['overtime_approval'] == '' ? null : item['overtime_approval'],
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      // ────────────── Deductions ──────────────
      Row(
        children: [
          Icon(Icons.monetization_on_rounded, color: AppTheme.textPrimary(context), size: 18),
          const SizedBox(width: 8),
          Text(t.translate("deduction"), style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13)),
        ],
      ),
      const SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.only(left: 26),
        child: Text(
          "Rp${item['deduction'] ?? '0'},-",
          style: TextStyle(
            color: item['deduction'] == '0' ? const Color(0xFF22c55e) : const Color(0xFFef4444),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      const SizedBox(height: 12),

      // ────────────── Reason ──────────────
      Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppTheme.textPrimary(context), size: 18),
          const SizedBox(width: 8),
          Text(t.translate("reason"), style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13)),
        ],
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          item['reason'] ?? '-',
          style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13),
        ),
      ),

      // ────────────── Lateness Button ──────────────
      if (status == "T3" || status == "late")
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFFef4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              label: Text(
                t.translate("lateConfirm"),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                await saveLatenessToPrefs(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.translate("latenessSaved")),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lateness()),
                );
              },
            ),
          ),
        ),
    ],
  );
}

Widget _timeDisplay(BuildContext context, IconData icon, String label, String? value) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary(context)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        value == null || value.isEmpty ? "-" : value,
        style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ],
  );
}

Widget _photoButton(BuildContext context, String label, bool available, String imagePath, IconData icon) {
  return SizedBox(
    height: 42,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: available ? const Color(0xFF22c55e) : AppTheme.borderColor(context),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      onPressed: available ? () => showPhotoPreview(context, imagePath) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: available ? const Color(0xFF22c55e) : AppTheme.textSecondary(context)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: available ? const Color(0xFF22c55e) : AppTheme.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _statusPill(BuildContext context, {required IconData icon, required String label, required String value, String? status}) {
  final color = status == null ? AppTheme.textSecondary(context) : _supervisorBadgeColor(status);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary(context), size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
        ],
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_supervisorBadgeIcon(status), size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ],
  );
}

class RackupAbsence extends StatefulWidget {
  const RackupAbsence({super.key});

  @override
  State<RackupAbsence> createState() => _RackupAbsenceState();
}

class _RackupAbsenceState extends State<RackupAbsence> {
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String? _startDatepref;
  String? _endDatepref;
  String? _namePref;
  String? _token;

  List<Map<String, dynamic>> absences = [];

  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  bool isLoading = false;

  @override
  void initState() {
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

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final dateFrom = formatter.format(startDate!);
    final dateTo = formatter.format(endDate!);

    final url =
        "https://cais.cbinstrument.com/auth/absensi/karyawan"
        "?nama=$_namePref"
        "&dateFrom=$dateFrom"
        "&dateTo=$dateTo";
    final headers = {"Authorization": "Bearer $_token"};

    try {
      final responses = await http.get(Uri.parse(url), headers: headers);

      if (responses.statusCode == 200) {
        final body = jsonDecode(responses.body);

        if (!mounted) return;
        setState(() {
          absences = body.cast<Map<String, dynamic>>();
        });
      }
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  bool getValidRangeTime() {
    if (startDate == null || endDate == null) return false;
    return endDate!.isAfter(startDate!);
  }

  String? getRangeErrorMessage() {
    if (startDate == null || endDate == null) return "Tanggal belum lengkap";
    if (endDate!.isBefore(startDate!)) return "Tanggal akhir harus setelah tanggal awal";
    if (endDate!.difference(startDate!).inDays > 31) return "Rentang tanggal maksimal 30 hari";
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

    if (_startDatepref == null || _endDatepref == null) {
      _setDefaultDateRange();
    } else {
      startDate = DateTime.parse(_startDatepref!);
      endDate = DateTime.parse(_endDatepref!);
      _startDate.text = _startDatepref!;
      _endDate.text = _endDatepref!;
    }
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("rackup")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ────────────── Filter Section ──────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground(context),
                border: Border(bottom: BorderSide(color: AppTheme.borderColor(context))),
              ),
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: Column(
                children: [
                  // Start Date
                  TextField(
                    controller: _startDate,
                    readOnly: true,
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                    decoration: InputDecoration(
                      labelText: t.translate("startDate"),
                      labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                      prefixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary(context)),
                      filled: true,
                      fillColor: AppTheme.surfaceLow(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () async {
                      final picked = await _pickDateTime(context);
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                          _startDate.text = formatter.format(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // End Date
                  TextField(
                    controller: _endDate,
                    readOnly: true,
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                    decoration: InputDecoration(
                      labelText: t.translate("endDate"),
                      labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                      prefixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary(context)),
                      filled: true,
                      fillColor: AppTheme.surfaceLow(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () async {
                      final picked = await _pickDateTime(context);
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                          _endDate.text = formatter.format(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Filter Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppTheme.cyanAccent,
                        elevation: 0,
                      ),
                      onPressed: (!getValidRangeTime() || isLoading)
                          ? null
                          : () async {
                              await _saveToPrefs();
                              await _loadApi();
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            t.translate("Filter"),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ────────────── Content ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: isLoading
                  ? _loadingSkeleton(context)
                  : absences.isEmpty
                      ? _emptyState(context, t)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: absences.length,
                          itemBuilder: (context, index) {
                            final item = absences[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: AppTheme.borderColor(context)),
                              ),
                              color: AppTheme.cardBackground(context),
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: _absenceCard(context, item),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingSkeleton(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 14, width: 140, decoration: BoxDecoration(color: AppTheme.borderColor(context), borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 8),
              Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: AppTheme.borderColor(context), borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              Container(height: 40, decoration: BoxDecoration(color: AppTheme.borderColor(context), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 12),
              Container(height: 12, width: 100, decoration: BoxDecoration(color: AppTheme.borderColor(context), borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: AppTheme.textSecondary(context).withAlpha(80)),
            const SizedBox(height: 16),
            Text(
              t.translate("noData"),
              style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
