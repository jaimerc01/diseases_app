import 'package:bcrypt/bcrypt.dart';

String encryptPassword(String password) {
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

bool verifyPassword(String password, String hashed) {
  return BCrypt.checkpw(password, hashed);
}
