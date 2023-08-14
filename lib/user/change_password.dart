import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../styles.dart';

import '../widget/drawer_app.dart';

class ChangePassword extends StatefulWidget {
  final String? title;
  const ChangePassword({super.key, required this.title});

  static const routeName = '/password';

  @override
  State<ChangePassword> createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');
  final _boxDoctors = Hive.box('doctors');
  bool _obscurePassword = true;

  String _dni = '';
  String _name = '';
  String _email = '';
  String _patientDoctor = '';

  String _doctorCollegiateNumber = '';

  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerNewPassword = TextEditingController();
  final TextEditingController _controllerConfirmNewPassword =
      TextEditingController();

  final FocusNode _focusNodeNewPassword = FocusNode();
  final FocusNode _focusNodeConfirmNewPassword = FocusNode();

  void _initUser() {
    _dni = '${_boxLogin.get('dni')}';
    if (_boxPatients.containsKey(_boxLogin.get('dni'))) {
      _name = '${_boxPatients.get(_boxLogin.get('dni'))['name']}';
      _email = '${_boxPatients.get(_boxLogin.get('dni'))['email']}';
      _patientDoctor = '${_boxPatients.get(_boxLogin.get('dni'))['doctor']}';
    } else if (_boxDoctors.containsKey(_boxLogin.get('dni'))) {
      _name = '${_boxDoctors.get(_boxLogin.get('dni'))['name']}';
      _email = '${_boxDoctors.get(_boxLogin.get('dni'))['email']}';
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
                    controller: _controllerPassword,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      errorStyle: errorTextStyle,
                      labelText: 'Contraseña actual',
                      prefixIcon: const Icon(Icons.password_outlined),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: _obscurePassword
                              ? const Icon(Icons.visibility_outlined)
                              : const Icon(Icons.visibility_off_outlined)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca la actual contraseña';
                      } else if (_boxPatients
                          .containsKey(_boxLogin.get('dni'))) {
                        if (value !=
                            _boxPatients
                                .get(_boxLogin.get('dni'))['password']) {
                          return 'La contraseña introducida es incorrecta';
                        }
                      } else if (_boxDoctors
                          .containsKey(_boxLogin.get('dni'))) {
                        if (value !=
                            _boxDoctors.get(_boxLogin.get('dni'))['password']) {
                          return 'La contraseña introducida es incorrecta';
                        }
                      }
                      return null;
                    },
                    onEditingComplete: () =>
                        _focusNodeNewPassword.requestFocus(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: formFieldTextStyle,
                    controller: _controllerNewPassword,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscurePassword,
                    focusNode: _focusNodeNewPassword,
                    decoration: InputDecoration(
                      errorStyle: errorTextStyle,
                      labelText: 'Nueva contraseña',
                      prefixIcon: const Icon(Icons.password_outlined),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: _obscurePassword
                              ? const Icon(Icons.visibility_outlined)
                              : const Icon(Icons.visibility_off_outlined)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca una contraseña';
                      } else if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                    onEditingComplete: () =>
                        _focusNodeConfirmNewPassword.requestFocus(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: formFieldTextStyle,
                    controller: _controllerConfirmNewPassword,
                    obscureText: _obscurePassword,
                    focusNode: _focusNodeConfirmNewPassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      errorStyle: errorTextStyle,
                      labelText: 'Confirmar nueva contraseña',
                      prefixIcon: const Icon(Icons.password_outlined),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: _obscurePassword
                              ? const Icon(Icons.visibility_outlined)
                              : const Icon(Icons.visibility_off_outlined)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca su contraseña';
                      } else if (value != _controllerNewPassword.text) {
                        return 'La contraseña no coincide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
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
                                _boxPatients.put(_dni, {
                                  'dni': _dni,
                                  'password':
                                      _controllerConfirmNewPassword.text,
                                  'email': _email,
                                  'name': _name,
                                  'doctor': _patientDoctor,
                                });
                              } else {
                                _boxDoctors.put(_dni, {
                                  'dni': _dni,
                                  'password':
                                      _controllerConfirmNewPassword.text,
                                  'email': _email,
                                  'name': _name,
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
                                        'Contraseña modificada correctamente'),
                                  ),
                                ),
                              );

                              _formKey.currentState?.reset();

                              Navigator.pushNamed(context, '/profile');
                            }
                          },
                          child: const Text(
                            'MODIFICAR CONTRASEÑA',
                            style: buttonTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]))));
  }

  @override
  void dispose() {
    _controllerPassword.dispose();
    _controllerNewPassword.dispose();
    _controllerConfirmNewPassword.dispose();
    _focusNodeConfirmNewPassword.dispose();
    _focusNodeNewPassword.dispose();
    super.dispose();
  }
}
