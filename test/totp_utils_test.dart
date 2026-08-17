import 'package:flutter_test/flutter_test.dart';
import 'package:authenticator_app/core/utils/totp_utils.dart';

void main() {
  group('TotpUtils', () {
    test('generateTotp should return 6-digit code', () {
      const secret = 'JBSWY3DPEHPK3PXP';
      final result = TotpUtils.generateTotp(secret);
      expect(result.code.length, 6);
      expect(int.tryParse(result.code), isNotNull);
    });

    test('generateTotp should have remaining seconds within period', () {
      const secret = 'JBSWY3DPEHPK3PXP';
      final result = TotpUtils.generateTotp(secret);
      expect(result.remainingSeconds, greaterThan(0));
      expect(result.remainingSeconds, lessThanOrEqualTo(result.period));
    });

    test('parseOtpAuthUri should parse valid otpauth URI', () {
      const uri =
          'otpauth://totp/Google:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google&digits=6&period=30';
      final result = TotpUtils.parseOtpAuthUri(uri);
      expect(result, isNotNull);
      expect(result!.issuer, 'Google');
      expect(result.label, 'user@example.com');
      expect(result.secret, 'JBSWY3DPEHPK3PXP');
      expect(result.digits, 6);
      expect(result.period, 30);
    });

    test('parseOtpAuthUri should return null for invalid URI', () {
      const uri = 'https://example.com';
      final result = TotpUtils.parseOtpAuthUri(uri);
      expect(result, isNull);
    });

    test('formatCode should add space after 3 digits', () {
      expect(TotpUtils.formatCode('123456'), '123 456');
      expect(TotpUtils.formatCode('12345678'), '12345678');
    });
  });
}
