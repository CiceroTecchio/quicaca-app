import 'dart:async';
import 'dart:convert';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_menu/full_screen_menu.dart';
import 'package:Quicaca/pages/login.dart';
import 'package:Quicaca/pages/solenoide.dart';
import 'package:Quicaca/variaveis.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex;
  Timer timer;
  bool buscando = false;

  buscarEquipamentos() async {
    setState(() {
      buscando = true;
    });
    String api = await Variaveis().getKey();

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": "Bearer $api"
    };

    final response = await http
        .get('${Variaveis.equipamento}', headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      setState(() {
        print(responseJson);
        Variaveis.equipamentos = responseJson;
        buscando = false;
      });
    }
  }

  void changePage(int index) {
    if (index == 2) {
      mostrarMenu();
    } else {}
  }

  void mostrarMenu() {
    FullScreenMenu.show(
      context,
      items: [
        FSMenuItem(
          icon: Icon(FontAwesomeIcons.signOutAlt, color: Colors.white),
          text: Text('Sair'),
          onTap: () {
            Variaveis().setKey(null);

            FullScreenMenu.hide();

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    const oneSec = const Duration(seconds: 5);
    timer = new Timer.periodic(oneSec, (Timer t) => buscarEquipamentos());
    super.initState();
    currentIndex = 0;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[800],
        body: Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Variaveis.equipamentos == null
              ? Container(child: Text('Nenhum equipamento identificado', style: TextStyle(color: Colors.white)))
              : ListView(children: <Widget>[
                  for (var item in Variaveis.equipamentos)
                    new GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(
                        builder: (context) => SolenoidePage(id: item['id']),
                      )),
                      child: Card(
                        child: ListTile(
                          leading: Icon(FontAwesomeIcons.solidCircle,
                              color: item['ativo'] == 1
                                  ? Colors.green
                                  : Colors.red),
                          title: Text(item['apelido']),
                          subtitle: item['ultimaConexao'] == null
                              ? Text('Nenhuma Informação Recebida')
                              : Column(children: <Widget>[
                                  Row(children: <Widget>[
                                    Text('Temperatura: '),
                                    Text('${item['temperatura']}º',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(' | Humidade: '),
                                    Text('${item['humidade']}%',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ]),
                                  Row(children: <Widget>[
                                    Text(
                                        '\nUltimo dado recebido ' +
                                            new DateFormat("dd/MM/yyyy HH:mm")
                                                .format(DateTime.parse(
                                                    item['ultimaConexao']))
                                                .toString(),
                                        style: TextStyle(fontSize: 12))
                                  ]),
                                ]),
                          trailing: Icon(FontAwesomeIcons.chevronCircleRight),
                        ),
                      ),
                    ),
                ]),
        )),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          changePage(2);
        },
        child: Icon(Icons.menu, color: Colors.blue[800],),
        backgroundColor: Colors.white,
),
floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BubbleBottomBar(
          hasNotch: true,
          opacity: .2,
          currentIndex: currentIndex,
        fabLocation: BubbleBottomBarFabLocation.end,
          onTap: changePage,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                  16)), //border radius doesn't work when the notch is enabled.
          elevation: 8,
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
                backgroundColor: Colors.blue[800],
                icon: Icon(
                  Icons.folder_open,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  FontAwesomeIcons.broadcastTower,
                  color: Colors.blue[800],
                ),
                title: Text("Equipamentos")),
            BubbleBottomBarItem(
                backgroundColor: Colors.green,
                icon: Icon(
                  Icons.menu,
                  color: Colors.transparent,
                ),
                activeIcon: Icon(
                  Icons.menu,
                  color: Colors.transparent,
                ),
                title: Text("Menu"))
          ],
        ));
  }
}
