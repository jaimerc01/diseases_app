import 'package:dni_nie_validator/dni_nie_validator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../styles.dart';
import '../widget/drawer_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final _boxDoctor = Hive.box('doctors');

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
              // Formulario para asignar un paciente (campo DNI/NIE)
              TextFormField(
                key: const Key('dniAssign'),
                style: formFieldTextStyle,
                controller: _controllerDni,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  errorStyle: errorTextStyle,
                  labelText: AppLocalizations.of(context).dni_paciente,
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
                    return AppLocalizations.of(context).introduzca_dni_paciente;
                  } else if (value.length != 9) {
                    return AppLocalizations.of(context).tamano_dni;
                  } else if (!value.isValidDNI() && !value.isValidNIE()) {
                    return AppLocalizations.of(context)
                        .correctamente_dni_paciente;
                  } else if (!_boxPatients.containsKey(value)) {
                    return AppLocalizations.of(context)
                        .no_registrado_dni_paciente;
                  } else if (_boxPatients.get(value)['doctor'] != '0' &&
                      _boxDoctor
                          .containsKey(_boxPatients.get(value)['doctor'])) {
                    return AppLocalizations.of(context).paciente_ya_asignado;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 50),
              // Botón para asignar el paciente
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
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
                            'password': _boxPatients
                                .get(_controllerDni.text)['password'],
                            'email':
                                _boxPatients.get(_controllerDni.text)['email'],
                            'name':
                                _boxPatients.get(_controllerDni.text)['name'],
                            'doctor': _boxLogin.get('dni'),
                          });

                          // Muestra un mensaje de que el paciente se ha
                          // asignado correctamente
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              width: 260,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              behavior: SnackBarBehavior.floating,
                              content: Center(
                                child: Text(
                                    AppLocalizations.of(context).asignado_ok),
                              ),
                            ),
                          );

                          _formKey.currentState?.reset();

                          Navigator.pushNamed(context, '/patients');
                        }
                      },
                      child: Text(
                          (AppLocalizations.of(context).boton_asignar_paciente),
                          style: buttonTextStyle),
                    ),
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
