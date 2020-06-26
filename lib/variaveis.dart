import 'package:shared_preferences/shared_preferences.dart';

class Variaveis {
  static String master = 'http://10.0.0.23:3700/api';

  static String login = '$master/login';

  static String solenoide = '$master/solenoide';

  static String equipamento = '$master/equipamento';

  void setKey(token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  getKey() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('api_token');
    return key;
  }

  static var equipamentos;
}