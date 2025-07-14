import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:ocr_qr_scanner/models/contact.dart';

void main() {
  group('Contact CRUD', () {
    setUp(() async {
      await setUpTestHive();
      Hive.registerAdapter(ContactAdapter());
      await Hive.openBox<Contact>('contacts');
    });
    tearDown(() async {
      await tearDownTestHive();
    });

    test('Add, update, and delete contact', () async {
      final box = Hive.box<Contact>('contacts');
      final c1 = Contact(name: 'A', phone: '123', email: 'a@mail.com', company: 'X');
      final key = await box.add(c1);
      expect(box.length, 1);
      // Update
      final updated = Contact(name: 'A2', phone: '123', email: 'a@mail.com', company: 'Y');
      await box.put(key, updated);
      final c2 = box.get(key);
      expect(c2?.name, 'A2');
      expect(c2?.company, 'Y');
      // Delete
      await box.delete(key);
      expect(box.length, 0);
    });
  });
} 