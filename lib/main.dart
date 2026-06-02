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
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await initializeDateFormatting('id_ID', null);
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final savedLang = prefs.getString('language') ?? 'id';

      runApp(MyApp(isLoggedIn: isLoggedIn, locale: Locale(savedLang)));
    },
    (error, stack) {
      debugPrint('Caught error in release: $error');
    },
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final Locale locale;

  const MyApp({super.key, required this.isLoggedIn, required this.locale});

  // from setting page
  static void setLocale(BuildContext context, Locale locale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
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
      supportedLocales: const [Locale('id'), Locale('en')],
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
  bool rememberMe = false;

  // password visible stakeholder
  bool _isVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
     final p = await SharedPreferences.getInstance();

    setState(() {
    rememberMe = p.getBool('rememberMe') ?? false;

    if (rememberMe) {
      emailController.text = p.getString('savedEmail') ?? '';
      AccessCodeController.text = p.getString('savedPassword') ?? '';
    }
  });
  }

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

        if (rememberMe) {
          await prefs.setBool('rememberMe', true);
          await prefs.setString(
            'savedEmail',
            emailController.text,
          );
          await prefs.setString(
            'savedPassword',
            AccessCodeController.text,
          );
        } else {
          await prefs.remove('rememberMe');
          await prefs.remove('savedEmail');
          await prefs.remove('savedPassword');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PilihDinas()),
        );
      } else {
        // ❌ login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 183, 131, 127),
            duration: const Duration(milliseconds: 600),
            content: Text(data['message'] ?? "Login gagal" , style: TextStyle(color: const Color.fromARGB(255, 96, 25, 20)),),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e", style: TextStyle(color: Colors.red),)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      // backgroundColor: Color(0xFF182234),
      body: 
      Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/loginBekgron.png',
                fit: BoxFit.cover,
              ),
            ),
            
            Align(
              alignment: Alignment.bottomCenter,
              child: 
              SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child:
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 1,
                    child: 
                    Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(12),
                      //   boxShadow: [
                      //     // outside glowing
                      //     BoxShadow(
                      //       color: Colors.cyanAccent.withOpacity(0.3),
                      //       blurRadius: 15,
                      //       spreadRadius: 2,
                      //     ),
                      //     BoxShadow(
                      //       color: Colors.cyanAccent.withOpacity(0.1),
                      //       blurRadius: 30,
                      //       spreadRadius: 6,
                      //     ),
                      //   ],
                      // ),
                      child: 
                          SingleChildScrollView(
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: const Color.fromARGB(255, 19, 89, 146), width: 1),
                              ),
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Image.asset(
                                      'assets/logoBiru.png',
                                      width: 220,
                                      height: 65,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width * 0.85,
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey,
                                      // indent: MediaQuery.sizeOf(context).width * 0.05,
                                      // endIndent: MediaQuery.sizeOf(context).width * 0.05,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20.0,
                                      bottom: 20.0,
                                      right: 20,
                                    ),
                                    child: Text(
                                      "CBI Automation & Integrated System CAIS",
                                      style: TextStyle(
                                        color: const Color.fromARGB(83, 42, 171, 235),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                            
                                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                                  Form(
                                    key: _formKey,
                                    child: 
                                    Container(
                                      // decoration: BoxDecoration(
                                      //   border: Border.all(
                                      //     color: Colors.white
                                      //   )
                                      // ),
                                      child: SizedBox(
                                        width: 
                                        // MediaQuery.sizeOf(context).width * 0.75
                                        350,
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //   border: Border.all(
                                          //     color: Colors.white
                                          //   )
                                          // ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text("Email", style: TextStyle(color: Color(0xFF475467)),),
                                              ),
                                              SizedBox(
                                                width:
                                                    350,
                                                // height:
                                                //     MediaQuery.sizeOf(context).height *
                                                //     0.06,
                                                child: 
                                                TextFormField(
                                                  style: TextStyle(color: const Color.fromARGB(255, 200, 200, 200)),
                                                  controller: emailController,
                                                  decoration: InputDecoration(
                                                    hintText: t.translate("username"),
                                                    hintStyle: TextStyle(
                                                      color: const Color.fromARGB(
                                                        255,
                                                        145,
                                                        145,
                                                        145,
                                                      ),
                                                      fontSize: 14,
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(
                                                        10,
                                                      ),
                                                      borderSide: BorderSide(
                                                        color: const Color.fromARGB(255, 19, 89, 146),
                                                      ),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(
                                                        10,
                                                      ),
                                                      borderSide: BorderSide(
                                                        color: const Color.fromARGB(255, 19, 89, 146),
                                                      ),
                                                    ),
                                                    filled: false,
                                                    prefixIcon: Padding(
                                                      padding: EdgeInsets.all(10),
                                                        child: Image.asset(
                                                        'assets/sms.png',
                                                        width: 20,
                                                        height: 20,
                                                      ),
                                                    )
                                                    // fillColor: Color(0xFF182234)
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context).height *
                                                    0.01,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text("Password", style: TextStyle(color: Color(0xFF475467)))
                                              ),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width * 0.9,
                                                // height:
                                                //     MediaQuery.sizeOf(context).height *
                                                //     0.06,
                                                child: TextFormField(
                                                  style: TextStyle(color: const Color.fromARGB(255, 223, 223, 223)),
                                                  controller: AccessCodeController,
                                                  obscureText: !_isVisible,
                                                  decoration: InputDecoration(
                                                    hintText: t.translate("password"),
                                                    hintStyle: TextStyle(
                                                      color: const Color.fromARGB(
                                                        255,
                                                        145,
                                                        145,
                                                        145,
                                                      ),
                                                      fontSize: 14,
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(
                                                        10,
                                                      ),
                                                      borderSide: BorderSide(
                                                        color: const Color.fromARGB(255, 19, 89, 146),
                                                      ),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(
                                                        10,
                                                      ),
                                                      borderSide: BorderSide(
                                                        color: const Color.fromARGB(255, 19, 89, 146),
                                                      ),
                                                    ),
                                                    filled: false,
                                                    // fillColor: Color(0xFF182234),
                                                    prefixIcon: Padding(
                                                      padding: EdgeInsets.all(10),
                                                        child: Image.asset(
                                                        'assets/finger-scan.png',
                                                        width: 20,
                                                        height: 20,
                                                      ),
                                                    ),
                                                    suffixIcon: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _isVisible = !_isVisible;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        _isVisible == true
                                                            ? Icons.visibility
                                                            : Icons.visibility_off,
                                                        color: Color(0xFF2AACEB),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                            
                                              // ===================================== Forgot Password ======================================
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width * 0.9,
                                                child: 
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    // Remember me
                                                    Row(
                                                      // mainAxisAlignment,
                                                      children: [
                                                        Container(
                                                          // decoration: BoxDecoration(
                                                          //   border: Border.all(
                                                          //     color: Colors.red
                                                          //   )
                                                          // ),
                                                          child: Checkbox(
                                                            visualDensity: VisualDensity.compact,
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            value: rememberMe,
                                                            activeColor: const Color(0xFF0066FF),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                rememberMe = value ?? false;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                        Container(
                                                          // decoration: BoxDecoration(
                                                          //   border: Border.all(
                                                          //     color: Colors.red
                                                          //   )
                                                          // ),
                                                          child: TextButton(
                                                            style: TextButton.styleFrom(
                                                              padding: EdgeInsets.zero,
                                                              minimumSize: Size.zero,
                                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            ),
                                                            onPressed: (){
                                                              setState(() {
                                                                rememberMe = !rememberMe;
                                                              });    
                                                            },
                                                            child: Text("Remember Me",
                                                            style: TextStyle(color: Colors.black)
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                            
                                                    TextButton(
                                                      onPressed: (){
                                                        // ===== Button Funct Here ======
                            
                                                      }, 
                                                      child: Text("Lupa Password")
                                                    )
                                                  ],
                                                )
                                              ),
                            
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 20.0,
                                                  bottom: 2.0,
                                                ),
                                                child: 
                                                
                                                // SizedBox(
                                                //   width: 350,
                                                //   child: 
                                                //   Container(
                                                //     decoration: BoxDecoration(
                                                //       border: Border.all(
                                                //         color: Colors.white
                                                //       )
                                                //     ),
                                                //     child: 
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        // // Regist
                                                        // SizedBox(
                                                        //   width:
                                                        //       150,
                                                        //   // height:
                                                        //   //     MediaQuery.sizeOf(
                                                        //   //       context,
                                                        //   //     ).height *
                                                        //   //     0.06,
                                                        //   child: Container(
                                                        //     // decoration: BoxDecoration(
                                                        //     //   boxShadow: [
                                                        //     //     BoxShadow(
                                                        //     //         color: Color(0x663B82F6),
                                                        //     //         blurRadius: 20,
                                                        //     //         offset: Offset(0, 0),
                                                        //     //       ),
                                                        //     //       BoxShadow(
                                                        //     //         color: Color(0x663B82F6),
                                                        //     //         blurRadius: 20,
                                                        //     //         offset: Offset(0, 0),
                                                        //     //      ),
                                                        //     //   ],
                                                        //     // ),
                                                        //     child: ElevatedButton(
                                                        //       style: 
                                                        //       ElevatedButton.styleFrom(
                                                        //         backgroundColor:
                                                        //             Color(0xFF0066ff),
                                                        //         shape: RoundedRectangleBorder(
                                                        //           borderRadius:
                                                        //               BorderRadius.circular(
                                                        //                 15,
                                                        //               ),
                                                        //         ),
                                                        //       ),
                                                        //       onPressed:
                                                        //           // button regist funct
                                                        //           () {
                                                        //             Navigator.push(
                                                        //               context,
                                                        //               MaterialPageRoute(
                                                        //                 builder: (context) =>
                                                        //                     Regist(),
                                                        //               ),
                                                        //             );
                                                        //           },
                                                        //       child: Text(
                                                        //         t.translate("reg"),
                                                        //         style: TextStyle(
                                                        //           color: Colors.white,
                                                        //         ),
                                                        //       ),
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                    
                                                        // login
                                                        Container(
                                                          width: MediaQuery.sizeOf(context).width * 0.88,
                                                          height: MediaQuery.sizeOf(context).height * 0.06,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(15),
                                                            gradient: const LinearGradient(
                                                              begin: Alignment.centerLeft,
                                                              end: Alignment.centerRight,
                                                              colors: [
                                                                Color(0xFF186185),
                                                                Color(0xFF2598CF),
                                                                Color(0xFF2AACEB),
                                                              ],
                                                            ),
                                                          ),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              _login();
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.transparent,
                                                              shadowColor: Colors.transparent,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              t.translate("in"),
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),

                                                  // ============== OR =====================
                                              
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width: MediaQuery.sizeOf(context).width * 0.35,
                                                            child: Divider()
                                                          ),
                                                          Text("OR"),
                                                          SizedBox(
                                                            width: MediaQuery.sizeOf(context).width * 0.35,
                                                            child: Divider()
                                                          ),  
                                                        ],
                                                      ),
                                                    ),
                            
                                                  // ============== Registrasi =============
                                                        Container(
                                                          width: MediaQuery.sizeOf(context).width * 0.9,
                                                          height: MediaQuery.sizeOf(context).height * 0.06,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: Color(0xFF2AACEB),
                                                              width: 2
                                                            ),
                                                            borderRadius: BorderRadius.circular(15),
                                                          //   gradient: const LinearGradient(
                                                          //     begin: Alignment.centerLeft,
                                                          //     end: Alignment.centerRight,
                                                          //     colors: [
                                                          //       Color(0xFF186185),
                                                          //       Color(0xFF2598CF),
                                                          //       Color(0xFF2AACEB),
                                                          //     ],
                                                          //   ),
                                                          ),
                                                          child: 
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                  Regist(),
                                                                ),
                                                              );
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              // backgroundColor: Colors.transparent,
                                                              // shadowColor: Colors.transparent,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              t.translate("reg"),
                                                              style: const TextStyle(
                                                                color: Color(0xff2AACEB),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Padding(padding: EdgeInsets.all(5.0)),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      t.translate("beta"),
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 195, 195, 195),
                                        fontSize: 10,
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
            )
          ]
        ),
    );
  }
}
