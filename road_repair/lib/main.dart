import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:road_repair/fitness_app/fitness_app_home_screen.dart';
import 'package:road_repair/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userSignIn/authenticate.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/init',
      routes: {
        '/init': (context) => RefreshPage(),
        '/sign': (context) => Authenticate(),
        '/home': (context) => FitnessAppHomeScreen(),
      },
    );
  }
}

class RefreshPage extends StatefulWidget {
  @override
  _RefreshPageState createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  String email;

  @override
  void initState() {
    _setRoute();
    super.initState();
  }

  void _setRoute() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      email = sharedPreferences.getString("email");
    });
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print('user :' + user.toString());
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/sign');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
