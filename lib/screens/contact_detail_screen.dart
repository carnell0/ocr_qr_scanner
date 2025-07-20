import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/contact.dart';
import 'add_contact_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;
  final int contactKey;
  const ContactDetailScreen({super.key, required this.contact, required this.contactKey});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du contact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer le contact'),
                  content: const Text('Voulez-vous vraiment supprimer ce contact ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final box = Hive.box<Contact>('contacts');
                await box.delete(contactKey);
                if (context.mounted) Navigator.pop(context);
              }
            },
            color: color,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      child: Icon(Icons.person, size: 40, color: color),
                      backgroundColor: color.withOpacity(0.1),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(
                        contact.name.isNotEmpty ? contact.name : 'Nom inconnu',
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (contact.phone.isNotEmpty)
                  _InfoRow(icon: Icons.phone, label: contact.phone),
                if (contact.email.isNotEmpty)
                  _InfoRow(icon: Icons.email, label: contact.email),
                if (contact.company.isNotEmpty)
                  _InfoRow(icon: Icons.business, label: contact.company),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit, color: color),
                    label: Text('Modifier', style: TextStyle(color: color)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: color, width: 2),
                      ),
                    ),
                    onPressed: () async {
                      final updated = await Navigator.push<Contact>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddContactScreen(
                            prefilled: contact,
                            contactKey: contactKey,
                          ),
                        ),
                      );
                      if (updated != null) {
                        final box = Hive.box<Contact>('contacts');
                        await box.put(contactKey, updated);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
