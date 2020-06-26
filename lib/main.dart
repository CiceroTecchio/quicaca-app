import 'package:flutter/material.dart';
import 'package:Quicaca/pages/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static MaterialColor azul =
      const MaterialColor(0xFF004c78, const <int, Color>{
    50: const Color(0xFF004c78),
    100: const Color(0xFF004c78),
    200: const Color(0xFF004c78),
    300: const Color(0xFF004c78),
    400: const Color(0xFF004c78),
    500: const Color(0xFF004c78),
    600: const Color(0xFF004c78),
    700: const Color(0xFF004c78),
    8900: const Color(0xFF004c78),
    900: const Color(0xFF004c78),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme:
          ThemeData(primaryColor: Color.fromRGBO(0,76,120,1.0), primarySwatch: azul),
      home: LoginPage(),
    );
  }
}
