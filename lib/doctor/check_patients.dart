import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../styles.dart';
import '../widget/drawer_app.dart';

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
  //List<dynamic> _searched = [];
  //final List<dynamic> _patients = [];

  final TextEditingController _controller = TextEditingController();

  void _checkPatients() {
    int index;

    _box.clear();
    for (index = 0; index < _boxPatients.length; index++) {
      if (_boxLogin.get('dni') == _boxPatients.getAt(index)['doctor']) {
        _box.add(_boxPatients.getAt(index));
        _contenido.add('${_boxPatients.getAt(index)['dni']}');
        //_searched.add(_boxPatients.getAt(index));
        //_patients.add(_boxPatients.getAt(index));
      }
    }
  }

  void checkHistory(int index) {
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

  void _unassignPatient(int index) {
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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      }
    }
  }

  /*void _searchPatient(String value) {
    var results = <dynamic>[];
    if (value.isEmpty) {
      results = _patients;
    } else {
      for (var i = 0; _box.length > i; i++) {
        if (_box.getAt(i)['dni'].toString().contains(value)) {
          results.add(_box.getAt(i));
        }
      }
    }
    setState((){_searched = results;});
  }*/

  @override
  Widget build(BuildContext context) {
    _checkPatients();
    return Scaffold(
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 5),
        body: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'dni',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: darkGreen),
                  ),
                ),
                //onChanged: (value) => _searchPatient(value),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _box.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 20.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'DNI/NIF: ${_box.getAt(index)['dni']}',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  'Nombre completo: ${_box.getAt(index)['name']}',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  'Correo electrónico: ${_box.getAt(index)['email']}',
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
                              Icons.view_list,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () => {
                              checkHistory(index),
                            },
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
                              _unassignPatient(index),
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  width: 240,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  content: const Text('Paciente desasignado'),
                                ),
                              )
                            },
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/assignPatient'),
          tooltip: 'Presione para asingar un paciente',
          label: const Text('Asignar paciente'),
          icon: const Icon(Icons.add),
        ));
  }
}
