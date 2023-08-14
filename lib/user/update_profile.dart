import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widget/drawer_app.dart';
import '../styles.dart';

class UpdateProfile extends StatefulWidget {
  final String? title;
  const UpdateProfile({super.key, required this.title});

  static const routeName = '/updateProfile';

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');
  final _boxDoctors = Hive.box('doctors');

  String _password = '';
  String _patientDoctor = '';

  String _doctorCollegiateNumber = '';

  final TextEditingController _controllerDni = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();

  void _initUser() {
    _controllerDni.text = '${_boxLogin.get('dni')}';
    if (_boxPatients.containsKey(_boxLogin.get('dni'))) {
      _controllerName.text =
          '${_boxPatients.get(_boxLogin.get('dni'))['name']}';
      _controllerEmail.text =
          '${_boxPatients.get(_boxLogin.get('dni'))['email']}';
      _password = '${_boxPatients.get(_boxLogin.get('dni'))['password']}';
      _patientDoctor = '${_boxPatients.get(_boxLogin.get('dni'))['doctor']}';
    } else if (_boxDoctors.containsKey(_boxLogin.get('dni'))) {
      _controllerName.text = '${_boxDoctors.get(_boxLogin.get('dni'))['name']}';
      _controllerEmail.text =
          '${_boxDoctors.get(_boxLogin.get('dni'))['email']}';
      _password = '${_boxDoctors.get(_boxLogin.get('dni'))['password']}';
      _doctorCollegiateNumber =
          '${_boxDoctors.get(_boxLogin.get('dni'))['collegiateNumber']}';
    }
  }

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 2),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(children: [
                  const SizedBox(height: 50),
                  TextFormField(
                    style: formFieldTextStyle,
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      errorStyle: errorTextStyle,
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca el correo electrónico';
                      } else if (!(value.contains('@') &&
                          value.contains('.'))) {
                        return 'Correo electrónico no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: formFieldTextStyle,
                    controller: _controllerName,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      errorStyle: errorTextStyle,
                      labelText: 'Nombre completo',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca su nombre completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
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
                              if (_boxPatients
                                  .containsKey(_boxLogin.get('dni'))) {
                                _boxPatients.put(_controllerDni.text, {
                                  'dni': _controllerDni.text,
                                  'password': _password,
                                  'email': _controllerEmail.text,
                                  'name': _controllerName.text,
                                  'doctor': _patientDoctor,
                                });
                              } else {
                                _boxDoctors.put(_controllerDni.text, {
                                  'dni': _controllerDni.text,
                                  'password': _password,
                                  'email': _controllerEmail.text,
                                  'name': _controllerName.text,
                                  'collegiateNumber': _doctorCollegiateNumber,
                                });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  width: 200,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  content: const Center(
                                    child: Text(
                                        'Perfil actualizado correctamente'),
                                  ),
                                ),
                              );

                              _formKey.currentState?.reset();

                              Navigator.pushNamed(context, '/profile');
                            }
                          },
                          child:
                              const Text('ACTUALIZAR', style: buttonTextStyle),
                        ),
                      ),
                    ],
                  ),
                ]))));
  }

  @override
  void dispose() {
    _controllerDni.dispose();
    _controllerEmail.dispose();
    _controllerName.dispose();
    super.dispose();
  }
}
