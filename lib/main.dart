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
  List _toDoList = [
    {"title": "Criar Apps Incriveis", "done": true},
    {"title": "Aprender Dart", "done": false}
  ];

  final _toDoController = TextEditingController();

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
                    controller: _toDoController,
                  )),
                  RaisedButton(
                    child: Text("ADD"),
                    onPressed: _addToDo,
                    color: COR_PRIMARIA,
                    textColor: Colors.white,
                  ),
                  ////////////
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final obj = _toDoList[index];

                  return CheckboxListTile(
                    title: Text(obj["title"]),
                    value: obj["done"],
                    secondary: CircleAvatar(
                      child: Icon(obj["done"] ? Icons.check : Icons.warning),
                    ),
                    onChanged: (value) {
                      setState(() {
                        obj["done"] = value;
                      });
                    },
                  );
                },
                itemCount: _toDoList.length,
              ),
            )
          ],
        ));
  }

  void _addToDo() {
    //Novo obj/map JSON
    Map<String, dynamic> newToDo = Map();
    newToDo["title"] = _toDoController.text;
    newToDo["done"] = false;

    //limpa o campo input
    _toDoController.text = "";

    setState(() {
      _toDoList.add(newToDo);
    });
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
