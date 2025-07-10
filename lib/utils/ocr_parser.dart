import '../models/contact.dart';

Contact parseTextToContact(String rawText) {
  final lines = rawText.split('\n').map((l) => l.trim()).toList();

  String name = '';
  String email = '';
  String phone = '';
  String company = '';

  final emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
  final phoneRegex = RegExp(r'(\+?\d[\d\s.-]{6,})'); // Simple international match

  for (final line in lines) {
    if (email.isEmpty && emailRegex.hasMatch(line)) {
      email = emailRegex.firstMatch(line)!.group(0)!;
    } else if (phone.isEmpty && phoneRegex.hasMatch(line)) {
      phone = phoneRegex.firstMatch(line)!.group(0)!.replaceAll(RegExp(r'\D'), '');
    } else if (name.isEmpty && RegExp(r'^[A-Z][a-z]+(\s[A-Z][a-z]+)+$').hasMatch(line)) {
      name = line;
    } else if (company.isEmpty && line.toLowerCase().contains('company')) {
      company = line;
    }
  }

  return Contact(
    name: name,
    phone: phone,
    email: email,
    company: company,
  );
}
