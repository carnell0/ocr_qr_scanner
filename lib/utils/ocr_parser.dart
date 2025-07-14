import '../models/contact.dart';

Contact parseTextToContact(String rawText) {
  final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  String name = '';
  String email = '';
  String phone = '';
  String company = '';

  // Regex plus robustes
  final emailRegex = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
  final phoneRegex = RegExp(r'(\+\d{1,3}[\s.-]?)?(\(?\d{2,4}\)?[\s.-]?)?\d{2,4}[\s.-]?\d{2,4}[\s.-]?\d{2,4}');
  final companyKeywords = ['company', 'sarl', 'sas', 'inc', 'ltd', 'corp', 'entreprise', 'agence', 'group', 'studio'];

  // Recherche email et téléphone sur toutes les lignes
  for (final line in lines) {
    if (email.isEmpty && emailRegex.hasMatch(line)) {
      email = emailRegex.firstMatch(line)!.group(0)!;
    }
    if (phone.isEmpty && phoneRegex.hasMatch(line)) {
      // Nettoie le numéro pour ne garder que les chiffres et +
      final raw = phoneRegex.firstMatch(line)!.group(0)!;
      phone = raw.replaceAll(RegExp(r'[^\d+]'), '');
    }
  }

  // Recherche du nom :
  // 1. Ligne sans chiffre, ni @, ni mot-clé d'entreprise, ni trop courte
  for (final line in lines) {
    if (name.isEmpty &&
        line.length > 2 &&
        !line.contains(RegExp(r'[\d@]')) &&
        !companyKeywords.any((kw) => line.toLowerCase().contains(kw)) &&
        line.split(' ').length <= 4) {
      name = line;
      break;
    }
  }

  // Recherche de l'entreprise
  for (final line in lines) {
    if (company.isEmpty && companyKeywords.any((kw) => line.toLowerCase().contains(kw))) {
      company = line;
      break;
    }
  }

  // Si pas d'entreprise trouvée, prendre la dernière ligne longue
  if (company.isEmpty && lines.length > 1) {
    final candidates = lines.where((l) => l.length > 4 && l != name && l != email && l != phone).toList();
    if (candidates.isNotEmpty) {
      company = candidates.last;
    }
  }

  return Contact(
    name: name,
    phone: phone,
    email: email,
    company: company,
  );
}
