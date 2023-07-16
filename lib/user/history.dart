import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widget/drawer_app.dart';

class History extends StatefulWidget {
  final String? title;
  const History({super.key, required this.title});

  static const routeName = '/history';

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final _boxLogin = Hive.box('login');
  final _boxHistory = Hive.box('history');
  final _boxUserHistory = Hive.box('userHistory');
  List<String> contenido = [];

  void _checkUserHistory() {
    int index;
    final boxHistoryLength = _boxHistory.length - 1;

    if (boxHistoryLength >= 0) {
      _boxUserHistory.clear();
      for (index = 0; index < boxHistoryLength; index++) {
        if (_boxHistory.getAt(index)['dni'] == _boxLogin.get('DNI')) {
          _boxUserHistory.add(_boxHistory.getAt(index));
          contenido.add('${_boxUserHistory.getAt(index)['contenido']}');
        }
      }
    }
  }

  void _deleteResult(int index) {
    int i;
    for (i = 0; i < _boxHistory.length - 1; i++) {
      if (_boxHistory.getAt(i)['dni'] == _boxLogin.get('DNI') &&
          _boxHistory.getAt(i)['contenido'] == contenido[index]) {
        _boxHistory.deleteAt(index);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkUserHistory();
    return Scaffold(
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 3),
        body: ListView.builder(
            itemCount: _boxUserHistory.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.file(File(
                                  // ignore: lines_longer_than_80_chars
                                  "${_boxUserHistory.getAt(index)['contenido']}"),
                              fit: BoxFit.fitHeight),
                        )),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 20.0, 0.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Fecha: ${_boxUserHistory.getAt(index)['fecha']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                            Text(
                              // ignore: lines_longer_than_80_chars
                              'Resultado: ${_boxUserHistory.getAt(index)['resultado']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                            Text(
                              // ignore: lines_longer_than_80_chars
                              'Precisión: ${(_boxUserHistory.getAt(index)['precision'] * 100).toStringAsFixed(2)}%',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                        onPressed: () => {_deleteResult(index)},
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  /*@override
  void dispose() {
    _boxUserHistory.clear();
    super.dispose();
  }*/
}
