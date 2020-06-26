import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:Quicaca/pages/home.dart';
import 'package:Quicaca/variaveis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_checkbox/grouped_checkbox.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SolenoidePage extends StatefulWidget {
  SolenoidePage({Key key, this.title, @required this.id}) : super(key: key);
  final String title;
  final int id;

  @override
  _SolenoidePageState createState() => _SolenoidePageState();
}

class _SolenoidePageState extends State<SolenoidePage> {
  bool _ativo;
  var configuracoesAtuais;
  var configuracoesNovas;
  final tempMax = TextEditingController();
  final tempMin = TextEditingController();
  final humMax = TextEditingController();
  final humMin = TextEditingController();
  bool load = false;
  bool enviando = false;
  var maskFormatter =
      new MaskTextInputFormatter(mask: '##.#', filter: {"#": RegExp(r'[0-9]')});
  List<String> checkedItemList = [];
  List<String> allItemList = [
    'Domingo',
    'Segunda-Feira',
    'Terça-Feira',
    'Quarta-Feira',
    'Quinta-Feira',
    'Sexta-Feira',
    'Sábado'
  ];

  @override
  void initState() {
    buscarStatus();
    super.initState();
  }

  preencherCheckbox(var variaveis) {
    if (variaveis['domingo'] == 1) {
      checkedItemList.add('Domingo');
    }

    if (variaveis['segunda'] == 1) {
      checkedItemList.add('Segunda-Feira');
    }

    if (variaveis['terca'] == 1) {
      checkedItemList.add('Terça-Feira');
    }

    if (variaveis['quarta'] == 1) {
      checkedItemList.add('Quarta-Feira');
    }

    if (variaveis['quinta'] == 1) {
      checkedItemList.add('Quinta-Feira');
    }

    if (variaveis['sexta'] == 1) {
      checkedItemList.add('Sexta-Feira');
    }

    if (variaveis['sabado'] == 1) {
      checkedItemList.add('Sábado');
    }
  }

  @override
  void dispose() {
    super.initState();
  }

  enviarConfiguracao() async {
    String api = await Variaveis().getKey();

    setState(() {
      enviando = true;
    });

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": "Bearer $api"
    };

    var body = json.encode({
      'temperatura_max': configuracoesNovas['temperatura_max'],
      'humidade_max': configuracoesNovas['humidade_max'],
      'temperatura_min': configuracoesNovas['temperatura_min'],
      'humidade_min': configuracoesNovas['humidade_min'],
      'domingo': checkedItemList.contains('Domingo') ? true : false,
      'segunda': checkedItemList.contains('Segunda-Feira') ? true : false,
      'terca': checkedItemList.contains('Terça-Feira') ? true : false,
      'quarta': checkedItemList.contains('Quarta-Feira') ? true : false,
      'quinta': checkedItemList.contains('Quinta-Feira') ? true : false,
      'sexta': checkedItemList.contains('Sexta-Feira') ? true : false,
      'sabado': checkedItemList.contains('Sábado') ? true : false,
      'horario_ativar': configuracoesNovas['horario_ativar'],
      'horario_desativar': configuracoesNovas['horario_desativar'],
    });

    final response = await http
        .patch('${Variaveis.equipamento}/${widget.id}',
            headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    setState(() {
      enviando = false;
    });

    if (response.statusCode == 200) {

    }
  }

  buscarStatus() async {
    String api = await Variaveis().getKey();

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": "Bearer $api"
    };

    final response = await http
        .get('${Variaveis.solenoide}/${widget.id}', headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      print(response.body);
      final responseJson = json.decode(response.body);
      preencherCheckbox(responseJson[0]);
      setState(() {
        _ativo = responseJson[0]['ativo'] == 1 ? true : false;
        configuracoesAtuais = responseJson[0];
        configuracoesNovas = responseJson[0];
        tempMax.text = configuracoesNovas['temperatura_max'] != null
            ? configuracoesNovas['temperatura_max'].toString()
            : '';
        tempMin.text = configuracoesNovas['temperatura_min'] != null
            ? configuracoesNovas['temperatura_min'].toString()
            : '';
        humMax.text = configuracoesNovas['humidade_max'] != null
            ? configuracoesNovas['humidade_max'].toString()
            : '';
        humMin.text = configuracoesNovas['humidade_min'] != null
            ? configuracoesNovas['humidade_min'].toString()
            : '';
        configuracoesNovas['manual'] =
            responseJson[0]['manual'] == 1 ? true : false;
      });
    }
    print(_ativo);
  }

  alterarSolenoide() async {
    setState(() {
      load = true;
    });
    await Future.delayed(Duration(seconds: 1));
    var body = json.encode({
      'status': !_ativo,
    });

    String api = await Variaveis().getKey();

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": "Bearer $api"
    };
    print('${Variaveis.solenoide}/${widget.id}');
    try {
      final response = await http
          .put('${Variaveis.solenoide}/${widget.id}',
              body: body, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() {
          _ativo = !_ativo;
        });
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _ativo == null
            ? Text('Aguarde, carregando, ...')
            : Text(configuracoesAtuais['apelido']),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowCircleLeft),
          tooltip: 'Show Snackbar',
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
          },
        ),
      ),
      body: Center(
        child: _ativo == null
            ? CircularProgressIndicator()
            : ListView(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Ativação Manual? ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Switch(
                            value: configuracoesNovas['manual'],
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                configuracoesNovas['manual'] = value;
                              });
                            }),
                      ]),
                  configuracoesNovas['manual'] == true
                      ? Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(children: <Widget>[
                            Text(
                              'A solenoide está ',
                            ),
                            Text(
                              _ativo == true ? 'ativa' : 'desativada',
                              style: Theme.of(context).textTheme.display1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: ClipOval(
                                child: Material(
                                  color: _ativo == true
                                      ? Colors.green
                                      : Colors.red, // button color
                                  child: load == true
                                      ? SizedBox(
                                          width: 86,
                                          height: 86,
                                          child: Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.white))))
                                      : InkWell(
                                          splashColor:
                                              Colors.black, // inkwell color
                                          child: SizedBox(
                                              width: 86,
                                              height: 86,
                                              child: Icon(
                                                  FontAwesomeIcons.powerOff,
                                                  color: Colors.white)),
                                          onTap: () {
                                            load == false
                                                ? alterarSolenoide()
                                                : null;
                                          },
                                        ),
                                ),
                              ),
                            )
                          ]))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Container(
                                width: 180,
                                child: Card(
                                    color: Colors.grey[300],
                                    child: Column(children: <Widget>[
                                      Text('Dias da Semana',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17,
                                              color: Colors.blue[800])),
                                      GroupedCheckbox(
                                          itemList: allItemList,
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                          checkedItemList: checkedItemList,
                                          disabled: ['Black'],
                                          onChanged: (List itemList) {
                                            setState(() {
                                              checkedItemList = itemList;
                                            });
                                          },
                                          orientation:
                                              CheckboxOrientation.VERTICAL,
                                          checkColor: Colors.white,
                                          activeColor: Colors.blue[800])
                                    ])),
                              ),
                              Column(children: <Widget>[
                                Container(
                                  width: 220,
                                  height: 130,
                                  child: Card(
                                    color: Colors.grey[300],
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                  FontAwesomeIcons
                                                      .temperatureHigh,
                                                  color: Colors.red[700]),
                                              Text('  Temperatura',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 17,
                                                      color: Colors.blue[800])),
                                            ]),
                                        Row(
                                          children: <Widget>[
                                            new Flexible(
                                                child: Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                controller: tempMin,
                                                inputFormatters: [
                                                  maskFormatter
                                                ],
                                                maxLength: 4,
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  hintText: 'Min',
                                                  prefixIcon: Icon(
                                                      FontAwesomeIcons.minus,
                                                      size: 15),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  filled: true,
                                                  fillColor: Colors.white70,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey[500],
                                                        width: 1),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue[800],
                                                        width: 1),
                                                  ),
                                                ),
                                              ),
                                            )),
                                            new Flexible(
                                                child: Container(
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                controller: tempMax,
                                                inputFormatters: [
                                                  maskFormatter
                                                ],
                                                maxLength: 4,
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  hintText: 'Max',
                                                  prefixIcon: Icon(
                                                      FontAwesomeIcons.plus,
                                                      size: 15),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  filled: true,
                                                  fillColor: Colors.white70,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey[500],
                                                        width: 1),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue[800],
                                                        width: 1),
                                                  ),
                                                ),
                                              ),
                                            )),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: 220,
                                  height: 130,
                                  child: Card(
                                    color: Colors.grey[300],
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(FontAwesomeIcons.tint,
                                                  color: Colors.blue),
                                              Text(' Humidade',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 17,
                                                      color: Colors.blue[800])),
                                            ]),
                                        Row(
                                          children: <Widget>[
                                            new Flexible(
                                                child: Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                controller: humMin,
                                                inputFormatters: [
                                                  maskFormatter
                                                ],
                                                maxLength: 4,
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  hintText: 'Min',
                                                  prefixIcon: Icon(
                                                      FontAwesomeIcons.minus,
                                                      size: 15),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  filled: true,
                                                  fillColor: Colors.white70,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey[500],
                                                        width: 1),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue[800],
                                                        width: 1),
                                                  ),
                                                ),
                                              ),
                                            )),
                                            new Flexible(
                                                child: Container(
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                controller: humMax,
                                                inputFormatters: [
                                                  maskFormatter
                                                ],
                                                maxLength: 4,
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  hintText: 'Max',
                                                  prefixIcon: Icon(
                                                      FontAwesomeIcons.plus,
                                                      size: 15),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  filled: true,
                                                  fillColor: Colors.white70,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey[500],
                                                        width: 1),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue[800],
                                                        width: 1),
                                                  ),
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                    width: 220,
                                    child: Column(children: <Widget>[
                                      RaisedButton.icon(
                                        onPressed: () async {
                                          TimeRange result =
                                              await showTimeRangePicker(
                                            use24HourFormat: true,
                                            strokeWidth: 16,
                                            handlerRadius: 18,
                                            fromText: 'De',
                                            toText: 'até',
                                            ticksColor: Colors.black,
                                            labelOffset: 40,
                                            ticks: 24,
                                            padding: 55,
                                            snap: false,
                                            labelStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                            labels: [
                                              "0",
                                              "3",
                                              "6",
                                              "9",
                                              "12",
                                              "15",
                                              "18",
                                              "21"
                                            ].asMap().entries.map((e) {
                                              return ClockLabel.fromIndex(
                                                  idx: e.key,
                                                  length: 8,
                                                  text: e.value);
                                            }).toList(),
                                            start: TimeOfDay(
                                                hour: int.parse(
                                                    configuracoesNovas[
                                                            'horario_ativar']
                                                        .split(":")[0]),
                                                minute: int.parse(
                                                    configuracoesNovas[
                                                            'horario_ativar']
                                                        .split(":")[1])),
                                            end: TimeOfDay(
                                                hour: int.parse(
                                                    configuracoesNovas[
                                                            'horario_desativar']
                                                        .split(":")[0]),
                                                minute: int.parse(
                                                    configuracoesNovas[
                                                            'horario_desativar']
                                                        .split(":")[1])),
                                            context: context,
                                          );
                                          setState(() {
                                            configuracoesNovas[
                                                    'horario_ativar'] =
                                                result.startTime
                                                    .format(context)
                                                    .toString();
                                            configuracoesNovas[
                                                    'horario_desativar'] =
                                                result.endTime
                                                    .format(context)
                                                    .toString();
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        label: Text(
                                          configuracoesNovas[
                                                          'horario_ativar'] !=
                                                      null &&
                                                  configuracoesNovas[
                                                          'horario_desativar'] !=
                                                      null
                                              ? configuracoesNovas[
                                                      'horario_ativar'] +
                                                  ' até ' +
                                                  configuracoesNovas[
                                                      'horario_desativar']
                                              : 'Nenhum horário',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        icon: Icon(
                                          FontAwesomeIcons.clock,
                                          color: Colors.white,
                                        ),
                                        textColor: Colors.white,
                                        color: Colors.blue[800],
                                      ),
                                    ]))
                              ]),
                            ]),
                  configuracoesNovas['manual'] == false
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: 48.0, left: 50, right: 50),
                          child: ButtonTheme(
                            minWidth: 250.0,
                            height: 50.0,
                            child: RaisedButton.icon(
                              onPressed: () async {
                                configuracoesNovas['temperatura_max'] =
                                    tempMax.text;
                                configuracoesNovas['temperatura_min'] =
                                    tempMin.text;
                                configuracoesNovas['humidade_max'] =
                                    humMax.text;
                                configuracoesNovas['humidade_min'] =
                                    humMin.text;
                                await enviarConfiguracao();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              label: Text(
                                enviando == false ? ' Salvar Alterações' : 'Enviando...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              icon: enviando == true ? CircularProgressIndicator(backgroundColor: Colors.white): Icon(
                                 FontAwesomeIcons.solidSave,
                                color: Colors.white,
                                size: 30,
                              ),
                              textColor: Colors.white,
                              color: Colors.green[800],
                            ),
                          ))
                      : Container(),
                ],
              ),
      ),
    );
  }
}
