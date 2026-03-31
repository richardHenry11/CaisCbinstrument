import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyReport extends StatefulWidget {
  const DailyReport({super.key});

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {

  String? _savedName;

  //================================== Functions ==================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameGetter();
  }

  Future<void> _nameGetter() async {
    SharedPreferences _fetcher = await SharedPreferences.getInstance();
    _savedName = _fetcher.getString('name');

    print(_savedName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}