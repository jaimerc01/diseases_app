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
          contenido.add('${_boxUserHistory.getAt(index)['path']}');
        }
      }
    }
  }

  void _deleteResult(int index) {
    int i;
    for (i = 0; i < _boxHistory.length - 1; i++) {
      if (_boxHistory.getAt(i)['dni'] == _boxLogin.get('DNI') &&
          _boxHistory.getAt(i)['path'] == contenido[index]) {
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
                          child: Image.file(
                              File("${_boxUserHistory.getAt(index)['path']}"),
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
                              'Fecha: ${_boxUserHistory.getAt(index)['date']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                            Text(
                              // ignore: lines_longer_than_80_chars
                              'Resultado: ${_boxUserHistory.getAt(index)['result']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                            Text(
                              // ignore: lines_longer_than_80_chars
                              'Precisión: ${(_boxUserHistory.getAt(index)['accuracy'] * 100).toStringAsFixed(2)}%',
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
                          color: Colors.blueGrey,
                        ),
                        onPressed: () => {
                          _deleteResult(index),
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              width: 240,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              behavior: SnackBarBehavior.floating,
                              content:
                                  const Text('Elemento borrado correctamente'),
                            ),
                          )
                        },
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}
