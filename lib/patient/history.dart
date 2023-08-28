import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widget/drawer_app.dart';
import '../styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final _boxPatientHistory = Hive.box('patientHistory');
  final _boxPatients = Hive.box('patients');
  final _boxDoctors = Hive.box('doctors');
  // Se utiliza esta variable porque cuando se pretende borrar el elemento en
  //deleteResult, patientHistory está vacío y no se puede acceder a su contenido
  List<String> contenido = [];
  bool empty = true;

  // Muestra un diálogo de confirmación para borrar el resultado
  Future<void> _confirmDeletion(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).pregunta_borrado_elemento),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context).pregunta_borrado_elemento),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).boton_cancelar),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text(AppLocalizations.of(context).boton_confirmar),
                onPressed: () {
                  _deleteResult(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      width: 240,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      behavior: SnackBarBehavior.floating,
                      content: Center(
                        child: Text(
                            AppLocalizations.of(context).borrado_elemento_ok),
                      ),
                    ),
                  );
                }),
          ],
        );
      },
    );
  }

  // Comprueba si el paciente tiene resultados asociados
  void _checkPatientHistory(String dni) {
    int index;
    final boxHistoryLength = _boxHistory.length - 1;

    // Se ejecuta si el paciente está viendo su propio historial
    if (_boxPatients.containsKey(_boxLogin.get('dni'))) {
      if (boxHistoryLength >= 0) {
        _boxPatientHistory.clear();
        for (index = 0; index < boxHistoryLength; index++) {
          if (_boxHistory.getAt(index)['dni'] == _boxLogin.get('dni')) {
            debugPrint('${_boxHistory.getAt(index)}');
            _boxPatientHistory.add(_boxHistory.getAt(index));
          }
        }
        for (index = 0; index < _boxPatientHistory.length; index++) {
          contenido.add('${_boxPatientHistory.getAt(index)['path']}');
        }
      }
    }
    // Se ejecuta si el médico está viendo el historial de un paciente
    else {
      if (boxHistoryLength >= 0) {
        _boxPatientHistory.clear();
        for (index = 0; index < boxHistoryLength; index++) {
          if (_boxHistory.getAt(index)['dni'] == dni) {
            _boxPatientHistory.add(_boxHistory.getAt(index));
            empty = false;
          }
        }
      }
    }
  }

  // Borra el resultado seleccionado
  void _deleteResult(int index) {
    int i;
    for (i = 0; i < _boxHistory.length - 1; i++) {
      if (_boxHistory.getAt(i)['dni'] == _boxLogin.get('dni') &&
          _boxHistory.getAt(i)['path'] == contenido[index]) {
        debugPrint('${_boxHistory.getAt(i)}');
        _boxHistory.deleteAt(index);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se inicializa a true para que no se muestre el mensaje de historial vacío
    // cuando el médico sea el que acceda a un historial vacío, ya que no tiene
    // la lista contenido para comprobarlo
    empty = true;
    // El caso en el que el médico solicite ver el historial de un paciente,
    // se obtiene el dni del paciente a través de los argumentos de la ruta
    final args = ModalRoute.of(context)!.settings.arguments.toString();
    final dni = args.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    _checkPatientHistory(dni);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 3),
        // Comprueba si el paciente tiene resultados asociados
        body: (contenido.isEmpty &&
                    _boxPatients.containsKey(_boxLogin.get('dni'))) ||
                (empty == true && _boxDoctors.containsKey(_boxLogin.get('dni')))
            ? Center(
                // Texto que se muestra si el paciente no tiene resultados
                child: Text(
                  AppLocalizations.of(context).historial_vacio,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 26,
                    color: pantoneBlueVeryPeryVariant,
                  ),
                ),
              )
            // Muestra los resultados del paciente
            : ListView.builder(
                itemCount: _boxPatientHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              // Imagen del resultado
                              child: Image.file(File(
                                      // ignore: lines_longer_than_80_chars
                                      "${_boxPatientHistory.getAt(index)['path']}"),
                                  fit: BoxFit.fitHeight),
                            )),
                        // Datos del resultado
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 20.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  '${AppLocalizations.of(context).fecha}: ${_boxPatientHistory.getAt(index)['date']}',
                                  style: historyTextStyle,
                                ),
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  '${AppLocalizations.of(context).resultado}: ${_boxPatientHistory.getAt(index)['result']}',
                                  style: historyTextStyle,
                                ),
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  '${AppLocalizations.of(context).precision}: ${(_boxPatientHistory.getAt(index)['accuracy'] * 100).toStringAsFixed(2)}%',
                                  style: historyTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Botón para borrar el resultado si es el propio
                        // paciente el que está viendo el historial
                        Expanded(
                          flex: 1,
                          child: _boxPatients.containsKey(_boxLogin.get('dni'))
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: pantoneBlueVeryPeryVariant,
                                  ),
                                  onPressed: () => _confirmDeletion(index),
                                )
                              : const Text(''),
                        ),
                      ],
                    ),
                  );
                }));
  }
}
