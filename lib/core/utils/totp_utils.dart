import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';

class TotpResult {
  final String code;
  final int remainingSeconds;
  final int period;

  TotpResult({
    required this.code,
    required this.remainingSeconds,
    required this.period,
  });
}

class TotpUtils {
  static const int _period = 30;
  static const int _digits = 6;
  static const String _algorithm = 'SHA1';

  static String _cleanSecret(String secret) {
    return secret.replaceAll(' ', '').replaceAll('-', '').toUpperCase();
  }

  static Uint8List _decodeBase32(String secret) {
    final cleaned = _cleanSecret(secret);
    return base32.decode(cleaned);
  }

  static int _getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  static List<int> _intToBytes(int value) {
    final bytes = List<int>.filled(8, 0);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = value & 0xFF;
      value = value >> 8;
    }
    return bytes;
  }

  static String _generateHOTP(
    Uint8List key,
    int counter, {
    int digits = _digits,
  }) {
    final counterBytes = Uint8List.fromList(_intToBytes(counter));
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(counterBytes);
    final hash = digest.bytes;

    final offset = hash[hash.length - 1] & 0x0F;
    final binary = ((hash[offset] & 0x7F) << 24) |
        ((hash[offset + 1] & 0xFF) << 16) |
        ((hash[offset + 2] & 0xFF) << 8) |
        (hash[offset + 3] & 0xFF);

    final otp = binary % pow(10, digits);
    return otp.toString().padLeft(digits, '0');
  }

  static int pow(int base, int exponent) {
    int result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  static TotpResult generateTotp(String secret,
      {int period = _period, int digits = _digits}) {
    final key = _decodeBase32(secret);
    final timestamp = _getCurrentTimestamp();
    final counter = timestamp ~/ period;
    final remaining = period - (timestamp % period);

    final code = _generateHOTP(key, counter, digits: digits);
    return TotpResult(
      code: code,
      remainingSeconds: remaining,
      period: period,
    );
  }

  static String formatCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3)}';
    }
    return code;
  }

  static OtpAuthData? parseOtpAuthUri(String uri) {
    if (!uri.startsWith('otpauth://')) return null;

    final uriObj = Uri.parse(uri);
    final type = uriObj.host;
    final path = uriObj.path.substring(1);
    final parts = path.split(':');
    final issuer = parts.length > 1 ? parts[0].trim() : (uriObj.queryParameters['issuer'] ?? '');
    final label = parts.length > 1 ? parts[1].trim() : parts[0].trim();
    final secret = uriObj.queryParameters['secret'] ?? '';
    final algorithm = uriObj.queryParameters['algorithm'] ?? _algorithm;
    final digits = int.tryParse(uriObj.queryParameters['digits'] ?? '$_digits') ?? _digits;
    final period = int.tryParse(uriObj.queryParameters['period'] ?? '$_period') ?? _period;

    if (secret.isEmpty) return null;

    return OtpAuthData(
      type: type,
      issuer: issuer,
      label: label,
      secret: secret,
      algorithm: algorithm,
      digits: digits,
      period: period,
    );
  }
}

class OtpAuthData {
  final String type;
  final String issuer;
  final String label;
  final String secret;
  final String algorithm;
  final int digits;
  final int period;

  OtpAuthData({
    required this.type,
    required this.issuer,
    required this.label,
    required this.secret,
    required this.algorithm,
    required this.digits,
    required this.period,
  });
}
