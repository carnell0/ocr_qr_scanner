import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/contact.dart';

class AddContactScreen extends StatefulWidget {
  final Contact? prefilled;
  const AddContactScreen({super.key, this.prefilled});


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
      await box.add(contact);

      Navigator.pop(context);
    }
  }

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
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
