import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/contact.dart';
import 'dart:convert';

class ContactQRScreen extends StatelessWidget {
  final Contact contact;

  const ContactQRScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final contactJson = jsonEncode({
      'name': contact.name,
      'phone': contact.phone,
      'email': contact.email,
      'company': contact.company,
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Contact QR Code')),
      body: Center(
        child: QrImageView(
          data: contactJson,
          version: QrVersions.auto,
          size: 250.0,
        ),
      ),
    );
  }
}
