import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../styles.dart';
import 'encrypt_password.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static const routeName = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerDni = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');
  final _boxPatientHistory = Hive.box('patientHistory');
  final _boxAdmins = Hive.box('admins');
  final _boxDoctors = Hive.box('doctors');

  @override
  void initState() {
    _boxLogin.clear();
    _boxPatientHistory.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              // Mensaje de inicio de sesión
              Text(
                AppLocalizations.of(context).titulo_inicio_sesion,
                style: subtitleTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 100),
              // Formulario de inicio de sesión (campo DNI/NIE)
              TextFormField(
                key: const Key('dni'),
                style: formFieldTextStyle,
                controller: _controllerDni,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: 'DNI/NIE',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorStyle: errorTextStyle),
                onEditingComplete: () => _focusNodePassword.requestFocus(),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).introduzca_dni;
                  } else if (!_boxPatients.containsKey(value) &&
                      !_boxAdmins.containsKey(value) &&
                      !_boxDoctors.containsKey(value)) {
                    return AppLocalizations.of(context).no_registrado;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Formulario de inicio de sesión (campo contraseña)
              TextFormField(
                key: const Key('password'),
                style: formFieldTextStyle,
                controller: _controllerPassword,
                focusNode: _focusNodePassword,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).contrasena,
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
                    errorStyle: errorTextStyle),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).introduzca_contrasena;
                  } else if (_boxPatients.containsKey(_controllerDni.text) &&
                      !verifyPassword(
                          value,
                          _boxPatients
                              .get(_controllerDni.text)['password']
                              .toString())) {
                    return AppLocalizations.of(context).incorrecta_contrasena;
                  } else if (_boxAdmins.containsKey(_controllerDni.text) &&
                      !verifyPassword(
                          value,
                          _boxAdmins
                              .get(_controllerDni.text)['password']
                              .toString())) {
                    return AppLocalizations.of(context).incorrecta_contrasena;
                  } else if (_boxDoctors.containsKey(_controllerDni.text) &&
                      !verifyPassword(
                          value,
                          _boxDoctors
                              .get(_controllerDni.text)['password']
                              .toString())) {
                    return AppLocalizations.of(context).incorrecta_contrasena;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 60),
              Column(
                children: [
                  // Botón de inicio de sesión
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
                          _boxLogin.put('dni', _controllerDni.text);

                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context).boton_iniciar_sesion,
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Texto de registro
                      Text(
                        AppLocalizations.of(context).pregunta_inicio_sesion,
                      ),
                      // Botón de registro
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();

                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(AppLocalizations.of(context).registrarse),
                      ),
                    ],
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
    _focusNodePassword.dispose();
    _controllerDni.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}
