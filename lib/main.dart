import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const COR_PRIMARIA = Colors.deepOrangeAccent;

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        hintColor: COR_PRIMARIA,
        primaryColor: COR_PRIMARIA,
        cursorColor: COR_PRIMARIA,
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: COR_PRIMARIA),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];

  final _toDoController = TextEditingController();

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  bool _hasValue = false;

  @override
  void initState() {
    super.initState();

    _getData().then((data) {
      _toDoList = json.decode(data);
      _sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: COR_PRIMARIA,
        centerTitle: false,
        actions: <Widget>[
          Visibility(
            child: buildBarButton(
                Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
                _deleteAll),
            visible: _toDoList.isNotEmpty,
          ),
          Visibility(
            child: buildBarButton(
                Icon(
                  Icons.done_all,
                  color: Colors.white,
                ),
                _doneAll),
            visible: _toDoList.isNotEmpty,
          ),
        ],
      ),
      body: Column(children: <Widget>[
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
                onChanged: (value) {
                  setState(() {
                    _hasValue = value.isNotEmpty;
                  });
                },
              )),
              ButtonTheme(
                minWidth: 40.0,
                //height: 100.0,
                child: RaisedButton(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: _hasValue ? _addToDo : null,
                  color: COR_PRIMARIA,
                  disabledColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
            child: RefreshIndicator(
          child: ListView.builder(
            itemBuilder: buildItem,
            itemCount: _toDoList.length,
          ),
          onRefresh: _refreshData,
        ))
      ]),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Powered by github.com/SidiBecker",
            )
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    final obj = _toDoList[index];

    return Dismissible(
      key: Key(obj["id"].toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: CheckboxListTile(
        title: Text(obj["title"]),
        value: obj["done"],
        secondary: CircleAvatar(
          child: Icon(obj["done"] ? Icons.check : Icons.warning),
          backgroundColor: COR_PRIMARIA,
          foregroundColor: Colors.white,
        ),
        activeColor: COR_PRIMARIA,
        onChanged: (value) {
          setState(() {
            obj["done"] = value;
          });

          _saveData();
        },
      ),
      onDismissed: (direction) {
        _lastRemoved = Map.from(_toDoList[index]);
        _lastRemovedPos = index;

        setState(() {
          _toDoList.removeAt(index);
        });

        _saveData();

        final snack = SnackBar(
          content: Text("A tarefa \"${_lastRemoved["title"]}\" foi removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            textColor: COR_PRIMARIA,
            onPressed: () {
              setState(() {
                _toDoList.insert(_lastRemovedPos, _lastRemoved);
              });

              _saveData();
            },
          ),
          duration: Duration(milliseconds: 2000),
        );

        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snack);
      },
    );
  }

  Widget buildBarButton(Icon icon, Function function) {
    return ButtonTheme(
      minWidth: 40.0,
      child: FlatButton(child: icon, onPressed: function),
    );
  }

  Future<Null> _refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    _sort();
    return null;
  }

  void _sort() {
    setState(() {
      _toDoList.sort((a, b) {
        if (a["done"] && !b["done"])
          return 1;
        else if (!a["done"] && b["done"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });
  }

  void _addToDo() {
    Map<String, dynamic> newToDo = Map();

    if (_toDoController.text.isNotEmpty) {
      newToDo["title"] = _toDoController.text;
      newToDo["done"] = false;

      if (_toDoList.isEmpty) {
        newToDo["id"] = 1;
      } else {
        final listaIds = _toDoList.map((e) => e["id"]);
        listaIds.toList().sort();
        newToDo["id"] = (listaIds.last) + 1;
      }

      //limpa o campo input
      _toDoController.text = "";

      setState(() {
        _toDoList.add(newToDo);
        _hasValue = false;
      });

      _saveData();
    }
  }

  void _deleteAll() {
    void callback() async {
      setState(() {
        _toDoList = [];
      });
      _saveData();
    }

    _showMyDialog(
        "REMOÇÃO DE TAREFAS", "Deseja remover todas as tarefas?", callback);
  }

  void _doneAll() {
    void callback() async {
      setState(() {
        _toDoList.toList().forEach((el) {
          el["done"] = true;
        });
      });

      _saveData();
    }

    _showMyDialog(
        "CONCLUSÃO DE TAREFAS", "Deseja concluir todas as tarefas?", callback);
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();

    return file.writeAsString(data);
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

  Future<void> _showMyDialog(
      String title, String body, Function callback) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("CONFIRMAR"),
              onPressed: () {
                Navigator.of(context).pop();
                if (callback != null) {
                  callback();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
