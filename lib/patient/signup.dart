import 'package:dni_nie_validator/dni_nie_validator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../styles.dart';
//import '../user/encrypt_password.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  static const routeName = '/signup';

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodeNombre = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _controllerDni = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConFirmPassword =
      TextEditingController();

  final _boxPatients = Hive.box('patients');
  final _boxAdmins = Hive.box('admins');
  final _boxDoctors = Hive.box('doctors');
  bool _obscurePassword = true;
  //late String? _encryptedPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'Cree su cuenta personal',
                style: subtitleTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              TextFormField(
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
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduzca su DNI/NIE.';
                  } else if (value.length != 9) {
                    return 'El tamaño no coincide con el de un DNI/NIE';
                  } else if (!value.isValidDNI() && !value.isValidNIE()) {
                    return 'Introduzca correctamente su DNI/NIE';
                  } else if (_boxPatients.containsKey(value) ||
                      _boxAdmins.containsKey(value) ||
                      _boxDoctors.containsKey(value)) {
                    return 'Su DNI/NIE ya está registrado';
                  }

                  return null;
                },
                onEditingComplete: () => _focusNodeEmail.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: formFieldTextStyle,
                controller: _controllerEmail,
                focusNode: _focusNodeEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorStyle: errorTextStyle),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduzca su correo electrónico';
                  } else if (!(value.contains('@') && value.contains('.'))) {
                    return 'Correo electrónico no válido';
                  }
                  return null;
                },
                onEditingComplete: () => _focusNodeNombre.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: formFieldTextStyle,
                controller: _controllerName,
                focusNode: _focusNodeNombre,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorStyle: errorTextStyle),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduzca su nombre completo';
                  }
                  return null;
                },
                onEditingComplete: () => _focusNodePassword.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: formFieldTextStyle,
                controller: _controllerPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    labelText: 'Contraseña',
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
                    return 'Introduzca una contraseña';
                  } else if (value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
                onEditingComplete: () =>
                    _focusNodeConfirmPassword.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: formFieldTextStyle,
                controller: _controllerConFirmPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodeConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
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
                    return 'Introduzca su contraseña';
                  } else if (value != _controllerPassword.text) {
                    return 'La contraseña no coincide';
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
                          /*_encryptedPassword = EncryptPassword.encrypt(
                            _controllerConFirmPassword.text);*/

                          _boxPatients.put(_controllerDni.text, {
                            'dni': _controllerDni.text,
                            'password': _controllerConFirmPassword.text,
                            //'password': _encryptedPassword,
                            'email': _controllerEmail.text,
                            'name': _controllerName.text,
                            'doctor': '0',
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
                              content: const Center(
                                child: Text('Registrado correctamente'),
                              ),
                            ),
                          );

                          _formKey.currentState?.reset();

                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      child: const Text('REGISTRARSE', style: buttonTextStyle),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Ya tiene cuenta?'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Iniciar sesión'),
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
    _focusNodeEmail.dispose();
    _focusNodeNombre.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    _controllerDni.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerName.dispose();
    _controllerConFirmPassword.dispose();
    super.dispose();
  }
}
