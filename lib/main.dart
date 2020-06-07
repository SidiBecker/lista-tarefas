import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const COR_PRIMARIA = Colors.deepPurple;

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: COR_PRIMARIA,
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: COR_PRIMARIA)),
                  )),
                  RaisedButton(
                    child: Text("add"),
                    onPressed: () {},
                    color: COR_PRIMARIA,
                    textColor: Colors.white,
                  ),
                  ////////////
                ],
              ),
            ),
          ],
        ));
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();

    file.writeAsString(data);
  }

  Future<String> _getData() async {
    try {
      //Tenta executar o que esta aqui.
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      //Se ocorrer algum erro executa o que esta aqui.
      return null;
    }
  }
}
