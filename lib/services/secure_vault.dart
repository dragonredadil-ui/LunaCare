import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypts the complete health-data payload with AES-256-GCM.
/// The AES key is stored in the platform secure-storage facility.
class SecureVault {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'lunacare_aes_key_v1';
  static const _payloadName = 'lunacare_encrypted_payload_v1';
  static final _aes = AesGcm.with256bits();

  Future<SecretKey> _getKey() async {
    var encoded = await _storage.read(key: _keyName);
    if (encoded == null) {
      final key = await _aes.newSecretKey();
      final bytes = await key.extractBytes();
      encoded = base64Encode(bytes);
      await _storage.write(key: _keyName, value: encoded);
      return key;
    }
    return SecretKey(base64Decode(encoded));
  }

  Future<void> saveJson(Map<String, dynamic> data) async {
    final key = await _getKey();
    final clear = utf8.encode(jsonEncode(data));
    final box = await _aes.encrypt(clear, secretKey: key);
    final packed = <int>[
      ...box.nonce,
      ...box.mac.bytes,
      ...box.cipherText,
    ];
    await _storage.write(key: _payloadName, value: base64Encode(packed));
  }

  Future<Map<String, dynamic>> readJson() async {
    final encoded = await _storage.read(key: _payloadName);
    if (encoded == null) return {};
    final packed = base64Decode(encoded);
    // AES-GCM nonce is 12 bytes; authentication tag is 16 bytes.
    if (packed.length < 28) throw const FormatException('Invalid encrypted payload');
    final box = SecretBox(
      packed.sublist(28),
      nonce: packed.sublist(0, 12),
      mac: Mac(packed.sublist(12, 28)),
    );
    final clear = await _aes.decrypt(box, secretKey: await _getKey());
    return Map<String, dynamic>.from(jsonDecode(utf8.decode(clear)) as Map);
  }

  Future<void> deleteAll() async {
    await _storage.delete(key: _payloadName);
    await _storage.delete(key: _keyName);
  }
}
