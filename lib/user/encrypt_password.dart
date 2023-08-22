/*import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptPassword {
  static Uint8List _randomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (index) => random.nextInt(256));
    return Uint8List.fromList(bytes);
  }

  static String? encrypt(String? password) {
    if (password == null || password.isEmpty) {
      return null;
    }
    final key = Key(_randomKey());
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encryptedPassword = encrypter.encrypt(password, iv: iv);
    return encryptedPassword.base64;
  }
}
*/
import 'dart:convert';
import 'package:crypto/crypto.dart';

String encryptPassword(String password) {
  final bytes = utf8.encode(password); // Convertir contraseña a bytes
  final digest = sha256.convert(bytes); // Encriptar bytes usando SHA-256
  return digest.toString(); // Retornar la contraseña encriptada
}
