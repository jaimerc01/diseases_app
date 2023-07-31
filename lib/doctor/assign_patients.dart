import 'package:dni_nie_validator/dni_nie_validator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widget/drawer_app.dart';

class AssingPatient extends StatefulWidget {
  final String? title;
  const AssingPatient({super.key, required this.title});

  static const routeName = '/assignPatient';

  @override
  State<AssingPatient> createState() => _AssingPatientState();
}

class _AssingPatientState extends State<AssingPatient> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _controllerDni = TextEditingController();

  final _boxPatients = Hive.box('patients');
  final _boxLogin = Hive.box('login');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      drawer: const DrawerApp(drawerValue: 4),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              TextFormField(
                controller: _controllerDni,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'DNI/NIE del paciente',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduzca el DNI/NIE cel paciente';
                  } else if (value.length != 9) {
                    return 'El tamaño no coincide con el de un DNI/NIE';
                  } else if (!value.isValidDNI() && !value.isValidNIE()) {
                    return 'Introduzca correctamente el DNI/NIE del paciente';
                  } else if (!_boxPatients.containsKey(value)) {
                    return 'El DNI/NIE del paciente no está registrado';
                  } else if (_boxPatients.get(value)['doctor'] != '0') {
                    return 'El paciente ya tiene un médico asignado';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _boxPatients.put(_controllerDni.text, {
                          'dni': _controllerDni.text,
                          'password':
                              _boxPatients.get(_controllerDni.text)['password'],
                          'email':
                              _boxPatients.get(_controllerDni.text)['email'],
                          'name': _boxPatients.get(_controllerDni.text)['name'],
                          'doctor': _boxLogin.get('dni'),
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            width: 200,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            behavior: SnackBarBehavior.floating,
                            content:
                                const Text('Paciente asignado correctamente'),
                          ),
                        );

                        _formKey.currentState?.reset();

                        Navigator.pushNamed(context, '/patients');
                      }
                    },
                    child: const Text('Asignar paciente'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllerDni.dispose();
    super.dispose();
  }
}
