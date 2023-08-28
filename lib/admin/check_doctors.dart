import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widget/drawer_app.dart';
import '../styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckDoctors extends StatefulWidget {
  final String? title;
  const CheckDoctors({super.key, required this.title});

  static const routeName = '/doctors';

  @override
  State<CheckDoctors> createState() => _CheckDoctorsState();
}

class _CheckDoctorsState extends State<CheckDoctors> {
  final _boxDoctors = Hive.box('doctors');

  // Función para borrar un doctor
  void _deleteDoctor(int index) {
    // Cuadro de diálogo para confirmar el borrado
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).confirmar_borrado_doctor),
        content: Text(AppLocalizations.of(context).pregunta_borrado_doctor),
        actions: [
          // Opción para cancelar el borrado
          TextButton(
            child: Text(AppLocalizations.of(context).boton_cancelar),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // Opción para confirmar el borrado
          TextButton(
            child: Text(AppLocalizations.of(context).boton_confirmar),
            onPressed: () {
              _boxDoctors.deleteAt(index);
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => super.widget));
              // Muestra un mensaje de que el borrado se ha realizado
              // correctamente
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  width: 240,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  behavior: SnackBarBehavior.floating,
                  content: Center(
                    child: Text(AppLocalizations.of(context).doctor_borrado_ok),
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
        body: (_boxDoctors.isEmpty)
            ? Center(
                child: Text(
                  AppLocalizations.of(context).no_hay_medicos,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 26,
                    color: pantoneBlueVeryPeryVariant,
                  ),
                ),
              )
            // Muestra la lista de doctores
            : ListView.builder(
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
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 20.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'DNI/NIE: ${_boxDoctors.getAt(index)['dni']}',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  '${AppLocalizations.of(context).nombre}: ${_boxDoctors.getAt(index)['name']}',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  '${AppLocalizations.of(context).numero_colegiado}: ${_boxDoctors.getAt(index)['collegiateNumber']}',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  '${AppLocalizations.of(context).correo_electronico}: ${_boxDoctors.getAt(index)['email']}',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          // Botón para borrar un doctor
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
        // Botón para añadir un doctor
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: pantoneBlueVeryPeryVariant,
          onPressed: () => Navigator.pushNamed(context, '/addDoctor'),
          tooltip: AppLocalizations.of(context).presione_medico,
          label: Text(AppLocalizations.of(context).boton_anadir_medico),
          icon: const Icon(Icons.add),
        ));
  }
}
