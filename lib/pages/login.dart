import 'dart:convert';
import 'package:Quicaca/pages/solenoide.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:Quicaca/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:Quicaca/variaveis.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Duration get loginTime => Duration(milliseconds: 2250);

  @override
  void didChangeDependencies() {
  checkUser();
  super.didChangeDependencies();
  }

  void checkUser() async {
    Loader.show(context,progressIndicator:LinearProgressIndicator());
    if (await Variaveis().getKey() == null) {
      Loader.hide();
    } else {
      Loader.hide();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(),
      ));
    }
  }

  Future<String> _authUser(LoginData data) async {
    print('Name: ${data.name}, Password: ${data.password}');

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };

    final response = await http
        .get('${Variaveis.login}/?email=${data.name}&senha=${data.password}',
            headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      Variaveis().setKey(response.body);
      return null;
    } else if (response.statusCode == 400) {
      return ('Credenciais Inválidas!');
    } else {
      return ('Erro no servidor, tente novamente!');
    }
  }

  Future<String> _recoverPassword(String name) {
    print('Name: $name');
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      logo: 'assets/images/logo-quicaca.png',
      onLogin: _authUser,
      onSignup: _authUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
