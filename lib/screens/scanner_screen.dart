import 'package:flutter/material.dart';
import 'add_contact_screen.dart';
import 'scan_card_screen.dart';
import 'scan_qr_import_screen.dart.dart';
import '../utils/ocr_parser.dart';
import '../models/contact.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner & Ajouter'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Scanner carte de visite (OCR)',
              color: color,
              onTap: () async {
                final contact = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanCardScreen()),
                );
                if (contact != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddContactScreen(prefilled: contact),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            _ActionButton(
              icon: Icons.qr_code,
              label: 'Importer contact via QR',
              color: color,
              onTap: () async {
                final contact = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanQrImportScreen()),
                );
                if (contact != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddContactScreen(prefilled: contact),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            _ActionButton(
              icon: Icons.add,
              label: 'Ajouter un contact manuellement',
              color: color,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddContactScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 32, color: color),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 18, color: color),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: color, width: 2),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
} 