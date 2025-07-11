import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/contact.dart';

class ContactQRScreen extends StatelessWidget {
  final Contact contact;

  const ContactQRScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code du contact')),
      body: Center(
        child: QrImageView(
          data: contact.toJsonString(),
          version: QrVersions.auto,
          size: 250.0,
        ),
      ),
    );
  }
}
