import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_qr_scanner/utils/ocr_parser.dart';
import 'package:ocr_qr_scanner/models/contact.dart';

void main() {
  group('OCR Parser', () {
    test('Parse simple business card', () {
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
      expect(contact.phone, '+33612345678');
    });

    test('Parse with company keyword', () {
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
      expect(contact.phone, '0123456789');
    });

    test('Parse with missing fields', () {
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