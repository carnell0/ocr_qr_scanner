import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/contact.dart';

class AddContactScreen extends StatefulWidget {
  final Contact? prefilled;
  final int? contactKey; // Ajout de la clé pour l'édition
  const AddContactScreen({super.key, this.prefilled, this.contactKey});


  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final contact = Contact(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        company: _companyController.text,
      );

      final box = Hive.box<Contact>('contacts');
      // Vérification des doublons (email ou numéro), ignorer le contact en cours d'édition
      final duplicate = box.values.toList().asMap().entries.any((entry) {
        final idx = entry.key;
        final c = entry.value;
        if (widget.contactKey != null && box.keyAt(idx) == widget.contactKey) return false;
        return (c.email.isNotEmpty && c.email == contact.email) ||
               (c.phone.isNotEmpty && c.phone == contact.phone);
      });
      if (duplicate) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Doublon détecté'),
            content: const Text('Un contact avec le même email ou numéro existe déjà. Voulez-vous l’ajouter quand même ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ajouter'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
      if (widget.contactKey != null) {
        await box.put(widget.contactKey, contact);
      } else {
        await box.add(contact);
      }
      Navigator.pop(context, contact);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.prefilled != null) {
      _nameController.text = widget.prefilled!.name;
      _phoneController.text = widget.prefilled!.phone;
      _emailController.text = widget.prefilled!.email;
      _companyController.text = widget.prefilled!.company;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
