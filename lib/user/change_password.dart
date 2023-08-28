import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../styles.dart';
import 'encrypt_password.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final _boxAdmins = Hive.box('admins');
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

  // Función para inicializar los datos del usuario dependiendo del tipo
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
    } else if (_boxAdmins.containsKey(_boxLogin.get('dni'))) {
      _name = '${_boxAdmins.get(_boxLogin.get('dni'))['name']}';
      _email = '${_boxAdmins.get(_boxLogin.get('dni'))['email']}';
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
                  // Formulario para cambiar la contraseña (campo actual)
                  TextFormField(
                    key: const Key('currentPassword'),
                    style: formFieldTextStyle,
                    controller: _controllerPassword,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      errorStyle: errorTextStyle,
                      labelText: AppLocalizations.of(context).contrasena_actual,
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
                        return AppLocalizations.of(context)
                            .introduzca_actual_contrasena;
                      } else if (_boxPatients
                          .containsKey(_boxLogin.get('dni'))) {
                        if (!verifyPassword(
                            value,
                            _boxPatients
                                .get(_boxLogin.get('dni'))['password']
                                .toString())) {
                          return AppLocalizations.of(context)
                              .incorrecta_contrasena;
                        }
                      } else if (_boxDoctors
                          .containsKey(_boxLogin.get('dni'))) {
                        if (!verifyPassword(
                            value,
                            _boxDoctors
                                .get(_boxLogin.get('dni'))['password']
                                .toString())) {
                          return AppLocalizations.of(context)
                              .incorrecta_contrasena;
                        }
                      } else if (_boxAdmins.containsKey(_boxLogin.get('dni'))) {
                        debugPrint('Admin');
                        if (!verifyPassword(
                            value,
                            _boxAdmins
                                .get(_boxLogin.get('dni'))['password']
                                .toString())) {
                          debugPrint(value);
                          debugPrint(
                              _boxAdmins.get(_boxLogin.get('dni')).toString());
                          return AppLocalizations.of(context)
                              .incorrecta_contrasena;
                        }
                      }
                      return null;
                    },
                    onEditingComplete: () =>
                        _focusNodeNewPassword.requestFocus(),
                  ),
                  const SizedBox(height: 10),
                  // Formulario para cambiar la contraseña (campo nueva)
                  TextFormField(
                    key: const Key('newPassword'),
                    style: formFieldTextStyle,
                    controller: _controllerNewPassword,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscurePassword,
                    focusNode: _focusNodeNewPassword,
                    decoration: InputDecoration(
                      errorStyle: errorTextStyle,
                      labelText: AppLocalizations.of(context).nueva_contrasena,
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
                        return AppLocalizations.of(context)
                            .introduzca_contrasena;
                      } else if (value.length < 8) {
                        return AppLocalizations.of(context).tamano_contrasena;
                      }
                      return null;
                    },
                    onEditingComplete: () =>
                        _focusNodeConfirmNewPassword.requestFocus(),
                  ),
                  const SizedBox(height: 10),
                  // Formulario para cambiar la contraseña
                  //(campo confirmar nueva)
                  TextFormField(
                    key: const Key('confirmPasswordChange'),
                    style: formFieldTextStyle,
                    controller: _controllerConfirmNewPassword,
                    obscureText: _obscurePassword,
                    focusNode: _focusNodeConfirmNewPassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      errorStyle: errorTextStyle,
                      labelText: AppLocalizations.of(context)
                          .confirmar_nueva_contrasena,
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
                        return AppLocalizations.of(context)
                            .introduzca_contrasena;
                      } else if (value != _controllerNewPassword.text) {
                        return AppLocalizations.of(context)
                            .no_coincide_contrasena;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  Column(
                    children: [
                      // Botón para cambiar la contraseña
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
                                  'password': encryptPassword(
                                      _controllerConfirmNewPassword.text),
                                  'email': _email,
                                  'name': _name,
                                  'doctor': _patientDoctor,
                                });
                              } else if (_boxDoctors
                                  .containsKey(_boxLogin.get('dni'))) {
                                _boxDoctors.put(_dni, {
                                  'dni': _dni,
                                  'password': encryptPassword(
                                      _controllerConfirmNewPassword.text),
                                  'email': _email,
                                  'name': _name,
                                  'collegiateNumber': _doctorCollegiateNumber,
                                });
                              } else {
                                _boxAdmins.put(_dni, {
                                  'dni': _dni,
                                  'password': encryptPassword(
                                      _controllerConfirmNewPassword.text),
                                  'email': _email,
                                  'name': _name,
                                });
                              }
                              // Muestra un mensaje de que la contraseña se
                              //ha cambiado
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  width: 200,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  content: Center(
                                    child: Text(AppLocalizations.of(context)
                                        .contrasena_ok),
                                  ),
                                ),
                              );

                              _formKey.currentState?.reset();

                              Navigator.pushNamed(context, '/profile');
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)
                                .boton_modificar_contrasena,
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
