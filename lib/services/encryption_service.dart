import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  // CORRECT KEY: 32 characters for AES-256
  final String _keyString = 'AbCdEfGhIjKlMnOpQrStUvWxYz123456'; // 32 chars
  
  String encryptData(String data) {
    try {
      final key = Key.fromUtf8(_keyString);
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key));
      
      final encrypted = encrypter.encrypt(data, iv: iv);
      return encrypted.base64;
    } catch (e) {
      print('❌ Encryption error: $e');
      return data;
    }
  }
  
  String decryptData(String encryptedBase64) {
    try {
      final key = Key.fromUtf8(_keyString);
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key));
      
      final encrypted = Encrypted.fromBase64(encryptedBase64);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('❌ Decryption error: $e');
      return encryptedBase64;
    }
  }
  
  String hashData(String data) {
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  String generateAadhaarHash(Map<String, dynamic> data) {
    String combined = '${data['aadhaarNumber']}-${data['name']}-${data['dob']}';
    return hashData(combined);
  }
  
  String maskAadhaarNumber(String aadhaarNumber) {
    if (aadhaarNumber.length < 12) return aadhaarNumber;
    return 'XXXX XXXX ${aadhaarNumber.substring(8)}';
  }
}