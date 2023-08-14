import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widget/drawer_app.dart';
import '../styles.dart';

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
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmación borrado de doctor'),
        content: const Text(
            // ignore: lines_longer_than_80_chars
            '¿Está seguro de que desea borrar la cuenta de este doctor permanentemente?'),
        actions: [
          TextButton(
            child: const Text('CANCELAR'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('CONFIRMAR'),
            onPressed: () {
              _boxDoctors.deleteAt(index);
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => super.widget));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  width: 240,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  behavior: SnackBarBehavior.floating,
                  content: const Center(
                    child: Text('Doctor borrado correctamente'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 4),
        body: ListView.builder(
            itemCount: _boxDoctors.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          color: pantoneBlueVeryPeryVariant,
                        ),
                        onPressed: () => {
                          _deleteDoctor(index),
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: pantoneBlueVeryPeryVariant,
          onPressed: () => Navigator.pushNamed(context, '/addDoctor'),
          tooltip: 'Presione para añadir un doctor',
          label: const Text('AÑADIR DOCTOR'),
          icon: const Icon(Icons.add),
        ));
  }
}
