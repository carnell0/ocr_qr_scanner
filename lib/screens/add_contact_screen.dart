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
    final isEditing = widget.contactKey != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le contact' : 'Ajouter un contact'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar section
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  hintText: 'Entrez le nom complet',
                  prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                validator: (value) => value!.isEmpty ? 'Le nom est requis' : null,
              ),
              const SizedBox(height: 16),
              
              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  hintText: 'Entrez le numéro de téléphone',
                  prefixIcon: Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Entrez l\'adresse email',
                  prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Company field
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  labelText: 'Entreprise',
                  hintText: 'Entrez le nom de l\'entreprise',
                  prefixIcon: Icon(Icons.business, color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 32),
              
              // Save button
              ElevatedButton.icon(
                onPressed: _saveContact,
                icon: Icon(Icons.save),
                label: Text(isEditing ? 'Modifier' : 'Enregistrer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
