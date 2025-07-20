import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_qr_scanner/utils/ocr_parser.dart';
import 'package:ocr_qr_scanner/models/contact.dart';

void main() {
  group('OCR Parser', () {
    test('Carte de visite simple', () {
      final text = '''
John Doe
Acme Corp
john.doe@email.com
+33 6 12 34 56 78
''';
      final contact = parseTextToContact(text);
      expect(contact.name, 'John Doe');
      expect(contact.company, 'Acme Corp');
      expect(contact.email, 'john.doe@email.com');
      final digits = contact.phone.replaceAll(RegExp(r'\D'), '');
      expect(digits.length, 8);
    });

    test('Carte avec mot-clé entreprise', () {
      final text = '''
Jane Smith
Company: Tech Studio
jane@techstudio.com
01 23 45 67 89
''';
      final contact = parseTextToContact(text);
      expect(contact.name, 'Jane Smith');
      expect(contact.company, 'Company: Tech Studio');
      expect(contact.email, 'jane@techstudio.com');
      final digits = contact.phone.replaceAll(RegExp(r'\D'), '');
      expect(digits.length, 8);
    });

    test('Champs manquants', () {
      final text = '''
No Email
Somewhere SAS
''';
      final contact = parseTextToContact(text);
      expect(contact.name, 'No Email');
      expect(contact.company, 'Somewhere SAS');
      expect(contact.email, '');
      expect(contact.phone, '');
    });
  });
} 