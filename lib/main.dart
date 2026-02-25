import 'dart:async';
import 'dart:convert';

// import 'package:absence/absence.dart';
import 'package:absence/Regist.dart';
import 'package:absence/pilihdinas.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDateFormatting('id_ID', null);
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final savedLang = prefs.getString('language') ?? 'id';

    runApp(MyApp(isLoggedIn: isLoggedIn, locale: Locale(savedLang),));
  }, (error, stack) {
    debugPrint('Caught error in release: $error');
  });
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final Locale locale;

  const MyApp({super.key, required this.isLoggedIn, required this.locale});

  // from setting page
  static void setLocale(BuildContext context, Locale locale) {
    final _MyAppState? state =
      context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locale = widget.locale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   colorScheme: 
      // ),
      locale: _locale,
      supportedLocales: const[
        Locale('id'),
        Locale('en')
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: widget.isLoggedIn ? const PilihDinas() : MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // const MyHomePage({super.key, required this.title});

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController AccessCodeController = TextEditingController();
  bool _isLoading = false;

  // password visible stakeholder
  bool _isVisible = false;

  void _login() async {
  setState(() => _isLoading = true);
  print(_isLoading);

  try {
    final response = await http
        .post(
          Uri.parse('https://cais.cbinstrument.com/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': emailController.text,
            'password': AccessCodeController.text,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      print(data);
      final user = data['data']['user_data']['user'];
      final token = data['data']['token'];
      final name = data['data']['nama_karyawan'];
      final id = data['data']['id'];
      final employeesId = data['data']['id_karyawan'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', user);
      await prefs.setString('token', token);
      await prefs.setString('name', name);
      await prefs.setString('id', id);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('employeesId', employeesId);

      print("name prefs: $name");
      print("token: $token");
      print("user: $user");
      print("id: $id");
      print("employees ID: $employeesId");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 600),
          content: Text("Login Berhasil ^_^"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PilihDinas()),
      );
    } else {
      // ❌ login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 600),
          content: Text(data['message'] ?? "Login gagal"),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 84, 134),
      body: 
      SizedBox(
        height: MediaQuery.sizeOf(context).height * 1,
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.blue, 
                          width: 1,
                        ),
                      ),
                      color: const Color.fromARGB(255, 5, 37, 93),
                      child: 
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.asset('assets/logoBiru.png', width: 220, height: 65),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.75,
                            child: 
                            Divider(
                              thickness: 1, 
                              color: Colors.grey,
                              // indent: MediaQuery.sizeOf(context).width * 0.05,
                              // endIndent: MediaQuery.sizeOf(context).width * 0.05,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, right: 20),
                            child: Text("CBI Automation & Integrated System CAIS", 
                                          style: TextStyle(color: const Color.fromARGB(255, 202, 202, 202), 
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900
                                          ),
                                        ),
                          ),
                          Form(
                            key: _formKey,
                            child:
                              Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width * 0.75,
                                    height: MediaQuery.sizeOf(context).height * 0.06,
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        hintText: t.translate("username"),
                                        hintStyle: TextStyle(color: const Color.fromARGB(255, 145, 145, 145), fontSize: 14),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: Colors.blue
                                          )
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: Colors.blue
                                          )
                                        ),
                                        filled: true,
                                        fillColor: const Color.fromARGB(255, 6, 45, 111)
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width * 0.75,
                                    height: MediaQuery.sizeOf(context).height * 0.06,
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      controller: AccessCodeController,
                                      obscureText: !_isVisible,
                                      decoration: InputDecoration(
                                        hintText: t.translate("password"),
                                        hintStyle: TextStyle(color: const Color.fromARGB(255, 145, 145, 145), fontSize: 14),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: Colors.blue
                                          )
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: Colors.blue
                                          )
                                        ),
                                        filled: true,
                                        fillColor: const Color.fromARGB(255, 6, 45, 111),
                    
                                        suffixIcon: IconButton(
                                          onPressed: (){
                                            setState(() {
                                              _isVisible = !_isVisible;
                                            });
                                          },
                                          icon: Icon(
                                            _isVisible == true ? Icons.visibility
                                            : Icons.visibility_off,
                                            color: Colors.grey,
                                          )
                                        )
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 3.0, bottom: 15),
                                    child: 
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        // Regist
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width * 0.35,
                                          height: MediaQuery.sizeOf(context).height * 0.06,
                                          child: 
                                          Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.cyanAccent.withOpacity(0.3),
                                                    blurRadius: 15,
                                                    spreadRadius: 2,
                                                ),
                                                BoxShadow(
                                                  color: Colors.cyanAccent.withOpacity(0.1),
                                                  blurRadius: 30,
                                                  spreadRadius: 6,
                                                )
                                              ]
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 70, 188, 242),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15)
                                                )
                                              ),
                                              onPressed: 
                                              // button regist funct
                                              (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => Regist()));
                                              }, 
                                              child: Text(t.translate("reg"), style: TextStyle(color: Colors.white),)
                                            ),
                                          ),
                                        ),
                    
                                        // login
                                        Padding(
                                          padding: const EdgeInsets.only(right: 15.0),
                                          child: SizedBox(
                                            width: MediaQuery.sizeOf(context).width * 0.38,
                                            height: MediaQuery.sizeOf(context).height * 0.06,
                                            child: 
                                            Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
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
                                              child: 
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color.fromARGB(255, 70, 188, 243),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(15)
                                                  )
                                                ),
                                                onPressed: 
                                                // button submit funct
                                                (){
                                                  _login();
                                                }, 
                                                child: Text(t.translate("in"), style: TextStyle(color: Colors.white),)
                                              ),
                                            ),
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
                                                                  255, 195, 195, 195), fontSize: 10, fontWeight: FontWeight.w800),
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
    );
  }
}
