import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:ocr_qr_scanner/models/contact.dart';

void main() {
  group('Contact duplicate detection', () {
    setUp(() async {
      await setUpTestHive();
      Hive.registerAdapter(ContactAdapter());
      await Hive.openBox<Contact>('contacts');
    });
    tearDown(() async {
      await tearDownTestHive();
    });

    test('Detect duplicate by email', () async {
      final box = Hive.box<Contact>('contacts');
      final c1 = Contact(name: 'A', phone: '123', email: 'a@mail.com', company: 'X');
      await box.add(c1);
      final duplicate = box.values.any((c) => c.email == 'a@mail.com');
      expect(duplicate, true);
    });

    test('Detect duplicate by phone', () async {
      final box = Hive.box<Contact>('contacts');
      final c1 = Contact(name: 'A', phone: '123', email: 'a@mail.com', company: 'X');
      await box.add(c1);
      final duplicate = box.values.any((c) => c.phone == '123');
      expect(duplicate, true);
    });

    test('No duplicate if different', () async {
      final box = Hive.box<Contact>('contacts');
      final c1 = Contact(name: 'A', phone: '123', email: 'a@mail.com', company: 'X');
      await box.add(c1);
      final duplicate = box.values.any((c) => c.email == 'b@mail.com' && c.phone == '456');
      expect(duplicate, false);
    });
  });
} 