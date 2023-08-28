import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../styles.dart';
import '../widget/drawer_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckPatients extends StatefulWidget {
  final String? title;
  const CheckPatients({super.key, required this.title});

  static const routeName = '/patients';

  @override
  State<CheckPatients> createState() => _CheckPatientsState();
}

class _CheckPatientsState extends State<CheckPatients> {
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');
  final _box = Hive.box('doctorPatients');
  final List<String> _contenido = [];

  // Función para comprobar los pacientes asignados al doctor
  void _checkPatients() {
    int index;

    _box.clear();
    for (index = 0; index < _boxPatients.length; index++) {
      if (_boxLogin.get('dni') == _boxPatients.getAt(index)['doctor']) {
        _box.add(_boxPatients.getAt(index));
        _contenido.add('${_boxPatients.getAt(index)['dni']}');
      }
    }
  }

  // Función para mostrar el historial de un paciente, enviando a la pantalla
  // de historial el DNI/NIE del paciente
  void checkHistory(int index) async {
    int i;
    for (i = 0; i < _boxPatients.length; i++) {
      if (_boxPatients.getAt(i)['dni'] == _contenido[index]) {
        Navigator.pushNamed(
          context,
          '/history',
          arguments: <String>{
            (_contenido[index]),
          },
        );
      }
    }
  }

  // Función para desasignar un paciente
  void _unassignPatient(int index) async {
    // Cuadro de diálogo para confirmar el desasignado
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).desasignar_pacientes),
          content:
              Text(AppLocalizations.of(context).pregunta_desasignar_pacientes),
          actions: <Widget>[
            // Opción para cancelar el desasignado
            TextButton(
              child: Text(AppLocalizations.of(context).boton_cancelar),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Opción para confirmar el desasignado
            TextButton(
              child: Text(AppLocalizations.of(context).boton_desasignar),
              onPressed: () {
                int i;
                for (i = 0; i < _boxPatients.length; i++) {
                  if (_boxPatients.getAt(i)['dni'] == _contenido[index]) {
                    _boxPatients.put(_contenido[index], {
                      'dni': _contenido[index],
                      'password': _boxPatients.getAt(i)['password'],
                      'email': _boxPatients.getAt(i)['email'],
                      'name': _boxPatients.getAt(i)['name'],
                      'doctor': '0',
                    });
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => super.widget));
                  }
                }
                // Muestra un mensaje de que el paciente se ha desasignado
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    width: 180,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    behavior: SnackBarBehavior.floating,
                    content: Center(
                      child: Text(
                          AppLocalizations.of(context).paciente_desasignado),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkPatients();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 5),
        body: Column(
          children: <Widget>[
            Expanded(
              // Muestra un mensaje si no hay pacientes asignados
              child: (_box.isEmpty)
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context).no_hay_pacientes,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 26,
                          color: pantoneBlueVeryPeryVariant,
                        ),
                      ),
                    )
                  // Muestra la lista de pacientes
                  : ListView.builder(
                      itemCount: _box.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    5.0, 20.0, 0.0, 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'DNI/NIE: ${_box.getAt(index)['dni']}',
                                      style: const TextStyle(fontSize: 17.0),
                                    ),
                                    Text(
                                      // ignore: lines_longer_than_80_chars
                                      '${AppLocalizations.of(context).nombre}: ${_box.getAt(index)['name']}',
                                      style: const TextStyle(fontSize: 17.0),
                                    ),
                                    Text(
                                      // ignore: lines_longer_than_80_chars
                                      '${AppLocalizations.of(context).correo_electronico}: ${_box.getAt(index)['email']}',
                                      style: const TextStyle(fontSize: 17.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Botón para mostrar el historial del paciente
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: Icon(
                                  Icons.view_list,
                                  color: pantoneBlueVeryPeryVariant,
                                  semanticLabel: AppLocalizations.of(context)
                                      .mostrar_historial,
                                ),
                                onPressed: () => {
                                  checkHistory(index),
                                },
                              ),
                            ),
                            // Botón para desasignar un paciente
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: pantoneBlueVeryPeryVariant,
                                  semanticLabel: AppLocalizations.of(context)
                                      .desasignar_pacientes,
                                ),
                                onPressed: () => {
                                  _unassignPatient(index),
                                },
                              ),
                            ),
                          ],
                        );
                      }),
            ),
          ],
        ),
        // Botón para asignar un paciente
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: pantoneBlueVeryPeryVariant,
          onPressed: () => Navigator.pushNamed(context, '/assignPatient'),
          tooltip: AppLocalizations.of(context).presione_paciente,
          label: Text(AppLocalizations.of(context).boton_asignar_paciente),
          icon: const Icon(Icons.add),
        ));
  }
}
