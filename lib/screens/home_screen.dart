import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ocr_qr_scanner/screens/add_contact_screen.dart';
import 'package:ocr_qr_scanner/screens/contact_qr_screen.dart';
import 'package:ocr_qr_scanner/screens/scan_card_screen.dart';
import 'package:ocr_qr_scanner/screens/scan_qr_import_screen.dart.dart';
import 'package:ocr_qr_scanner/utils/ocr_parser.dart';
import 'package:ocr_qr_scanner/models/contact.dart';
import 'package:ocr_qr_scanner/screens/contact_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Contact> contactBox = Hive.box<Contact>('contacts');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Save'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: contactBox.listenable(),
        builder: (context, Box<Contact> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No contacts yet.'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final contact = box.getAt(index);

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(contact?.name ?? ''),
                subtitle: Text(contact?.email ?? ''),
                onTap: () {
                  if (contact != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContactDetailScreen(
                          contact: contact,
                          contactKey: box.keyAt(index) as int,
                        ),
                      ),
                    );
                  }
                },
                trailing: IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContactQRScreen(contact: contact!),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
