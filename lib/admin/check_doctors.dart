import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widget/drawer_app.dart';

class CheckDoctors extends StatefulWidget {
  final String? title;
  const CheckDoctors({super.key, required this.title});

  static const routeName = '/doctors';

  @override
  State<CheckDoctors> createState() => _CheckDoctorsState();
}

class _CheckDoctorsState extends State<CheckDoctors> {
  final _boxDoctors = Hive.box('doctors');

  void _deleteDoctor(int index) {
    _boxDoctors.deleteAt(index);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 4),
        body: ListView.builder(
            itemCount: _boxDoctors.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 20.0, 0.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'DNI/NIF: ${_boxDoctors.getAt(index)['dni']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                            Text(
                              // ignore: lines_longer_than_80_chars
                              'Nombre completo: ${_boxDoctors.getAt(index)['name']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                            Text(
                              // ignore: lines_longer_than_80_chars
                              'Número de colegiado: ${_boxDoctors.getAt(index)['collegiateNumber']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                            Text(
                              // ignore: lines_longer_than_80_chars
                              'Correo electrónico: ${_boxDoctors.getAt(index)['email']}',
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
                          _deleteDoctor(index),
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
                                  const Text('Doctor borrado correctamente'),
                            ),
                          )
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/addDoctor'),
          tooltip: 'Presione para añadir un doctor',
          label: const Text('Añadir doctor'),
          icon: const Icon(Icons.add),
        ));
  }
}
